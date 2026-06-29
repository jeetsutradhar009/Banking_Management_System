package com.bank.dao;

import com.bank.model.Account;
import com.bank.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class AccountDAO {

    public Account getAccountByUserId(int userId) {
        Account account = null;

        String sql = "SELECT account_id, user_id, account_number, account_type, balance, status " +
                     "FROM accounts " +
                     "WHERE user_id = ? " +
                     "ORDER BY account_id DESC " +
                     "LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    account = mapAccount(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return account;
    }

    public List<Account> getAccountsByUserId(int userId) {
        List<Account> accounts = new ArrayList<>();

        String sql = "SELECT account_id, user_id, account_number, account_type, balance, status " +
                     "FROM accounts " +
                     "WHERE user_id = ? " +
                     "ORDER BY account_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    accounts.add(mapAccount(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return accounts;
    }

    public Account getAccountByAccountNumber(String accountNumber) {
        Account account = null;

        String sql = "SELECT account_id, user_id, account_number, account_type, balance, status " +
                     "FROM accounts " +
                     "WHERE account_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    account = mapAccount(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return account;
    }

    public Account getAccountByNumber(String accountNumber) {
        return getAccountByAccountNumber(accountNumber);
    }

    public Account getAccountById(int accountId) {
        Account account = null;

        String sql = "SELECT account_id, user_id, account_number, account_type, balance, status " +
                     "FROM accounts " +
                     "WHERE account_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, accountId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    account = mapAccount(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return account;
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

    public String getAccountHolderNameByAccountNumber(String accountNumber) {
        String holderName = null;

        String sql = "SELECT u.full_name " +
                     "FROM accounts a " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "WHERE a.account_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    holderName = rs.getString("full_name");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return holderName;
    }

    public boolean createAccount(int userId, String accountType, double openingBalance) {
        String accountNumber = generateAccountNumber();

        String sql = "INSERT INTO accounts(user_id, account_number, account_type, balance, status) " +
                     "VALUES(?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, accountNumber);
            ps.setString(3, accountType);
            ps.setDouble(4, openingBalance);
            ps.setString(5, "ACTIVE");

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean createAccount(Account account) {
        String sql = "INSERT INTO accounts(user_id, account_number, account_type, balance, status) " +
                     "VALUES(?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String accountNumber = account.getAccountNumber();

            if (accountNumber == null || accountNumber.isBlank()) {
                accountNumber = generateAccountNumber();
            }

            String status = account.getStatus();

            if (status == null || status.isBlank()) {
                status = "ACTIVE";
            }

            ps.setInt(1, account.getUserId());
            ps.setString(2, accountNumber);
            ps.setString(3, account.getAccountType());
            ps.setDouble(4, account.getBalance());
            ps.setString(5, status);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateBalance(String accountNumber, double newBalance) {
        String sql = "UPDATE accounts SET balance = ? WHERE account_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, newBalance);
            ps.setString(2, accountNumber);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean addBalance(String accountNumber, double amount) {
        String sql = "UPDATE accounts SET balance = balance + ? WHERE account_number = ? AND status = 'ACTIVE'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, amount);
            ps.setString(2, accountNumber);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean addBalance(String accountNumber, BigDecimal amount) {
        String sql = "UPDATE accounts SET balance = balance + ? WHERE account_number = ? AND status = 'ACTIVE'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setBigDecimal(1, amount);
            ps.setString(2, accountNumber);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deductBalance(String accountNumber, double amount) {
        String sql = "UPDATE accounts " +
                     "SET balance = balance - ? " +
                     "WHERE account_number = ? AND balance >= ? AND status = 'ACTIVE'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, amount);
            ps.setString(2, accountNumber);
            ps.setDouble(3, amount);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deductBalance(String accountNumber, BigDecimal amount) {
        String sql = "UPDATE accounts " +
                     "SET balance = balance - ? " +
                     "WHERE account_number = ? AND balance >= ? AND status = 'ACTIVE'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setBigDecimal(1, amount);
            ps.setString(2, accountNumber);
            ps.setBigDecimal(3, amount);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean transferAmount(String senderAccount, String receiverAccount, double amount) {
        String senderSql = "UPDATE accounts " +
                           "SET balance = balance - ? " +
                           "WHERE account_number = ? AND balance >= ? AND status = 'ACTIVE'";

        String receiverSql = "UPDATE accounts " +
                             "SET balance = balance + ? " +
                             "WHERE account_number = ? AND status = 'ACTIVE'";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try (PreparedStatement senderPs = con.prepareStatement(senderSql);
                 PreparedStatement receiverPs = con.prepareStatement(receiverSql)) {

                senderPs.setDouble(1, amount);
                senderPs.setString(2, senderAccount);
                senderPs.setDouble(3, amount);

                int senderRows = senderPs.executeUpdate();

                if (senderRows == 0) {
                    con.rollback();
                    return false;
                }

                receiverPs.setDouble(1, amount);
                receiverPs.setString(2, receiverAccount);

                int receiverRows = receiverPs.executeUpdate();

                if (receiverRows == 0) {
                    con.rollback();
                    return false;
                }

                con.commit();
                return true;

            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
            } finally {
                con.setAutoCommit(true);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean transferAmount(String senderAccount, String receiverAccount, BigDecimal amount) {
        String senderSql = "UPDATE accounts " +
                           "SET balance = balance - ? " +
                           "WHERE account_number = ? AND balance >= ? AND status = 'ACTIVE'";

        String receiverSql = "UPDATE accounts " +
                             "SET balance = balance + ? " +
                             "WHERE account_number = ? AND status = 'ACTIVE'";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try (PreparedStatement senderPs = con.prepareStatement(senderSql);
                 PreparedStatement receiverPs = con.prepareStatement(receiverSql)) {

                senderPs.setBigDecimal(1, amount);
                senderPs.setString(2, senderAccount);
                senderPs.setBigDecimal(3, amount);

                int senderRows = senderPs.executeUpdate();

                if (senderRows == 0) {
                    con.rollback();
                    return false;
                }

                receiverPs.setBigDecimal(1, amount);
                receiverPs.setString(2, receiverAccount);

                int receiverRows = receiverPs.executeUpdate();

                if (receiverRows == 0) {
                    con.rollback();
                    return false;
                }

                con.commit();
                return true;

            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
            } finally {
                con.setAutoCommit(true);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean isAccountExists(String accountNumber) {
        String sql = "SELECT account_id FROM accounts WHERE account_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean isAccountActive(String accountNumber) {
        String sql = "SELECT status FROM accounts WHERE account_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    return "ACTIVE".equalsIgnoreCase(status);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean changeAccountStatus(String accountNumber, String status) {
        String sql = "UPDATE accounts SET status = ? WHERE account_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, accountNumber);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<Account> searchAccounts(String keyword) {
        List<Account> accounts = new ArrayList<>();

        String sql = "SELECT account_id, user_id, account_number, account_type, balance, status " +
                     "FROM accounts " +
                     "WHERE account_number LIKE ? " +
                     "OR account_type LIKE ? " +
                     "OR status LIKE ? " +
                     "OR CAST(balance AS CHAR) LIKE ? " +
                     "ORDER BY account_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String search = "%" + keyword + "%";

            ps.setString(1, search);
            ps.setString(2, search);
            ps.setString(3, search);
            ps.setString(4, search);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    accounts.add(mapAccount(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return accounts;
    }

    public double getBalance(String accountNumber) {
        String sql = "SELECT balance FROM accounts WHERE account_number = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("balance");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0.0;
    }

    public String generateAccountNumber() {
        int random = new Random().nextInt(900) + 100;
        return "ACC" + System.currentTimeMillis() + random;
    }

    private Account mapAccount(ResultSet rs) throws Exception {
        Account account = new Account();

        account.setAccountId(rs.getInt("account_id"));
        account.setUserId(rs.getInt("user_id"));
        account.setAccountNumber(rs.getString("account_number"));
        account.setAccountType(rs.getString("account_type"));
        account.setBalance(rs.getDouble("balance"));

        try {
            account.setStatus(rs.getString("status"));
        } catch (Exception e) {
            account.setStatus("ACTIVE");
        }

        return account;
    }
}