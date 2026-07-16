package com.bank.controller.admin;

import com.bank.dao.AdminDAO;
import com.bank.model.Account;
import com.bank.model.Transaction;
import com.bank.model.User;
import com.bank.util.AdminAuth;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/generate-report")
public class GenerateReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=DKS_Bank_Admin_Report.csv");

        try (PrintWriter out = response.getWriter()) {
            out.println("DKS Bank Admin Report");
            out.println();

            writeUsers(out, adminDAO.getAllUsers());
            writeAccounts(out, adminDAO.getAllAccounts());
            writeTransactions(out, adminDAO.getAllTransactions());

            HttpSession session = request.getSession(false);
            User actor = session != null ? (User) session.getAttribute("user") : null;

            adminDAO.logAction(actor, "GENERATE_REPORT", "Admin downloaded CSV report");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void writeUsers(PrintWriter out, List<User> users) {
        out.println("USERS");
        out.println("User ID,Full Name,Email,Phone,Role");

        for (User user : users) {
            out.println(
                    csv(user.getUserId()) + "," +
                    csv(user.getFullName()) + "," +
                    csv(user.getEmail()) + "," +
                    csv(user.getPhone()) + "," +
                    csv(user.getRole())
            );
        }

        out.println();
    }

    private void writeAccounts(PrintWriter out, List<Account> accounts) {
        out.println("ACCOUNTS");
        out.println("Account ID,User ID,Account Number,Account Type,Balance,Status");

        for (Account account : accounts) {
            out.println(
                    csv(account.getAccountId()) + "," +
                    csv(account.getUserId()) + "," +
                    csv(account.getAccountNumber()) + "," +
                    csv(account.getAccountType()) + "," +
                    csv(account.getBalance()) + "," +
                    csv(account.getStatus())
            );
        }

        out.println();
    }

    private void writeTransactions(PrintWriter out, List<Transaction> transactions) {
        out.println("TRANSACTIONS");
        out.println("Transaction ID,Sender Account,Receiver Account,Amount,Status,Date");

        for (Transaction transaction : transactions) {
            out.println(
                    csv(transaction.getTransactionId()) + "," +
                    csv(transaction.getSenderAccount()) + "," +
                    csv(transaction.getReceiverAccount()) + "," +
                    csv(transaction.getAmount()) + "," +
                    csv(transaction.getStatus()) + "," +
                    csv(transaction.getTransactionDate())
            );
        }

        out.println();
    }

    private String csv(Object value) {
        if (value == null) {
            return "";
        }

        String text = String.valueOf(value).replace("\"", "\"\"");

        return "\"" + text + "\"";
    }
}
