package com.bank.controller;

import com.bank.dao.AccountDAO;
import com.bank.dao.TransactionDAO;
import com.bank.model.Account;
import com.bank.model.Transaction;
import com.bank.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/history")
public class TransactionHistoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AccountDAO accountDAO = new AccountDAO();
    private TransactionDAO transactionDAO = new TransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        Account account = accountDAO.getAccountByUserId(user.getUserId());

        if (account == null) {
            request.setAttribute("error", "Account not found.");
            request.getRequestDispatcher("error.jsp").forward(request, response);
            return;
        }

        List<Transaction> txList = transactionDAO.getUserTransactions(account.getAccountNumber());

        request.setAttribute("account", account);
        request.setAttribute("txList", txList);

        request.getRequestDispatcher("history.jsp").forward(request, response);
    }
}