package com.bank.controller.auth;

import com.bank.dao.PasswordResetDAO;
import com.bank.dao.UserDAO;
import com.bank.model.PasswordResetToken;
import com.bank.model.User;
import com.bank.util.AuditLogger;
import com.bank.util.PasswordUtil;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VIEW = "/WEB-INF/views/auth/resetPassword.jsp";

    private static final String INVALID_LINK_MESSAGE = "Invalid or expired reset link.";

    private final PasswordResetDAO passwordResetDAO = new PasswordResetDAO();
    private final UserDAO userDAO = new UserDAO();

    /**
     * Shows the reset form only if the token in the URL is currently
     * valid (exists, unused, not expired) - findValidToken() already
     * encodes all three checks in one query, so a single null check
     * here covers every invalid case with the same generic message.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");

        if (isEmpty(token) || passwordResetDAO.findValidToken(PasswordUtil.hashToken(token.trim())) == null) {
            request.setAttribute("error", INVALID_LINK_MESSAGE);
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        // The PLAIN token (never the hash) is what goes back into the
        // page - it is what the hidden form field must resubmit on
        // POST, since only the hash is ever stored in the database.
        request.setAttribute("token", token.trim());
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    /**
     * Completes the reset: re-validates the token (never trusts the
     * hidden field alone - the token could have expired or been used
     * by a second submission between GET and POST), validates the new
     * password, updates it via UserDAO, marks the token single-use,
     * and audit-logs the completion.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            if (isEmpty(token)) {
                request.setAttribute("error", INVALID_LINK_MESSAGE);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            token = token.trim();

            String tokenHash = PasswordUtil.hashToken(token);

            PasswordResetToken resetToken = passwordResetDAO.findValidToken(tokenHash);

            if (resetToken == null) {
                request.setAttribute("error", INVALID_LINK_MESSAGE);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            if (isEmpty(newPassword) || isEmpty(confirmPassword)) {
                request.setAttribute("error", "Both password fields are required.");
                request.setAttribute("token", token);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            newPassword = newPassword.trim();
            confirmPassword = confirmPassword.trim();

            // Same minimum-length rule already used at registration
            // time (see RegisterServlet), kept identical for consistency.
            if (newPassword.length() < 6) {
                request.setAttribute("error", "Password must be at least 6 characters.");
                request.setAttribute("token", token);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Password and confirm password do not match.");
                request.setAttribute("token", token);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            String email = resetToken.getUserEmail();

            // Fetched once, before the update, so the name/customer ID
            // needed for the audit log below does not require a second
            // lookup afterward.
            User user = passwordResetDAO.getUserByEmail(email);

            boolean updated = userDAO.resetPassword(email, newPassword);

            if (!updated) {
                request.setAttribute("error", "Unable to reset password right now. Please try again.");
                request.setAttribute("token", token);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            // Token is single-use: once the password update succeeds,
            // this token must never work again. The hash is what is
            // stored, so the hash is what must be marked used.
            passwordResetDAO.markTokenUsed(tokenHash);

            String fullName = (user != null && user.getFullName() != null) ? user.getFullName() : "Customer";
            String customerId = (user != null && user.getCustomerId() != null) ? user.getCustomerId() : email;

            AuditLogger.logByIdentifier(customerId, fullName,
                    "PASSWORD_RESET_COMPLETED", "Password reset completed successfully");

            response.sendRedirect(request.getContextPath()
                    + "/login?success=Password%20updated%20successfully.%20Please%20login%20with%20your%20new%20password.");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Something went wrong. Please try again.");
            request.getRequestDispatcher(VIEW).forward(request, response);
        }
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}