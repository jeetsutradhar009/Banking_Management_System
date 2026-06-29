package com.bank.controller;

import com.bank.dao.AccountDAO;
import com.bank.model.Account;
import com.bank.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/transfer")
public class TransferServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        Account account = accountDAO.getAccountByUserId(user.getUserId());

        request.setAttribute("account", account);
        request.setAttribute("accountLoaded", true);

        if (account == null) {
            request.setAttribute("error", "Your account not found.");
        }

        request.getRequestDispatcher("transfer.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        Account senderAccount = accountDAO.getAccountByUserId(user.getUserId());

        request.setAttribute("account", senderAccount);
        request.setAttribute("accountLoaded", true);

        if (senderAccount == null) {
            request.setAttribute("error", "Your account not found.");
            request.getRequestDispatcher("transfer.jsp").forward(request, response);
            return;
        }

        String receiverAccount = request.getParameter("receiverAccount");
        String amountStr = request.getParameter("amount");

        try {
            if (receiverAccount == null || receiverAccount.trim().isEmpty()
                    || amountStr == null || amountStr.trim().isEmpty()) {

                request.setAttribute("error", "Receiver account and amount are required.");
                request.getRequestDispatcher("transfer.jsp").forward(request, response);
                return;
            }

            receiverAccount = receiverAccount.trim();

            double amount = Double.parseDouble(amountStr);

            if (amount <= 0) {
                request.setAttribute("error", "Amount must be greater than 0.");
                request.getRequestDispatcher("transfer.jsp").forward(request, response);
                return;
            }

            if (senderAccount.getAccountNumber().equals(receiverAccount)) {
                request.setAttribute("error", "You cannot transfer money to your own account.");
                request.getRequestDispatcher("transfer.jsp").forward(request, response);
                return;
            }

            Account receiver = accountDAO.getAccountByAccountNumber(receiverAccount);

            if (receiver == null) {
                request.setAttribute("error", "Receiver account not found.");
                request.getRequestDispatcher("transfer.jsp").forward(request, response);
                return;
            }

            String receiverName = accountDAO.getAccountHolderNameByAccountNumber(receiverAccount);

            if (receiverName == null || receiverName.trim().isEmpty()) {
                receiverName = "Account Holder";
            }

            if (senderAccount.getBalance() < amount) {
                request.setAttribute("error", "Insufficient balance.");
                request.getRequestDispatcher("transfer.jsp").forward(request, response);
                return;
            }

            request.setAttribute("receiverAccount", receiverAccount);
            request.setAttribute("receiverName", receiverName);
            request.setAttribute("amount", amount);

            request.getRequestDispatcher("confirmTransfer.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid amount.");
            request.getRequestDispatcher("transfer.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Something went wrong: " + e.getMessage());
            request.getRequestDispatcher("transfer.jsp").forward(request, response);
        }
    }
}