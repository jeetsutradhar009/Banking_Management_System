package com.bank.model;

import java.sql.Date;
import java.sql.Timestamp;

public class OtpVerification {

    private int otpId;
    private String verificationToken;
    private String purpose;

    private String firstName;
    private String lastName;
    private Date dob;
    private String address;
    private String email;
    private String phone;
    private String accountType;
    private double initialDeposit;

    private String otpHash;
    private int attempts;
    private int maxAttempts;
    private String status;
    private boolean emailVerified;
    private Timestamp expiresAt;
    private Timestamp lastSentAt;
    private Timestamp createdAt;
    private Timestamp verifiedAt;

    public OtpVerification() {
    }

    public OtpVerification(String verificationToken,
                            String purpose,
                            String firstName,
                            String lastName,
                            Date dob,
                            String address,
                            String email,
                            String phone,
                            String accountType,
                            double initialDeposit,
                            String otpHash,
                            Timestamp expiresAt) {

        this.verificationToken = verificationToken;
        this.purpose = purpose;
        this.firstName = firstName;
        this.lastName = lastName;
        this.dob = dob;
        this.address = address;
        this.email = email;
        this.phone = phone;
        this.accountType = accountType;
        this.initialDeposit = initialDeposit;
        this.otpHash = otpHash;
        this.expiresAt = expiresAt;
    }

    public int getOtpId() {
        return otpId;
    }

    public void setOtpId(int otpId) {
        this.otpId = otpId;
    }

    public String getVerificationToken() {
        return verificationToken;
    }

    public void setVerificationToken(String verificationToken) {
        this.verificationToken = verificationToken;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
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

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public double getInitialDeposit() {
        return initialDeposit;
    }

    public void setInitialDeposit(double initialDeposit) {
        this.initialDeposit = initialDeposit;
    }

    public String getOtpHash() {
        return otpHash;
    }

    public void setOtpHash(String otpHash) {
        this.otpHash = otpHash;
    }

    public int getAttempts() {
        return attempts;
    }

    public void setAttempts(int attempts) {
        this.attempts = attempts;
    }

    public int getMaxAttempts() {
        return maxAttempts;
    }

    public void setMaxAttempts(int maxAttempts) {
        this.maxAttempts = maxAttempts;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isEmailVerified() {
        return emailVerified;
    }

    public void setEmailVerified(boolean emailVerified) {
        this.emailVerified = emailVerified;
    }

    public Timestamp getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }

    public Timestamp getLastSentAt() {
        return lastSentAt;
    }

    public void setLastSentAt(Timestamp lastSentAt) {
        this.lastSentAt = lastSentAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getVerifiedAt() {
        return verifiedAt;
    }

    public void setVerifiedAt(Timestamp verifiedAt) {
        this.verifiedAt = verifiedAt;
    }
}