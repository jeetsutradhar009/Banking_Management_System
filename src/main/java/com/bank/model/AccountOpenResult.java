package com.bank.model;

public class AccountOpenResult {

    private boolean success;
    private String message;
    private String customerId;
    private String accountNumber;
    private String ifscCode;

    public AccountOpenResult() {
    }

    public AccountOpenResult(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public AccountOpenResult(boolean success, String message, String customerId, String accountNumber, String ifscCode) {
        this.success = success;
        this.message = message;
        this.customerId = customerId;
        this.accountNumber = accountNumber;
        this.ifscCode = ifscCode;
    }

    public boolean isSuccess() {
        return success;
    }

    public boolean getSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }
    
    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public String getIfscCode() {
        return ifscCode;
    }

    public void setIfscCode(String ifscCode) {
        this.ifscCode = ifscCode;
    }
}