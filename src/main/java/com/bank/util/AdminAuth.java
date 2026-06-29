package com.bank.util;

import java.io.IOException;
import java.lang.reflect.Method;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AdminAuth {

    public static boolean requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please login first");
            return false;
        }

        String role = null;

        String[] roleKeys = {"role", "userRole"};
        for (String key : roleKeys) {
            Object value = session.getAttribute(key);
            if (value != null) {
                role = String.valueOf(value);
                break;
            }
        }

        String[] userKeys = {"user", "loggedUser", "currentUser", "loginUser"};
        for (String key : userKeys) {
            Object userObj = session.getAttribute(key);

            if ((role == null || role.isBlank()) && userObj != null) {
                try {
                    Method getRoleMethod = userObj.getClass().getMethod("getRole");
                    Object value = getRoleMethod.invoke(userObj);

                    if (value != null) {
                        role = String.valueOf(value);
                        break;
                    }
                } catch (Exception ignored) {
                }
            }
        }

        if (!"ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Admin access required");
            return false;
        }

        return true;
    }
}