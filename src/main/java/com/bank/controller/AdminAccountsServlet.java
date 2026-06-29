package com.bank.controller;

import com.bank.dao.AdminDAO;
import com.bank.model.User;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/accounts")
public class AdminAccountsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) {
            return;
        }

        String keyword = request.getParameter("q");

        if (keyword != null && !keyword.trim().isEmpty()) {
            keyword = keyword.trim();
            request.setAttribute("keyword", keyword);
            request.setAttribute("accounts", adminDAO.searchAccounts(keyword));
        } else {
            request.setAttribute("accounts", adminDAO.getAllAccounts());
        }

        request.getRequestDispatcher("/adminAccounts.jsp").forward(request, response);
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }

        User user = (User) session.getAttribute("user");

        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return false;
        }

        return true;
    }
}