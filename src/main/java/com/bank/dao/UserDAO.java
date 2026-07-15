package com.bank.dao;

import com.bank.model.AccountOpenResult;
import com.bank.model.RegistrationInfo;
import com.bank.model.User;
import com.bank.util.DBConnection;
import com.bank.util.PasswordUtil;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class UserDAO {

    private static final String IFSC_CODE = "DKSB0001886";
    private static final SecureRandom random = new SecureRandom();

    public AccountOpenResult openBankAccount(String firstName,
                                             String lastName,
                                             String dob,
                                             String address,
                                             String email,
                                             String phone,
                                             String accountType,
                                             double initialDeposit) {

        Connection con = null;

        try {
            con = DBConnection.getConnection();

            if (con == null) {
                return new AccountOpenResult(false, "Database connection failed.");
            }

            if (isEmailOrPhoneExists(con, email, phone)) {
                return new AccountOpenResult(false, "Email or mobile number already exists.");
            }

            con.setAutoCommit(false);

            String customerId = generateUniqueCustomerId(con);
            String accountNumber = generateUniqueAccountNumber(con);
            String fullName = (firstName + " " + lastName).trim();

            String userSql = """
                    INSERT INTO users
                    (customer_id, first_name, last_name, full_name, dob, address, email, phone, password, role, online_banking_enabled)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL, 'USER', 0)
                    """;

            int userId;

            try (PreparedStatement ps = con.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, customerId);
                ps.setString(2, firstName.trim());
                ps.setString(3, lastName.trim());
                ps.setString(4, fullName);
                ps.setDate(5, Date.valueOf(dob));
                ps.setString(6, address.trim());
                ps.setString(7, email.trim().toLowerCase());
                ps.setString(8, phone.trim());

                int rows = ps.executeUpdate();

                if (rows == 0) {
                    con.rollback();
                    return new AccountOpenResult(false, "Unable to create user account.");
                }

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                    } else {
                        con.rollback();
                        return new AccountOpenResult(false, "Unable to get generated user ID.");
                    }
                }
            }

            String accountSql = """
                    INSERT INTO accounts
                    (user_id, account_number, ifsc_code, account_type, balance)
                    VALUES (?, ?, ?, ?, ?)
                    """;

            try (PreparedStatement ps = con.prepareStatement(accountSql)) {
                ps.setInt(1, userId);
                ps.setString(2, accountNumber);
                ps.setString(3, IFSC_CODE);
                ps.setString(4, accountType);
                ps.setDouble(5, initialDeposit);
                ps.executeUpdate();
            }

            con.commit();

            return new AccountOpenResult(
                    true,
                    "Account opened successfully.",
                    customerId,
                    accountNumber,
                    IFSC_CODE
            );

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception rollbackException) {
                rollbackException.printStackTrace();
            }

            return new AccountOpenResult(false, "Something went wrong while opening account.");

        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public RegistrationInfo getRegistrationInfoByCustomerId(String customerId) {
        RegistrationInfo info = null;

        String sql = """
                SELECT u.user_id,
                       u.customer_id,
                       u.full_name,
                       u.email,
                       u.phone,
                       u.online_banking_enabled,
                       a.account_number,
                       a.ifsc_code,
                       a.account_type
                FROM users u
                INNER JOIN accounts a ON u.user_id = a.user_id
                WHERE TRIM(u.customer_id) = ?
                  AND u.role = 'USER'
                LIMIT 1
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, customerId.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    info = new RegistrationInfo();

                    info.setUserId(rs.getInt("user_id"));
                    info.setCustomerId(rs.getString("customer_id"));
                    info.setFullName(rs.getString("full_name"));
                    info.setEmail(rs.getString("email"));
                    info.setPhone(rs.getString("phone"));
                    info.setOnlineBankingEnabled(rs.getInt("online_banking_enabled") == 1);
                    info.setAccountNumber(rs.getString("account_number"));
                    info.setIfscCode(rs.getString("ifsc_code"));
                    info.setAccountType(rs.getString("account_type"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return info;
    }

    public boolean activateOnlineBanking(String customerId, String password) {
        boolean success = false;

        String sql = """
                UPDATE users
                SET password = ?,
                    online_banking_enabled = 1
                WHERE TRIM(customer_id) = ?
                  AND role = 'USER'
                  AND online_banking_enabled = 0
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, password.trim());
            ps.setString(2, customerId.trim());

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return success;
    }

    public User loginUser(String loginId, String password) {
        User user = null;

        if (loginId == null || password == null) {
            return null;
        }

        String cleanLoginId = loginId.trim();
        String cleanPassword = password.trim();

        String sql = """
                SELECT *
                FROM users
                WHERE (
                        TRIM(customer_id) = ?
                        OR LOWER(TRIM(email)) = LOWER(?)
                      )
                  AND TRIM(password) = ?
                LIMIT 1
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, cleanLoginId);
            ps.setString(2, cleanLoginId);
            ps.setString(3, cleanPassword);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = mapUser(rs);

                    if ("USER".equalsIgnoreCase(user.getRole())
                            && !user.isOnlineBankingEnabled()) {
                        return null;
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    public boolean changePassword(int userId, String currentPassword, String newPassword) {
        boolean success = false;

        String sql = """
                UPDATE users
                SET password = ?
                WHERE user_id = ?
                  AND TRIM(password) = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newPassword.trim());
            ps.setInt(2, userId);
            ps.setString(3, currentPassword.trim());

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return success;
    }

    /**
     * Updates the password for the user matching the given email, used
     * by the Forgot Password flow (ResetPasswordServlet) where the
     * customer does not know their current password, so it cannot be
     * verified the way changePassword() does.
     *
     * Stores the password using the same plain storage format the rest
     * of the project currently uses (see activateOnlineBanking() /
     * changePassword() / loginUser()) so login keeps working unchanged.
     * The actual write goes through PasswordUtil.process(), so
     * switching to real hashing later only requires changing that one
     * method, not this query.
     */
    public boolean resetPassword(String email, String newPassword) {
        boolean success = false;

        String sql = """
                UPDATE users
                SET password = ?
                WHERE LOWER(TRIM(email)) = LOWER(?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, PasswordUtil.process(newPassword.trim()));
            ps.setString(2, email.trim());

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return success;
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

    private boolean isEmailOrPhoneExists(Connection con, String email, String phone) {
        boolean exists = false;

        String sql = """
                SELECT user_id
                FROM users
                WHERE LOWER(TRIM(email)) = LOWER(?)
                   OR TRIM(phone) = ?
                LIMIT 1
                """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            ps.setString(2, phone.trim());

            try (ResultSet rs = ps.executeQuery()) {
                exists = rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return exists;
    }

    private String generateUniqueCustomerId(Connection con) throws Exception {
        String customerId;

        do {
            long number = 1000000000L + Math.floorMod(random.nextLong(), 9000000000L);
            customerId = String.valueOf(number);
        } while (exists(con, "users", "customer_id", customerId));

        return customerId;
    }

    private String generateUniqueAccountNumber(Connection con) throws Exception {
        String accountNumber;

        do {
            long number = 100000000000L + Math.floorMod(random.nextLong(), 900000000000L);
            accountNumber = "ACC" + number;
        } while (exists(con, "accounts", "account_number", accountNumber));

        return accountNumber;
    }

    private boolean exists(Connection con, String tableName, String columnName, String value) throws Exception {
        String sql = "SELECT 1 FROM " + tableName + " WHERE " + columnName + " = ? LIMIT 1";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, value);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}