package com.bank.setup;

import com.bank.util.DBConnection;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Scanner;

/**
 * DatabaseSetup
 *
 * One-time project setup utility. Run this class's main() method
 * exactly once when standing up a new environment (local, TiDB
 * Cloud, or any other MySQL-compatible target).
 *
 * Responsibilities (all moved out of DBConnection):
 *   - Create the database if it does not exist
 *   - Create all tables if they do not exist
 *   - Run schema migrations (add missing columns, backfill data)
 *   - Interactively seed the first ADMIN user, only if none exists
 *
 * After running this once, the rest of the application (Registration,
 * Login, New Account, Deposit, Withdraw, Transfer, etc.) should use
 * ONLY {@link DBConnection#getConnection()} and must never execute
 * any setup/migration code.
 *
 * Connection details are read from the same environment variables as
 * DBConnection (DB_URL, DB_USERNAME, TIDB_PASSWORD). The database
 * name and a "server-level" URL (without the database name, used to
 * issue CREATE DATABASE) are derived from DB_URL so there is no
 * duplicated / hardcoded connection information.
 */
public class DatabaseSetup {

	private static final String DB_URL =
	        System.getenv("DB_URL") != null
	        ? System.getenv("DB_URL")
	        : "jdbc:mysql://localhost:3306/dks_banking";

	private static final String USERNAME =
	        System.getenv("DB_USERNAME") != null
	        ? System.getenv("DB_USERNAME")
	        : "root";

	private static final String PASSWORD =
	        System.getenv("DB_PASSWORD") != null
	        ? System.getenv("DB_PASSWORD")
	        : "";


    // Fixed customer ID reserved for the single seeded admin account.
    private static final String ADMIN_CUSTOMER_ID = "9999999999";

    public static void main(String[] args) {
        createDatabaseAndTables();
        initializeAdminIfMissing();
    }

    // ------------------------------------------------------------------
    // Database / table creation
    // ------------------------------------------------------------------

    /**
     * Creates the database (if missing), creates all tables (if
     * missing), and runs every migration. Safe to run repeatedly.
     */
    public static void createDatabaseAndTables() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            String dbName = extractDbName(DB_URL);
            String serverUrl = buildServerUrl(DB_URL);

            // Create the database itself using a server-level connection
            // (one that does not reference the database in its path yet).
            Connection serverCon = DriverManager.getConnection(serverUrl, USERNAME, PASSWORD);
            Statement serverStmt = serverCon.createStatement();

            serverStmt.executeUpdate("CREATE DATABASE IF NOT EXISTS " + dbName);

            serverStmt.close();
            serverCon.close();

            // Now connect to the actual database to create tables / migrate.
            Connection con = DBConnection.getConnection();
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

            // Backs the customer self-service "Open Account" UPI payment
            // simulation ONLY (com.bank.controller.payment). Beyond the
            // core payment fields, this also snapshots the pending
            // registration (first/last name, dob, address, email, phone,
            // account type) so the account can be created from any
            // device once payment succeeds - e.g. the demo QR code being
            // scanned on a phone, in a different browser session than
            // the one that filled the account-opening form.
            String paymentsTable = """
                    CREATE TABLE IF NOT EXISTS payments (
                        payment_id INT AUTO_INCREMENT PRIMARY KEY,
                        request_id VARCHAR(36) UNIQUE NOT NULL,
                        payment_method VARCHAR(30),
                        amount DECIMAL(15, 2) NOT NULL,
                        transaction_reference VARCHAR(50),
                        status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                        first_name VARCHAR(100),
                        last_name VARCHAR(100),
                        dob DATE,
                        address VARCHAR(500),
                        email VARCHAR(100),
                        phone VARCHAR(20),
                        account_type VARCHAR(50),
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                    """;

            stmt.executeUpdate(usersTable);
            stmt.executeUpdate(accountsTable);
            stmt.executeUpdate(transactionsTable);
            stmt.executeUpdate(auditLogsTable);
            stmt.executeUpdate(paymentsTable);

            migrateUsersTable(con, stmt);
            migrateAccountsTable(con, stmt);
            migrateAuditLogsTable(con, stmt);

            stmt.close();
            con.close();

            System.out.println("Database, tables and migration completed successfully.");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ------------------------------------------------------------------
    // Migrations (unchanged logic, moved as-is from DBConnection)
    // ------------------------------------------------------------------

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

            addColumnIfMissing(con, stmt, "audit_logs", "actor_type",
                    "actor_type VARCHAR(10) NOT NULL DEFAULT 'USER' AFTER log_id");

            addColumnIfMissing(con, stmt, "audit_logs", "actor_user_id",
                    "actor_user_id INT NULL AFTER actor_type");

