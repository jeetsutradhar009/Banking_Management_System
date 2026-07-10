package com.bank.util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DBConnection {

    private static final String DB_NAME = "online_banking";

    private static final String SERVER_URL =
            "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/?sslMode=VERIFY_IDENTITY";

    private static final String DB_URL =
             "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/" + DB_NAME + "?sslMode=VERIFY_IDENTITY";

    private static final String USERNAME = "2nsWXALPeaXhVt8.root";
    private static final String PASSWORD = System.getenv("TIDB_PASSWORD");

    public static Connection getConnection() {
        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(DB_URL, USERNAME, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return con;
    }

    public static void createDatabaseAndTables() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection serverCon = DriverManager.getConnection(SERVER_URL, USERNAME, PASSWORD);
            Statement serverStmt = serverCon.createStatement();

            serverStmt.executeUpdate("CREATE DATABASE IF NOT EXISTS " + DB_NAME);

            serverStmt.close();
            serverCon.close();

            Connection con = getConnection();
            Statement stmt = con.createStatement();

            String usersTable = """
                    CREATE TABLE IF NOT EXISTS users (
                        user_id INT AUTO_INCREMENT PRIMARY KEY,
                        customer_id VARCHAR(10) UNIQUE,
                        first_name VARCHAR(100),
                        last_name VARCHAR(100),
                        full_name VARCHAR(150) NOT NULL,
                        dob DATE,
                        address VARCHAR(500),
                        email VARCHAR(100) UNIQUE NOT NULL,
                        phone VARCHAR(20),
                        password VARCHAR(255) NULL,
                        role ENUM('USER', 'ADMIN') DEFAULT 'USER',
                        online_banking_enabled TINYINT(1) DEFAULT 0,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                    """;

            String accountsTable = """
                    CREATE TABLE IF NOT EXISTS accounts (
                        account_id INT AUTO_INCREMENT PRIMARY KEY,
                        user_id INT NOT NULL,
                        account_number VARCHAR(30) UNIQUE NOT NULL,
                        ifsc_code VARCHAR(20) DEFAULT 'DKSB0001886',
                        account_type VARCHAR(50) DEFAULT 'SAVINGS',
                        balance DECIMAL(15, 2) DEFAULT 0.00,
                        status VARCHAR(20) DEFAULT 'ACTIVE',
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (user_id) REFERENCES users(user_id)
                    )
                    """;

            String transactionsTable = """
                    CREATE TABLE IF NOT EXISTS transactions (
                        transaction_id INT AUTO_INCREMENT PRIMARY KEY,
                        sender_account VARCHAR(30),
                        receiver_account VARCHAR(30),
                        amount DECIMAL(15, 2) NOT NULL,
                        transaction_type VARCHAR(50),
                        status VARCHAR(50) DEFAULT 'Success',
                        transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                    """;

            String auditLogsTable = """
                    CREATE TABLE IF NOT EXISTS audit_logs (
                        log_id INT AUTO_INCREMENT PRIMARY KEY,
                        action VARCHAR(100) NOT NULL,
                        description VARCHAR(500),
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                    """;

            stmt.executeUpdate(usersTable);
            stmt.executeUpdate(accountsTable);
            stmt.executeUpdate(transactionsTable);
            stmt.executeUpdate(auditLogsTable);

            migrateUsersTable(con, stmt);
            migrateAccountsTable(con, stmt);
            migrateAuditLogsTable(con, stmt);

            String adminInsert = """
                    INSERT IGNORE INTO users
                    (customer_id, first_name, last_name, full_name, dob, address, email, phone, password, role, online_banking_enabled)
                    VALUES
                    ('9999999999', 'Dipankar', 'Admin', 'Dipankar Admin', '2000-01-01', 'DKS Bank Admin Office',
                     'admin@bank.com', '6208456135', 'admin123', 'ADMIN', 1)
                    """;

            stmt.executeUpdate(adminInsert);

            String adminUpdate = """
                    UPDATE users
                    SET customer_id = '9999999999',
                        first_name = 'Dipankar',
                        last_name = 'Admin',
                        full_name = 'Dipankar Admin',
                        dob = '2000-01-01',
                        address = 'DKS Bank Admin Office',
                        email = 'admin@bank.com',
                        phone = '6208456135',
                        password = 'admin123',
                        role = 'ADMIN',
                        online_banking_enabled = 1
                    WHERE email = 'admin@bank.com'
                       OR customer_id = '9999999999'
                    """;

            stmt.executeUpdate(adminUpdate);

            stmt.close();
            con.close();

            System.out.println("Database, tables and migration completed successfully.");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void migrateUsersTable(Connection con, Statement stmt) {
        try {
            addColumnIfMissing(con, stmt, "users", "customer_id",
                    "customer_id VARCHAR(10) UNIQUE AFTER user_id");

            addColumnIfMissing(con, stmt, "users", "first_name",
                    "first_name VARCHAR(100) AFTER customer_id");

            addColumnIfMissing(con, stmt, "users", "last_name",
                    "last_name VARCHAR(100) AFTER first_name");

            addColumnIfMissing(con, stmt, "users", "dob",
                    "dob DATE AFTER full_name");

            addColumnIfMissing(con, stmt, "users", "address",
                    "address VARCHAR(500) AFTER dob");

            addColumnIfMissing(con, stmt, "users", "online_banking_enabled",
                    "online_banking_enabled TINYINT(1) DEFAULT 0 AFTER role");

            stmt.executeUpdate("ALTER TABLE users MODIFY password VARCHAR(255) NULL");

            stmt.executeUpdate("""
                    UPDATE users
                    SET first_name = SUBSTRING_INDEX(full_name, ' ', 1)
                    WHERE first_name IS NULL
                    """);

            stmt.executeUpdate("""
                    UPDATE users
                    SET last_name = ''
                    WHERE last_name IS NULL
                    """);

            stmt.executeUpdate("""
                    UPDATE users
                    SET online_banking_enabled = 1
                    WHERE password IS NOT NULL AND password <> ''
                    """);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void migrateAccountsTable(Connection con, Statement stmt) {
        try {
            addColumnIfMissing(con, stmt, "accounts", "ifsc_code",
                    "ifsc_code VARCHAR(20) DEFAULT 'DKSB0001886' AFTER account_number");

            addColumnIfMissing(con, stmt, "accounts", "status",
                    "status VARCHAR(20) DEFAULT 'ACTIVE' AFTER balance");

            stmt.executeUpdate("ALTER TABLE accounts MODIFY account_number VARCHAR(30) NOT NULL");

            stmt.executeUpdate("""
                    UPDATE accounts
                    SET ifsc_code = 'DKSB0001886'
                    WHERE ifsc_code IS NULL OR ifsc_code = ''
                    """);

            stmt.executeUpdate("""
                    UPDATE accounts
                    SET status = 'ACTIVE'
                    WHERE status IS NULL OR status = ''
                    """);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void migrateAuditLogsTable(Connection con, Statement stmt) {
        try {
            String auditLogsTable = """
                    CREATE TABLE IF NOT EXISTS audit_logs (
                        log_id INT AUTO_INCREMENT PRIMARY KEY,
                        action VARCHAR(100) NOT NULL,
                        description VARCHAR(500),
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                    """;

            stmt.executeUpdate(auditLogsTable);

            addColumnIfMissing(con, stmt, "audit_logs", "action",
                    "action VARCHAR(100) NOT NULL AFTER log_id");

            addColumnIfMissing(con, stmt, "audit_logs", "description",
                    "description VARCHAR(500) AFTER action");

            addColumnIfMissing(con, stmt, "audit_logs", "created_at",
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER description");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void addColumnIfMissing(Connection con,
                                           Statement stmt,
                                           String tableName,
                                           String columnName,
                                           String columnDefinition) {
        try {
            if (!columnExists(con, tableName, columnName)) {
                stmt.executeUpdate("ALTER TABLE " + tableName + " ADD COLUMN " + columnDefinition);
                System.out.println("Column added: " + tableName + "." + columnName);
            }
        } catch (Exception e) {
            System.out.println("Column migration skipped/failed: " + tableName + "." + columnName);
            e.printStackTrace();
        }
    }

    private static boolean columnExists(Connection con, String tableName, String columnName) {
        boolean exists = false;

        try {
            DatabaseMetaData metaData = con.getMetaData();

            try (ResultSet rs = metaData.getColumns(con.getCatalog(), null, tableName, columnName)) {
                exists = rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return exists;
    }

    public static void main(String[] args) {
        createDatabaseAndTables();
    }
}
