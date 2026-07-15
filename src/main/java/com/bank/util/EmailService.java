package com.bank.util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * EmailService
 *
 * Single Responsibility: send transactional emails (currently: Account
 * Opening OTP) over SMTP using the Jakarta Mail API.
 *
 * Configuration resolution order (same pattern as {@link DBConnection}):
 *
 *   1. Environment variables (used in production / Render deployment):
 *        SMTP_HOST
 *        SMTP_PORT
 *        SMTP_USERNAME
 *        SMTP_PASSWORD
 *        SMTP_FROM_EMAIL
 *        SMTP_FROM_NAME
 *
 *   2. If any environment variable is missing, falls back to a
 *      classpath resource "email.properties" (used for local
 *      development only). This file is NOT committed to source
 *      control - see email.properties.example for the template.
 *
 * No SMTP credentials are ever hardcoded in this class.
 *
 * Every send() call returns an {@link EmailResult} instead of throwing
 * or silently swallowing failures, so callers (OpenAccountServlet,
 * ResendOtpServlet) can react to a failed send (e.g. show an error
 * instead of redirecting to the OTP page).
 */
public class EmailService {

    private static final String PROPERTIES_FILE = "email.properties";

    private final String smtpHost;
    private final String smtpPort;
    private final String smtpUsername;
    private final String smtpPassword;
    private final String fromEmail;
    private final String fromName;

    public EmailService() {
        Properties fallback = loadFallbackProperties();

        this.smtpHost = resolve("SMTP_HOST", fallback);
        this.smtpPort = resolve("SMTP_PORT", fallback);
        this.smtpUsername = resolve("SMTP_USERNAME", fallback);
        this.smtpPassword = resolve("SMTP_PASSWORD", fallback);
        this.fromEmail = resolve("SMTP_FROM_EMAIL", fallback);
        this.fromName = resolve("SMTP_FROM_NAME", fallback);
    }

    /**
     * Sends the Account Opening OTP email.
     *
     * @param toEmail  recipient email address
     * @param fullName recipient full name (used in greeting)
     * @param otpCode  the plain 6-digit OTP (never persisted in plain form,
     *                 only ever passed in-memory to be emailed)
     * @param validityMinutes how many minutes the OTP stays valid, shown in the email
     * @return EmailResult indicating success/failure - callers MUST check this
     */
    public EmailResult sendOtpEmail(String toEmail, String fullName, String otpCode, int validityMinutes) {

        if (isBlank(smtpHost) || isBlank(smtpPort) || isBlank(smtpUsername)
                || isBlank(smtpPassword) || isBlank(fromEmail)) {

            return EmailResult.failure(
                    "Email service is not configured. Please set SMTP_HOST, SMTP_PORT, "
                    + "SMTP_USERNAME, SMTP_PASSWORD and SMTP_FROM_EMAIL (environment variables "
                    + "or email.properties).");
        }

        try {
            Session session = buildSession();

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail, isBlank(fromName) ? "DKS Bank" : fromName));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("DKS Bank - Your Account Opening OTP");
            message.setText(buildOtpEmailBody(fullName, otpCode, validityMinutes));

            Transport.send(message);

            return EmailResult.success();

        } catch (MessagingException | java.io.UnsupportedEncodingException e) {
            e.printStackTrace();
            return EmailResult.failure("Unable to send OTP email. Please try again in a moment.");
        }
    }

    /**
     * Sends the Forgot Password reset link email.
     *
     * @param toEmail   recipient email address
     * @param fullName  recipient full name (used in greeting)
     * @param resetLink the full, ready-to-click reset URL (built by the
     *                  caller from the current request, e.g.
     *                  https://host/context/reset-password?token=...)
     * @return EmailResult indicating success/failure - callers MUST check this
     */
    public EmailResult sendPasswordResetEmail(String toEmail, String fullName, String resetLink) {

        if (isBlank(smtpHost) || isBlank(smtpPort) || isBlank(smtpUsername)
                || isBlank(smtpPassword) || isBlank(fromEmail)) {

            return EmailResult.failure(
                    "Email service is not configured. Please set SMTP_HOST, SMTP_PORT, "
                    + "SMTP_USERNAME, SMTP_PASSWORD and SMTP_FROM_EMAIL (environment variables "
                    + "or email.properties).");
        }

        try {
            Session session = buildSession();

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail, isBlank(fromName) ? "DKS Bank" : fromName));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("DKS Bank - Password Reset Request");
            message.setText(buildPasswordResetEmailBody(fullName, resetLink));

            Transport.send(message);

            return EmailResult.success();

        } catch (MessagingException | java.io.UnsupportedEncodingException e) {
            e.printStackTrace();
            return EmailResult.failure("Unable to send password reset email. Please try again in a moment.");
        }
    }

    private Session buildSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.ssl.trust", smtpHost);

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUsername, smtpPassword);
            }
        });
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

    /**
     * Simple success/failure result so callers never have to catch a
     * mail exception themselves - EmailService already did.
     */
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