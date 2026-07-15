package com.bank.controller;

import com.bank.dao.AdminDAO;
import com.bank.model.User;
import com.bank.util.AdminAuth;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/accounts/create")
public class CreateAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.getRequestDispatcher("/create-account.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String accountType = request.getParameter("accountType");
            BigDecimal openingBalance = new BigDecimal(request.getParameter("openingBalance"));

            if (openingBalance.compareTo(BigDecimal.ZERO) < 0) {
                throw new Exception("Opening balance cannot be negative");
            }

            HttpSession session = request.getSession(false);
            User actor = session != null ? (User) session.getAttribute("user") : null;

            String accountNumber = adminDAO.createAccount(actor, userId, accountType, openingBalance);

            String msg = "Account created successfully: " + accountNumber;

            response.sendRedirect(request.getContextPath()
                    + "/admin/accounts/create?msg="
                    + URLEncoder.encode(msg, StandardCharsets.UTF_8));

        } catch (Exception e) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/accounts/create?err="
                    + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }
}