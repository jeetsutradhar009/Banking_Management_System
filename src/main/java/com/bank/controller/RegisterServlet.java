package com.bank.controller;

import com.bank.dao.UserDAO;
import com.bank.model.RegistrationInfo;
import com.bank.util.AuditLogger;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String customerId = request.getParameter("customerId");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (isEmpty(customerId) || isEmpty(password) || isEmpty(confirmPassword)) {
            request.setAttribute("error", "Customer ID, password and confirm password are required.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        customerId = customerId.trim();
        password = password.trim();
        confirmPassword = confirmPassword.trim();

        if (!customerId.matches("[0-9]{10}")) {
            request.setAttribute("error", "Customer ID must be 10 digits.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Password and confirm password do not match.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        RegistrationInfo info = userDAO.getRegistrationInfoByCustomerId(customerId);

        if (info == null) {
            request.setAttribute("error", "Invalid Customer ID. Please open account first.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (info.isOnlineBankingEnabled()) {
            request.setAttribute("error", "Online banking already registered. Please login.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        boolean registered = userDAO.activateOnlineBanking(customerId, password);

        if (registered) {
            AuditLogger.logByIdentifier(customerId, info.getFullName(),
                    "REGISTER_ONLINE_BANKING", "Customer ID " + customerId + " activated online banking");

            response.sendRedirect(request.getContextPath() + "/login.jsp?success=Registration%20completed.%20Login%20with%20Customer%20ID.");
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}