<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String fullName = user.getFullName() != null ? user.getFullName() : "User";

    String initials = "U";
    String[] nameParts = fullName.trim().split(" ");

    if (nameParts.length >= 2) {
        initials = nameParts[0].substring(0, 1).toUpperCase()
                + nameParts[1].substring(0, 1).toUpperCase();
    } else if (fullName.length() >= 1) {
        initials = fullName.substring(0, 1).toUpperCase();
    }

    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Change Password - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=204">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">
</head>

<body>

<div class="app-layout">

    <aside class="sidebar">

        <div class="logo">
            <div class="logo-icon">
                <i class="bi bi-bank2"></i>
            </div>

            <div>
                <h2>DKS Bank</h2>
                <p>Online Banking</p>
            </div>
        </div>

        <nav class="side-menu">

    <a href="${pageContext.request.contextPath}/dashboard">
        <i class="bi bi-house-door"></i>
        <span>Dashboard</span>
    </a>

    <a href="${pageContext.request.contextPath}/myAccount">
        <i class="bi bi-person-circle"></i>
        <span>My Account</span>
    </a>

    <a href="${pageContext.request.contextPath}/transfer">
        <i class="bi bi-send"></i>
        <span>Fund Transfer</span>
    </a>

    <a href="${pageContext.request.contextPath}/history">
        <i class="bi bi-receipt"></i>
        <span>Transaction History</span>
    </a>

    <a href="#" onclick="alert('Cards - Coming Soon!'); return false;">
        <i class="bi bi-credit-card"></i>
        <span>Cards</span>
    </a>

    <a href="${pageContext.request.contextPath}/services">
        <i class="bi bi-gear"></i>
        <span>Services</span>
    </a>

    <a href="${pageContext.request.contextPath}/change-password" class="active">
        <i class="bi bi-key"></i>
        <span>Change Password</span>
    </a>

    <a href="${pageContext.request.contextPath}/logout">
        <i class="bi bi-box-arrow-right"></i>
        <span>Logout</span>
    </a>

