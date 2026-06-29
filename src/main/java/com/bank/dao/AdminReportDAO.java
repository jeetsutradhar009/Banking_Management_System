package com.bank.dao;

import com.bank.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminReportDAO {

    public int getTotalUsers() {
        return getIntValue("SELECT COUNT(*) FROM users WHERE role = 'USER'");
    }

    public int getTotalAdmins() {
        return getIntValue("SELECT COUNT(*) FROM users WHERE role = 'ADMIN'");
    }

    public int getTotalAccounts() {
        return getIntValue("SELECT COUNT(*) FROM accounts");
    }

    public int getTotalTransactions() {
        return getIntValue("SELECT COUNT(*) FROM transactions");
    }

    public int getTodayTransactions() {
        return getIntValue("""
                SELECT COUNT(*)
                FROM transactions
                WHERE DATE(transaction_date) = CURDATE()
                """);
    }

    public int getSuccessfulTransactions() {
        return getIntValue("""
                SELECT COUNT(*)
                FROM transactions
                WHERE LOWER(status) = 'success'
                """);
    }

    public int getFailedTransactions() {
        return getIntValue("""
                SELECT COUNT(*)
                FROM transactions
                WHERE LOWER(status) <> 'success'
                """);
    }

    public double getTotalBankBalance() {
        return getDoubleValue("""
                SELECT COALESCE(SUM(balance), 0)
                FROM accounts
                """);
    }

    public double getTotalTransactionAmount() {
        return getDoubleValue("""
                SELECT COALESCE(SUM(amount), 0)
                FROM transactions
                """);
    }

    public double getTodayTransactionAmount() {
        return getDoubleValue("""
                SELECT COALESCE(SUM(amount), 0)
                FROM transactions
                WHERE DATE(transaction_date) = CURDATE()
                """);
    }

    public List<Map<String, Object>> getMonthlyTransactions() {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT DATE_FORMAT(transaction_date, '%b %Y') AS label,
                       COUNT(*) AS txn_count,
                       COALESCE(SUM(amount), 0) AS total_amount
                FROM transactions
                WHERE transaction_date >= DATE_SUB(CURDATE(), INTERVAL 5 MONTH)
                GROUP BY YEAR(transaction_date), MONTH(transaction_date), DATE_FORMAT(transaction_date, '%b %Y')
                ORDER BY YEAR(transaction_date), MONTH(transaction_date)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("label", rs.getString("label"));
                row.put("count", rs.getInt("txn_count"));
                row.put("amount", rs.getDouble("total_amount"));
                list.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getAccountTypeDistribution() {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT COALESCE(account_type, 'UNKNOWN') AS label,
                       COUNT(*) AS total
                FROM accounts
                GROUP BY COALESCE(account_type, 'UNKNOWN')
                ORDER BY total DESC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("label", rs.getString("label"));
                row.put("count", rs.getInt("total"));
                list.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getUserRoleDistribution() {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT role AS label,
                       COUNT(*) AS total
                FROM users
                GROUP BY role
                ORDER BY total DESC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("label", rs.getString("label"));
                row.put("count", rs.getInt("total"));
                list.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getTransactionStatusDistribution() {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT COALESCE(status, 'Unknown') AS label,
                       COUNT(*) AS total
                FROM transactions
                GROUP BY COALESCE(status, 'Unknown')
                ORDER BY total DESC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("label", rs.getString("label"));
                row.put("count", rs.getInt("total"));
                list.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getTopAccountsByBalance() {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT a.account_number,
                       a.account_type,
                       a.balance,
                       u.full_name,
                       u.customer_id
                FROM accounts a
                LEFT JOIN users u ON a.user_id = u.user_id
                ORDER BY a.balance DESC
                LIMIT 5
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("accountNumber", rs.getString("account_number"));
                row.put("accountType", rs.getString("account_type"));
                row.put("balance", rs.getDouble("balance"));
                row.put("fullName", rs.getString("full_name"));
                row.put("customerId", rs.getString("customer_id"));
                list.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getRecentTransactions() {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT t.transaction_id,
                       t.sender_account,
                       t.receiver_account,
                       t.amount,
                       t.transaction_type,
                       t.status,
                       t.transaction_date,
                       sender.full_name AS sender_name,
                       receiver.full_name AS receiver_name
                FROM transactions t
                LEFT JOIN accounts sa ON t.sender_account = sa.account_number
                LEFT JOIN users sender ON sa.user_id = sender.user_id
                LEFT JOIN accounts ra ON t.receiver_account = ra.account_number
                LEFT JOIN users receiver ON ra.user_id = receiver.user_id
                ORDER BY t.transaction_date DESC
                LIMIT 8
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("transactionId", rs.getInt("transaction_id"));
                row.put("senderAccount", rs.getString("sender_account"));
                row.put("receiverAccount", rs.getString("receiver_account"));
                row.put("senderName", rs.getString("sender_name"));
                row.put("receiverName", rs.getString("receiver_name"));
                row.put("amount", rs.getDouble("amount"));
                row.put("transactionType", rs.getString("transaction_type"));
                row.put("status", rs.getString("status"));
                row.put("transactionDate", rs.getTimestamp("transaction_date"));
                list.add(row);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private int getIntValue(String sql) {
        int value = 0;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                value = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return value;
    }

    private double getDoubleValue(String sql) {
        double value = 0;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                value = rs.getDouble(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return value;
    }
}