package com.bank.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Properties;

/**
 * Sends transactional emails via Brevo's HTTPS Transactional Email API
 * (https://api.brevo.com/v3/smtp/email) instead of raw SMTP.
 *
 * This class used to connect directly to an SMTP server (e.g.
 * smtp.gmail.com:587) using Jakarta Mail. That stopped working once the
 * app was deployed on Render's free tier, because Render blocks outbound
 * traffic to SMTP ports (25, 465, 587) on free web services - see
 * https://render.com/changelog/free-web-services-will-no-longer-allow-outbound-traffic-to-smtp-ports
 *
 * Brevo's API is a plain HTTPS POST on port 443, which free tiers do not
 * block, so this works from Render's free plan without any upgrade.
 * Brevo also does not require owning/verifying a custom domain - a single
 * verified sender email (e.g. an existing Gmail address) is enough to
 * send to ANY recipient, unlike some other providers' sandbox mode.
 */
public class EmailService {

    private static final String PROPERTIES_FILE = "email.properties";
    private static final String BREVO_API_URL = "https://api.brevo.com/v3/smtp/email";

    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    private final String brevoApiKey;
    private final String fromEmail;
    private final String fromName;

    public EmailService() {
        Properties fallback = loadFallbackProperties();

        this.brevoApiKey = resolve("BREVO_API_KEY", fallback);
        this.fromEmail = resolve("EMAIL_FROM_ADDRESS", fallback);
        this.fromName = resolve("EMAIL_FROM_NAME", fallback);
    }

    public EmailResult sendOtpEmail(String toEmail, String fullName, String otpCode, int validityMinutes) {

        if (isBlank(brevoApiKey) || isBlank(fromEmail)) {
            return EmailResult.failure(
                    "Email service is not configured. Please set BREVO_API_KEY and EMAIL_FROM_ADDRESS "
                    + "(environment variables or email.properties).");
        }

        return sendViaBrevo(toEmail, fullName,
                "DKS Bank - Your Account Opening OTP",
                buildOtpEmailBody(fullName, otpCode, validityMinutes),
                null,
                "Unable to send OTP email. Please try again in a moment.");
    }

    public EmailResult sendPasswordResetEmail(String toEmail, String fullName, String resetLink) {

        if (isBlank(brevoApiKey) || isBlank(fromEmail)) {
            return EmailResult.failure(
                    "Email service is not configured. Please set BREVO_API_KEY and EMAIL_FROM_ADDRESS "
                    + "(environment variables or email.properties).");
        }

        return sendViaBrevo(toEmail, fullName,
                "DKS Bank - Password Reset Request",
                buildPasswordResetEmailBody(fullName, resetLink),
                null,
                "Unable to send password reset email. Please try again in a moment.");
    }

    /**
     * Sends the new-account details email for accounts created by an
     * admin (CreateAccountServlet) - the same Customer ID / Account
     * Number / IFSC Code shown on the admin's success popup.
     *
     * No login password or any other credential is ever included in
     * this email. Instead, the customer is pointed to the existing
     * self-service "/register" route (Online Banking Registration) via
     * a button, using the application's own current base URL rather
     * than a hardcoded host.
     *
     * @param toEmail         recipient email address
     * @param fullName        recipient full name (used in greeting)
     * @param customerId      the generated Customer ID
     * @param accountNumber   the generated Account Number
     * @param ifscCode        the branch IFSC code
     * @param registrationUrl full, ready-to-click URL to the Online
     *                        Banking registration page (built by the
     *                        caller from the current request, e.g.
     *                        https://host/context/register)
     * @return EmailResult indicating success/failure - callers MUST check this
     */
    public EmailResult sendAccountDetailsEmail(String toEmail,
                                                String fullName,
                                                String customerId,
                                                String accountNumber,
                                                String ifscCode,
                                                String registrationUrl) {

        if (isBlank(brevoApiKey) || isBlank(fromEmail)) {
            return EmailResult.failure(
                    "Email service is not configured. Please set BREVO_API_KEY and EMAIL_FROM_ADDRESS "
                    + "(environment variables or email.properties).");
        }

        return sendViaBrevo(toEmail, fullName,
                "DKS Bank - Your New Account Details",
                null,
                buildAccountDetailsEmailHtml(fullName, customerId, accountNumber, ifscCode, registrationUrl),
                "Unable to send account details email. Please try again in a moment.");
    }

    /**
     * Sends the "Online Banking Activated" email when an admin
     * activates online banking for an existing customer via the Add
     * User (CUSTOMER role) flow. Includes the auto-generated temporary
     * password, since the whole point of this flow is that the
     * customer needs it to log in for the first time - unlike
     * sendAccountDetailsEmail(), which deliberately never includes a
     * password.
     *
     * @param toEmail           recipient email address
     * @param fullName          recipient full name (used in greeting)
     * @param customerId        the customer's existing Customer ID
     * @param temporaryPassword the auto-generated temporary password
     * @param loginUrl          full, ready-to-click URL to the login page
     *                          (built by the caller from the current request)
     * @return EmailResult indicating success/failure - callers MUST check this
     */
    public EmailResult sendOnlineBankingActivatedEmail(String toEmail,
                                                        String fullName,
                                                        String customerId,
                                                        String temporaryPassword,
                                                        String loginUrl) {

        if (isBlank(brevoApiKey) || isBlank(fromEmail)) {
            return EmailResult.failure(
                    "Email service is not configured. Please set BREVO_API_KEY and EMAIL_FROM_ADDRESS "
                    + "(environment variables or email.properties).");
        }

        return sendViaBrevo(toEmail, fullName,
                "DKS Bank - Online Banking Activated",
                null,
                buildOnlineBankingActivatedEmailHtml(fullName, customerId, temporaryPassword, loginUrl),
                "Unable to send activation email. Please try again in a moment.");
    }

