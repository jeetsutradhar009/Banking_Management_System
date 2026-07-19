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

    String employeeId = admin != null ? admin.getCustomerId() : null;
    String email = admin != null ? admin.getEmail() : null;
    String phone = admin != null ? admin.getPhone() : null;
    String role = admin != null ? admin.getRole() : null;

    String adminInitial = adminName.trim().length() > 0
            ? adminName.trim().substring(0, 1).toUpperCase()
            : "A";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Profile Overview - DKS Bank Admin</title>

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
                <h3>Profile Overview</h3>
                <p>A quick glance at your admin account.</p>
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
                    <h1>Profile Overview</h1>
                    <p>Summary of your admin account.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin" class="admin-export-btn">
                    <i class="bi bi-arrow-left"></i>
                    Back to Dashboard
                </a>
            </div>

            <div class="myacc-panel">

                <div class="myacc-panel-head">
                    <h3><i class="bi bi-person-badge"></i> Account Summary</h3>
                </div>

                <div class="myacc-info-row">
                    <span>Name</span>
                    <b><%= safe(adminName) %></b>
                </div>

                <div class="myacc-info-row">
                    <span>Role</span>
                    <b><%= safe(role) %></b>
                </div>

                <div class="myacc-info-row">
                    <span>Employee / Admin ID</span>
                    <b><%= safe(employeeId) %></b>
                </div>

                <div class="myacc-info-row">
                    <span>Email</span>
                    <b><%= safe(email) %></b>
                </div>

                <div class="myacc-info-row">
                    <span>Mobile</span>
                    <b><%= safe(phone) %></b>
                </div>

            </div>

            <div class="admin-top-actions" style="margin-top: 18px;">

                <a href="${pageContext.request.contextPath}/admin/profile" class="admin-export-btn">
                    <i class="bi bi-person"></i>
                    View Full Profile
                </a>

                <a href="${pageContext.request.contextPath}/admin/change-password" class="admin-export-btn">
                    <i class="bi bi-key"></i>
                    Change Password
                </a>

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

</body>
</html>
