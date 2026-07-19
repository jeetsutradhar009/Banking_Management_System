package com.bank.controller.account;

import com.bank.dao.AccountDAO;
import com.bank.model.Account;
import com.bank.model.User;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/myAccount")
public class MyAccountServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        Account account = accountDAO.getAccountByUserId(user.getUserId());

        request.setAttribute("account", account);
        request.setAttribute("accountLoaded", true);

        if (account == null) {
            request.setAttribute("error", "Your account not found.");
        }

        request.getRequestDispatcher("/WEB-INF/views/user/myAccount.jsp").forward(request, response);
    }
}