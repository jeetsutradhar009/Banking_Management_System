package com.bank.util;

import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.gmail.Gmail;
import com.google.api.services.gmail.model.Message;

import jakarta.mail.Session;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.Properties;

/**
 * EmailService
 *
 * Sends all customer-facing transactional email (OTP verification,
 * password reset, new-account details, online-banking-activated) via
 * the Gmail API, authenticated with OAuth2 using a long-lived refresh
 * token - NOT SMTP, and NOT a username/password.
 *
 * ------------------------------------------------------------------
 * WHY GMAIL API INSTEAD OF SMTP
 * ------------------------------------------------------------------
 * The previous implementation authenticated to smtp.gmail.com with a
 * Gmail "App Password" read from SMTP_USERNAME/SMTP_PASSWORD (or a
 * checked-in email.properties file as a local fallback). App
 * Passwords are long-lived static secrets with full mailbox access
 * scope; if leaked (e.g. committed to source control), they must be
 * manually revoked and are otherwise valid forever.
 *
 * This implementation instead uses a Google OAuth2 "refresh token"
 * scoped ONLY to https://www.googleapis.com/auth/gmail.send (send-only,
 * no read/delete/mailbox access), obtained once via Google's OAuth
 * consent flow outside of this application. The refresh token is
 * exchanged for a short-lived access token on every send, and the
 * access token is never persisted anywhere - it lives in memory only
 * for the duration of a single Gmail API call.
 *
 * ------------------------------------------------------------------
 * CONFIGURATION - environment variables ONLY, no properties-file
 * fallback (unlike the old SMTP config, deliberately - a credential
 * fallback file is exactly how the previous SMTP password ended up
 * committed to the repository):
 * ------------------------------------------------------------------
 *   GMAIL_CLIENT_ID      - OAuth2 client ID (from Google Cloud Console)
 *   GMAIL_CLIENT_SECRET  - OAuth2 client secret
 *   GMAIL_REFRESH_TOKEN  - long-lived refresh token, gmail.send scope
 *   GMAIL_SENDER_EMAIL   - the mailbox these credentials belong to;
 *                          used both as the Gmail API user ID ("me"
 *                          maps to this account) and as the From:
 *                          address on every message.
 *
 * Optional:
 *   GMAIL_SENDER_NAME    - display name for the From: header
 *                          (defaults to "DKS Bank" if unset, same
 *                          default the old SMTP_FROM_NAME had).
 *
 * None of these four required values have a hardcoded fallback. If
 * any are missing, every send method returns a clear EmailResult
 * failure instead of throwing - identical behavior to the previous
 * implementation's "Email service is not configured" path.
 *
 * ------------------------------------------------------------------
 * SECURITY NOTES
 * ------------------------------------------------------------------
 * - GMAIL_CLIENT_SECRET and GMAIL_REFRESH_TOKEN are never logged, in
 *   full or in part, anywhere in this class - only generic exception
 *   messages/types are logged (see logError()). The Gmail API client
 *   library itself does not include the refresh token or client
 *   secret in its own exception messages (it wraps error responses
 *   from Google's token endpoint, e.g. "invalid_grant", not the
 *   request body that was sent).
 * - The access token obtained per-send is held only in the
 *   short-lived GoogleCredential instance in memory; it is never
 *   written to disk, session, or log.
 * - Public method signatures are UNCHANGED from the SMTP version, so
 *   no calling servlet needs to change.
 */
public class EmailService {

    private static final String APPLICATION_NAME = "DKS Bank Online Banking";
    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();

    // Used only by the 3-argument sendPasswordResetEmail() overload,
    // for callers that don't pass an explicit validity window. Must
    // be kept in sync with ForgotPasswordServlet's own default
    // (resolveTokenValidityMinutes()'s fallback) if that ever changes,
    // since this constant has no way to read that servlet's env-var
    // configuration. Callers that care about staying in sync should
    // use the 4-argument overload instead - see class Javadoc.
    private static final int DEFAULT_PASSWORD_RESET_VALIDITY_MINUTES = 2;

    private final String clientId;
    private final String clientSecret;
    private final String refreshToken;
    private final String fromEmail;
    private final String fromName;

