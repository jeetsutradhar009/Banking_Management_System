package com.bank.model;

/**
 * Result of AdminDAO.activateOnlineBankingForCustomer() - the admin
 * "Add User" page's CUSTOMER-role flow that verifies an existing
 * Customer ID + Account Number pair, then activates online banking
 * for that customer with an auto-generated temporary password.
 *
 * Kept separate from AccountOpenResult (used by the unrelated
 * "Open Account" flows) so this activation flow can never accidentally
 * be confused with, or affect, account-opening behavior.
 */
public class ActivationResult {

    private boolean success;
    private String message;
    private String fullName;
    private String email;
    private String customerId;
    private String temporaryPassword;

    public ActivationResult() {
    }

    public ActivationResult(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public ActivationResult(boolean success, String message, String fullName, String email,
                             String customerId, String temporaryPassword) {
        this.success = success;
        this.message = message;
        this.fullName = fullName;
        this.email = email;
        this.customerId = customerId;
        this.temporaryPassword = temporaryPassword;
    }

    public boolean isSuccess() {
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

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public String getTemporaryPassword() {
        return temporaryPassword;
    }

    public void setTemporaryPassword(String temporaryPassword) {
        this.temporaryPassword = temporaryPassword;
    }
}