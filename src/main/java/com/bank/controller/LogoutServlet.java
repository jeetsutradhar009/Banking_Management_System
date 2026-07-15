package com.bank.controller;

import com.bank.model.User;
import com.bank.util.AuditLogger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            Object obj = session.getAttribute("user");

            if (obj instanceof User) {
                User user = (User) obj;
                AuditLogger.log(user, "LOGOUT",
                        ("ADMIN".equalsIgnoreCase(user.getRole()) ? "Admin" : "User") + " logged out");
            }

            session.invalidate();
        }

        response.sendRedirect("login.jsp");
    }
}