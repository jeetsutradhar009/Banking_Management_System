package com.bank.controller;

import com.bank.dao.UserDAO;
import com.bank.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginType = request.getParameter("loginType");
        String loginId = request.getParameter("customerId");
        String password = request.getParameter("password");

        if (loginType == null || loginType.trim().isEmpty()) {
            loginType = "USER";
        }

        loginType = loginType.trim().toUpperCase();

        if (loginId == null || loginId.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Please enter login ID and password.");
            request.setAttribute("selectedLoginType", loginType);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.loginUser(loginId.trim(), password.trim());

        if (user == null) {
            request.setAttribute("error", "Invalid login ID or password.");
            request.setAttribute("selectedLoginType", loginType);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        String role = user.getRole();

        if ("ADMIN".equalsIgnoreCase(loginType)) {

            if (!"ADMIN".equalsIgnoreCase(role)) {
                request.setAttribute("error", "This account is not an admin account.");
                request.setAttribute("selectedLoginType", loginType);
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        if ("ADMIN".equalsIgnoreCase(role)) {
            request.setAttribute("error", "Please use Admin Login option.");
            request.setAttribute("selectedLoginType", loginType);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("user", user);

        response.sendRedirect(request.getContextPath() + "/dashboard");
    }
}