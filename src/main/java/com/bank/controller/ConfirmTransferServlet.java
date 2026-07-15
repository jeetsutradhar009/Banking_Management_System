package com.bank.controller;

import com.bank.dao.AccountDAO;
import com.bank.dao.TransactionDAO;
import com.bank.model.Account;
import com.bank.model.User;
import com.bank.util.AuditLogger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/confirm-transfer")
public class ConfirmTransferServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AccountDAO accountDAO = new AccountDAO();
    private TransactionDAO transactionDAO = new TransactionDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        String receiverAccount = request.getParameter("receiverAccount");
        String receiverName = request.getParameter("receiverName");
        double amount = Double.parseDouble(request.getParameter("amount"));

        Account sender = accountDAO.getAccountByUserId(user.getUserId());

        if (sender == null) {
            request.setAttribute("error", "Sender account not found.");
            request.getRequestDispatcher("transfer.jsp").forward(request, response);
            return;
        }

        boolean status = transactionDAO.transferMoney(
                sender.getAccountNumber(),
                receiverAccount,
                amount
        );

        if (status) {
            request.setAttribute("amount", amount);
            request.setAttribute("receiverAccount", receiverAccount);
            request.setAttribute("receiverName", receiverName);

            AuditLogger.log(user, "FUND_TRANSFER",
                    "Transferred \u20B9" + amount + " from " + sender.getAccountNumber()
                            + " to " + receiverAccount + " (" + receiverName + ")");

            request.getRequestDispatcher("success.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Transfer failed.");
            request.getRequestDispatcher("transfer.jsp").forward(request, response);
        }
    }
}