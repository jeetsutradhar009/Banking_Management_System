package com.bank.controller.transaction;

import com.bank.dao.AccountDAO;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/check-account")
public class CheckAccountServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.getWriter().write("{\"found\":false,\"message\":\"Session expired. Please login again.\"}");
            return;
        }

        String accountNumber = request.getParameter("accountNumber");

        if (accountNumber == null || accountNumber.trim().isEmpty()) {
            response.getWriter().write("{\"found\":false,\"message\":\"Account number required\"}");
            return;
        }

        accountNumber = accountNumber.trim();

        try {
            String holderName = accountDAO.getAccountHolderNameByAccountNumber(accountNumber);

            if (holderName == null || holderName.trim().isEmpty()) {
                response.getWriter().write("{\"found\":false,\"message\":\"Account not found\"}");
                return;
            }

            holderName = holderName.replace("\\", "\\\\").replace("\"", "\\\"");

            response.getWriter().write(
                    "{\"found\":true,\"holderName\":\"" + holderName + "\"}"
            );

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"found\":false,\"message\":\"Something went wrong\"}");
        }
    }
}