package com.bank.controller.admin;

import com.bank.dao.AdminDAO;
import com.bank.model.Transaction;
import com.bank.model.User;
import com.bank.util.AuditLogger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * Exports the Transactions page's full transaction list as a CSV file
 * - same admin-only auth pattern and CSV-writing approach as
 * AdminReportExportServlet, just for the transactions table instead
 * of the analytics report.
 */
@WebServlet("/admin/transactions/export")
public class AdminTransactionExportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Honors the same search box used on the Transactions page, so
        // exporting after a search only exports the filtered results -
        // exporting with no search present exports everything.
        String keyword = request.getParameter("q");

        List<Transaction> transactions = (keyword != null && !keyword.trim().isEmpty())
                ? adminDAO.searchTransactions(keyword.trim())
                : adminDAO.getAllTransactions();

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=DKS_Bank_Transactions.csv");

        AuditLogger.log(user, "EXPORT_TRANSACTIONS", "Admin exported the transactions CSV");

        SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy hh:mm a");

        try (PrintWriter out = response.getWriter()) {
            out.println("ID,Sender Account,Receiver Account,Amount,Status,Date");

            for (Transaction txn : transactions) {
                String dateText = txn.getTransactionDate() != null ? sdf.format(txn.getTransactionDate()) : "";

                out.println(
                        txn.getTransactionId() + "," +
                        safe(txn.getSenderAccount()) + "," +
                        safe(txn.getReceiverAccount()) + "," +
                        txn.getAmount() + "," +
                        safe(txn.getStatus()) + "," +
                        safe(dateText)
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