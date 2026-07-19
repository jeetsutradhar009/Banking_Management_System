package com.bank.dao;

import com.bank.model.Account;
import com.bank.model.ActivationResult;
import com.bank.model.Transaction;
import com.bank.model.User;
import com.bank.util.DBConnection;
import com.bank.util.PasswordUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

public class AdminDAO {

    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'USER'";
        return getCountFromSql(sql);
    }

    public int getTotalAccounts() {
        String sql = "SELECT COUNT(*) FROM accounts";
        return getCountFromSql(sql);
    }

    public int getTotalTransactions() {
        String sql = "SELECT COUNT(*) FROM transactions";
        return getCountFromSql(sql);
    }

    public int getCount(String tableName, String condition) {
        String sql = "SELECT COUNT(*) FROM " + tableName + " " + (condition == null ? "" : condition);
        return getCountFromSql(sql);
    }

    private int getCountFromSql(String sql) {
        int count = 0;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    public List<User> getRecentUsers(int limit) {
        List<User> users = new ArrayList<>();

        String sql = "SELECT user_id, full_name, email, phone, role " +
                     "FROM users " +
                     "ORDER BY user_id DESC " +
                     "LIMIT ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                users.add(mapUser(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return users;
    }

    public List<Account> getRecentAccounts(int limit) {
        List<Account> accounts = new ArrayList<>();

        String sql = "SELECT account_id, user_id, account_number, account_type, balance, status " +
                     "FROM accounts " +
                     "ORDER BY account_id DESC " +
                     "LIMIT ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                accounts.add(mapAccount(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return accounts;
    }

    public List<Transaction> getRecentTransactions(int limit) {
        List<Transaction> transactions = new ArrayList<>();

        String sql = "SELECT transaction_id, sender_account, receiver_account, amount, status, transaction_date " +
                     "FROM transactions " +
                     "ORDER BY transaction_date DESC " +
                     "LIMIT ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                transactions.add(mapTransaction(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return transactions;
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();

        String sql = "SELECT user_id, full_name, email, phone, role " +
                     "FROM users " +
                     "ORDER BY user_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                users.add(mapUser(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return users;
    }

    public List<Account> getAllAccounts() {
        List<Account> accounts = new ArrayList<>();

        String sql = "SELECT account_id, user_id, account_number, account_type, balance, status " +
                     "FROM accounts " +
                     "ORDER BY account_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                accounts.add(mapAccount(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return accounts;
    }

    public List<Transaction> getAllTransactions() {
        List<Transaction> transactions = new ArrayList<>();

        String sql = "SELECT transaction_id, sender_account, receiver_account, amount, status, transaction_date " +
                     "FROM transactions " +
                     "ORDER BY transaction_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                transactions.add(mapTransaction(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return transactions;
    }

    public List<User> searchUsers(String keyword) {
        List<User> users = new ArrayList<>();

        String sql = "SELECT user_id, full_name, email, phone, role " +
                     "FROM users " +
                     "WHERE full_name LIKE ? OR email LIKE ? OR phone LIKE ? OR role LIKE ? " +
                     "ORDER BY user_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String search = "%" + keyword + "%";

            ps.setString(1, search);
            ps.setString(2, search);
            ps.setString(3, search);
            ps.setString(4, search);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                users.add(mapUser(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return users;
    }

    public List<Account> searchAccounts(String keyword) {
        List<Account> accounts = new ArrayList<>();

        String sql = "SELECT account_id, user_id, account_number, account_type, balance, status " +
                     "FROM accounts " +
                     "WHERE account_number LIKE ? OR account_type LIKE ? OR status LIKE ? OR CAST(balance AS CHAR) LIKE ? " +
                     "ORDER BY account_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String search = "%" + keyword + "%";

            ps.setString(1, search);
            ps.setString(2, search);
            ps.setString(3, search);
            ps.setString(4, search);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                accounts.add(mapAccount(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return accounts;
    }

    public List<Transaction> searchTransactions(String keyword) {
        List<Transaction> transactions = new ArrayList<>();

        String sql = "SELECT transaction_id, sender_account, receiver_account, amount, status, transaction_date " +
                     "FROM transactions " +
                     "WHERE sender_account LIKE ? OR receiver_account LIKE ? OR status LIKE ? OR CAST(amount AS CHAR) LIKE ? " +
                     "ORDER BY transaction_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String search = "%" + keyword + "%";

            ps.setString(1, search);
            ps.setString(2, search);
            ps.setString(3, search);
            ps.setString(4, search);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                transactions.add(mapTransaction(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return transactions;
    }

    /**
     * Admin "Add User" page - CUSTOMER role flow.
     *
     * Verifies that the given Customer ID and Account Number both
     * exist AND belong to the same customer (ownership check), then
     * activates online banking for that EXISTING customer with a
     * fresh, auto-generated temporary password. The admin never types
     * or sees a password they chose - it is generated here.
     *
     * This only UPDATEs an existing users row - it never creates a
     * new user, and never touches the accounts table, so it cannot
     * affect the customer account opening flow or existing DB
     * relations.
     */
    public ActivationResult activateOnlineBankingForCustomer(User actor, String customerId, String accountNumber)
            throws SQLException {

        String lookupSql = "SELECT u.user_id, u.full_name, u.email " +
                "FROM users u " +
                "INNER JOIN accounts a ON a.user_id = u.user_id " +
                "WHERE TRIM(u.customer_id) = ? " +
                "  AND TRIM(a.account_number) = ? " +
                "  AND u.role = 'USER' " +
                "LIMIT 1";

        try (Connection con = DBConnection.getConnection()) {

            int userId;
            String fullName;
            String email;

            try (PreparedStatement ps = con.prepareStatement(lookupSql)) {
                ps.setString(1, customerId.trim());
                ps.setString(2, accountNumber.trim());

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return new ActivationResult(false,
                                "No matching customer found for this Customer ID and Account Number. "
                                        + "Please verify both values belong to the same customer.");
                    }

                    userId = rs.getInt("user_id");
                    fullName = rs.getString("full_name");
                    email = rs.getString("email");
                }
            }

            String temporaryPassword = generateTemporaryPassword();

            String updateSql = "UPDATE users SET password = ?, online_banking_enabled = 1 WHERE user_id = ?";

            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setString(1, PasswordUtil.process(temporaryPassword));
                ps.setInt(2, userId);

                int rows = ps.executeUpdate();

                if (rows == 0) {
                    return new ActivationResult(false, "Unable to activate online banking for this customer.");
                }
            }

            logAction(con, actor, "ACTIVATE_ONLINE_BANKING",
                    "Admin activated online banking for Customer ID " + customerId.trim());

            return new ActivationResult(true, "Activation Complete Successfully",
                    fullName, email, customerId.trim(), temporaryPassword);
        }
    }

    /**
     * Admin "Add User" page - ADMIN role flow.
     *
     * Creates a brand-new ADMIN user directly, active and ready to log
     * in immediately with the password the admin entered on the form
     * (role = ADMIN, online_banking_enabled = 1).
     *
     * If customerId is blank, one is auto-generated using the same
     * Customer ID generator the account-opening flows use
     * (UserDAO.generateUniqueCustomerId()), so it stays consistent
     * with, and never collides with, customer Customer IDs.
     */
    public String addAdminUser(User actor, String fullName, String email, String phone,
                                String dob, String address, String password, String customerId)
            throws SQLException {

        String finalCustomerId = customerId;

        if (finalCustomerId == null || finalCustomerId.trim().isEmpty()) {
            try {
                finalCustomerId = new UserDAO().generateUniqueCustomerId();
            } catch (SQLException se) {
                throw se;
            } catch (Exception e) {
                throw new SQLException("Unable to generate a Customer ID for the new admin.", e);
            }
        }

        String sql = "INSERT INTO users " +
                "(customer_id, full_name, dob, address, email, phone, password, role, online_banking_enabled) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, 'ADMIN', 1)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, finalCustomerId.trim());
            ps.setString(2, fullName.trim());

            if (dob != null && !dob.trim().isEmpty()) {
                ps.setDate(3, java.sql.Date.valueOf(dob.trim()));
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }

            ps.setString(4, address == null ? null : address.trim());
            ps.setString(5, email.trim());
            ps.setString(6, phone.trim());
            ps.setString(7, PasswordUtil.process(password));

            int rows = ps.executeUpdate();

            logAction(con, actor, "ADD_ADMIN", "Admin created new ADMIN user: " + email.trim()
                    + " (Customer ID " + finalCustomerId.trim() + ")");

            if (rows == 0) {
                throw new SQLException("Unable to create admin user.");
            }

            return finalCustomerId.trim();
        }
    }

    private String generateTemporaryPassword() {
        int randomDigits = new Random().nextInt(9000) + 1000;
        return "DKS@" + randomDigits;
    }

    public boolean changeAccountStatus(User actor, String accountNumber, String newStatus) throws SQLException {
        String sql = "UPDATE accounts SET status = ? WHERE account_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setString(2, accountNumber);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                logAction(con, actor, "ACCOUNT_STATUS", "Account " + accountNumber + " status changed to " + newStatus);
            }

            return rows > 0;
        }
    }

    public Map<String, Object> findAccount(String accountNumber, String customerId) throws SQLException {
        StringBuilder sql = new StringBuilder();

        sql.append("SELECT a.account_id, a.user_id, u.customer_id, u.full_name, u.email, u.phone, ");
        sql.append("a.account_number, a.account_type, a.balance, a.status, a.created_at ");
        sql.append("FROM accounts a ");
        sql.append("LEFT JOIN users u ON a.user_id = u.user_id ");
        sql.append("WHERE ");

        List<Object> params = new ArrayList<>();

        if (accountNumber != null && !accountNumber.trim().isEmpty()) {
            sql.append("a.account_number = ? ");
            params.add(accountNumber.trim());
        } else {
            // customer_id is the 10-digit VARCHAR customer-facing ID
            // (users.customer_id), not the internal numeric user_id -
            // it must be matched as a string against the joined users
            // table, never parsed as an int.
            sql.append("u.customer_id = ? ");
            params.add(customerId.trim());
        }

        sql.append("ORDER BY a.account_id DESC LIMIT 1");

        List<Map<String, Object>> rows = queryList(sql.toString(), params.toArray());

        return rows.isEmpty() ? null : rows.get(0);
    }

    public boolean addBalance(User actor, String accountNumber, BigDecimal amount, String note) throws SQLException {
        String findSql = "SELECT balance, status FROM accounts WHERE account_number = ? FOR UPDATE";

        String updateSql = "UPDATE accounts SET balance = balance + ? WHERE account_number = ?";

        String txnSql = "INSERT INTO transactions(sender_account, receiver_account, amount, transaction_type, status, transaction_date) " +
                        "VALUES(?,?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                String currentStatus;

                try (PreparedStatement findPs = con.prepareStatement(findSql)) {
                    findPs.setString(1, accountNumber);

                    try (ResultSet rs = findPs.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("Account not found");
                        }

                        currentStatus = rs.getString("status");
                    }
                }

                if ("FROZEN".equalsIgnoreCase(currentStatus)) {
                    throw new SQLException("This account is frozen. Balance cannot be added.");
                }

                try (PreparedStatement updatePs = con.prepareStatement(updateSql)) {
                    updatePs.setBigDecimal(1, amount);
                    updatePs.setString(2, accountNumber);
                    updatePs.executeUpdate();
                }

                try (PreparedStatement txnPs = con.prepareStatement(txnSql)) {
                    txnPs.setString(1, "ADMIN");
                    txnPs.setString(2, accountNumber);
                    txnPs.setBigDecimal(3, amount);
                    txnPs.setString(4, "ADMIN_CREDIT");
                    txnPs.setString(5, "SUCCESS");
                    txnPs.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
                    txnPs.executeUpdate();
                }

                String finalNote = (note == null || note.isBlank()) ? "No note" : note.trim();

                logAction(con, actor, "ADD_BALANCE", "Admin added ₹" + amount + " to account " + accountNumber + ". Note: " + finalNote);

                con.commit();
                return true;

            } catch (Exception e) {
                con.rollback();

                if (e instanceof SQLException) {
                    throw (SQLException) e;
                }

                throw new SQLException(e);

            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public String createAccount(User actor, int userId, String accountType, BigDecimal openingBalance) throws SQLException {
        String checkUserSql = "SELECT user_id FROM users WHERE user_id = ?";

        String insertSql = "INSERT INTO accounts(user_id, account_number, account_type, balance, status) " +
                           "VALUES(?,?,?,?,?)";

        String accountNumber = generateAccountNumber();

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                try (PreparedStatement checkPs = con.prepareStatement(checkUserSql)) {
                    checkPs.setInt(1, userId);

                    try (ResultSet rs = checkPs.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("User ID not found");
                        }
                    }
                }

                try (PreparedStatement insertPs = con.prepareStatement(insertSql)) {
                    insertPs.setInt(1, userId);
                    insertPs.setString(2, accountNumber);
                    insertPs.setString(3, accountType);
                    insertPs.setBigDecimal(4, openingBalance);
                    insertPs.setString(5, "ACTIVE");
                    insertPs.executeUpdate();
                }

                logAction(con, actor, "CREATE_ACCOUNT", "Admin created account " + accountNumber + " for user ID " + userId);

                con.commit();

                return accountNumber;

            } catch (Exception e) {
                con.rollback();

                if (e instanceof SQLException) {
                    throw (SQLException) e;
                }

                throw new SQLException(e);

            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public List<Map<String, Object>> getAuditLogs() throws SQLException {
        String sql = "SELECT log_id, actor_type, actor_identifier, actor_name, action, description, created_at " +
                     "FROM audit_logs ORDER BY log_id DESC";
        return queryList(sql);
    }

    // Kept for any old caller that doesn't have an actor available.
    public void logAction(String action, String description) throws SQLException {
        logAction((User) null, action, description);
    }

    public void logAction(User actor, String action, String description) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            logAction(con, actor, action, description);
        }
    }

    // Kept for internal callers that don't pass an actor.
    private void logAction(Connection con, String action, String description) throws SQLException {
        logAction(con, null, action, description);
    }

    private void logAction(Connection con, User actor, String action, String description) throws SQLException {
        String sql = "INSERT INTO audit_logs(actor_type, actor_user_id, actor_identifier, actor_name, action, description) " +
                     "VALUES (?,?,?,?,?,?)";

        String actorType = "USER";
        Integer actorUserId = null;
        String actorIdentifier = null;
        String actorName = "UNKNOWN";

        if (actor != null) {
            actorType = "ADMIN".equalsIgnoreCase(actor.getRole()) ? "ADMIN" : "USER";
            actorUserId = actor.getUserId();
            actorIdentifier = actor.getCustomerId();
            actorName = actor.getFullName();
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, actorType);

            if (actorUserId != null) {
                ps.setInt(2, actorUserId);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }

            ps.setString(3, actorIdentifier);
            ps.setString(4, actorName);
            ps.setString(5, action);
            ps.setString(6, description);
            ps.executeUpdate();
        }
    }

    private List<Map<String, Object>> queryList(String sql, Object... params) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            for (int i = 0; params != null && i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                int columnCount = meta.getColumnCount();

                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    for (int i = 1; i <= columnCount; i++) {
                        row.put(meta.getColumnLabel(i), rs.getObject(i));
                    }

                    list.add(row);
                }
            }
        }

        return list;
    }

    private String generateAccountNumber() {
        int random = new Random().nextInt(900) + 100;
        return "ACC" + System.currentTimeMillis() + random;
    }

    private User mapUser(ResultSet rs) throws Exception {
        User user = new User();

        user.setUserId(rs.getInt("user_id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setRole(rs.getString("role"));

        return user;
    }

    private Account mapAccount(ResultSet rs) throws Exception {
        Account account = new Account();

        account.setAccountId(rs.getInt("account_id"));
        account.setUserId(rs.getInt("user_id"));
        account.setAccountNumber(rs.getString("account_number"));
        account.setAccountType(rs.getString("account_type"));
        account.setBalance(rs.getDouble("balance"));
        account.setStatus(rs.getString("status"));

        return account;
    }

    private Transaction mapTransaction(ResultSet rs) throws Exception {
        Transaction transaction = new Transaction();

        transaction.setTransactionId(rs.getInt("transaction_id"));
        transaction.setSenderAccount(rs.getString("sender_account"));
        transaction.setReceiverAccount(rs.getString("receiver_account"));
        transaction.setAmount(rs.getDouble("amount"));
        transaction.setStatus(rs.getString("status"));
        transaction.setTransactionDate(rs.getTimestamp("transaction_date"));

        return transaction;
    }
}