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

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * ResendEmailOtpServlet
 *
 * AJAX endpoint used by the "Resend OTP" button inside the email
 * verification popup on openAccount.jsp. Regenerates and re-sends the
 * OTP for a pending EMAIL_VERIFICATION record, enforcing a 120 second
 * cooldown server-side (based on last_sent_at) so the cooldown cannot
 * be bypassed via browser/dev tools.
 *
 * This is intentionally separate from the older ACCOUNT_OPENING OTP
 * flow (ResendOtpServlet), which is left completely untouched.
 */
@WebServlet("/resend-email-otp")
public class ResendEmailOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int OTP_VALIDITY_MINUTES = 5;
    private static final int RESEND_COOLDOWN_SECONDS = 30;

    private final OtpDAO otpDAO = new OtpDAO();
    private final EmailService emailService = new EmailService();
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");

        try {
            if (isEmpty(token)) {
                writeJson(response, false, "Invalid verification session. Please click Verify again.", 0);
                return;
            }

            OtpVerification otpVerification = otpDAO.getByVerificationToken(token.trim());

            if (otpVerification == null) {
                writeJson(response, false, "Invalid or expired verification session. Please click Verify again.", 0);
                return;
            }

            if (!"PENDING".equalsIgnoreCase(otpVerification.getStatus())) {
                writeJson(response, false, "This OTP has already been used or is no longer valid.", 0);
                return;
            }

            long secondsSinceLastSend = secondsSince(otpVerification.getLastSentAt());

            if (secondsSinceLastSend < RESEND_COOLDOWN_SECONDS) {
                long waitSeconds = RESEND_COOLDOWN_SECONDS - secondsSinceLastSend;
                writeJson(response, false,
                        "Please wait " + waitSeconds + " second(s) before requesting a new OTP.",
                        (int) waitSeconds);
                return;
            }

            String newOtpCode = generateOtp();
            String newOtpHash = hashOtp(newOtpCode);
            Timestamp newExpiresAt = new Timestamp(
                    System.currentTimeMillis() + (OTP_VALIDITY_MINUTES * 60L * 1000L));

            boolean updated = otpDAO.updateResendOtp(token.trim(), newOtpHash, newExpiresAt);

            if (!updated) {
                writeJson(response, false, "Unable to resend OTP right now. Please try again.", 0);
                return;
            }

            EmailService.EmailResult emailResult = emailService.sendOtpEmail(
                    otpVerification.getEmail(),
                    otpVerification.getEmail(),
                    newOtpCode,
                    OTP_VALIDITY_MINUTES
            );

            if (!emailResult.isSuccess()) {
                writeJson(response, false, emailResult.getMessage(), 0);
                return;
            }

            AuditLogger.logByIdentifier(otpVerification.getEmail(), otpVerification.getEmail(),
                    "EMAIL_OTP_RESENT", "Email verification OTP resent (token " + token.trim() + ")");

            writeJson(response, true, "A new OTP has been sent to your email.", RESEND_COOLDOWN_SECONDS);

        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, false, "Something went wrong while resending the OTP. Please try again.", 0);
        }
    }

    private long secondsSince(Timestamp lastSentAt) {
        if (lastSentAt == null) {
            return Long.MAX_VALUE;
        }

        return (System.currentTimeMillis() - lastSentAt.getTime()) / 1000L;
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Same random 6-digit OTP generation used across the rest of the
     * OTP flow.
     */
    private String generateOtp() {
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    /**
     * Same SHA-256 hashing scheme used across the rest of the OTP
     * flow.
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
     * already used by CustomerLookupServlet / SendEmailVerificationServlet
     * / VerifyEmailOtpServlet (no JSON library dependency in this
     * project).
     */
    private void writeJson(HttpServletResponse response,
                            boolean success,
                            String message,
                            int resendCooldownSeconds) throws IOException {

        String json =
                "{" +
                "\"success\":" + success + "," +
                "\"message\":\"" + esc(message) + "\"," +
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