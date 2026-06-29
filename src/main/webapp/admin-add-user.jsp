<%@ page import="com.bank.model.User" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add User - DKS Bank</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=204">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>

<body>

<div class="admin-page add-user-page">

    <div class="add-user-header">
        <div class="add-user-title">
            <h1>Add User</h1>
            <p>Create a new customer or admin account for DKS Bank.</p>
        </div>

        <a class="add-user-dashboard-btn" href="${pageContext.request.contextPath}/admin">
            <i class="bi bi-arrow-left"></i>
            Dashboard
        </a>
    </div>

    <% if (request.getParameter("msg") != null) { %>
        <div class="success"><%= request.getParameter("msg") %></div>
    <% } %>

    <% if (request.getParameter("err") != null) { %>
        <div class="error"><%= request.getParameter("err") %></div>
    <% } %>

    <div class="add-user-layout">

        <div class="add-user-info-card">
            <div class="add-user-info-content">

                <div class="add-user-bank-icon">
                    <i class="bi bi-bank2"></i>
                </div>

                <h2>Create Secure User Profile</h2>

                <p>
                    Add new users safely to the banking system. After creating a user,
                    you can create their bank account from the Accounts section.
                </p>

                <div class="add-user-points">
                    <div class="add-user-point">
                        <span><i class="bi bi-shield-check"></i></span>
                        Role-based access
                    </div>

                    <div class="add-user-point">
                        <span><i class="bi bi-person-check"></i></span>
                        Customer profile setup
                    </div>

                    <div class="add-user-point">
                        <span><i class="bi bi-clock-history"></i></span>
                        Admin activity tracking
                    </div>
                </div>

                <div class="add-user-admin-chip">
                    <small>Logged in as</small>
                    <strong><%= fullName %></strong>
                </div>

            </div>
        </div>

        <div class="add-user-form-card">

            <div class="add-user-form-top">
                <div>
                    <h2>User Details</h2>
                    <p>Fill the details carefully before adding a new user.</p>
                </div>

                <span class="add-user-secure-badge">
                    <i class="bi bi-lock-fill"></i>
                    Secure Entry
                </span>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/admin/add-user">

                <div class="add-user-form-grid">

                    <div class="add-user-field">
                        <label>Full Name</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-person"></i>
                            <input type="text" name="fullName" placeholder="Enter full name" required>
                        </div>
                    </div>

                    <div class="add-user-field">
                        <label>Email</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-envelope"></i>
                            <input type="email" name="email" placeholder="Enter email address" required>
                        </div>
                    </div>

                    <div class="add-user-field">
                        <label>Phone</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-telephone"></i>
                            <input type="text" name="phone" placeholder="Enter phone number" required>
                        </div>
                    </div>

                    <div class="add-user-field">
                        <label>Role</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-person-badge"></i>
                            <select name="role" required>
                                <option value="USER">USER</option>
                                <option value="ADMIN">ADMIN</option>
                            </select>
                        </div>
                    </div>

                    <div class="add-user-field full">
                        <label>Password</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-key"></i>
                            <input type="password" name="password" id="passwordInput" placeholder="Create password" required>

                            <button type="button" class="password-toggle" onclick="togglePassword()">
                                <i class="bi bi-eye" id="passwordIcon"></i>
                            </button>
                        </div>

                        <div class="add-user-help">
                            Use a strong password for better account security.
                        </div>
                    </div>

                </div>

                <div class="add-user-submit-row">
                    <div class="add-user-note">
                        <i class="bi bi-info-circle"></i>
                        User will be stored in the database after submission.
                    </div>

                    <button type="submit" class="add-user-submit-btn">
                        <i class="bi bi-person-plus"></i>
                        Add User
                    </button>
                </div>

            </form>

        </div>

    </div>

</div>

<script>
    function togglePassword() {
        const input = document.getElementById("passwordInput");
        const icon = document.getElementById("passwordIcon");

        if (input.type === "password") {
            input.type = "text";
            icon.className = "bi bi-eye-slash";
        } else {
            input.type = "password";
            icon.className = "bi bi-eye";
        }
    }
</script>

</body>
</html>