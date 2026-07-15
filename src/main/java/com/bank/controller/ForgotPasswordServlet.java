package com.bank.controller;

import com.bank.dao.PasswordResetDAO;
import com.bank.model.PasswordResetToken;
import com.bank.model.User;
import com.bank.util.AuditLogger;
import com.bank.util.EmailService;
import com.bank.util.PasswordUtil;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.util.Base64;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int TOKEN_VALIDITY_MINUTES = resolveTokenValidityMinutes();
    private static final int RESET_COOLDOWN_SECONDS = 60;

    private static final String EMAIL_PATTERN = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";

    private static final String GENERIC_SUCCESS_MESSAGE =
            "If your email is registered, a password reset link has been sent.";

    private final PasswordResetDAO passwordResetDAO = new PasswordResetDAO();
    private final EmailService emailService = new EmailService();
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");

        try {
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Please enter your registered email address.");
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
                return;
            }

            email = email.trim().toLowerCase();

            if (!email.matches(EMAIL_PATTERN)) {
                // A format check is not an account-existence leak - it is
                // safe to report distinctly, so we skip a wasted DB call
                // for something that can never match a stored email.
                request.setAttribute("error", "Please enter a valid email address.");
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
                return;
            }

            User user = passwordResetDAO.getUserByEmail(email);

            if (user != null && isEligibleForReset(user)) {
                processResetRequest(user, request);
            }

            // Same message whether or not the email is registered,
            // whether or not online banking is activated, whether or
            // not a cooldown is active, and regardless of what
            // happened internally - never reveal account state
            // through this response.
            request.setAttribute("success", GENERIC_SUCCESS_MESSAGE);
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);

        } catch (Exception e) {
            logError("Unexpected error while processing forgot-password request", e);
            request.setAttribute("success", GENERIC_SUCCESS_MESSAGE);
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
        }
    }

    /**
     * A password can only be "forgotten" if one was ever set in the
     * first place. ADMIN accounts always have a password (seeded at
     * setup time), so they are always eligible. USER accounts only
     * have a password once online banking has been activated
     * (UserDAO.activateOnlineBanking()) - an account that only
     * completed account opening (Phase 1) but never registered for
     * online banking (Phase 2) has no password to reset, so Forgot
     * Password must behave exactly as if the email were not
     * registered at all for such accounts.
     */
    private boolean isEligibleForReset(User user) {
        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            return true;
        }

        return user.isOnlineBankingEnabled();
    }

    /**
     * Generates and emails a reset token for a user known to exist
     * and to be eligible. Kept as its own method so doPost() stays a
     * straightforward "look up, then act" flow.
     */
    private void processResetRequest(User user, HttpServletRequest request) {
        String userEmail = user.getEmail() != null ? user.getEmail().trim() : null;
        String fullName = user.getFullName() != null ? user.getFullName().trim() : "Customer";
        String customerId = user.getCustomerId() != null ? user.getCustomerId().trim() : userEmail;

        if (userEmail == null || userEmail.isEmpty()) {
            // Defensive only - email is NOT NULL in the schema, so this
            // should not happen, but we never want a null email reaching
            // the DAO/EmailService layer.
            logError("User row returned by getUserByEmail() had a null/blank email", null);
            return;
        }

        // Rate limiting: if a reset was already requested for this
        // email within the cooldown window, silently do nothing -
        // no new token, no email, and (per requirement) no different
        // response, so the cooldown itself is never revealed either.
        Timestamp lastRequestTime = passwordResetDAO.getLastRequestTime(userEmail);

        if (lastRequestTime != null && secondsSince(lastRequestTime) < RESET_COOLDOWN_SECONDS) {
            return;
        }

        String plainToken = generateToken();
        String tokenHash = PasswordUtil.hashToken(plainToken);

        Timestamp expiresAt = new Timestamp(
                System.currentTimeMillis() + (TOKEN_VALIDITY_MINUTES * 60L * 1000L));

        // Only the HASH is ever persisted - the plain token exists only
        // in this method's local variable and in the emailed link.
        PasswordResetToken resetToken = new PasswordResetToken(userEmail, tokenHash, expiresAt);

        boolean saved = passwordResetDAO.saveResetToken(resetToken);

        if (!saved) {
            // Nothing was invalidated yet at this point, so a save
            // failure here never costs the customer an existing valid
            // token - they simply keep whatever they already had.
            return;
        }

        // Invalidate previous tokens only AFTER the new one is safely
        // saved, and explicitly excluding the new token's own hash, so
        // a database hiccup while saving can never leave the customer
        // with zero working reset links.
        passwordResetDAO.invalidateOtherActiveTokensForEmail(userEmail, tokenHash);

        AuditLogger.logByIdentifier(customerId, fullName,
                "PASSWORD_RESET_REQUESTED", "Password reset requested for " + userEmail);

        // Note: neither the plain token, the token hash, nor the
        // reset link is ever written to the audit log.
        String resetLink = buildResetLink(request, plainToken);
        sendResetEmail(userEmail, fullName, customerId, resetLink);
    }

    /**
     * Sends the reset email and logs the outcome separately from the
     * "requested" log above, so a failed send is distinguishable from
     * a successful one in the audit trail.
     */
    private void sendResetEmail(String userEmail, String fullName, String customerId, String resetLink) {
        EmailService.EmailResult emailResult =
                emailService.sendPasswordResetEmail(userEmail, fullName, resetLink);

        if (emailResult.isSuccess()) {
            AuditLogger.logByIdentifier(customerId, fullName,
                    "PASSWORD_RESET_EMAIL_SENT", "Password reset email sent to " + userEmail);
        } else {
            AuditLogger.logByIdentifier(customerId, fullName,
                    "PASSWORD_RESET_EMAIL_FAILED", "Password reset email could not be sent to " + userEmail);
        }
    }

    /**
     * Builds the reset link dynamically from the current request, so
     * the same code works both locally and on the live deployment
     * without any hardcoded host. Only appends a port when it is not
     * the default port for the scheme in use (80 for http, 443 for
     * https), so an HTTPS deployment on the standard port does not
     * leak an unnecessary ":443" into the link. The token embedded
     * here is always the PLAIN token, never the hash - the hash only
     * ever lives in the database.
     */
    private String buildResetLink(HttpServletRequest request, String plainToken) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        boolean isDefaultPort =
                ("http".equalsIgnoreCase(scheme) && serverPort == 80)
                || ("https".equalsIgnoreCase(scheme) && serverPort == 443);

        String portPart = isDefaultPort ? "" : ":" + serverPort;

        return scheme + "://" + serverName + portPart + contextPath + "/reset-password?token=" + plainToken;
    }

    /**
     * Generates a cryptographically strong, unique PLAIN reset token
     * using SecureRandom (32 random bytes, URL-safe Base64 encoded -
     * about 43 characters). Only PasswordUtil.hashToken() of this
     * value is ever stored; this plain value is only used in-memory
     * to build the emailed link.
     */
    private String generateToken() {
        byte[] randomBytes = new byte[32];
        random.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }

    private long secondsSince(Timestamp timestamp) {
        return (System.currentTimeMillis() - timestamp.getTime()) / 1000L;
    }

    /**
     * Reads the token validity window from an environment variable if
     * present (PASSWORD_RESET_TOKEN_VALIDITY_MINUTES), falling back to
     * 10 minutes - same env-var-first, sane-default pattern already
     * used by DBConnection/EmailService for configuration.
     */
    private static int resolveTokenValidityMinutes() {
        String configured = System.getenv("PASSWORD_RESET_TOKEN_VALIDITY_MINUTES");

        if (configured != null && !configured.trim().isEmpty()) {
            try {
                int minutes = Integer.parseInt(configured.trim());
                if (minutes > 0) {
                    return minutes;
                }
            } catch (NumberFormatException e) {
                // fall through to default
            }
        }

        return 10;
    }

    /**
     * This project has no logging framework anywhere (every DAO/
     * servlet/util class uses e.printStackTrace() directly - there is
     * no SLF4J/Log4j already in use to switch to). Routing through
     * this one method keeps that same behavior but gives a single
     * place to plug in a real logger later without touching every
     * catch block in this file.
     */
    private void logError(String message, Exception e) {
        System.err.println("[ForgotPasswordServlet] " + message);
        if (e != null) {
            e.printStackTrace();
        }
    }
}