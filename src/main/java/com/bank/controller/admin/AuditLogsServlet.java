package com.bank.controller.admin;

import com.bank.dao.AdminDAO;
import com.bank.util.AdminAuth;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/audit-logs")
public class AuditLogsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        try {
            request.setAttribute("logs", adminDAO.getAuditLogs());
            request.getRequestDispatcher("/WEB-INF/views/admin/audit-logs.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}