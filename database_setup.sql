-- ============================================================
-- DB_Backup.sql
--
-- Manual fallback for DatabaseSetup.java.
--
-- This file contains the EXACT same SQL that DatabaseSetup.java
-- runs programmatically (database creation, table creation, and
-- every schema migration). If DatabaseSetup.java fails to run for
-- any reason (driver issue, environment variable problem, etc.),
-- open this file in your SQL editor (TiDB Cloud SQL Editor / MySQL
-- Workbench / any MySQL-compatible client) and run it top to bottom
-- against your database.
--
-- NOTE:
--   - Every ALTER TABLE ADD COLUMN below is safe to re-run because
--     it uses "ADD COLUMN IF NOT EXISTS" (MySQL 8 / TiDB support
--     this syntax). This mirrors the addColumnIfMissing() check in
--     DatabaseSetup.java.
--   - The admin user is NOT included here — DatabaseSetup.java
--     creates it interactively (prompts for First Name, Last Name,
--     Phone, Email, Password). If you skip Java setup entirely, you
--     must insert the admin row yourself (template included at the
--     bottom, commented out).
-- ============================================================


-- ------------------------------------------------------------
-- 1. Create database
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS dks_banking;

USE dks_banking;


-- ------------------------------------------------------------
-- 2. Create tables
-- ------------------------------------------------------------

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
);

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
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_account VARCHAR(30),
    receiver_account VARCHAR(30),
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'Success',
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Backs the customer self-service "Open Account" UPI payment
-- simulation ONLY (com.bank.controller.payment). Beyond the core
-- payment fields, this also snapshots the pending registration
-- (first/last name, dob, address, email, phone, account type) so the
-- account can be created from any device once payment succeeds -
-- e.g. the demo QR code being scanned on a phone, in a different
-- browser session than the one that filled the account-opening form.
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
);


-- ------------------------------------------------------------
-- 3. Migrate: users table
-- ------------------------------------------------------------

ALTER TABLE users ADD COLUMN IF NOT EXISTS customer_id VARCHAR(10) UNIQUE AFTER user_id;
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(100) AFTER customer_id;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(100) AFTER first_name;
ALTER TABLE users ADD COLUMN IF NOT EXISTS dob DATE AFTER full_name;
ALTER TABLE users ADD COLUMN IF NOT EXISTS address VARCHAR(500) AFTER dob;
ALTER TABLE users ADD COLUMN IF NOT EXISTS online_banking_enabled TINYINT(1) DEFAULT 0 AFTER role;

ALTER TABLE users MODIFY password VARCHAR(255) NULL;

UPDATE users
SET first_name = SUBSTRING_INDEX(full_name, ' ', 1)
WHERE first_name IS NULL;

UPDATE users
SET last_name = ''
WHERE last_name IS NULL;

UPDATE users
SET online_banking_enabled = 1
WHERE password IS NOT NULL AND password <> '';


-- ------------------------------------------------------------
-- 4. Migrate: accounts table
-- ------------------------------------------------------------

ALTER TABLE accounts ADD COLUMN IF NOT EXISTS ifsc_code VARCHAR(20) DEFAULT 'DKSB0001886' AFTER account_number;
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'ACTIVE' AFTER balance;

ALTER TABLE accounts MODIFY account_number VARCHAR(30) NOT NULL;

UPDATE accounts
SET ifsc_code = 'DKSB0001886'
WHERE ifsc_code IS NULL OR ifsc_code = '';

UPDATE accounts
SET status = 'ACTIVE'
WHERE status IS NULL OR status = '';


-- ------------------------------------------------------------
-- 5. Migrate: audit_logs table
-- ------------------------------------------------------------

ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS actor_type VARCHAR(10) NOT NULL DEFAULT 'USER' AFTER log_id;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS actor_user_id INT NULL AFTER actor_type;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS actor_identifier VARCHAR(150) NULL AFTER actor_user_id;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS actor_name VARCHAR(150) NULL AFTER actor_identifier;

ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS action VARCHAR(100) NOT NULL AFTER log_id;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS description VARCHAR(500) AFTER action;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER description;


-- ============================================================
-- 6. (Optional) Manual admin seed
--
-- DatabaseSetup.java creates the admin INTERACTIVELY (terminal
-- prompts). If you are running this SQL file standalone instead of
-- running the Java setup, uncomment the block below and fill in
-- your own values before running it.
--
-- customer_id, role, and online_banking_enabled must stay exactly
-- as shown to match what the application expects.
-- ============================================================

-- INSERT INTO users
-- (customer_id, first_name, last_name, full_name, dob, address, email, phone, password, role, online_banking_enabled)
-- VALUES
-- ('9999999999', '<First Name>', '<Last Name>', '<First Name> <Last Name>', NULL, NULL, '<email>', '<phone>', '<password>', 'ADMIN', 1);