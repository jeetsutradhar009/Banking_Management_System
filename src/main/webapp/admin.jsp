<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Account" %>
<%@ page import="com.bank.model.Transaction" %>

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

    private String money(Object value) {
        if (value == null) {
            return "0.00";
        }

        try {
            double amount = Double.parseDouble(String.valueOf(value));
            return String.format("%,.2f", amount);
        } catch (Exception e) {
            return String.valueOf(value);
        }
    }
%>

<%
    User admin = (User) session.getAttribute("user");

    Number totalUsersObj = (Number) request.getAttribute("totalUsers");
    Number totalAccountsObj = (Number) request.getAttribute("totalAccounts");
    Number totalTransactionsObj = (Number) request.getAttribute("totalTransactions");

    int totalUsers = totalUsersObj != null ? totalUsersObj.intValue() : 0;
    int totalAccounts = totalAccountsObj != null ? totalAccountsObj.intValue() : 0;
    int totalTransactions = totalTransactionsObj != null ? totalTransactionsObj.intValue() : 0;

    List<User> recentUsers = (List<User>) request.getAttribute("recentUsers");
    List<Account> recentAccounts = (List<Account>) request.getAttribute("recentAccounts");
    List<Transaction> recentTransactions = (List<Transaction>) request.getAttribute("recentTransactions");

    String adminName = "Admin";

    if (admin != null && admin.getFullName() != null && !admin.getFullName().trim().isEmpty()) {
        adminName = admin.getFullName();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Panel - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="images/logo.png">

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=21">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">
</head>

<body class="admin-body">

<div class="admin-layout">

    <!-- SIDEBAR -->
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

            <a href="${pageContext.request.contextPath}/admin" class="active">
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

    <!-- MAIN -->
    <main class="admin-main">

        <!-- TOPBAR -->
        <header class="admin-topbar">

            <div class="admin-welcome">
                <h3>Welcome, <%= safe(adminName) %></h3>
                <p>Manage users, accounts and transactions from one secure place.</p>
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

                <div class="admin-profile-chip">
                    <span>
                        <%= adminName != null && !adminName.trim().isEmpty()
                                ? adminName.substring(0, 1).toUpperCase()
                                : "A" %>
                    </span>
                    <i class="bi bi-chevron-down"></i>
                </div>

                <a href="${pageContext.request.contextPath}/logout" class="admin-logout-btn">
                    <i class="bi bi-power"></i>
                    Logout
                </a>

            </div>

        </header>

        <!-- CONTENT -->
        <section class="admin-content">

            <!-- PAGE HEADING -->
            <div class="admin-page-heading">
                <div>
                    <h1>Admin Dashboard</h1>
                    <p>Overview of banking system users, accounts and transaction activity.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/reports/export" class="admin-export-btn">
                    <i class="bi bi-download"></i>
                    Export Report
                </a>
            </div>

            <!-- STATS -->
            <div class="admin-stats-grid">

                <div class="admin-stat-card">
                    <div class="admin-stat-icon green">
                        <i class="bi bi-people"></i>
                    </div>

                    <div>
                        <h4>Total Users</h4>
                        <h2><%= totalUsers %></h2>
                        <p>Registered customers</p>
                    </div>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-icon blue">
                        <i class="bi bi-wallet2"></i>
                    </div>

                    <div>
                        <h4>Total Accounts</h4>
                        <h2><%= totalAccounts %></h2>
                        <p>Active bank accounts</p>
                    </div>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-icon orange">
                        <i class="bi bi-arrow-left-right"></i>
                    </div>

                    <div>
                        <h4>Total Transactions</h4>
                        <h2><%= totalTransactions %></h2>
                        <p>Processed transfers</p>
                    </div>
                </div>

                <div class="admin-stat-card">
                    <div class="admin-stat-icon green">
                        <i class="bi bi-check-circle"></i>
                    </div>

                    <div>
                        <h4>System Status</h4>
                        <h2>Online</h2>
                        <p>All services running</p>
                    </div>
                </div>

            </div>

            <!-- QUICK ACTIONS -->
            <!-- QUICK ACTIONS -->
<div class="admin-panel">

    <div class="admin-panel-head">
        <h3>Quick Admin Actions</h3>
    </div>

    <div class="admin-action-grid">

        <a href="${pageContext.request.contextPath}/admin/add-user"
           class="admin-action-card">
            <i class="bi bi-person-plus-fill"></i>
            <span>Add User</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/freeze-account"
           class="admin-action-card">
            <i class="bi bi-lock-fill"></i>
            <span>Freeze Account</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/reports"
           class="admin-action-card">
            <i class="bi bi-file-earmark-bar-graph-fill"></i>
            <span>Generate Report</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/audit-logs"
           class="admin-action-card">
            <i class="bi bi-list-check"></i>
            <span>Audit Logs</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/add-balance"
           class="admin-action-card">
            <i class="bi bi-plus-circle-fill"></i>
            <span>Add Balance</span>
        </a>

        <a href="${pageContext.request.contextPath}/admin/reports/export"
           class="admin-action-card">
            <i class="bi bi-cloud-arrow-down-fill"></i>
            <span>Backup</span>
        </a>

    </div>

</div>
            <!-- RECENT USERS -->
            <div class="admin-panel">

                <div class="admin-panel-head">
                    <h3>Recent Users</h3>

                    <a href="${pageContext.request.contextPath}/admin/users">
                        View All
                    </a>
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
                        <% if (recentUsers != null && !recentUsers.isEmpty()) { %>
                            <% for (User user : recentUsers) { %>
                                <tr>
                                    <td>#<%= user.getUserId() %></td>

                                    <td>
                                        <div class="admin-user-cell">
                                            <span>
                                                <%= user.getFullName() != null && !user.getFullName().trim().isEmpty()
                                                        ? user.getFullName().substring(0, 1).toUpperCase()
                                                        : "U" %>
                                            </span>

                                            <div>
                                                <b><%= safe(user.getFullName()) %></b>
                                                <small>CUST ID: <%= safe(user.getCustomerId()) %></small>
                                            </div>
                                        </div>
                                    </td>

                                    <td><%= safe(user.getEmail()) %></td>
                                    <td><%= safe(user.getPhone()) %></td>

                                    <td>
                                        <span class="admin-role-badge">
                                            <%= safe(user.getRole()) %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        <% } else { %>
                            <tr>
                                <td colspan="5" class="admin-empty-row">
                                    No users found.
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            </div>

            <!-- RECENT DATA GRID -->
            <div class="admin-data-grid">

                <!-- RECENT ACCOUNTS -->
                <div class="admin-panel">

                    <div class="admin-panel-head">
                        <h3>Recent Accounts</h3>

                        <a href="${pageContext.request.contextPath}/admin/accounts">
                            View All
                        </a>
                    </div>

                    <div class="admin-table-wrap">
                        <table class="admin-table">
                            <thead>
                            <tr>
                                <th>Account No.</th>
                                <th>Type</th>
                                <th>Status</th>
                                <th>Balance</th>
                            </tr>
                            </thead>

                            <tbody>
                            <% if (recentAccounts != null && !recentAccounts.isEmpty()) { %>
                                <% for (Account account : recentAccounts) { %>
                                    <tr>
                                        <td>
                                            <b><%= safe(account.getAccountNumber()) %></b>
                                            <small>IFSC: <%= safe(account.getIfscCode()) %></small>
                                        </td>

                                        <td><%= safe(account.getAccountType()) %></td>

                                        <td>
                                            <span class="admin-status-badge">
                                                <%= safe(account.getStatus()) %>
                                            </span>
                                        </td>

                                        <td class="admin-green-text">
                                            ₹ <%= money(account.getBalance()) %>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } else { %>
                                <tr>
                                    <td colspan="4" class="admin-empty-row">
                                        No accounts found.
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>

                </div>

                <!-- RECENT TRANSACTIONS -->
                <div class="admin-panel">

                    <div class="admin-panel-head">
                        <h3>Recent Transactions</h3>

                        <a href="${pageContext.request.contextPath}/admin/transactions">
                            View All
                        </a>
                    </div>

                    <div class="admin-table-wrap">
                        <table class="admin-table">
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>From</th>
                                <th>To</th>
                                <th>Amount</th>
                                <th>Status</th>
                            </tr>
                            </thead>

                            <tbody>
                            <% if (recentTransactions != null && !recentTransactions.isEmpty()) { %>
                                <% for (Transaction txn : recentTransactions) { %>
                                    <tr>
                                        <td>#<%= txn.getTransactionId() %></td>

                                        <td><%= safe(txn.getSenderAccount()) %></td>

                                        <td><%= safe(txn.getReceiverAccount()) %></td>

                                        <td class="admin-orange-text">
                                            ₹ <%= money(txn.getAmount()) %>
                                        </td>

                                        <td>
                                            <span class="admin-status-badge">
                                                <%= safe(txn.getStatus()) %>
                                            </span>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } else { %>
                                <tr>
                                    <td colspan="5" class="admin-empty-row">
                                        No transactions found.
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>

                </div>

            </div>

        </section>

    </main>

</div>

<!-- Coming Soon Modal -->
<div class="dks-popup-overlay" id="dksComingOverlay">
    <div class="dks-popup-box">

        <button type="button"
                class="dks-popup-close"
                onclick="closeComingSoon()">
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

        <button type="button"
                class="dks-popup-ok"
                onclick="closeComingSoon()">
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
</script>

</body>
</html>