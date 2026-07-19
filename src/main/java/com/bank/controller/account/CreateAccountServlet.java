package com.bank.controller.account;

import com.bank.dao.UserDAO;
import com.bank.model.AccountOpenResult;
import com.bank.model.User;
import com.bank.util.AdminAuth;
import com.bank.util.AuditLogger;
import com.bank.util.EmailService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * CreateAccountServlet
 *
 * Admin-panel "Create Account" flow (create-account.jsp). Creates a
 * brand-new customer profile AND account together in one step -
 * matching what create-account.jsp's form actually collects
 * (first/last name, DOB, phone, email, address, account type, opening
 * deposit).
 *
 * No password is generated or set here. This reuses the exact same
 * UserDAO.openBankAccount() method used by the customer self-service
 * "Open Account" flow, so online banking stays disabled until the
 * customer separately registers via /register and chooses their own
 * password.
 */
@WebServlet("/admin/accounts/create")
public class CreateAccountServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VIEW = "/WEB-INF/views/admin/create-account.jsp";

    private final UserDAO userDAO = new UserDAO();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String dob = request.getParameter("dob");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String accountType = request.getParameter("accountType");
        String openingBalanceStr = request.getParameter("openingBalance");

        try {
            if (isEmpty(firstName) || isEmpty(lastName) || isEmpty(dob) || isEmpty(phone)
                    || isEmpty(email) || isEmpty(address) || isEmpty(accountType) || isEmpty(openingBalanceStr)) {

                redirectWithError(request, response, "All fields are required.");
                return;
            }

            if (!phone.trim().matches("[0-9]{10}")) {
                redirectWithError(request, response, "Phone number must be 10 digits.");
                return;
            }

            double openingBalance;

            try {
                openingBalance = Double.parseDouble(openingBalanceStr.trim());
            } catch (NumberFormatException e) {
                redirectWithError(request, response, "Invalid initial deposit amount.");
                return;
            }

            if (openingBalance < 500) {
                redirectWithError(request, response, "Initial deposit must be at least \u20B9500.");
                return;
            }

            // Same core creation logic as the customer self-service "Open
            // Account" flow: no password is set here at all, and online
            // banking stays disabled until the customer registers
            // themselves via /register and picks their own password.
            AccountOpenResult result = userDAO.openBankAccount(
                    firstName.trim(),
                    lastName.trim(),
                    dob.trim(),
                    address.trim(),
                    email.trim(),
                    phone.trim(),
                    accountType.trim(),
                    openingBalance
            );

            if (!result.isSuccess()) {
                redirectWithError(request, response, result.getMessage());
                return;
            }

            HttpSession session = request.getSession(false);
            User actor = session != null ? (User) session.getAttribute("user") : null;
            String fullName = (firstName.trim() + " " + lastName.trim()).trim();

            AuditLogger.log(actor, "CREATE_ACCOUNT",
                    "Admin created account " + result.getAccountNumber()
                            + " for new Customer ID " + result.getCustomerId());

            // Same details shown on the success popup (Customer ID,
            // Account Number, IFSC Code) are emailed to the customer.
            // No password or any other credential is sent by email -
            // instead the customer is pointed to the existing /register
            // route to activate online banking themselves.
            String registrationUrl = buildAppBaseUrl(request) + "/register";

            EmailService.EmailResult emailResult = emailService.sendAccountDetailsEmail(
                    email.trim(),
                    fullName,
                    result.getCustomerId(),
                    result.getAccountNumber(),
                    result.getIfscCode(),
                    registrationUrl
            );

            StringBuilder successUrl = new StringBuilder(request.getContextPath())
                    .append("/admin/accounts/create")
                    .append("?custId=").append(encode(result.getCustomerId()))
                    .append("&accNo=").append(encode(result.getAccountNumber()))
                    .append("&ifsc=").append(encode(result.getIfscCode()))
                    .append("&accType=").append(encode(accountType.trim()));

            if (!emailResult.isSuccess()) {
                // Account is already created successfully at this point -
                // a failed email must never be treated as a failed account
                // creation. We just let the admin know so the details can
                // be shared manually if needed.
                successUrl.append("&emailWarning=")
                        .append(encode("Account created, but the details email could not be sent."));
            }

            response.sendRedirect(successUrl.toString());

        } catch (Exception e) {
            e.printStackTrace();
            redirectWithError(request, response, "Something went wrong while creating the account.");
        }
    }

    /**
     * Builds "scheme://host[:port]/contextPath" from the current
     * request, honouring X-Forwarded-Proto / X-Forwarded-Host when the
     * app is running behind a reverse proxy (e.g. the Render
     * deployment), so the emailed registration link never hardcodes
     * localhost and always matches however the admin is currently
     * accessing the app.
     */
    private String buildAppBaseUrl(HttpServletRequest request) {
        String forwardedProto = request.getHeader("X-Forwarded-Proto");
        String forwardedHost = request.getHeader("X-Forwarded-Host");

        String scheme = !isEmpty(forwardedProto) ? forwardedProto.trim() : request.getScheme();

        if (!isEmpty(forwardedHost)) {
            return scheme + "://" + forwardedHost.trim() + request.getContextPath();
        }

        String serverName = request.getServerName();
        int serverPort = request.getServerPort();

        StringBuilder base = new StringBuilder(scheme).append("://").append(serverName);

        boolean isDefaultHttpPort = "http".equalsIgnoreCase(scheme) && serverPort == 80;
        boolean isDefaultHttpsPort = "https".equalsIgnoreCase(scheme) && serverPort == 443;

        if (!isDefaultHttpPort && !isDefaultHttpsPort) {
            base.append(":").append(serverPort);
        }

        return base.append(request.getContextPath()).toString();
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {

        response.sendRedirect(request.getContextPath()
                + "/admin/accounts/create?err=" + encode(message));
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}