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

@WebServlet("/admin/add-user")
public class AddUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.getRequestDispatcher("/admin-add-user.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        HttpSession session = request.getSession(false);
        User actor = session != null ? (User) session.getAttribute("user") : null;

        try {
            adminDAO.addUser(actor, fullName, email, phone, password, role);
            redirect(response, request, "User added successfully", null);
        } catch (Exception e) {
            redirect(response, request, null, e.getMessage());
        }
    }

    private void redirect(HttpServletResponse response, HttpServletRequest request, String msg, String err) throws IOException {
        String url = request.getContextPath() + "/admin/add-user";

        if (msg != null) {
            url += "?msg=" + URLEncoder.encode(msg, StandardCharsets.UTF_8);
        }

        if (err != null) {
            url += "?err=" + URLEncoder.encode(err, StandardCharsets.UTF_8);
        }

        response.sendRedirect(url);
    }
}
