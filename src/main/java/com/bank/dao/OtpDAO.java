package com.bank.dao;

import com.bank.model.OtpVerification;
import com.bank.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class OtpDAO {

    /**
     * Inserts a new pending OTP verification record, carrying the full
     * account-opening form data along with the hashed OTP and its
     * expiry. Called by OpenAccountServlet after form validation,
     * before any row is written to users/accounts.
     *
     * otp_id, attempts, max_attempts, status, created_at and
     * last_sent_at are left to their DB defaults (0 / 'PENDING' /
     * CURRENT_TIMESTAMP as defined in the schema).
     */
    public boolean saveOtpVerification(OtpVerification otp) {
        boolean success = false;

        String sql = """
                INSERT INTO otp_verifications
                (verification_token, purpose, first_name, last_name, dob, address,
                 email, phone, account_type, initial_deposit, otp_hash, expires_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, otp.getVerificationToken());
            ps.setString(2, otp.getPurpose());
            ps.setString(3, otp.getFirstName());
            ps.setString(4, otp.getLastName());
            ps.setDate(5, otp.getDob());
            ps.setString(6, otp.getAddress());
            ps.setString(7, otp.getEmail());
            ps.setString(8, otp.getPhone());
            ps.setString(9, otp.getAccountType());
            ps.setDouble(10, otp.getInitialDeposit());
            ps.setString(11, otp.getOtpHash());
            ps.setTimestamp(12, otp.getExpiresAt());

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return success;
    }

    /**
     * Fetches a pending-registration record by its verification token.
     * Used to render verifyOtp.jsp (masked email, etc.) and to pull
     * the stored form fields once OTP verification succeeds.
     */
    public OtpVerification getByVerificationToken(String token) {
        OtpVerification otp = null;

        String sql = """
                SELECT *
                FROM otp_verifications
                WHERE TRIM(verification_token) = ?
                LIMIT 1
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    otp = mapOtpVerification(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return otp;
    }

    /**
     * Verifies the submitted OTP for a given token in a single atomic
     * UPDATE: the row is only flipped to VERIFIED when every condition
     * holds at once (still PENDING, hash matches, not expired, attempts
     * not exhausted). If the update affects 0 rows, the OTP was wrong,
     * expired, already used, or attempts were exhausted - the caller
     * (VerifyOtpServlet) decides which message to show by re-fetching
     * the record via getByVerificationToken() when this returns false.
     */
    public boolean verifyOtp(String token, String otpHash) {
        boolean verified = false;

        String sql = """
                UPDATE otp_verifications
                SET status = 'VERIFIED',
                    verified_at = CURRENT_TIMESTAMP
                WHERE TRIM(verification_token) = ?
                  AND status = 'PENDING'
                  AND otp_hash = ?
                  AND expires_at > CURRENT_TIMESTAMP
                  AND attempts < max_attempts
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token.trim());
            ps.setString(2, otpHash);

            verified = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return verified;
    }

    /**
     * Verifies the submitted OTP for the new inline EMAIL_VERIFICATION
     * flow (used by VerifyEmailOtpServlet), separate from verifyOtp()
     * above which belongs to the older ACCOUNT_OPENING flow.
     *
     * Same atomic-UPDATE pattern as verifyOtp(): the row is only
     * flipped when every condition holds at once (still PENDING, hash
     * matches, not expired, attempts not exhausted). On success this
     * also sets email_verified = TRUE, which the final account-creation
     * step (OpenAccountServlet) later checks via isEmailVerified().
     */
    public boolean verifyEmailOtp(String token, String otpHash) {
        boolean verified = false;

        String sql = """
                UPDATE otp_verifications
                SET status = 'VERIFIED',
                    email_verified = TRUE,
                    verified_at = CURRENT_TIMESTAMP
                WHERE TRIM(verification_token) = ?
                  AND status = 'PENDING'
                  AND otp_hash = ?
                  AND expires_at > CURRENT_TIMESTAMP
                  AND attempts < max_attempts
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token.trim());
            ps.setString(2, otpHash);

            verified = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return verified;
    }

    /**
     * Server-side re-check used at final account-creation time
     * (OpenAccountServlet), so a customer cannot bypass email
     * verification by tampering with a hidden form field in dev
     * tools. Returns true only when the token and email both match
     * the same VERIFIED, email_verified = TRUE record.
     */
    public boolean isEmailVerified(String token, String email) {
        boolean verified = false;

        String sql = """
                SELECT otp_id
                FROM otp_verifications
                WHERE TRIM(verification_token) = ?
                  AND LOWER(TRIM(email)) = LOWER(?)
                  AND status = 'VERIFIED'
                  AND email_verified = TRUE
                LIMIT 1
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token.trim());
            ps.setString(2, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                verified = rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return verified;
    }

    /**
     * Increments the failed-attempt counter for a pending OTP record.
     * Called by VerifyOtpServlet whenever verifyOtp() returns false
     * due to a wrong code (not due to expiry, which is a separate
     * condition already covered by verifyOtp()'s WHERE clause).
     */
    public boolean incrementAttempts(String token) {
        boolean success = false;

        String sql = """
                UPDATE otp_verifications
                SET attempts = attempts + 1
                WHERE TRIM(verification_token) = ?
                  AND status = 'PENDING'
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
     * Regenerates the OTP for an existing pending record: new hash,
     * new expiry, last_sent_at refreshed to now, and attempts reset
     * to 0 so the customer gets a fresh set of tries. Called by
     * ResendOtpServlet after its own cooldown check has passed.
     */
    public boolean updateResendOtp(String token, String newOtpHash, Timestamp expiryTime) {
        boolean success = false;

        String sql = """
                UPDATE otp_verifications
                SET otp_hash = ?,
                    expires_at = ?,
                    last_sent_at = CURRENT_TIMESTAMP,
                    attempts = 0
                WHERE TRIM(verification_token) = ?
                  AND status = 'PENDING'
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newOtpHash);
            ps.setTimestamp(2, expiryTime);
            ps.setString(3, token.trim());

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return success;
    }

    /**
     * Optional cleanup: flips any PENDING record whose expiry has
     * already passed to EXPIRED, so stale rows do not sit around as
     * PENDING forever. Not required for correctness (verifyOtp()
     * already rejects expired rows via its WHERE clause) but useful
     * for reporting/cleanup jobs. Returns the number of rows updated.
     */
    public int markExpiredOtp() {
        int rowsUpdated = 0;

        String sql = """
                UPDATE otp_verifications
                SET status = 'EXPIRED'
                WHERE status = 'PENDING'
                  AND expires_at <= CURRENT_TIMESTAMP
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            rowsUpdated = ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return rowsUpdated;
    }

    private OtpVerification mapOtpVerification(ResultSet rs) throws Exception {
        OtpVerification otp = new OtpVerification();

        otp.setOtpId(rs.getInt("otp_id"));
        otp.setVerificationToken(rs.getString("verification_token"));
        otp.setPurpose(rs.getString("purpose"));
        otp.setFirstName(rs.getString("first_name"));
        otp.setLastName(rs.getString("last_name"));
        otp.setDob(rs.getDate("dob"));
        otp.setAddress(rs.getString("address"));
        otp.setEmail(rs.getString("email"));
        otp.setPhone(rs.getString("phone"));
        otp.setAccountType(rs.getString("account_type"));
        otp.setInitialDeposit(rs.getDouble("initial_deposit"));
        otp.setOtpHash(rs.getString("otp_hash"));
        otp.setAttempts(rs.getInt("attempts"));
        otp.setMaxAttempts(rs.getInt("max_attempts"));
        otp.setStatus(rs.getString("status"));
        otp.setEmailVerified(rs.getBoolean("email_verified"));
        otp.setExpiresAt(rs.getTimestamp("expires_at"));
        otp.setLastSentAt(rs.getTimestamp("last_sent_at"));
        otp.setCreatedAt(rs.getTimestamp("created_at"));
        otp.setVerifiedAt(rs.getTimestamp("verified_at"));

        return otp;
    }
}