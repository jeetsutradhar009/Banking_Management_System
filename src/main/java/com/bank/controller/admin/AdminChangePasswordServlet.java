package com.bank.controller.admin;

import com.bank.dao.UserDAO;
import com.bank.model.User;
import com.bank.util.AdminAuth;
import com.bank.util.AuditLogger;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Dedicated admin "Change Password" page at "/admin/change-password" -
 * a distinct URL from the customer-facing "/change-password", so the
 * two flows never share a JSP. Validation rules mirror the customer
 * ChangePasswordServlet exactly (same checks, same messages, same
 * UserDAO.changePassword(...) call).
 */
@WebServlet("/admin/change-password")
public class AdminChangePasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/admin-change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User admin = (User) session.getAttribute("user");

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (isEmpty(currentPassword) || isEmpty(newPassword) || isEmpty(confirmPassword)) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-change-password.jsp").forward(request, response);
            return;
        }

        currentPassword = currentPassword.trim();
        newPassword = newPassword.trim();
        confirmPassword = confirmPassword.trim();

        if (newPassword.length() < 6) {
            request.setAttribute("error", "New password must be at least 6 characters.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-change-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New password and confirm password do not match.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-change-password.jsp").forward(request, response);
            return;
        }

        if (currentPassword.equals(newPassword)) {
            request.setAttribute("error", "New password cannot be same as current password.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-change-password.jsp").forward(request, response);
            return;
        }

        boolean updated = userDAO.changePassword(admin.getUserId(), currentPassword, newPassword);

        if (updated) {
            request.setAttribute("success", "Password updated successfully.");
            AuditLogger.log(admin, "CHANGE_PASSWORD", "Admin changed their account password");
        } else {
            request.setAttribute("error", "Current password is incorrect.");
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/admin-change-password.jsp").forward(request, response);
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}