    // Built lazily on first send, then reused for the lifetime of this
    // EmailService instance. GoogleCredential auto-refreshes its
    // access token on each API call as needed, so this is safe to
    // reuse across multiple sends from the same instance.
    private volatile Gmail gmailService;

    public EmailService() {
        this.clientId = env("GMAIL_CLIENT_ID");
        this.clientSecret = env("GMAIL_CLIENT_SECRET");
        this.refreshToken = env("GMAIL_REFRESH_TOKEN");
        this.fromEmail = env("GMAIL_SENDER_EMAIL");

        String senderName = env("GMAIL_SENDER_NAME");
        this.fromName = isBlank(senderName) ? "DKS Bank" : senderName;
    }

    // ==================================================================
    // Public API - UNCHANGED signatures from the SMTP implementation
    // ==================================================================

    public EmailResult sendOtpEmail(String toEmail, String fullName, String otpCode, int validityMinutes) {
        return buildAndSend(
                toEmail,
                "DKS Bank - Your Account Opening OTP",
                buildOtpEmailBody(otpCode, validityMinutes),
                true,
                "Unable to send OTP email. Please try again in a moment."
        );
    }

    /**
     * @deprecated Kept for backward compatibility with callers that
     * do not pass an explicit validity window. Delegates to the
     * overload below using DEFAULT_PASSWORD_RESET_VALIDITY_MINUTES.
     * New/updated callers should use the 4-argument overload and pass
     * their actual configured token validity, so the emailed text
     * always matches the real DB-enforced expiry.
     */
    public EmailResult sendPasswordResetEmail(String toEmail, String fullName, String resetLink) {
        return sendPasswordResetEmail(toEmail, fullName, resetLink, DEFAULT_PASSWORD_RESET_VALIDITY_MINUTES);
    }

    /**
     * Same as the 3-argument overload, but the displayed expiry
     * window is passed in explicitly rather than hardcoded in the
     * template - callers should pass whatever value they actually
     * used to compute the token's expiry timestamp, so the email text
     * can never drift out of sync with the real expiry.
     */
    public EmailResult sendPasswordResetEmail(String toEmail, String fullName, String resetLink, int validityMinutes) {
        return buildAndSend(
                toEmail,
                "DKS Bank - Password Reset Request",
                buildPasswordResetEmailBody(fullName, resetLink, validityMinutes),
                true,
                "Unable to send password reset email. Please try again in a moment."
        );
    }

    /**
     * Sends the new-account details email for accounts created by an
     * admin (CreateAccountServlet) or via the customer self-service
     * UPI-payment-simulation flow (ProcessUpiPaymentServlet). No login
     * password or any other credential is ever included in this
     * email - the customer is pointed to "/register" instead.
     *
     * @return EmailResult indicating success/failure - callers MUST check this
     */
    public EmailResult sendAccountDetailsEmail(String toEmail,
                                                String fullName,
                                                String customerId,
                                                String accountNumber,
                                                String ifscCode,
                                                String registrationUrl) {
        return buildAndSend(
                toEmail,
                "DKS Bank - Your New Account Details",
                buildAccountDetailsEmailHtml(fullName, customerId, accountNumber, ifscCode, registrationUrl),
                true,
                "Unable to send account details email. Please try again in a moment."
        );
    }

    /**
     * Sends the "Online Banking Activated" email, including the
     * auto-generated temporary password, when an admin activates
     * online banking for an existing customer (AddUserServlet).
     *
     * @return EmailResult indicating success/failure - callers MUST check this
     */
    public EmailResult sendOnlineBankingActivatedEmail(String toEmail,
                                                        String fullName,
                                                        String customerId,
                                                        String temporaryPassword,
                                                        String loginUrl) {
        return buildAndSend(
                toEmail,
                "DKS Bank - Online Banking Activated",
                buildOnlineBankingActivatedEmailHtml(fullName, customerId, temporaryPassword, loginUrl),
                true,
                "Unable to send activation email. Please try again in a moment."
        );
    }

    // ==================================================================
    // Shared send pipeline
    // ==================================================================

