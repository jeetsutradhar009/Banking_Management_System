package com.bank.model;

public class RegistrationInfo {

    private int userId;
    private String customerId;
    private String fullName;
    private String email;
    private String phone;
    private String accountNumber;
    private String ifscCode;
    private String accountType;
    private boolean onlineBankingEnabled;

    public RegistrationInfo() {
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public String getMobile() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setMobile(String mobile) {
        this.phone = mobile;
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

    public String getAccountType() {
        return accountType;
    }
    
    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public boolean isOnlineBankingEnabled() {
        return onlineBankingEnabled;
    }

    public boolean getOnlineBankingEnabled() {
        return onlineBankingEnabled;
    }

    public void setOnlineBankingEnabled(boolean onlineBankingEnabled) {
        this.onlineBankingEnabled = onlineBankingEnabled;
    }
}