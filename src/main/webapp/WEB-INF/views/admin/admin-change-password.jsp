<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>

<%!
    private String safe(Object value) {
        if (value == null) {
            return "-";
        }

        String text = String.valueOf(value);

        if (text.trim().isEmpty()) {
            return "-";
        }

        return text;
    }
%>

<%
    User admin = (User) session.getAttribute("user");

    String adminName = "Admin";

    if (admin != null && admin.getFullName() != null && !admin.getFullName().trim().isEmpty()) {
        adminName = admin.getFullName();
    }

    String adminInitial = adminName.trim().length() > 0
            ? adminName.trim().substring(0, 1).toUpperCase()
            : "A";

    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Change Password - DKS Bank Admin</title>

    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=21">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">
</head>

<body class="admin-body">

<div class="admin-layout">

    <aside class="admin-sidebar">

        <div class="admin-logo">
            <span class="admin-logo-icon">
                <i class="bi bi-bank2"></i>
            </span>

            <div>
                <h2>DKS Bank</h2>
                <p>Admin Console</p>
            </div>
        </div>

        <nav class="admin-menu">

            <a href="${pageContext.request.contextPath}/admin">
                <i class="bi bi-speedometer2"></i>
                <span>Admin Dashboard</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/users">
                <i class="bi bi-people"></i>
                <span>User Management</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/accounts">
                <i class="bi bi-wallet2"></i>
                <span>Accounts</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/transactions">
                <i class="bi bi-receipt"></i>
                <span>Transactions</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/reports">
                <i class="bi bi-bar-chart-line"></i>
                <span>Reports</span>
            </a>

            <a href="javascript:void(0)" onclick="return comingSoon('Security');">
                <i class="bi bi-shield-lock"></i>
                <span>Security</span>
            </a>

            <a href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-box-arrow-right"></i>
                <span>Logout</span>
            </a>

        </nav>

        <div class="admin-support-box">
            <i class="bi bi-shield-check"></i>
            <p>Admin Access</p>
            <h4>Secured Panel</h4>
        </div>

    </aside>

    <main class="admin-main">

        <header class="admin-topbar">

            <div class="admin-welcome">
                <h3>Change Password</h3>
                <p>Update your admin account password.</p>
            </div>

            <form action="${pageContext.request.contextPath}/admin/search"
                  method="get"
                  class="admin-search-box">
                <i class="bi bi-search"></i>
                <input type="text"
                       name="q"
                       placeholder="Search users, accounts, transactions..."
                       required>
            </form>

            <div class="admin-top-actions">

                <button type="button"
                        class="admin-icon-btn"
                        onclick="return comingSoon('Notifications');">
                    <i class="bi bi-bell"></i>
                    <span>5</span>
                </button>

                <button type="button"
                        class="admin-icon-btn"
                        onclick="return comingSoon('Messages');">
                    <i class="bi bi-envelope"></i>
                    <span>2</span>
                </button>

                <div class="profile-menu">

                    <div class="admin-profile-chip"
                         onclick="toggleAdminProfileDropdown()"
                         style="cursor: pointer;">
                        <span><%= adminInitial %></span>
                        <i class="bi bi-chevron-down"></i>
                    </div>

                    <div class="profile-dropdown" id="adminProfileDropdown">

                        <div class="profile-head">
                            <h4><%= safe(adminName).toUpperCase() %></h4>
                            <p>Admin Access</p>
                        </div>

                        <a href="${pageContext.request.contextPath}/admin/admin-profile-overview">
                            <i class="bi bi-person-badge"></i>
                            Profile Overview
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/profile">
                            <i class="bi bi-person"></i>
                            My Profile
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/change-password">
                            <i class="bi bi-key"></i>
                            Change Password
                        </a>

                        <a href="javascript:void(0)" onclick="return comingSoon('Notifications');">
                            <i class="bi bi-bell"></i>
                            Notifications
                        </a>

                        <a href="javascript:void(0)" onclick="return comingSoon('Profile Settings');">
                            <i class="bi bi-gear"></i>
                            Profile Settings
                        </a>

                        <a href="${pageContext.request.contextPath}/logout" class="dropdown-logout">
                            <i class="bi bi-box-arrow-right"></i>
                            Logout
                        </a>

                    </div>

                </div>

                <a href="${pageContext.request.contextPath}/logout" class="admin-logout-btn">
                    <i class="bi bi-power"></i>
                    Logout
                </a>

            </div>

        </header>

        <section class="admin-content">

            <div class="admin-page-heading">
                <div>
                    <h1>Change Password</h1>
                    <p>Enter your current password and set a new password.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/profile" class="admin-export-btn">
                    <i class="bi bi-arrow-left"></i>
                    Back to My Profile
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
                            <p>Choose a strong new password for your admin account.</p>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/admin/change-password"
                          method="post"
                          onsubmit="return validateAdminPasswordForm()">

                        <div class="cp-form-group">
                            <label>Current Password</label>

                            <div class="cp-input">
                                <i class="bi bi-lock"></i>
                                <input type="password"
                                       name="currentPassword"
                                       id="currentPassword"
                                       placeholder="Enter current password"
                                       required>
                                <button type="button" onclick="toggleAdminPassword('currentPassword', this)">
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
                                       oninput="checkAdminStrength()"
                                       required>
                                <button type="button" onclick="toggleAdminPassword('newPassword', this)">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>

                            <div class="password-strength">
                                <div id="adminStrengthBar"></div>
                            </div>

                            <small id="adminStrengthText" class="strength-text">
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
                                <button type="button" onclick="toggleAdminPassword('confirmPassword', this)">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>

                            <small id="adminMatchText" class="strength-text"></small>
                        </div>

                        <div class="cp-security-note">
                            <i class="bi bi-info-circle"></i>
                            <p>
                                Use at least 6 characters. For better security, use uppercase,
                                lowercase, numbers and special characters.
                            </p>
                        </div>

                        <div class="cp-buttons">
                            <button type="reset" class="cp-cancel-btn" onclick="resetAdminStrength()">
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
                        <p>Do not share your admin password with anyone.</p>
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

