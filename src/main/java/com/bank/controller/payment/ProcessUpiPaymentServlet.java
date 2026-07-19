package com.bank.controller.payment;

import com.bank.dao.PaymentDAO;
import com.bank.dao.TransactionDAO;
import com.bank.dao.UserDAO;
import com.bank.model.AccountOpenResult;
import com.bank.model.Payment;
import com.bank.util.AuditLogger;
import com.bank.util.EmailService;

import java.io.IOException;
import java.security.SecureRandom;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * ProcessUpiPaymentServlet
 *
 * Customer self-service "Open Account" flow ONLY - AJAX endpoint
 * behind the "Pay" button on the UPI tab of payment.jsp. This is a
 * DEMO SIMULATION: no real payment gateway is involved anywhere in
 * this class - a random demo transaction reference is generated and
 * the payment is marked SUCCESS unconditionally (see class-level note
 * below on where real gateway integration would go if ever added).
 *
 * On simulated success, and ONLY then, the actual account is created:
 *   1. Payment marked SUCCESS (PaymentDAO)
 *   2. UserDAO.openBankAccount() - completely unchanged, same method
 *      already used by the pre-payment version of this flow and by
 *      VerifyOtpServlet's older OTP-gated path
 *   3. Initial CREDIT ledger entry (TransactionDAO.recordInitialDeposit)
 *   4. Account details email (EmailService.sendAccountDetailsEmail)
 *
 * The Admin "Create Account" flow never reaches this servlet and is
 * not affected by anything here.
 */
@WebServlet("/payment/process")
public class ProcessUpiPaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String REF_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final UserDAO userDAO = new UserDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final EmailService emailService = new EmailService();
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String requestId = request.getParameter("requestId");

        try {
            if (isEmpty(requestId)) {
                writeJson(response, false, "Invalid payment session.", null, null, null, null);
                return;
            }

            requestId = requestId.trim();

            Payment payment = paymentDAO.findByRequestId(requestId);

            if (payment == null) {
                writeJson(response, false, "Invalid or expired payment session.", null, null, null, null);
                return;
            }

            if ("SUCCESS".equalsIgnoreCase(payment.getStatus())) {
                writeJson(response, false, "This payment has already been completed.", null, null, null, null);
                return;
            }

            // ------------------------------------------------------------
            // DEMO SIMULATION ONLY - no real payment gateway is called.
            // A real integration (e.g. Razorpay/PayU/a bank's UPI API)
            // would replace this block with an actual payment-status
            // check before marking the payment SUCCESS. Nothing below
            // this comment processes real money.
            // ------------------------------------------------------------

            String transactionReference = generateTransactionReference();

            boolean marked = paymentDAO.markSuccess(requestId, "UPI", transactionReference);

            if (!marked) {
                // Row was not in PENDING status anymore (already
                // processed by a concurrent request, e.g. a
                // double-click) - do not create a second account for
                // the same request.
                writeJson(response, false, "This payment has already been completed.", null, null, null, null);
                return;
            }

            AccountOpenResult result = userDAO.openBankAccount(
                    payment.getFirstName(),
                    payment.getLastName(),
                    payment.getDob().toString(),
                    payment.getAddress(),
                    payment.getEmail(),
                    payment.getPhone(),
                    payment.getAccountType(),
                    payment.getAmount()
            );

            if (!result.isSuccess()) {
                // Payment is already marked SUCCESS at this point (the
                // simulated money is "accepted"), but account creation
                // failed (e.g. a duplicate email/phone that slipped
                // through since the form was first filled). This is
                // a genuine edge case with no clean automatic recovery
                // in a demo system - surfaced clearly so the customer
                // knows to contact support rather than assuming the
                // account exists.
                writeJson(response, false,
                        "Payment was recorded, but the account could not be created (" + result.getMessage()
                                + "). Please contact support with reference " + transactionReference + ".",
                        transactionReference, null, null, null);
                return;
            }

            String fullName = (payment.getFirstName() + " " + payment.getLastName()).trim();

            transactionDAO.recordInitialDeposit(result.getAccountNumber(), payment.getAmount());

            AuditLogger.logByIdentifier(result.getCustomerId(), fullName,
                    "OPEN_ACCOUNT", "New account opened via UPI payment simulation: " + result.getAccountNumber()
                            + " (Customer ID " + result.getCustomerId() + ", ref " + transactionReference + ")");

            // Customer self-service flow: no password is ever set at
            // account-opening time - the customer registers separately
            // with their own password via RegisterServlet. The email
            // points there with a ready-to-click link, matching the
            // current EmailService.sendAccountDetailsEmail(...)
            // signature (registrationUrl, not a password).
            String registrationUrl = buildRegistrationUrl(request);

            emailService.sendAccountDetailsEmail(
                    payment.getEmail(), fullName, result.getCustomerId(),
                    result.getAccountNumber(), result.getIfscCode(), registrationUrl
            );

            writeJson(response, true, "Payment successful.", transactionReference,
                    result.getCustomerId(), result.getAccountNumber(), result.getIfscCode());

        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, false, "Something went wrong while processing the payment. Please try again.", null, null, null, null);
        }
    }

    /**
     * Demo transaction reference, e.g. "UPI_SIM_7K4Q9XZP" - 8 random
     * uppercase alphanumeric characters, clearly prefixed so it is
     * never mistaken for a real UPI transaction ID.
     */
    /**
     * Builds the full absolute URL to the Online Banking registration
     * page, e.g. "http://192.168.1.5:8080/OnlineBankingSystem/register" -
     * same host-detection approach already used by
     * ForgotPasswordServlet.buildResetLink() and
     * PaymentServlet.buildAbsoluteUrl(), so it works correctly on both
     * localhost and the live deployment without any hardcoded host.
     */
    private String buildRegistrationUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        boolean isDefaultPort =
                ("http".equalsIgnoreCase(scheme) && serverPort == 80)
                || ("https".equalsIgnoreCase(scheme) && serverPort == 443);

        String portPart = isDefaultPort ? "" : ":" + serverPort;

        return scheme + "://" + serverName + portPart + contextPath + "/register";
    }

    private String generateTransactionReference() {
        StringBuilder suffix = new StringBuilder(8);

        for (int i = 0; i < 8; i++) {
            suffix.append(REF_CHARS.charAt(random.nextInt(REF_CHARS.length())));
        }

        return "UPI_SIM_" + suffix;
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void writeJson(HttpServletResponse response,
                            boolean success,
                            String message,
                            String transactionReference,
                            String customerId,
                            String accountNumber,
                            String ifscCode) throws IOException {

        String json =
                "{" +
                "\"success\":" + success + "," +
                "\"message\":\"" + esc(message) + "\"," +
                "\"transactionReference\":\"" + esc(transactionReference) + "\"," +
                "\"customerId\":\"" + esc(customerId) + "\"," +
                "\"accountNumber\":\"" + esc(accountNumber) + "\"," +
                "\"ifscCode\":\"" + esc(ifscCode) + "\"" +
                "}";

        response.getWriter().write(json);
    }

    private String esc(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}