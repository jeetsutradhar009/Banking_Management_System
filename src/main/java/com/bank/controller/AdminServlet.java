package com.bank.controller;

import com.bank.dao.AdminDAO;
import com.bank.model.Account;
import com.bank.model.Transaction;
import com.bank.model.User;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AdminDAO adminDAO;

    @Override
    public void init() {
        adminDAO = new AdminDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User admin = (User) session.getAttribute("user");

        if (!"ADMIN".equalsIgnoreCase(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int totalUsers = adminDAO.getTotalUsers();
        int totalAccounts = adminDAO.getTotalAccounts();
        int totalTransactions = adminDAO.getTotalTransactions();

        List<User> recentUsers = adminDAO.getRecentUsers(5);
        List<Account> recentAccounts = adminDAO.getRecentAccounts(5);
        List<Transaction> recentTransactions = adminDAO.getRecentTransactions(5);

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("totalTransactions", totalTransactions);

        request.setAttribute("recentUsers", recentUsers);
        request.setAttribute("recentAccounts", recentAccounts);
        request.setAttribute("recentTransactions", recentTransactions);

        request.getRequestDispatcher("/admin.jsp").forward(request, response);
    }
}