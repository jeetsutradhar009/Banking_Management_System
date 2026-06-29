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
import java.io.PrintWriter;
import java.util.Map;

@WebServlet("/admin/reports/export")
public class AdminReportExportServlet extends HttpServlet {

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

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=DKS_Bank_Admin_Report.csv");

        try (PrintWriter out = response.getWriter()) {
            out.println("DKS Bank Admin Report");
            out.println();

            out.println("Summary,Value");
            out.println("Total Users," + reportDAO.getTotalUsers());
            out.println("Total Admins," + reportDAO.getTotalAdmins());
            out.println("Total Accounts," + reportDAO.getTotalAccounts());
            out.println("Total Transactions," + reportDAO.getTotalTransactions());
            out.println("Today Transactions," + reportDAO.getTodayTransactions());
            out.println("Successful Transactions," + reportDAO.getSuccessfulTransactions());
            out.println("Failed Transactions," + reportDAO.getFailedTransactions());
            out.println("Total Bank Balance," + reportDAO.getTotalBankBalance());
            out.println("Total Transaction Amount," + reportDAO.getTotalTransactionAmount());
            out.println("Today Transaction Amount," + reportDAO.getTodayTransactionAmount());

            out.println();
            out.println("Top Accounts By Balance");
            out.println("Customer ID,Name,Account Number,Account Type,Balance");

            for (Map<String, Object> row : reportDAO.getTopAccountsByBalance()) {
                out.println(
                        safe(row.get("customerId")) + "," +
                        safe(row.get("fullName")) + "," +
                        safe(row.get("accountNumber")) + "," +
                        safe(row.get("accountType")) + "," +
                        safe(row.get("balance"))
                );
            }

            out.println();
            out.println("Recent Transactions");
            out.println("Txn ID,Sender,Receiver,Amount,Status,Date");

            for (Map<String, Object> row : reportDAO.getRecentTransactions()) {
                out.println(
                        safe(row.get("transactionId")) + "," +
                        safe(row.get("senderAccount")) + "," +
                        safe(row.get("receiverAccount")) + "," +
                        safe(row.get("amount")) + "," +
                        safe(row.get("status")) + "," +
                        safe(row.get("transactionDate"))
                );
            }
        }
    }

    private String safe(Object value) {
        if (value == null) {
            return "";
        }

        String text = String.valueOf(value);
        text = text.replace("\"", "\"\"");

        if (text.contains(",") || text.contains("\"") || text.contains("\n")) {
            text = "\"" + text + "\"";
        }

        return text;
    }
}