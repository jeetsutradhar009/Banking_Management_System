package com.bank.controller;

import com.bank.dao.OtpDAO;
import com.bank.model.OtpVerification;
import com.bank.util.AuditLogger;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Timestamp;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * VerifyEmailOtpServlet
 *
 * AJAX endpoint used by the email verification popup on
 * openAccount.jsp. Verifies the OTP entered by the user against the
 * pending EMAIL_VERIFICATION record and, on success, flips
 * email_verified to TRUE via OtpDAO.verifyEmailOtp().
 *
 * This is intentionally separate from the older ACCOUNT_OPENING OTP
 * flow (VerifyOtpServlet), which is left completely untouched.
 */
@WebServlet("/verify-email-otp")
public class VerifyEmailOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OtpDAO otpDAO = new OtpDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");
        String enteredOtp = request.getParameter("otp");

        try {
            if (isEmpty(token)) {
                writeJson(response, false, "Invalid verification session. Please click Verify again.", 0);
                return;
            }

            if (isEmpty(enteredOtp)) {
                writeJson(response, false, "Please enter the OTP sent to your email.", 0);
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

            Timestamp now = new Timestamp(System.currentTimeMillis());

            if (otpVerification.getExpiresAt() == null || otpVerification.getExpiresAt().before(now)) {
                writeJson(response, false, "This OTP has expired. Please request a new one.", 0);
                return;
            }

            if (otpVerification.getAttempts() >= otpVerification.getMaxAttempts()) {
                writeJson(response, false, "Maximum OTP attempts exceeded. Please request a new one.", 0);
                return;
            }

            String enteredOtpHash = hashOtp(enteredOtp.trim());

            if (!enteredOtpHash.equals(otpVerification.getOtpHash())) {
                otpDAO.incrementAttempts(token.trim());

                int remaining = otpVerification.getMaxAttempts() - (otpVerification.getAttempts() + 1);
                String message = remaining > 0
                        ? "Invalid OTP. " + remaining + " attempt(s) remaining."
                        : "Invalid OTP. No attempts remaining - please request a new one.";

                writeJson(response, false, message, Math.max(remaining, 0));
                return;
            }

            boolean verified = otpDAO.verifyEmailOtp(token.trim(), enteredOtpHash);

            if (!verified) {
                writeJson(response, false, "Unable to verify OTP right now. Please try again.", 0);
                return;
            }

            AuditLogger.logByIdentifier(otpVerification.getEmail(), otpVerification.getEmail(),
                    "EMAIL_VERIFIED", "Email verified for account opening (token " + token.trim() + ")");

            writeJson(response, true, "Email verified successfully.", 0);

        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, false, "Something went wrong while verifying your OTP. Please try again.", 0);
        }
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Same SHA-256 hashing scheme used across the rest of the OTP
     * flow (SendEmailVerificationServlet, OpenAccountServlet).
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
     * (no JSON library dependency in this project).
     */
    private void writeJson(HttpServletResponse response,
                            boolean success,
                            String message,
                            int remainingAttempts) throws IOException {

        String json =
                "{" +
                "\"success\":" + success + "," +
                "\"message\":\"" + esc(message) + "\"," +
                "\"remainingAttempts\":" + remainingAttempts +
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