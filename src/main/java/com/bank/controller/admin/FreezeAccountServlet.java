package com.bank.controller.admin;

import com.bank.dao.AdminDAO;
import com.bank.model.User;
import com.bank.util.AdminAuth;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/freeze-account")
public class FreezeAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.setAttribute("accounts", adminDAO.getAllAccounts());
        request.getRequestDispatcher("/freeze-account.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        String accountNumber = request.getParameter("accountNumber");
        String newStatus = request.getParameter("newStatus");

        HttpSession session = request.getSession(false);
        User actor = session != null ? (User) session.getAttribute("user") : null;

        try {
            adminDAO.changeAccountStatus(actor, accountNumber, newStatus);

            String msg = "Account " + accountNumber + " changed to " + newStatus;

            response.sendRedirect(request.getContextPath()
                    + "/admin/freeze-account?msg="
                    + URLEncoder.encode(msg, StandardCharsets.UTF_8));

        } catch (Exception e) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/freeze-account?err="
                    + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }
}
