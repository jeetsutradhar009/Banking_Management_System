package com.bank.controller;

import com.bank.dao.UserDAO;
import com.bank.model.AccountOpenResult;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/open-account")
public class OpenAccountServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("openAccount.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String accountType = request.getParameter("accountType");
        String initialDepositStr = request.getParameter("initialDeposit");

        try {
            if (isEmpty(firstName) || isEmpty(lastName) || isEmpty(dob)
                    || isEmpty(address) || isEmpty(email) || isEmpty(phone)
                    || isEmpty(accountType) || isEmpty(initialDepositStr)) {

                request.setAttribute("error", "All fields are required.");
                request.getRequestDispatcher("openAccount.jsp").forward(request, response);
                return;
            }

            if (!phone.matches("[0-9]{10}")) {
                request.setAttribute("error", "Phone number must be 10 digits.");
                request.getRequestDispatcher("openAccount.jsp").forward(request, response);
                return;
            }

            double initialDeposit = Double.parseDouble(initialDepositStr);

            if (initialDeposit < 500) {
                request.setAttribute("error", "Initial deposit must be at least ₹500.");
                request.getRequestDispatcher("openAccount.jsp").forward(request, response);
                return;
            }

            AccountOpenResult result = userDAO.openBankAccount(
                    firstName,
                    lastName,
                    dob,
                    address,
                    email,
                    phone,
                    accountType,
                    initialDeposit
            );

            if (result.isSuccess()) {
                request.setAttribute("success", result.getMessage());
                request.setAttribute("customerId", result.getCustomerId());
                request.setAttribute("accountNumber", result.getAccountNumber());
                request.setAttribute("ifscCode", result.getIfscCode());
            } else {
                request.setAttribute("error", result.getMessage());
            }

            request.getRequestDispatcher("openAccount.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid initial deposit amount.");
            request.getRequestDispatcher("openAccount.jsp").forward(request, response);
        }
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}