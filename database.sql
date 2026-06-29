USE online_banking;

-- Freeze/Unfreeze ke liye status column
-- Agar duplicate column error aaye, is ALTER line ko skip kar dena.
ALTER TABLE accounts ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE';

-- Admin actions track karne ke liye audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(100) NOT NULL,
    description VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);