<div class="dks-popup-overlay" id="dksComingOverlay">
    <div class="dks-popup-box">

        <button type="button" class="dks-popup-close" onclick="closeComingSoon()">
            <i class="bi bi-x-lg"></i>
        </button>

        <div class="dks-popup-icon">
            <i class="bi bi-hourglass-split"></i>
        </div>

        <h2>Coming Soon!</h2>

        <p>
            <span id="dksComingFeature">This feature</span>
            is currently under development.
        </p>

        <button type="button" class="dks-popup-ok" onclick="closeComingSoon()">
            OK
        </button>

    </div>
</div>

<script>
    function comingSoon(featureName) {
        const overlay = document.getElementById("dksComingOverlay");
        const feature = document.getElementById("dksComingFeature");

        if (feature) {
            feature.textContent = featureName || "This feature";
        }

        if (overlay) {
            overlay.classList.add("show");
        }

        return false;
    }

    function closeComingSoon() {
        const overlay = document.getElementById("dksComingOverlay");

        if (overlay) {
            overlay.classList.remove("show");
        }
    }

    function toggleAdminProfileDropdown() {
        const dropdown = document.getElementById("adminProfileDropdown");

        if (dropdown) {
            dropdown.classList.toggle("show");
        }
    }

    document.addEventListener("click", function (event) {
        if (!event.target.closest(".profile-menu")) {
            const dropdown = document.getElementById("adminProfileDropdown");

            if (dropdown && dropdown.classList.contains("show")) {
                dropdown.classList.remove("show");
            }
        }
    });
</script>

<script>
    function toggleAdminPassword(inputId, button) {
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

    function checkAdminStrength() {
        const password = document.getElementById("newPassword").value;
        const bar = document.getElementById("adminStrengthBar");
        const text = document.getElementById("adminStrengthText");

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

    function validateAdminPasswordForm() {
        const currentPassword = document.getElementById("currentPassword").value.trim();
        const newPassword = document.getElementById("newPassword").value.trim();
        const confirmPassword = document.getElementById("confirmPassword").value.trim();
        const matchText = document.getElementById("adminMatchText");

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

    function resetAdminStrength() {
        const bar = document.getElementById("adminStrengthBar");
        const text = document.getElementById("adminStrengthText");
        const matchText = document.getElementById("adminMatchText");

        bar.style.width = "0%";
        bar.className = "";
        text.textContent = "Password strength will appear here";
        text.className = "strength-text";
        matchText.textContent = "";
    }
</script>

</body>
</html>
