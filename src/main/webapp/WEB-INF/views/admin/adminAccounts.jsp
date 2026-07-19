<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Account" %>
<%@ page import="java.util.List" %>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String keyword = (String) request.getAttribute("keyword");
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Accounts - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

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

            <a href="${pageContext.request.contextPath}/admin/users">
                <i class="bi bi-people"></i>
                <span>User Management</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/accounts" class="active">
                <i class="bi bi-wallet2"></i>
                <span>Accounts</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/transactions">
                <i class="bi bi-receipt"></i>
                <span>Transactions</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/generate-report">
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
                <h3>Accounts</h3>
                <p>Welcome, <%= fullName %></p>
            </div>

            <form action="${pageContext.request.contextPath}/admin/accounts" method="get" class="admin-search-box">
                <i class="bi bi-search"></i>
                <input type="text" name="q" placeholder="Search accounts by number, type, balance..."
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
                    <h1>All Accounts</h1>
                    <p>
                        <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                            Search results for "<%= keyword %>"
                        <% } else { %>
                            Complete list of bank accounts.
                        <% } %>
                    </p>
                </div>

                <form action="${pageContext.request.contextPath}/admin/accounts/create" method="get" style="margin:0;">
                    <button type="submit">
                        <i class="bi bi-wallet2"></i>
                        Create Account
                    </button>
                </form>
            </div>

            <div class="admin-panel">

                <div class="admin-section-head">
                    <h3>Account List</h3>
                    <a href="${pageContext.request.contextPath}/admin/accounts">Clear Search</a>
                </div>

                <div class="admin-table-wrap">

                    <table class="admin-table">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>User ID</th>
                            <th>Account Number</th>
                            <th>Type</th>
                            <th>Balance</th>
                            <th>Status</th>
                        </tr>
                        </thead>

                        <tbody>
                        <%
                            if (accounts != null && !accounts.isEmpty()) {
                                for (Account a : accounts) {

                                    String accountStatus = "ACTIVE";

                                    try {
                                        if (a.getStatus() != null && !a.getStatus().trim().isEmpty()) {
                                            accountStatus = a.getStatus();
                                        }
                                    } catch (Exception e) {
                                        accountStatus = "ACTIVE";
                                    }
                        %>
                        <tr>
                            <td>#<%= a.getAccountId() %></td>
                            <td>#<%= a.getUserId() %></td>
                            <td><b><%= a.getAccountNumber() %></b></td>
                            <td><%= a.getAccountType() %></td>
                            <td class="admin-green-text">₹ <%= String.format("%.2f", a.getBalance()) %></td>
                            <td><span class="admin-status-active"><%= accountStatus %></span></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="6" class="admin-empty-row">No accounts found.</td>
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