package com.bank.controller.account;

import com.bank.dao.UserDAO;
import com.bank.model.User;
import com.bank.util.AuditLogger;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/change-password", "/changePassword"})
public class ChangePasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VIEW = "/WEB-INF/views/user/changePassword.jsp";

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (currentPassword == null || currentPassword.trim().isEmpty()
                || newPassword == null || newPassword.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {

            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        currentPassword = currentPassword.trim();
        newPassword = newPassword.trim();
        confirmPassword = confirmPassword.trim();

        if (newPassword.length() < 6) {
            request.setAttribute("error", "New password must be at least 6 characters.");
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New password and confirm password do not match.");
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        if (currentPassword.equals(newPassword)) {
            request.setAttribute("error", "New password cannot be same as current password.");
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        boolean updated = userDAO.changePassword(
                user.getUserId(),
                currentPassword,
                newPassword
        );

        if (updated) {
            request.setAttribute("success", "Password updated successfully.");
            AuditLogger.log(user, "CHANGE_PASSWORD", "User changed their account password");
        } else {
            request.setAttribute("error", "Current password is incorrect.");
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}