</nav>

        <div class="support-box">
            <i class="bi bi-headset"></i>
            <p>Need Help?</p>
            <h4>24x7 Support</h4>
        </div>

    </aside>

    <main class="main-panel">

        <header class="topbar">

            <div class="welcome-box">
                <h3>Change Password</h3>
                <p>Update your login password securely.</p>
            </div>

            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Search security, profile, services...">
            </div>

            <div class="top-actions">

                <button class="icon-btn" type="button">
                    <i class="bi bi-bell"></i>
                    <span>3</span>
                </button>

                <button class="icon-btn" type="button">
                    <i class="bi bi-envelope"></i>
                    <span>8</span>
                </button>

                <button class="icon-btn no-badge" type="button">
                    <i class="bi bi-question-circle"></i>
                </button>

                <div class="profile-menu">

                    <button class="profile-btn" onclick="toggleProfileDropdown()" type="button">
                        <span class="profile-avatar"><%= initials %></span>
                        <i class="bi bi-chevron-down"></i>
                    </button>

                    <div class="profile-dropdown" id="profileDropdown">

                        <div class="profile-head">
                            <h4><%= fullName.toUpperCase() %></h4>
                            <p>Last Login: 15-06-2026 01:00 PM IST</p>
                        </div>

                        <a href="${pageContext.request.contextPath}/profileOverview.jsp">
                            <i class="bi bi-person-badge"></i>
                            Profile Overview
                        </a>

                        <a href="${pageContext.request.contextPath}/myAccount">
                            <i class="bi bi-person"></i>
                            My Profile
                        </a>

                        <a href="${pageContext.request.contextPath}/change-password">
                            <i class="bi bi-key"></i>
                            Change Password
                        </a>

                        <a href="#">
                            <i class="bi bi-bell"></i>
                            Notifications
                        </a>

                        <a href="#">
                            <i class="bi bi-gear"></i>
                            Profile Settings
                        </a>

                        <a href="${pageContext.request.contextPath}/logout" class="dropdown-logout">
                            <i class="bi bi-box-arrow-right"></i>
                            Logout
                        </a>

                    </div>

                </div>

                <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                    <i class="bi bi-power"></i>
                    Logout
                </a>

            </div>

        </header>

        <section class="page-content">

            <div class="cp-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <i class="bi bi-chevron-right"></i>
                <span>Change Password</span>
            </div>

            <div class="cp-header">
                <div>
                    <h1>Change Password</h1>
                    <p>Create a strong password to keep your DKS Bank account secure.</p>
                </div>

                <a href="${pageContext.request.contextPath}/myAccount" class="cp-outline-btn">
                    <i class="bi bi-person-circle"></i>
                    My Account
                </a>
            </div>

            <% if (error != null) { %>
                <div class="cp-alert error">
                    <i class="bi bi-exclamation-circle"></i>
                    <%= error %>
                </div>
            <% } %>

            <% if (success != null) { %>
                <div class="cp-alert success">
                    <i class="bi bi-check-circle"></i>
                    <%= success %>
                </div>
            <% } %>

            <div class="cp-layout">

                <div class="cp-main-card">

                    <div class="cp-card-head">
                        <div class="cp-lock-icon">
                            <i class="bi bi-shield-lock"></i>
                        </div>

                        <div>
                            <h2>Update Password</h2>
                            <p>Enter your current password and set a new password.</p>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/change-password" method="post" onsubmit="return validatePasswordForm()">

                        <div class="cp-form-group">
                            <label>Current Password</label>

                            <div class="cp-input">
                                <i class="bi bi-lock"></i>
                                <input type="password"
                                       name="currentPassword"
                                       id="currentPassword"
                                       placeholder="Enter current password"
                                       required>
                                <button type="button" onclick="togglePassword('currentPassword', this)">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="cp-form-group">
                            <label>New Password</label>

                            <div class="cp-input">
                                <i class="bi bi-key"></i>
                                <input type="password"
                                       name="newPassword"
                                       id="newPassword"
                                       placeholder="Enter new password"
                                       oninput="checkStrength()"
                                       required>
                                <button type="button" onclick="togglePassword('newPassword', this)">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>

                            <div class="password-strength">
                                <div id="strengthBar"></div>
                            </div>

                            <small id="strengthText" class="strength-text">
                                Password strength will appear here
                            </small>
                        </div>

                        <div class="cp-form-group">
                            <label>Confirm New Password</label>

                            <div class="cp-input">
                                <i class="bi bi-check2-circle"></i>
                                <input type="password"
                                       name="confirmPassword"
                                       id="confirmPassword"
                                       placeholder="Confirm new password"
                                       required>
                                <button type="button" onclick="togglePassword('confirmPassword', this)">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>

                            <small id="matchText" class="strength-text"></small>
                        </div>

                        <div class="cp-security-note">
                            <i class="bi bi-info-circle"></i>
                            <p>
                                Use at least 6 characters. For better security, use uppercase,
                                lowercase, numbers and special characters.
                            </p>
                        </div>

                        <div class="cp-buttons">
                            <button type="reset" class="cp-cancel-btn" onclick="resetStrength()">
                                <i class="bi bi-x-circle"></i>
                                Clear
                            </button>

                            <button type="submit" class="cp-submit-btn">
                                <i class="bi bi-shield-check"></i>
                                Update Password
                            </button>
                        </div>

                    </form>

                </div>

                <div class="cp-side">

                    <div class="cp-side-card">
                        <i class="bi bi-shield-check"></i>
                        <h3>Security Tip</h3>
                        <p>Do not share your banking password with anyone.</p>
                    </div>

                    <div class="cp-side-card gold">
                        <i class="bi bi-key"></i>
                        <h3>Strong Password</h3>
                        <p>Use a mix of letters, numbers and special characters.</p>
                    </div>

                    <div class="cp-side-card danger">
                        <i class="bi bi-exclamation-triangle"></i>
                        <h3>Important</h3>
                        <p>Never use your phone number or date of birth as password.</p>
                    </div>

                </div>

            </div>

        </section>

    </main>