    /**
     * Builds a MimeMessage (plain text or HTML), then hands it to the
     * Gmail API. Centralizes the config check + exception handling
     * that used to be duplicated in every public method.
     */
    private EmailResult buildAndSend(String toEmail,
                                      String subject,
                                      String body,
                                      boolean isHtml,
                                      String failureMessage) {

        if (isBlank(clientId) || isBlank(clientSecret) || isBlank(refreshToken) || isBlank(fromEmail)) {
            return EmailResult.failure(
                    "Email service is not configured. Please set GMAIL_CLIENT_ID, GMAIL_CLIENT_SECRET, "
                    + "GMAIL_REFRESH_TOKEN and GMAIL_SENDER_EMAIL as environment variables.");
        }

        if (isBlank(toEmail)) {
            return EmailResult.failure(failureMessage);
        }

        try {
            MimeMessage mimeMessage = buildMimeMessage(toEmail, subject, body, isHtml);
            Gmail gmail = getGmailService();

            Message message = new Message();
            message.setRaw(encodeToBase64Url(mimeMessage));

            // "me" is a Gmail API convention meaning "the authenticated
            // user" - resolved from the OAuth2 credential, i.e.
            // GMAIL_SENDER_EMAIL's mailbox.
            gmail.users().messages().send("me", message).execute();

            return EmailResult.success();

        } catch (Exception e) {
            // Deliberately logs only the exception's class/message,
            // never clientSecret/refreshToken, which are never part
            // of this call chain's local variables at the point of
            // failure logging.
            logError(failureMessage, e);
            return EmailResult.failure(failureMessage);
        }
    }

    private MimeMessage buildMimeMessage(String toEmail, String subject, String body, boolean isHtml)
            throws Exception {

        // A blank Session is sufficient here - it is only used by
        // MimeMessage to build well-formed MIME headers/encoding. No
        // SMTP host/auth properties are needed since Gmail API (not
        // this Session) is the transport.
        Session session = Session.getDefaultInstance(new Properties());

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(fromEmail, fromName));
        message.setRecipients(jakarta.mail.Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);

        if (isHtml) {
            message.setContent(body, "text/html; charset=UTF-8");
        } else {
            message.setText(body);
        }

