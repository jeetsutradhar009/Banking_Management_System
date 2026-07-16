package com.bank.controller.admin;

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

@WebServlet("/admin/add-balance")
public class AddBalanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        String accountNo = request.getParameter("accountNo");
        String customerId = request.getParameter("customerId");

        try {
            if ((accountNo != null && !accountNo.trim().isEmpty())
                    || (customerId != null && !customerId.trim().isEmpty())) {

                request.setAttribute("account", adminDAO.findAccount(accountNo, customerId));
            }

            request.getRequestDispatcher("/add-balance.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("err", e.getMessage());
            request.getRequestDispatcher("/add-balance.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        String accountNumber = request.getParameter("accountNumber");
        String amountStr = request.getParameter("amount");
        String note = request.getParameter("note");

        try {
            BigDecimal amount = new BigDecimal(amountStr);

            if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                throw new Exception("Amount must be greater than 0");
            }

            HttpSession session = request.getSession(false);
            User actor = session != null ? (User) session.getAttribute("user") : null;

            adminDAO.addBalance(actor, accountNumber, amount, note);

            response.sendRedirect(request.getContextPath()
                    + "/admin/add-balance?accountNo=" + accountNumber
                    + "&msg=" + URLEncoder.encode("Balance added successfully", StandardCharsets.UTF_8));

        } catch (Exception e) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/add-balance?accountNo=" + accountNumber
                    + "&err=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }
}
