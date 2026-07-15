package com.bank.dao;

import com.bank.model.Account;
import com.bank.model.Transaction;
import com.bank.model.User;
import com.bank.util.DBConnection;

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

    public boolean addUser(User actor, String fullName, String email, String phone, String password, String role) throws SQLException {
        String sql = "INSERT INTO users(full_name, email, phone, password, role) VALUES(?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, password);
            ps.setString(5, role);

            int rows = ps.executeUpdate();

            logAction(con, actor, "ADD_USER", "Admin added new user: " + email);

            return rows > 0;
        }
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

    public Map<String, Object> findAccount(String accountNumber, String userId) throws SQLException {
        StringBuilder sql = new StringBuilder();

        sql.append("SELECT a.account_id, a.user_id, u.full_name, u.email, u.phone, ");
        sql.append("a.account_number, a.account_type, a.balance, a.status, a.created_at ");
        sql.append("FROM accounts a ");
        sql.append("LEFT JOIN users u ON a.user_id = u.user_id ");
        sql.append("WHERE ");

        List<Object> params = new ArrayList<>();

        if (accountNumber != null && !accountNumber.trim().isEmpty()) {
            sql.append("a.account_number = ? ");
            params.add(accountNumber.trim());
        } else {
            sql.append("a.user_id = ? ");
            params.add(Integer.parseInt(userId.trim()));
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