    /**
     * Posts a single transactional email to Brevo's API. Exactly one of
     * textBody/htmlBody should be non-null - the other stays null.
     */
    private EmailResult sendViaBrevo(String toEmail,
                                      String toName,
                                      String subject,
                                      String textBody,
                                      String htmlBody,
                                      String failureMessage) {
        try {
            String requestJson = buildBrevoRequestJson(toEmail, toName, subject, textBody, htmlBody);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(BREVO_API_URL))
                    .timeout(Duration.ofSeconds(15))
                    .header("api-key", brevoApiKey)
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestJson))
                    .build();

            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                return EmailResult.success();
            }

            // Brevo's error responses are JSON like {"code":"...","message":"..."} -
            // logged server-side only, never shown to the end user.
            System.err.println("Brevo API request failed (HTTP " + response.statusCode() + "): " + response.body());
            return EmailResult.failure(failureMessage);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            e.printStackTrace();
            return EmailResult.failure(failureMessage);
        } catch (IOException e) {
            e.printStackTrace();
            return EmailResult.failure(failureMessage);
        }
    }

    private String buildBrevoRequestJson(String toEmail,
                                          String toName,
                                          String subject,
                                          String textBody,
                                          String htmlBody) {
        StringBuilder json = new StringBuilder();
        json.append("{");

        json.append("\"sender\":{\"name\":\"")
                .append(jsonEscape(isBlank(fromName) ? "DKS Bank" : fromName))
                .append("\",\"email\":\"")
                .append(jsonEscape(fromEmail))
                .append("\"},");

        json.append("\"to\":[{\"email\":\"").append(jsonEscape(toEmail)).append("\"");
        if (!isBlank(toName)) {
            json.append(",\"name\":\"").append(jsonEscape(toName)).append("\"");
        }
        json.append("}],");

        json.append("\"subject\":\"").append(jsonEscape(subject)).append("\"");

        if (htmlBody != null) {
            json.append(",\"htmlContent\":\"").append(jsonEscape(htmlBody)).append("\"");
        } else {
            json.append(",\"textContent\":\"").append(jsonEscape(textBody)).append("\"");
        }

        json.append("}");
        return json.toString();
    }

    private String jsonEscape(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder sb = new StringBuilder(value.length());
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:
                    if (c < 0x20) {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }

    private String buildOtpEmailBody(String fullName, String otpCode, int validityMinutes) {
        String name = isBlank(fullName) ? "Customer" : fullName;

        return "Dear " + name + ",\n\n"
                + "Thank you for opening an account with DKS Bank.\n\n"
                + "Your One-Time Password (OTP) for account opening verification is:\n\n"
                + "        " + otpCode + "\n\n"
                + "This OTP is valid for " + validityMinutes + " minutes. Do not share this OTP with anyone, "
                + "including DKS Bank staff.\n\n"
                + "If you did not request this, please ignore this email.\n\n"
                + "Regards,\n"
                + "DKS Bank";
    }

    private String buildPasswordResetEmailBody(String fullName, String resetLink) {
        String name = isBlank(fullName) ? "Customer" : fullName;

        return "Dear " + name + ",\n\n"
                + "We received a request to reset your online banking password.\n\n"
                + "Click the link below to reset your password:\n\n"
                + "        " + resetLink + "\n\n"
                + "This link will expire after 10 minutes and can be used only once.\n\n"
                + "If you did not request this, please ignore this email - your password will "
                + "remain unchanged and no further action is needed.\n\n"
                + "Regards,\n"
                + "DKS Bank";
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

                // Header / branding
                + "<tr><td style=\"background:#0f8a4c;padding:24px 32px;text-align:center;\">"
                + "<span style=\"color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.5px;\">DKS Bank</span>"
                + "</td></tr>"

                // Body
                + "<tr><td style=\"padding:32px;\">"
                + "<p style=\"margin:0 0 16px;color:#0d3b2e;font-size:16px;\">Dear <strong>" + name + "</strong>,</p>"
                + "<p style=\"margin:0 0 20px;color:#3f4b46;font-size:14px;line-height:1.6;\">"
                + "Your new bank account has been opened successfully with DKS Bank. Here are your account details:"
                + "</p>"

                // Account details card
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

                // Registration button
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

                // Footer
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

    private Properties loadFallbackProperties() {
        Properties props = new Properties();

        try (InputStream in = getClass().getClassLoader().getResourceAsStream(PROPERTIES_FILE)) {
            if (in != null) {
                props.load(in);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return props;
    }

    private String resolve(String key, Properties fallback) {
        String envValue = System.getenv(key);

        if (envValue != null && !envValue.trim().isEmpty()) {
            return envValue.trim();
        }

        String propValue = fallback.getProperty(key);
        return propValue == null ? null : propValue.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
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