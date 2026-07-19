package com.bank.controller.admin;

import com.bank.dao.AdminDAO;
import com.bank.model.ActivationResult;
import com.bank.model.User;
import com.bank.util.AdminAuth;
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
 * AddUserServlet
 *
 * Admin "Add User" page (admin-add-user.jsp), role-based:
 *
 *   - role=CUSTOMER: verifies an EXISTING Customer ID + Account Number
 *     pair belongs to the same customer, then activates online
 *     banking for that customer with an auto-generated temporary
 *     password (admin never sets a password manually). No new user
 *     row is created - this only updates an existing one.
 *
 *   - role=ADMIN: creates a brand new ADMIN user directly, active
 *     immediately with the password the admin entered.
 *
 * Does not touch the customer "Open Account" flow, admin login, or
 * online banking self-registration in any way.
 */
@WebServlet("/admin/add-user")
public class AddUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String VIEW = "/WEB-INF/views/admin/admin-add-user.jsp";

    private final AdminDAO adminDAO = new AdminDAO();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String role = request.getParameter("role");

        HttpSession session = request.getSession(false);
        User actor = session != null ? (User) session.getAttribute("user") : null;

        if ("CUSTOMER".equalsIgnoreCase(role)) {
            handleCustomerActivation(request, response, actor);
        } else if ("ADMIN".equalsIgnoreCase(role)) {
            handleAdminCreation(request, response, actor);
        } else {
            redirectWithError(request, response, "Please select a valid role.");
        }
    }

    private void handleCustomerActivation(HttpServletRequest request, HttpServletResponse response, User actor)
            throws IOException {

        String customerId = request.getParameter("verifyCustomerId");
        String accountNumber = request.getParameter("accountNumber");

        if (isEmpty(customerId) || isEmpty(accountNumber)) {
            redirectWithError(request, response, "Customer ID and Account Number are both required.");
            return;
        }

        try {
            ActivationResult result = adminDAO.activateOnlineBankingForCustomer(
                    actor, customerId.trim(), accountNumber.trim());

            if (!result.isSuccess()) {
                redirectWithError(request, response, result.getMessage());
                return;
            }

            String loginUrl = buildAppBaseUrl(request) + "/login";

            EmailService.EmailResult emailResult = emailService.sendOnlineBankingActivatedEmail(
                    result.getEmail(),
                    result.getFullName(),
                    result.getCustomerId(),
                    result.getTemporaryPassword(),
                    loginUrl
            );

            StringBuilder url = new StringBuilder(request.getContextPath())
                    .append("/admin/add-user")
                    .append("?type=customer")
                    .append("&custId=").append(encode(result.getCustomerId()));

            if (!emailResult.isSuccess()) {
                url.append("&emailWarning=")
                        .append(encode("Online banking activated, but the notification email could not be sent."));
            }

            response.sendRedirect(url.toString());

        } catch (Exception e) {
            e.printStackTrace();
            redirectWithError(request, response, "Something went wrong while activating online banking.");
        }
    }

    private void handleAdminCreation(HttpServletRequest request, HttpServletResponse response, User actor)
            throws IOException {

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String customerId = request.getParameter("adminCustomerId");

        if (isEmpty(firstName) || isEmpty(lastName) || isEmpty(email) || isEmpty(phone) || isEmpty(password)) {
            redirectWithError(request, response, "First Name, Last Name, Email, Phone and Password are required.");
            return;
        }

        String fullName = (firstName.trim() + " " + lastName.trim()).trim();

        try {
            String assignedId = adminDAO.addAdminUser(
                    actor, fullName, email.trim(), phone.trim(),
                    dob, address, password, customerId
            );

            response.sendRedirect(request.getContextPath()
                    + "/admin/add-user?type=admin&adminId=" + encode(assignedId));

        } catch (Exception e) {
            e.printStackTrace();
            redirectWithError(request, response, "Something went wrong while creating the admin account.");
        }
    }

    /**
     * Builds "scheme://host[:port]/contextPath" from the current
     * request, honouring X-Forwarded-Proto / X-Forwarded-Host when
     * running behind a reverse proxy (e.g. the Render deployment), so
     * the emailed login link never hardcodes localhost.
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

        response.sendRedirect(request.getContextPath() + "/admin/add-user?err=" + encode(message));
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}