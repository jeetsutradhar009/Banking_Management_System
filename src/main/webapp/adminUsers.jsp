<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="java.util.List" %>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String keyword = (String) request.getAttribute("keyword");
    List<User> users = (List<User>) request.getAttribute("users");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Management - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=204">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>

<body>

<div class="admin-layout">

    <aside class="admin-sidebar">

        <div class="admin-logo">
            <div class="admin-logo-icon">
                <i class="bi bi-bank2"></i>
            </div>
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

            <a href="${pageContext.request.contextPath}/admin/users" class="active">
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

            <a href="#" onclick="return comingSoon('Security Settings');">
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
                <h3>User Management</h3>
                <p>Welcome, <%= fullName %></p>
            </div>

            <form action="${pageContext.request.contextPath}/admin/users" method="get" class="admin-search-box">
                <i class="bi bi-search"></i>
                <input type="text" name="q" placeholder="Search users by name, email, phone, role..."
                       value="<%= keyword != null ? keyword : "" %>">
            </form>

            <div class="admin-top-actions">
                <a href="${pageContext.request.contextPath}/admin" class="admin-logout-btn">
                    <i class="bi bi-arrow-left"></i>
                    Dashboard
                </a>

                <a href="${pageContext.request.contextPath}/logout" class="admin-logout-btn">
                    <i class="bi bi-power"></i>
                    Logout
                </a>
            </div>

        </header>

        <section class="admin-content">

            <div class="admin-page-heading">
                <div>
                    <h1>All Users</h1>
                    <p>
                        <% if (keyword != null) { %>
                            Search results for "<%= keyword %>"
                        <% } else { %>
                            Complete list of registered users.
                        <% } %>
                    </p>
                </div>

                <button type="button" onclick="return comingSoon('Add New User');">
                    <i class="bi bi-person-plus"></i>
                    Add User
                </button>
            </div>

            <div class="admin-panel">

                <div class="admin-section-head">
                    <h3>User List</h3>
                    <a href="${pageContext.request.contextPath}/admin/users">Clear Search</a>
                </div>

                <div class="admin-table-wrap">

                    <table class="admin-table">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>User</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                        </tr>
                        </thead>

                        <tbody>
                        <%
                            if (users != null && !users.isEmpty()) {
                                for (User u : users) {
                                    String name = u.getFullName() != null ? u.getFullName() : "User";
                        %>
                        <tr>
                            <td>#<%= u.getUserId() %></td>
                            <td>
                                <div class="admin-user-cell">
                                    <span><%= name.substring(0, 1).toUpperCase() %></span>
                                    <b><%= name %></b>
                                </div>
                            </td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getPhone() != null ? u.getPhone() : "N/A" %></td>
                            <td><span class="admin-badge-role"><%= u.getRole() %></span></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" class="admin-empty-row">No users found.</td>
                        </tr>
                        <%
                            }
                        %>
                        </tbody>
                    </table>

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
        <p><span id="dksComingFeature">This feature</span> is currently under development.</p>
        <button type="button" class="dks-popup-ok" onclick="closeComingSoon()">OK</button>
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
</script>

</body>
</html>