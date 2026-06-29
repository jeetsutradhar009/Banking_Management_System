package com.bank.model;

import java.sql.Timestamp;

public class Account {

    private int accountId;
    private int userId;
    private String accountNumber;
    private String ifscCode;
    private String accountType;
    private double balance;
    private String status;
    private Timestamp createdAt;

    public Account() {
    }

    public Account(int accountId,
                   int userId,
                   String accountNumber,
                   String ifscCode,
                   String accountType,
                   double balance,
                   String status) {

        this.accountId = accountId;
        this.userId = userId;
        this.accountNumber = accountNumber;
        this.ifscCode = ifscCode;
        this.accountType = accountType;
        this.balance = balance;
        this.status = status;
    }

    public int getAccountId() {
        return accountId;
    }

    public int getAccount_id() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public void setAccount_id(int accountId) {
        this.accountId = accountId;
    }

    public int getUserId() {
        return userId;
    }

    public int getUser_id() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public void setUser_id(int userId) {
        this.userId = userId;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public String getAccount_number() {
        return accountNumber;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public void setAccount_number(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public String getIfscCode() {
        return ifscCode;
    }

    public String getIfsc_code() {
        return ifscCode;
    }

    public void setIfscCode(String ifscCode) {
        this.ifscCode = ifscCode;
    }

    public void setIfsc_code(String ifscCode) {
        this.ifscCode = ifscCode;
    }

    public String getAccountType() {
        return accountType;
    }

    public String getAccount_type() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public void setAccount_type(String accountType) {
        this.accountType = accountType;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public String getStatus() {
        if (status == null || status.trim().isEmpty()) {
            return "ACTIVE";
        }

        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public Timestamp getCreated_at() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public void setCreated_at(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}