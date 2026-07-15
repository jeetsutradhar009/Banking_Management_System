package com.bank.dao;

import com.bank.model.PasswordResetToken;
import com.bank.model.User;
import com.bank.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class PasswordResetDAO {

    /**
     * Inserts a new pending reset token. id, used and created_at are
     * left to their DB defaults (AUTO_INCREMENT / DEFAULT FALSE /
     * DEFAULT CURRENT_TIMESTAMP).
     */
    public boolean saveResetToken(PasswordResetToken token) {
        boolean success = false;

        String sql = """
                INSERT INTO password_reset_tokens
                (user_email, reset_token, expires_at)
                VALUES (?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token.getUserEmail());
            ps.setString(2, token.getResetToken());
            ps.setTimestamp(3, token.getExpiresAt());

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return success;
    }

    /**
     * Fetches a reset token row only if it is still usable right now:
     * not already used, and not expired. Returns null for a missing,
     * already-used, or expired token - the caller (ResetPasswordServlet)
     * treats all of those the same way ("Invalid or expired reset link"),
     * without needing to know which specific condition failed.
     */
    public PasswordResetToken findValidToken(String token) {
        PasswordResetToken resetToken = null;

        String sql = """
                SELECT *
                FROM password_reset_tokens
                WHERE TRIM(reset_token) = ?
                  AND used = FALSE
                  AND expires_at > CURRENT_TIMESTAMP
                LIMIT 1
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    resetToken = mapToken(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return resetToken;
    }

    /**
     * Marks a token as used so it becomes single-use - once this
     * succeeds, findValidToken() will no longer return this row.
     */
    public boolean markTokenUsed(String token) {
        boolean success = false;

        String sql = """
                UPDATE password_reset_tokens
                SET used = TRUE
                WHERE TRIM(reset_token) = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token.trim());

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return success;
    }

    /**
     * Invalidates every other still-active (unused) token for a given
     * email, EXCLUDING the token hash just saved by the caller. This
     * is deliberately called AFTER a new token has been successfully
     * saved (see ForgotPasswordServlet.processResetRequest()), not
     * before - so a database failure while saving the new token can
     * never leave a customer with zero working reset links. The
     * "except" token is excluded so this invalidation step cannot
     * accidentally mark the brand-new token as used the moment after
     * it was created.
     */
    public int invalidateOtherActiveTokensForEmail(String email, String exceptTokenHash) {
        int rowsUpdated = 0;

        String sql = """
                UPDATE password_reset_tokens
                SET used = TRUE
                WHERE LOWER(TRIM(user_email)) = LOWER(?)
                  AND used = FALSE
                  AND reset_token != ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            ps.setString(2, exceptTokenHash);

            rowsUpdated = ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return rowsUpdated;
    }

    /**
     * Returns the most recent request timestamp for a given email
     * (across all of its tokens, used or not), or null if none exist.
     * Used by ForgotPasswordServlet to enforce a resend cooldown -
     * same purpose as the last_sent_at cooldown check already used in
     * the OTP flow (ResendOtpServlet/ResendEmailOtpServlet), adapted
     * here since password_reset_tokens does not have a separate
     * last_sent_at column of its own - created_at already serves that
     * purpose since each request creates a new row.
     */
    public Timestamp getLastRequestTime(String email) {
        Timestamp lastRequestTime = null;

        String sql = """
                SELECT MAX(created_at) AS last_created
                FROM password_reset_tokens
                WHERE LOWER(TRIM(user_email)) = LOWER(?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    lastRequestTime = rs.getTimestamp("last_created");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lastRequestTime;
    }

    /**
     * Optional cleanup: permanently removes tokens whose expiry has
     * already passed. Not required for correctness (findValidToken()
     * already excludes expired rows via its WHERE clause) - this is
     * just housekeeping so the table does not grow unbounded. Returns
     * the number of rows deleted.
     */
    public int deleteExpiredTokens() {
        int rowsDeleted = 0;

        String sql = """
                DELETE FROM password_reset_tokens
                WHERE expires_at <= CURRENT_TIMESTAMP
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            rowsDeleted = ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return rowsDeleted;
    }

    /**
     * Looks up a user by email, used by ForgotPasswordServlet to check
     * whether the submitted email is registered (and to get the
     * customer's name for personalizing the reset email / audit log).
     *
     * Note: this reads from the users table rather than
     * password_reset_tokens. That is a deliberate exception to the
     * one-DAO-per-table convention used elsewhere in this project
     * (e.g. OtpDAO never touches users - UserDAO.openBankAccount() is
     * always called separately), made here specifically because it
     * was requested for this DAO. UserDAO itself is not modified by
     * this method.
     */
    public User getUserByEmail(String email) {
        User user = null;

        String sql = """
                SELECT *
                FROM users
                WHERE LOWER(TRIM(email)) = LOWER(?)
                LIMIT 1
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = mapUser(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    private PasswordResetToken mapToken(ResultSet rs) throws Exception {
        PasswordResetToken token = new PasswordResetToken();

        token.setId(rs.getInt("id"));
        token.setUserEmail(rs.getString("user_email"));
        token.setResetToken(rs.getString("reset_token"));
        token.setExpiresAt(rs.getTimestamp("expires_at"));
        token.setUsed(rs.getBoolean("used"));
        token.setCreatedAt(rs.getTimestamp("created_at"));

        return token;
    }

    private User mapUser(ResultSet rs) throws Exception {
        User user = new User();

        user.setUserId(rs.getInt("user_id"));
        user.setCustomerId(rs.getString("customer_id"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setFullName(rs.getString("full_name"));
        user.setDob(rs.getDate("dob"));
        user.setAddress(rs.getString("address"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setPassword(rs.getString("password"));
        user.setRole(rs.getString("role"));
        user.setOnlineBankingEnabled(rs.getInt("online_banking_enabled") == 1);

        return user;
    }
}