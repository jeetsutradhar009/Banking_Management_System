package com.bank.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Payment
 *
 * Represents a row in the "payments" table. Used exclusively by the
 * customer self-service "Open Account" flow's UPI payment
 * simulation (com.bank.controller.payment) - the Admin "Create
 * Account" flow does not use this at all.
 *
 * Beyond the payment fields requested (payment_id, request_id,
 * payment_method, amount, transaction_reference, status,
 * created_at), this also carries a snapshot of the pending
 * registration (first/last name, dob, address, email, phone,
 * account type) collected on openAccount.jsp. This is necessary
 * because the account cannot be created until payment succeeds, and
 * the payment page must be reachable from a completely different
 * device/browser session than the one that filled the form (e.g.
 * scanning the QR code with a phone) - so the pending data cannot
 * live only in the original browser's HttpSession.
 */
public class Payment {

    private int paymentId;
    private String requestId;
    private String paymentMethod;
    private double amount;
    private String transactionReference;
    private String status;
    private Timestamp createdAt;

    // Pending-registration snapshot (see class javadoc above)
    private String firstName;
    private String lastName;
    private Date dob;
    private String address;
    private String email;
    private String phone;
    private String accountType;

    public Payment() {
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getTransactionReference() {
        return transactionReference;
    }

    public void setTransactionReference(String transactionReference) {
        this.transactionReference = transactionReference;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
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
}