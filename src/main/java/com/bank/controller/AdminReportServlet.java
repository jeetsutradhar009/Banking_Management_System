package com.bank.controller;

import com.bank.dao.AdminReportDAO;
import com.bank.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/admin/reports")
public class AdminReportServlet extends HttpServlet {

    private AdminReportDAO reportDAO;

    @Override
    public void init() {
        reportDAO = new AdminReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        request.setAttribute("totalUsers", reportDAO.getTotalUsers());
        request.setAttribute("totalAdmins", reportDAO.getTotalAdmins());
        request.setAttribute("totalAccounts", reportDAO.getTotalAccounts());
        request.setAttribute("totalTransactions", reportDAO.getTotalTransactions());

        request.setAttribute("todayTransactions", reportDAO.getTodayTransactions());
        request.setAttribute("successfulTransactions", reportDAO.getSuccessfulTransactions());
        request.setAttribute("failedTransactions", reportDAO.getFailedTransactions());

        request.setAttribute("totalBankBalance", reportDAO.getTotalBankBalance());
        request.setAttribute("totalTransactionAmount", reportDAO.getTotalTransactionAmount());
        request.setAttribute("todayTransactionAmount", reportDAO.getTodayTransactionAmount());

        request.setAttribute("monthlyTransactions", reportDAO.getMonthlyTransactions());
        request.setAttribute("accountTypeDistribution", reportDAO.getAccountTypeDistribution());
        request.setAttribute("userRoleDistribution", reportDAO.getUserRoleDistribution());
        request.setAttribute("transactionStatusDistribution", reportDAO.getTransactionStatusDistribution());

        request.setAttribute("topAccounts", reportDAO.getTopAccountsByBalance());
        request.setAttribute("recentTransactions", reportDAO.getRecentTransactions());

        request.getRequestDispatcher("/adminReports.jsp").forward(request, response);
    }
}