package com.bank.model;

import java.sql.Date;

public class User {

    private int userId;
    private String customerId;
    private String firstName;
    private String lastName;
    private String fullName;
    private Date dob;
    private String address;
    private String email;
    private String phone;
    private String password;
    private String role;
    private boolean onlineBankingEnabled;

    public User() {
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

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getFullName() {
        if (fullName != null && !fullName.trim().isEmpty()) {
            return fullName;
        }

        String fName = firstName == null ? "" : firstName.trim();
        String lName = lastName == null ? "" : lastName.trim();

        return (fName + " " + lName).trim();
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public Date getDob() {
        return dob;
    }

    public void setDob(Date dob) {
        this.dob = dob;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
    
    public boolean isOnlineBankingEnabled() {
        return onlineBankingEnabled;
    }

    public void setOnlineBankingEnabled(boolean onlineBankingEnabled) {
        this.onlineBankingEnabled = onlineBankingEnabled;
    }
}