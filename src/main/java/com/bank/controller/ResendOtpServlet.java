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

@WebServlet("/resend-otp")
public class ResendOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int OTP_VALIDITY_MINUTES = 10;
    private static final int RESEND_COOLDOWN_SECONDS = 45;

    private final OtpDAO otpDAO = new OtpDAO();
    private final EmailService emailService = new EmailService();
    private final SecureRandom random = new SecureRandom();

    /**
     * Regenerates and re-sends the OTP for a pending account-opening
     * verification. Does not touch users/accounts in any way.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");

        try {
            if (isEmpty(token)) {
                request.setAttribute("error", "Invalid verification link. Please open your account again.");
                request.getRequestDispatcher("openAccount.jsp").forward(request, response);
                return;
            }

            OtpVerification otpVerification = otpDAO.getByVerificationToken(token.trim());

            if (otpVerification == null) {
                request.setAttribute("error", "Invalid or expired verification link. Please open your account again.");
                request.getRequestDispatcher("openAccount.jsp").forward(request, response);
                return;
            }

            if (!"PENDING".equalsIgnoreCase(otpVerification.getStatus())) {
                request.setAttribute("error", "This OTP has already been used or is no longer valid. Please open your account again.");
                request.getRequestDispatcher("openAccount.jsp").forward(request, response);
                return;
            }

            long secondsSinceLastSend = secondsSince(otpVerification.getLastSentAt());

            if (secondsSinceLastSend < RESEND_COOLDOWN_SECONDS) {
                long waitSeconds = RESEND_COOLDOWN_SECONDS - secondsSinceLastSend;
                request.setAttribute("error", "Please wait " + waitSeconds + " second(s) before requesting a new OTP.");
                showVerifyPage(request, response, token);
                return;
            }

            String newOtpCode = generateOtp();
            String newOtpHash = hashOtp(newOtpCode);
            Timestamp newExpiresAt = new Timestamp(
                    System.currentTimeMillis() + (OTP_VALIDITY_MINUTES * 60L * 1000L));

            boolean updated = otpDAO.updateResendOtp(token.trim(), newOtpHash, newExpiresAt);

            if (!updated) {
                request.setAttribute("error", "Unable to resend OTP right now. Please try again.");
                showVerifyPage(request, response, token);
                return;
            }

            String fullName = (otpVerification.getFirstName() + " " + otpVerification.getLastName()).trim();

            EmailService.EmailResult emailResult = emailService.sendOtpEmail(
                    otpVerification.getEmail(),
                    fullName,
                    newOtpCode,
                    OTP_VALIDITY_MINUTES
            );

            if (!emailResult.isSuccess()) {
                request.setAttribute("error", emailResult.getMessage());
                showVerifyPage(request, response, token);
                return;
            }

            AuditLogger.logByIdentifier(otpVerification.getEmail(), fullName,
                    "OTP_RESENT", "Account opening OTP resent (token " + token.trim() + ")");

            request.setAttribute("success", "A new OTP has been sent to your email.");
            showVerifyPage(request, response, token);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Something went wrong while resending the OTP. Please try again.");
            request.getRequestDispatcher("openAccount.jsp").forward(request, response);
        }
    }

    private void showVerifyPage(HttpServletRequest request, HttpServletResponse response, String token)
            throws ServletException, IOException {

        OtpVerification otpVerification = otpDAO.getByVerificationToken(token.trim());

        request.setAttribute("token", token.trim());

        if (otpVerification != null) {
            request.setAttribute("email", otpVerification.getEmail());
        }

        request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
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
     * Same random 6-digit OTP generation used in OpenAccountServlet.
     */
    private String generateOtp() {
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    /**
     * Same SHA-256 hashing scheme used in OpenAccountServlet and
     * VerifyOtpServlet - keeps OTP security logic consistent across
     * the whole account-opening verification flow.
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
}
