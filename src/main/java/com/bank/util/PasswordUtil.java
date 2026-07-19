package com.bank.util;

import org.mindrot.jbcrypt.BCrypt;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.regex.Pattern;

public class PasswordUtil {

    private static final int SALT_ROUNDS = 12;

    // BCrypt hashes always start with $2a$, $2b$ or $2y$ and are 60 chars.
    private static final Pattern BCRYPT_PATTERN =
            Pattern.compile("^\\$2[aby]\\$\\d{2}\\$[./A-Za-z0-9]{53}$");

    private PasswordUtil() {
    }

    /**
     * Hashes a plain-text password with BCrypt before storage.
     * Replaces the previous plain-text no-op.
     */
    public static String process(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(SALT_ROUNDS));
    }

    /**
     * Verifies a plain-text password against whatever is currently
     * stored. Works for both a real BCrypt hash and a legacy
     * plain-text row (pre-migration users).
     */
    public static boolean verify(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) {
            return false;
        }

        if (isBcryptHash(storedPassword)) {
            return BCrypt.checkpw(plainPassword, storedPassword);
        }

        // Legacy plain-text row - direct compare only, never bcrypt-check it.
        return storedPassword.trim().equals(plainPassword);
    }

    /**
     * True if the stored value is already a BCrypt hash (post-migration),
     * false if it's still a legacy plain-text password.
     */
    public static boolean isBcryptHash(String storedPassword) {
        return storedPassword != null && BCRYPT_PATTERN.matcher(storedPassword).matches();
    }

    /**
     * SHA-256 token hashing - UNCHANGED.
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
            throw new IllegalStateException("SHA-256 is not available on this JVM", e);
        }
    }
}