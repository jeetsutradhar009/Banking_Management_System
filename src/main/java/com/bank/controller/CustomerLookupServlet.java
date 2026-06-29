package com.bank.controller;

import com.bank.dao.UserDAO;
import com.bank.model.RegistrationInfo;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/customer-lookup")
public class CustomerLookupServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String customerId = request.getParameter("customerId");

        if (customerId == null || customerId.trim().isEmpty()) {
            response.getWriter().write("{\"found\":false,\"message\":\"Customer ID required\"}");
            return;
        }

        RegistrationInfo info = userDAO.getRegistrationInfoByCustomerId(customerId.trim());

        if (info == null) {
            response.getWriter().write("{\"found\":false,\"message\":\"Customer ID not found\"}");
            return;
        }

        if (info.isOnlineBankingEnabled()) {
            response.getWriter().write("{\"found\":false,\"message\":\"Online banking already registered for this Customer ID\"}");
            return;
        }

        String json =
                "{" +
                "\"found\":true," +
                "\"customerId\":\"" + esc(info.getCustomerId()) + "\"," +
                "\"fullName\":\"" + esc(info.getFullName()) + "\"," +
                "\"accountNumber\":\"" + esc(info.getAccountNumber()) + "\"," +
                "\"ifscCode\":\"" + esc(info.getIfscCode()) + "\"," +
                "\"email\":\"" + esc(info.getEmail()) + "\"," +
                "\"phone\":\"" + esc(info.getPhone()) + "\"" +
                "}";

        response.getWriter().write(json);
    }

    private String esc(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}