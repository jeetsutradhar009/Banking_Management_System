package com.bank.controller.admin;

import com.bank.util.AdminAuth;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * "Profile Overview" page - a separate, dedicated page from "My Profile"
 * as requested, even though both currently read the same admin data
 * from the session. Kept as its own servlet/JSP so it has its own URL
 * and can grow independently later without affecting "My Profile" or
 * "Change Password".
 */
@WebServlet("/admin/admin-profile-overview")
public class AdminProfileOverviewServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/admin-profile-overview.jsp").forward(request, response);
    }
}