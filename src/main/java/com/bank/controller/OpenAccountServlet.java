package com.bank.controller;

import com.bank.dao.OtpDAO;
import com.bank.dao.UserDAO;
import com.bank.model.AccountOpenResult;
import com.bank.util.AuditLogger;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/open-account")
public class OpenAccountServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OtpDAO otpDAO = new OtpDAO();
    private final UserDAO userDAO = new UserDAO();

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
        String verificationToken = request.getParameter("verificationToken");

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

            // ------------------------------------------------------------
            // Email verification gate:
            // The email is verified separately and BEFORE this form is
            // submitted, via the inline popup on openAccount.jsp
            // (SendEmailVerificationServlet -> VerifyEmailOtpServlet).
            // This servlet only re-checks, server-side, that the
            // verificationToken submitted with the form corresponds to
            // a record where this exact email was already verified -
            // this cannot be bypassed by tampering with a hidden field
            // in dev tools, since isEmailVerified() re-queries the DB.
            // ------------------------------------------------------------

            if (isEmpty(verificationToken) || !otpDAO.isEmailVerified(verificationToken.trim(), email.trim())) {
                request.setAttribute("error", "Please verify your email before creating an account.");
                request.getRequestDispatcher("openAccount.jsp").forward(request, response);
                return;
            }

            AccountOpenResult result = userDAO.openBankAccount(
                    firstName, lastName, dob, address, email, phone, accountType, initialDeposit
            );

            if (result.isSuccess()) {
                request.setAttribute("success", result.getMessage());
                request.setAttribute("customerId", result.getCustomerId());
                request.setAttribute("accountNumber", result.getAccountNumber());
                request.setAttribute("ifscCode", result.getIfscCode());

                AuditLogger.logByIdentifier(result.getCustomerId(), firstName + " " + lastName,
                        "OPEN_ACCOUNT", "New account opened: " + result.getAccountNumber()
                                + " (Customer ID " + result.getCustomerId() + ")");
            } else {
                request.setAttribute("error", result.getMessage());
            }

            request.getRequestDispatcher("openAccount.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid initial deposit amount.");
            request.getRequestDispatcher("openAccount.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Something went wrong while creating the account. Please check your details and try again.");
            request.getRequestDispatcher("openAccount.jsp").forward(request, response);
        }
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}
