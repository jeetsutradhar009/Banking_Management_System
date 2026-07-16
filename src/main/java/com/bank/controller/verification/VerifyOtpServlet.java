package com.bank.controller.verification;

import com.bank.dao.OtpDAO;
import com.bank.dao.UserDAO;
import com.bank.model.AccountOpenResult;
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

@WebServlet("/verify-otp")
public class VerifyOtpServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OtpDAO otpDAO = new OtpDAO();
    private final UserDAO userDAO = new UserDAO();

    /**
     * Renders verifyOtp.jsp for a given pending-registration token.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");

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

        request.setAttribute("token", token.trim());
        request.setAttribute("email", otpVerification.getEmail());
        request.getRequestDispatcher("verifyOtp.jsp").forward(request, response);
    }

    /**
     * Verifies the submitted OTP. Only on success is the account
     * actually created, by calling the existing, unmodified
     * UserDAO.openBankAccount(...).
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");
        String enteredOtp = request.getParameter("otp");

        try {
            if (isEmpty(token)) {
                request.setAttribute("error", "Invalid verification link. Please open your account again.");
                request.getRequestDispatcher("openAccount.jsp").forward(request, response);
                return;
            }

            if (isEmpty(enteredOtp)) {
                request.setAttribute("error", "Please enter the OTP sent to your email.");
                showVerifyPage(request, response, token);
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

            Timestamp now = new Timestamp(System.currentTimeMillis());

            if (otpVerification.getExpiresAt() == null || otpVerification.getExpiresAt().before(now)) {
                request.setAttribute("error", "This OTP has expired. Please request a new one.");
                showVerifyPage(request, response, token);
                return;
            }

            if (otpVerification.getAttempts() >= otpVerification.getMaxAttempts()) {
                request.setAttribute("error", "Maximum OTP attempts exceeded. Please request a new one.");
                showVerifyPage(request, response, token);
                return;
            }

            String enteredOtpHash = hashOtp(enteredOtp.trim());

            if (!enteredOtpHash.equals(otpVerification.getOtpHash())) {
                otpDAO.incrementAttempts(token.trim());

                int remaining = otpVerification.getMaxAttempts() - (otpVerification.getAttempts() + 1);
                String message = remaining > 0
                        ? "Invalid OTP. " + remaining + " attempt(s) remaining."
                        : "Invalid OTP. No attempts remaining - please request a new one.";

                request.setAttribute("error", message);
                showVerifyPage(request, response, token);
                return;
            }

            boolean verified = otpDAO.verifyOtp(token.trim(), enteredOtpHash);

            if (!verified) {
                request.setAttribute("error", "Unable to verify OTP right now. Please try again.");
                showVerifyPage(request, response, token);
                return;
            }

            // ------------------------------------------------------------
            // OTP confirmed - now, and only now, create the account using
            // the existing, unmodified UserDAO.openBankAccount(...).
            // ------------------------------------------------------------

            AccountOpenResult result = userDAO.openBankAccount(
                    otpVerification.getFirstName(),
                    otpVerification.getLastName(),
                    otpVerification.getDob().toString(),
                    otpVerification.getAddress(),
                    otpVerification.getEmail(),
                    otpVerification.getPhone(),
                    otpVerification.getAccountType(),
                    otpVerification.getInitialDeposit()
            );

            if (result.isSuccess()) {
                String fullName = (otpVerification.getFirstName() + " " + otpVerification.getLastName()).trim();

                request.setAttribute("success", result.getMessage());
                request.setAttribute("customerId", result.getCustomerId());
                request.setAttribute("accountNumber", result.getAccountNumber());
                request.setAttribute("ifscCode", result.getIfscCode());

                AuditLogger.logByIdentifier(result.getCustomerId(), fullName,
                        "OPEN_ACCOUNT", "New account opened: " + result.getAccountNumber()
                                + " (Customer ID " + result.getCustomerId() + ")");
            } else {
                request.setAttribute("error", result.getMessage());
            }

            request.getRequestDispatcher("openAccount.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Something went wrong while verifying your OTP. Please try again.");
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

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Same SHA-256 hashing scheme used in OpenAccountServlet when the
     * OTP was first generated - the entered OTP must hash to the same
     * value as what was stored.
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