            addColumnIfMissing(con, stmt, "audit_logs", "actor_identifier",
                    "actor_identifier VARCHAR(150) NULL AFTER actor_user_id");

            addColumnIfMissing(con, stmt, "audit_logs", "actor_name",
                    "actor_name VARCHAR(150) NULL AFTER actor_identifier");

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

    // ------------------------------------------------------------------
    // Interactive admin seeding
    // ------------------------------------------------------------------

    /**
     * If no ADMIN user exists yet, prompts the operator in the
     * terminal for the admin's identity and inserts exactly one
     * ADMIN user. If an admin already exists, this is a no-op.
     */
    public static void initializeAdminIfMissing() {
        try (Connection con = DBConnection.getConnection()) {

            if (con == null) {
                System.out.println("Could not connect to the database - admin setup skipped.");
                return;
            }

            if (adminExists(con)) {
                System.out.println("Admin already exists - skipping admin setup.");
                return;
            }

            promptAndCreateAdmin(con);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Checks whether any user with role = 'ADMIN' already exists.
     */
    private static boolean adminExists(Connection con) throws Exception {
        String checkAdminSql = "SELECT COUNT(*) FROM users WHERE role = 'ADMIN'";

        try (Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(checkAdminSql)) {

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }

        return false;
    }

    /**
     * Collects admin details from the terminal and inserts the
     * seeded admin row via a parameterized PreparedStatement.
     */
    private static void promptAndCreateAdmin(Connection con) throws Exception {
        Scanner scanner = new Scanner(System.in);

        System.out.println("No admin account found. Let's create one now.");

        System.out.print("First Name: ");
        String firstName = scanner.nextLine().trim();

        System.out.print("Last Name: ");
        String lastName = scanner.nextLine().trim();

        System.out.print("Phone Number: ");
        String phone = scanner.nextLine().trim();

        System.out.print("Email: ");
        String email = scanner.nextLine().trim();

        System.out.print("Password: ");
        String password = scanner.nextLine().trim();

        String fullName = firstName + " " + lastName;

        insertAdmin(con, firstName, lastName, fullName, phone, email, password);

        System.out.println("Admin account created successfully for " + email);
    }

    /**
     * Inserts the admin row using a PreparedStatement.
     *
     * customer_id, role, and online_banking_enabled are fixed:
     *   customer_id             = 9999999999
     *   role                    = ADMIN
     *   online_banking_enabled  = 1
     *
     * dob and address are not collected interactively, so they are
     * left NULL (both columns are nullable in the schema).
     */
    private static void insertAdmin(Connection con,
                                     String firstName,
                                     String lastName,
                                     String fullName,
                                     String phone,
                                     String email,
                                     String password) throws Exception {

        String insertAdminSql = """
                INSERT INTO users
                (customer_id, first_name, last_name, full_name, dob, address, email, phone, password, role, online_banking_enabled)
                VALUES
                (?, ?, ?, ?, NULL, 'DKS bank admin office', ?, ?, ?, 'ADMIN', 1)
                """;

        try (PreparedStatement ps = con.prepareStatement(insertAdminSql)) {
            ps.setString(1, ADMIN_CUSTOMER_ID);
            ps.setString(2, firstName);
            ps.setString(3, lastName);
            ps.setString(4, fullName);
            ps.setString(5, email);
            ps.setString(6, phone);
            ps.setString(7, password);

            ps.executeUpdate();
        }
    }

    // ------------------------------------------------------------------
    // URL parsing helpers
    // ------------------------------------------------------------------

    /**
     * Extracts the database name from a JDBC URL such as:
     *   jdbc:mysql://host:4000/online_banking?sslMode=VERIFY_IDENTITY
     * -> "online_banking"
     */
    private static String extractDbName(String jdbcUrl) {
        int lastSlash = jdbcUrl.lastIndexOf('/');
        int queryIndex = jdbcUrl.indexOf('?', lastSlash);

        return (queryIndex == -1)
                ? jdbcUrl.substring(lastSlash + 1)
                : jdbcUrl.substring(lastSlash + 1, queryIndex);
    }

    /**
     * Builds a server-level JDBC URL (no database name in the path,
     * so it can be used to run CREATE DATABASE) from a full JDBC URL
     * such as:
     *   jdbc:mysql://host:4000/online_banking?sslMode=VERIFY_IDENTITY
     * -> jdbc:mysql://host:4000/?sslMode=VERIFY_IDENTITY
     */
    private static String buildServerUrl(String jdbcUrl) {
        int lastSlash = jdbcUrl.lastIndexOf('/');
        int queryIndex = jdbcUrl.indexOf('?', lastSlash);

        String prefix = jdbcUrl.substring(0, lastSlash + 1);
        String suffix = (queryIndex == -1) ? "" : jdbcUrl.substring(queryIndex);

        return prefix + suffix;
    }
}