        return message;
    }

    private String encodeToBase64Url(MimeMessage mimeMessage) throws Exception {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        mimeMessage.writeTo(buffer);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(buffer.toByteArray());
    }

    /**
     * Lazily builds (and caches on this instance) the authenticated
     * Gmail API client. GoogleCredential is given the OAuth2 client
     * ID/secret and refresh token once here; it transparently
     * exchanges the refresh token for a fresh short-lived access
     * token on every API call made through this Gmail client, so no
     * manual token refresh/expiry handling is needed anywhere else in
     * this class.
     */
    private Gmail getGmailService() throws Exception {
        Gmail service = gmailService;

        if (service == null) {
            synchronized (this) {
                service = gmailService;
                if (service == null) {
                    HttpTransport httpTransport = GoogleNetHttpTransport.newTrustedTransport();

                    GoogleCredential credential = new GoogleCredential.Builder()
                            .setTransport(httpTransport)
                            .setJsonFactory(JSON_FACTORY)
                            .setClientSecrets(clientId, clientSecret)
                            .build()
                            .setRefreshToken(refreshToken);

                    service = new Gmail.Builder(httpTransport, JSON_FACTORY, credential)
                            .setApplicationName(APPLICATION_NAME)
                            .build();

                    gmailService = service;
                }
            }
        }

        return service;
    }

    // ==================================================================
    // Email body builders
    //
    // OTP and password-reset templates below are HTML (updated in this
    // change). Account-details and online-banking-activated templates
    // were already HTML from the Gmail API migration and are UNCHANGED
    // here.
    // ==================================================================

    /**
     * OTP email for account-opening email verification. Always
     * addressed to "Dear User," rather than a name - at this point in
     * the flow (SendEmailVerificationServlet / ResendEmailOtpServlet)
     * no user record exists yet, so the only value callers have to
     * pass as a "name" is the email address itself. Rather than ever
     * risk displaying an email address as if it were a name, this
     * template intentionally ignores whatever is passed for that
     * field and always uses the generic greeting. Validity minutes
     * remains a parameter (not hardcoded) so the displayed text always
     * matches whatever expiry the caller actually set in the database.
     */
    private String buildOtpEmailBody(String otpCode, int validityMinutes) {
        String otp = escapeHtml(otpCode);
        String minuteWord = (validityMinutes == 1) ? "minute" : "minutes";

        return "<!DOCTYPE html>"
                + "<html><head><meta charset=\"UTF-8\"></head>"
                + "<body style=\"margin:0;padding:0;background:#f2f6f4;font-family:'Segoe UI',Arial,sans-serif;\">"
                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:#f2f6f4;padding:32px 0;\">"
                + "<tr><td align=\"center\">"
                + "<table role=\"presentation\" width=\"480\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 8px 24px rgba(15,23,42,0.08);\">"

                + "<tr><td style=\"background:#0f8a4c;padding:24px 32px;text-align:center;\">"
                + "<span style=\"color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.5px;\">DKS Bank</span>"
                + "</td></tr>"

                + "<tr><td style=\"padding:32px;\">"
                + "<p style=\"margin:0 0 16px;color:#0d3b2e;font-size:16px;\">Dear User,</p>"
                + "<p style=\"margin:0 0 20px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "Thank you for opening an account with DKS Bank. Your One-Time Password (OTP) for "
                + "account opening verification is:"
                + "</p>"

                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"margin:0 0 20px;\">"
                + "<tr><td align=\"center\" style=\"background:#f3f8f5;border:1px solid #dcece3;border-radius:12px;padding:20px;\">"
                + "<span style=\"display:inline-block;color:#0f8a4c;font-size:32px;font-weight:800;letter-spacing:8px;\">"
                + otp + "</span>"
                + "</td></tr></table>"

                + "<p style=\"margin:0 0 8px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "This OTP is valid for <strong>" + validityMinutes + " " + minuteWord + "</strong>."
                + "</p>"
                + "<p style=\"margin:0;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "Do not share this OTP with anyone, including DKS Bank staff."
                + "</p>"

                + "<p style=\"margin:28px 0 0;color:#8a958f;font-size:12px;line-height:1.6;\">"
                + "If you did not request this, please ignore this email."
                + "</p>"
                + "</td></tr>"

                + "<tr><td style=\"background:#f3f8f5;padding:18px 32px;text-align:center;\">"
                + "<span style=\"color:#5a6b63;font-size:12px;\">&copy; DKS Bank. This is an automated message, please do not reply.</span>"
                + "</td></tr>"

                + "</table></td></tr></table>"
                + "</body></html>";
    }

    /**
     * Password reset email. fullName here already comes from the
     * database (ForgotPasswordServlet looks up the User row before
     * calling this), so - unlike the OTP template above - it is safe
     * and correct to display it. The reset link is rendered as a
     * styled button rather than a raw URL. validityMinutes is no
     * longer hardcoded - callers pass the actual window their token
     * was created with (see the 4-argument sendPasswordResetEmail()
     * overload), so this text can never drift out of sync with the
     * real DB-enforced expiry.
     */
    private String buildPasswordResetEmailBody(String fullName, String resetLink, int validityMinutes) {
        String name = escapeHtml(isBlank(fullName) ? "Customer" : fullName);
        String link = escapeHtml(resetLink);
        String minuteWord = (validityMinutes == 1) ? "minute" : "minutes";

        return "<!DOCTYPE html>"
                + "<html><head><meta charset=\"UTF-8\"></head>"
                + "<body style=\"margin:0;padding:0;background:#f2f6f4;font-family:'Segoe UI',Arial,sans-serif;\">"
                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:#f2f6f4;padding:32px 0;\">"
                + "<tr><td align=\"center\">"
                + "<table role=\"presentation\" width=\"480\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 8px 24px rgba(15,23,42,0.08);\">"

                + "<tr><td style=\"background:#0f8a4c;padding:24px 32px;text-align:center;\">"
                + "<span style=\"color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.5px;\">DKS Bank</span>"
                + "</td></tr>"

                + "<tr><td style=\"padding:32px;\">"
                + "<p style=\"margin:0 0 16px;color:#0d3b2e;font-size:16px;\">Dear <b>" + name + "</b>,</p>"
                + "<p style=\"margin:0 0 24px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "We received a request to reset your online banking password. Click the button below "
                + "to choose a new password:"
                + "</p>"

                + "<table role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" style=\"margin:0 auto 24px;\">"
                + "<tr><td style=\"border-radius:10px;background:#16a34a;\">"
                + "<a href=\"" + link + "\" "
                + "style=\"display:inline-block;padding:14px 32px;color:#ffffff;font-size:14px;font-weight:700;"
                + "text-decoration:none;border-radius:10px;\">Click Here To Reset Password</a>"
                + "</td></tr></table>"

                + "<p style=\"margin:0 0 8px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "This link will expire after <strong>" + validityMinutes + " " + minuteWord + "</strong> and can be used only once."
                + "</p>"

                + "<p style=\"margin:28px 0 0;color:#8a958f;font-size:12px;line-height:1.6;\">"
                + "If you did not request this, please ignore this email - your password will remain "
                + "unchanged and no further action is needed."
                + "</p>"
                + "</td></tr>"

                + "<tr><td style=\"background:#f3f8f5;padding:18px 32px;text-align:center;\">"
                + "<span style=\"color:#5a6b63;font-size:12px;\">&copy; DKS Bank. This is an automated message, please do not reply.</span>"
                + "</td></tr>"

                + "</table></td></tr></table>"
                + "</body></html>";
    }

    private String buildAccountDetailsEmailHtml(String fullName,
                                                 String customerId,
                                                 String accountNumber,
                                                 String ifscCode,
                                                 String registrationUrl) {
        String name = escapeHtml(isBlank(fullName) ? "Customer" : fullName);
        String custId = escapeHtml(customerId);
        String accNo = escapeHtml(accountNumber);
        String ifsc = escapeHtml(ifscCode);
        String regUrl = escapeHtml(registrationUrl);

        return "<!DOCTYPE html>"
                + "<html><head><meta charset=\"UTF-8\"></head>"
                + "<body style=\"margin:0;padding:0;background:#f2f6f4;font-family:'Segoe UI',Arial,sans-serif;\">"
                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:#f2f6f4;padding:32px 0;\">"
                + "<tr><td align=\"center\">"
                + "<table role=\"presentation\" width=\"480\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 8px 24px rgba(15,23,42,0.08);\">"

                + "<tr><td style=\"background:#0f8a4c;padding:24px 32px;text-align:center;\">"
                + "<span style=\"color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.5px;\">DKS Bank</span>"
                + "</td></tr>"

                + "<tr><td style=\"padding:32px;\">"
                + "<p style=\"margin:0 0 16px;color:#0d3b2e;font-size:16px;\">Dear <strong>" + name + "</strong>,</p>"
                + "<p style=\"margin:0 0 20px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "Your new bank account has been opened successfully with DKS Bank. Here are your account details:"
                + "</p>"

                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"background:#f3f8f5;border:1px solid #dcece3;border-radius:12px;\">"
                + detailRow("Customer Name", name, false)
                + detailRow("Customer ID", custId, true)
                + detailRow("Account Number", accNo, true)
                + detailRow("IFSC Code", ifsc, true)
                + "</table>"

                + "<p style=\"margin:24px 0 16px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "To use online banking services, please register using the button below."
                + "</p>"

                + "<table role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" style=\"margin:0 auto;\">"
                + "<tr><td style=\"border-radius:10px;background:#16a34a;\">"
                + "<a href=\"" + regUrl + "\" "
                + "style=\"display:inline-block;padding:14px 32px;color:#ffffff;font-size:14px;font-weight:700;"
                + "text-decoration:none;border-radius:10px;\">Register for Online Banking</a>"
                + "</td></tr></table>"

                + "<p style=\"margin:28px 0 0;color:#8a958f;font-size:12px;line-height:1.6;\">"
                + "For your security, DKS Bank will never ask for your password or OTP over email or phone. "
                + "If you did not request this account, please contact DKS Bank support immediately."
                + "</p>"
                + "</td></tr>"

                + "<tr><td style=\"background:#f3f8f5;padding:18px 32px;text-align:center;\">"
                + "<span style=\"color:#5a6b63;font-size:12px;\">&copy; DKS Bank. This is an automated message, please do not reply.</span>"
                + "</td></tr>"

                + "</table></td></tr></table>"
                + "</body></html>";
    }

    private String buildOnlineBankingActivatedEmailHtml(String fullName,
                                                          String customerId,
                                                          String temporaryPassword,
                                                          String loginUrl) {
        String name = escapeHtml(isBlank(fullName) ? "Customer" : fullName);
        String custId = escapeHtml(customerId);
        String tempPwd = escapeHtml(temporaryPassword);
        String loginLink = escapeHtml(loginUrl);

        return "<!DOCTYPE html>"
                + "<html><head><meta charset=\"UTF-8\"></head>"
                + "<body style=\"margin:0;padding:0;background:#f2f6f4;font-family:'Segoe UI',Arial,sans-serif;\">"
                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:#f2f6f4;padding:32px 0;\">"
                + "<tr><td align=\"center\">"
                + "<table role=\"presentation\" width=\"480\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 8px 24px rgba(15,23,42,0.08);\">"

                + "<tr><td style=\"background:#0f8a4c;padding:24px 32px;text-align:center;\">"
                + "<span style=\"color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.5px;\">DKS Bank</span>"
                + "</td></tr>"

                + "<tr><td style=\"padding:32px;\">"
                + "<p style=\"margin:0 0 16px;color:#0d3b2e;font-size:16px;\">Dear <strong>" + name + "</strong>,</p>"
                + "<p style=\"margin:0 0 20px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "Your online banking service has been activated by DKS Bank Admin. Here are your login details:"
                + "</p>"

                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"background:#f3f8f5;border:1px solid #dcece3;border-radius:12px;\">"
                + detailRow("Customer ID", custId, false)
                + detailRow("Temporary Password", tempPwd, true)
                + "</table>"

                + "<p style=\"margin:24px 0 16px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "Please login and change your password immediately."
                + "</p>"

                + "<table role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" style=\"margin:0 auto;\">"
                + "<tr><td style=\"border-radius:10px;background:#16a34a;\">"
                + "<a href=\"" + loginLink + "\" "
                + "style=\"display:inline-block;padding:14px 32px;color:#ffffff;font-size:14px;font-weight:700;"
                + "text-decoration:none;border-radius:10px;\">Login to Online Banking</a>"
                + "</td></tr></table>"

                + "<p style=\"margin:28px 0 0;color:#8a958f;font-size:12px;line-height:1.6;\">"
                + "For your security, DKS Bank will never ask for your password or OTP over email or phone. "
                + "If you did not request this activation, please contact DKS Bank support immediately."
                + "</p>"
                + "</td></tr>"

                + "<tr><td style=\"background:#f3f8f5;padding:18px 32px;text-align:center;\">"
                + "<span style=\"color:#5a6b63;font-size:12px;\">&copy; DKS Bank. This is an automated message, please do not reply.</span>"
                + "</td></tr>"

                + "</table></td></tr></table>"
                + "</body></html>";
    }

    private String detailRow(String label, String value, boolean withTopBorder) {
        String border = withTopBorder ? "border-top:1px solid #dcece3;" : "";

        return "<tr>"
                + "<td style=\"padding:12px 18px;color:#5a6b63;font-size:13px;" + border + "\">" + label + "</td>"
                + "<td style=\"padding:12px 18px;color:#0d3b2e;font-size:14px;font-weight:700;text-align:right;" + border + "\">"
                + value + "</td>"
                + "</tr>";
    }

    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    // ==================================================================
    // Config / logging helpers
    // ==================================================================

    /**
     * Environment variables ONLY - no properties-file fallback. This
     * is intentional: a local-file credential fallback is exactly how
     * the previous SMTP app password ended up committed to source
     * control. Every deployment (local, Render, CI) must set these
     * four variables explicitly.
     */
    private String env(String key) {
        String value = System.getenv(key);
        return (value == null) ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Logs only the exception's type and message (and, for Gmail API
     * errors, whatever Google's client library itself put in that
     * message - typically an HTTP status/reason, never request
     * credentials). clientId/clientSecret/refreshToken are local
     * fields on this class and are never interpolated into any log
     * statement, here or anywhere else in this file.
     */
    private void logError(String context, Exception e) {
        System.err.println("[EmailService] " + context + " - " + e.getClass().getSimpleName() + ": " + e.getMessage());
    }

    public static class EmailResult {

        private final boolean success;
        private final String message;

        private EmailResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static EmailResult success() {
            return new EmailResult(true, "Email sent successfully.");
        }

        public static EmailResult failure(String message) {
            return new EmailResult(false, message);
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }
    }
}