</div>

<script>
    function toggleProfileDropdown() {
        const dropdown = document.getElementById("profileDropdown");
        dropdown.classList.toggle("show");
    }

    window.onclick = function(event) {
        if (!event.target.closest(".profile-menu")) {
            const dropdown = document.getElementById("profileDropdown");

            if (dropdown && dropdown.classList.contains("show")) {
                dropdown.classList.remove("show");
            }
        }
    }
</script>

<script>
    function togglePassword(inputId, button) {
        const input = document.getElementById(inputId);
        const icon = button.querySelector("i");

        if (input.type === "password") {
            input.type = "text";
            icon.className = "bi bi-eye-slash";
        } else {
            input.type = "password";
            icon.className = "bi bi-eye";
        }
    }

    function checkStrength() {
        const password = document.getElementById("newPassword").value;
        const bar = document.getElementById("strengthBar");
        const text = document.getElementById("strengthText");

        let score = 0;

        if (password.length >= 6) score++;
        if (password.length >= 8) score++;
        if (/[A-Z]/.test(password)) score++;
        if (/[0-9]/.test(password)) score++;
        if (/[^A-Za-z0-9]/.test(password)) score++;

        bar.className = "";

        if (password.length === 0) {
            bar.style.width = "0%";
            text.textContent = "Password strength will appear here";
            text.className = "strength-text";
        } else if (score <= 2) {
            bar.style.width = "35%";
            bar.className = "weak";
            text.textContent = "Weak password";
            text.className = "strength-text weak";
        } else if (score <= 4) {
            bar.style.width = "70%";
            bar.className = "medium";
            text.textContent = "Medium password";
            text.className = "strength-text medium";
        } else {
            bar.style.width = "100%";
            bar.className = "strong";
            text.textContent = "Strong password";
            text.className = "strength-text strong";
        }
    }

    function validatePasswordForm() {
        const currentPassword = document.getElementById("currentPassword").value.trim();
        const newPassword = document.getElementById("newPassword").value.trim();
        const confirmPassword = document.getElementById("confirmPassword").value.trim();
        const matchText = document.getElementById("matchText");

        if (currentPassword.length === 0 || newPassword.length === 0 || confirmPassword.length === 0) {
            matchText.textContent = "All fields are required";
            matchText.className = "strength-text weak";
            return false;
        }

        if (newPassword.length < 6) {
            matchText.textContent = "New password must be at least 6 characters";
            matchText.className = "strength-text weak";
            return false;
        }

        if (newPassword !== confirmPassword) {
            matchText.textContent = "New password and confirm password do not match";
            matchText.className = "strength-text weak";
            return false;
        }

        if (currentPassword === newPassword) {
            matchText.textContent = "New password cannot be same as current password";
            matchText.className = "strength-text weak";
            return false;
        }

        matchText.textContent = "";
        return true;
    }

    function resetStrength() {
        const bar = document.getElementById("strengthBar");
        const text = document.getElementById("strengthText");
        const matchText = document.getElementById("matchText");

        bar.style.width = "0%";
        bar.className = "";
        text.textContent = "Password strength will appear here";
        text.className = "strength-text";
        matchText.textContent = "";
    }
</script>

<script>
    function toggleProfileDropdown() {
        const dropdown = document.getElementById("profileDropdown");

        if (dropdown) {
            dropdown.classList.toggle("show");
        }
    }

    document.addEventListener("click", function (event) {
        if (!event.target.closest(".profile-menu")) {
            const dropdown = document.getElementById("profileDropdown");

            if (dropdown && dropdown.classList.contains("show")) {
                dropdown.classList.remove("show");
            }
        }
    });
</script>


</body>
</html>