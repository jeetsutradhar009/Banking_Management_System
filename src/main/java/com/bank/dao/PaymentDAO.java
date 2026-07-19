package com.bank.dao;

import com.bank.model.Payment;
import com.bank.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.UUID;

/**
 * PaymentDAO
 *
 * Backs the UPI payment simulation for the customer self-service
 * "Open Account" flow ONLY (com.bank.controller.payment). The Admin
 * "Create Account" flow (com.bank.controller.account.CreateAccountServlet)
 * never touches this DAO or the payments table.
 */
public class PaymentDAO {

    /**
     * Creates a PENDING payment row holding a snapshot of the
     * not-yet-created registration, and returns the generated
     * request_id that identifies it (embedded in the QR code / page
     * URL as /payment/demo?id=REQUEST_ID).
     */
    public String createPendingPayment(String firstName,
                                        String lastName,
                                        String dob,
                                        String address,
                                        String email,
                                        String phone,
                                        String accountType,
                                        double amount) throws Exception {

        String requestId = UUID.randomUUID().toString();

        String sql = """
                INSERT INTO payments
                (request_id, payment_method, amount, status,
                 first_name, last_name, dob, address, email, phone, account_type)
                VALUES (?, NULL, ?, 'PENDING', ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, requestId);
            ps.setDouble(2, amount);
            ps.setString(3, firstName);
            ps.setString(4, lastName);
            ps.setDate(5, Date.valueOf(dob));
            ps.setString(6, address);
            ps.setString(7, email);
            ps.setString(8, phone);
            ps.setString(9, accountType);

            ps.executeUpdate();
        }

        return requestId;
    }

    /**
     * Looks up a payment by its request_id - this is a plain DB
     * lookup (not tied to any HttpSession), so it works correctly
     * even when the payment page is opened from a different
     * device/browser than the one that filled the account-opening
     * form (e.g. scanning the demo QR code with a phone).
     */
    public Payment findByRequestId(String requestId) throws Exception {

        String sql = "SELECT * FROM payments WHERE request_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                Payment payment = new Payment();
                payment.setPaymentId(rs.getInt("payment_id"));
                payment.setRequestId(rs.getString("request_id"));
                payment.setPaymentMethod(rs.getString("payment_method"));
                payment.setAmount(rs.getDouble("amount"));
                payment.setTransactionReference(rs.getString("transaction_reference"));
                payment.setStatus(rs.getString("status"));
                payment.setCreatedAt(rs.getTimestamp("created_at"));
                payment.setFirstName(rs.getString("first_name"));
                payment.setLastName(rs.getString("last_name"));
                payment.setDob(rs.getDate("dob"));
                payment.setAddress(rs.getString("address"));
                payment.setEmail(rs.getString("email"));
                payment.setPhone(rs.getString("phone"));
                payment.setAccountType(rs.getString("account_type"));

                return payment;
            }
        }
    }

    /**
     * Marks a PENDING payment as SUCCESS with the given demo
     * transaction reference. Only rows currently in PENDING status
     * are updated (returns false otherwise) - this makes the
     * finalize step naturally safe against being triggered twice for
     * the same request_id (e.g. a double-click, or the QR page and
     * the original tab both completing the same payment).
     */
    public boolean markSuccess(String requestId, String paymentMethod, String transactionReference) throws Exception {

        String sql = """
                UPDATE payments
                SET status = 'SUCCESS', payment_method = ?, transaction_reference = ?
                WHERE request_id = ? AND status = 'PENDING'
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, paymentMethod);
            ps.setString(2, transactionReference);
            ps.setString(3, requestId);

            return ps.executeUpdate() > 0;
        }
    }
}