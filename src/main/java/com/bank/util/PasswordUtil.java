package com.bank.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * PasswordUtil
 *
 * Central place for preparing a password for storage.
 *
 * The rest of this project (UserDAO.loginUser(), activateOnlineBanking(),
 * changePassword()) still stores and compares passwords in plain text.
 * Migrating all of that to hashing at once risks breaking existing
 * logins, so that is intentionally NOT done here.
 *
 * This class exists so that, when password hashing is introduced later,
 * only this one method needs to change (plus the matching comparison
 * logic wherever a password is checked) - callers do not need to be
 * touched.
 *
 * Currently used ONLY by the new Forgot Password flow
 * (UserDAO.resetPassword()). loginUser(), activateOnlineBanking() and
 * changePassword() are untouched and keep working exactly as before.
 */
public class PasswordUtil {

    private PasswordUtil() {
    }

    /**
     * Prepares a plain-text password for storage. Currently a no-op
     * (returns the value unchanged) so it matches the project's
     * existing plain-text storage format. Replace this implementation
     * to hash the password (e.g. BCrypt/SHA-256) when the project is
     * ready to migrate - every caller of process() will then start
     * storing hashed passwords without any other code changes.
     */
    public static String process(String plainPassword) {
        return plainPassword;
    }

    /**
     * Hashes a password-reset token with SHA-256 before it is stored
     * in or looked up from password_reset_tokens.reset_token - the
     * plain token itself is only ever placed in the emailed link, and
     * is never persisted anywhere. Same SHA-256/hex-encoding scheme
     * already used for OTP hashing elsewhere in this project, so the
     * output is always exactly 64 hex characters - fits
     * reset_token VARCHAR(64) exactly.
     */
    public static String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(token.getBytes(StandardCharsets.UTF_8));

            StringBuilder hex = new StringBuilder();
            for (byte b : hashBytes) {
                hex.append(String.format("%02x", b));
            }

            return hex.toString();

        } catch (NoSuchAlgorithmException e) {
            // SHA-256 is a guaranteed-available JDK algorithm - this
            // should never happen, but if it did, a token that cannot
            // be hashed must not silently fall back to plain storage.
            throw new IllegalStateException("SHA-256 is not available on this JVM", e);
        }
    }
}