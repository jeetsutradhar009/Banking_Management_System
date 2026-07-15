package com.bank.model;

import java.sql.Timestamp;

public class PasswordResetToken {

    private int id;
    private String userEmail;
    private String resetToken;
    private Timestamp expiresAt;
    private boolean used;
    private Timestamp createdAt;

    public PasswordResetToken() {
    }

    public PasswordResetToken(String userEmail, String resetToken, Timestamp expiresAt) {
        this.userEmail = userEmail;
        this.resetToken = resetToken;
        this.expiresAt = expiresAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public Timestamp getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isUsed() {
        return used;
    }

    public void setUsed(boolean used) {
        this.used = used;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}