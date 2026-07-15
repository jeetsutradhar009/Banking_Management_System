package com.bank.controller;

import com.bank.dao.OtpDAO;
import com.bank.model.OtpVerification;
import com.bank.util.AuditLogger;
import com.bank.util.EmailService;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * SendEmailVerificationServlet
 *
 * AJAX endpoint behind the "Verify" button next to the Email field on
 * openAccount.jsp. Only the email is known at this point - the rest
 * of the account-opening form has not been filled in yet - so a
 * pending otp_verifications row is created with purpose =
 * 'EMAIL_VERIFICATION' and every account-opening field left null.
 *
 * This is intentionally separate from the older ACCOUNT_OPENING OTP
 * flow (OpenAccountServlet / VerifyOtpServlet / ResendOtpServlet),
 * which is left completely untouched.
 */
@WebServlet("/send-email-verification")
public class SendEmailVerificationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int OTP_VALIDITY_MINUTES = 5;
    private static final int RESEND_COOLDOWN_SECONDS = 30;

    private static final String EMAIL_PATTERN = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";

    private final OtpDAO otpDAO = new OtpDAO();
    private final EmailService emailService = new EmailService();
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");

        try {
            if (email == null || email.trim().isEmpty()) {
                writeJson(response, false, "Email address is required.", null, null, 0, 0);
                return;
            }

            email = email.trim().toLowerCase();

            if (!email.matches(EMAIL_PATTERN)) {
                writeJson(response, false, "Please enter a valid email address.", null, null, 0, 0);
                return;
            }

            String otpCode = generateOtp();
            String otpHash = hashOtp(otpCode);
            String verificationToken = UUID.randomUUID().toString();

            Timestamp expiresAt = new Timestamp(
                    System.currentTimeMillis() + (OTP_VALIDITY_MINUTES * 60L * 1000L));

            OtpVerification otpVerification = new OtpVerification(
                    verificationToken,
                    "EMAIL_VERIFICATION",
                    null,               // firstName - not filled in yet
                    null,               // lastName - not filled in yet
                    null,               // dob - not filled in yet
                    null,               // address - not filled in yet
                    email,
                    null,               // phone - not filled in yet
                    null,               // accountType - not filled in yet
                    0,                  // initialDeposit - not filled in yet
                    otpHash,
                    expiresAt
            );

            boolean saved = otpDAO.saveOtpVerification(otpVerification);

            if (!saved) {
                writeJson(response, false, "Unable to start email verification. Please try again.", null, null, 0, 0);
                return;
            }

            EmailService.EmailResult emailResult = emailService.sendOtpEmail(
                    email,
                    email,
                    otpCode,
                    OTP_VALIDITY_MINUTES
            );

            if (!emailResult.isSuccess()) {
                writeJson(response, false, emailResult.getMessage(), null, null, 0, 0);
                return;
            }

            AuditLogger.logByIdentifier(email, email,
                    "EMAIL_OTP_SENT", "Email verification OTP sent (token " + verificationToken + ")");

            writeJson(response, true, "OTP sent to your email address.",
                    verificationToken, maskEmail(email),
                    OTP_VALIDITY_MINUTES * 60, RESEND_COOLDOWN_SECONDS);

        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, false, "Something went wrong while sending the OTP. Please try again.", null, null, 0, 0);
        }
    }

    /**
     * Masks an email address for display in the verification popup,
     * e.g. "dsutradhar@gmail.com" -> "ds******@gmail.com".
     */
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return "";
        }

        String[] parts = email.split("@", 2);
        String namePart = parts[0];
        String domainPart = parts[1];

        if (namePart.length() <= 2) {
            return namePart.charAt(0) + "***@" + domainPart;
        }

        return namePart.substring(0, 2) + "******@" + domainPart;
    }

    /**
     * Same random 6-digit OTP generation used across the rest of the
     * OTP flow (OpenAccountServlet, ResendOtpServlet).
     */
    private String generateOtp() {
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    /**
     * Same SHA-256 hashing scheme used across the rest of the OTP
     * flow, so the stored hash format is identical everywhere.
     */
    private String hashOtp(String otpCode) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hashBytes = digest.digest(otpCode.getBytes(StandardCharsets.UTF_8));

        StringBuilder hex = new StringBuilder();
        for (byte b : hashBytes) {
            hex.append(String.format("%02x", b));
        }

        return hex.toString();
    }

    /**
     * Hand-built JSON response, matching the manual-JSON convention
     * already used by CustomerLookupServlet (no JSON library dependency
     * in this project).
     */
    private void writeJson(HttpServletResponse response,
                            boolean success,
                            String message,
                            String token,
                            String maskedEmail,
                            int expiresInSeconds,
                            int resendCooldownSeconds) throws IOException {

        String json =
                "{" +
                "\"success\":" + success + "," +
                "\"message\":\"" + esc(message) + "\"," +
                "\"token\":\"" + esc(token) + "\"," +
                "\"maskedEmail\":\"" + esc(maskedEmail) + "\"," +
                "\"expiresInSeconds\":" + expiresInSeconds + "," +
                "\"resendCooldownSeconds\":" + resendCooldownSeconds +
                "}";

        response.getWriter().write(json);
    }

    private String esc(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}