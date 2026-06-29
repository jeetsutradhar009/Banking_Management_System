package com.bank.dao;

import com.bank.model.Transaction;
import com.bank.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    public boolean transferMoney(String senderAccount, String receiverAccount, double amount) {

        boolean status = false;

        String debitSql = "UPDATE accounts SET balance = balance - ? WHERE account_number = ? AND balance >= ?";
        String creditSql = "UPDATE accounts SET balance = balance + ? WHERE account_number = ?";
        String transactionSql = "INSERT INTO transactions(sender_account, receiver_account, amount, transaction_type, status) VALUES (?, ?, ?, ?, ?)";

        Connection con = null;

        try {
            con = DBConnection.getConnection();

            if (con == null) {
                System.out.println("Database connection failed.");
                return false;
            }

            con.setAutoCommit(false);

            try (PreparedStatement debitPs = con.prepareStatement(debitSql)) {
                debitPs.setDouble(1, amount);
                debitPs.setString(2, senderAccount);
                debitPs.setDouble(3, amount);

                int debitRows = debitPs.executeUpdate();

                if (debitRows <= 0) {
                    con.rollback();
                    System.out.println("Debit failed. Insufficient balance or sender account not found.");
                    return false;
                }
            }

            try (PreparedStatement creditPs = con.prepareStatement(creditSql)) {
                creditPs.setDouble(1, amount);
                creditPs.setString(2, receiverAccount);

                int creditRows = creditPs.executeUpdate();

                if (creditRows <= 0) {
                    con.rollback();
                    System.out.println("Credit failed. Receiver account not found.");
                    return false;
                }
            }

            try (PreparedStatement txPs = con.prepareStatement(transactionSql)) {
                txPs.setString(1, senderAccount);
                txPs.setString(2, receiverAccount);
                txPs.setDouble(3, amount);
                txPs.setString(4, "Transfer");
                txPs.setString(5, "Success");

                int txRows = txPs.executeUpdate();

                if (txRows <= 0) {
                    con.rollback();
                    System.out.println("Transaction save failed.");
                    return false;
                }
            }

            con.commit();
            status = true;

            System.out.println("Money transferred successfully.");

        } catch (Exception e) {

            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception rollbackException) {
                rollbackException.printStackTrace();
            }

            e.printStackTrace();

        } finally {

            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception closeException) {
                closeException.printStackTrace();
            }
        }

        return status;
    }

    public List<Transaction> getUserTransactions(String accountNumber) {

        List<Transaction> list = new ArrayList<>();

        String sql =
                "SELECT t.*, " +
                "su.full_name AS sender_name, " +
                "ru.full_name AS receiver_name " +
                "FROM transactions t " +
                "LEFT JOIN accounts sa ON t.sender_account = sa.account_number " +
                "LEFT JOIN users su ON sa.user_id = su.user_id " +
                "LEFT JOIN accounts ra ON t.receiver_account = ra.account_number " +
                "LEFT JOIN users ru ON ra.user_id = ru.user_id " +
                "WHERE t.sender_account = ? OR t.receiver_account = ? " +
                "ORDER BY t.transaction_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);
            ps.setString(2, accountNumber);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Transaction tx = new Transaction();

                    tx.setTransactionId(rs.getInt("transaction_id"));
                    tx.setSenderAccount(rs.getString("sender_account"));
                    tx.setReceiverAccount(rs.getString("receiver_account"));
                    tx.setAmount(rs.getDouble("amount"));
                    tx.setTransactionType(rs.getString("transaction_type"));
                    tx.setStatus(rs.getString("status"));
                    tx.setTransactionDate(rs.getTimestamp("transaction_date"));

                    tx.setSenderName(rs.getString("sender_name"));
                    tx.setReceiverName(rs.getString("receiver_name"));

                    list.add(tx);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Transaction> getMiniStatement(String accountNumber) {

        List<Transaction> list = new ArrayList<>();

        String sql =
                "SELECT t.*, " +
                "su.full_name AS sender_name, " +
                "ru.full_name AS receiver_name " +
                "FROM transactions t " +
                "LEFT JOIN accounts sa ON t.sender_account = sa.account_number " +
                "LEFT JOIN users su ON sa.user_id = su.user_id " +
                "LEFT JOIN accounts ra ON t.receiver_account = ra.account_number " +
                "LEFT JOIN users ru ON ra.user_id = ru.user_id " +
                "WHERE t.sender_account = ? OR t.receiver_account = ? " +
                "ORDER BY t.transaction_date DESC LIMIT 10";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);
            ps.setString(2, accountNumber);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Transaction tx = new Transaction();

                    tx.setTransactionId(rs.getInt("transaction_id"));
                    tx.setSenderAccount(rs.getString("sender_account"));
                    tx.setReceiverAccount(rs.getString("receiver_account"));
                    tx.setAmount(rs.getDouble("amount"));
                    tx.setTransactionType(rs.getString("transaction_type"));
                    tx.setStatus(rs.getString("status"));
                    tx.setTransactionDate(rs.getTimestamp("transaction_date"));

                    tx.setSenderName(rs.getString("sender_name"));
                    tx.setReceiverName(rs.getString("receiver_name"));

                    list.add(tx);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}