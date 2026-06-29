<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.bank.model.User" %>

<%!
    private String js(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\"", "\\\"");
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

    Number totalUsers = (Number) request.getAttribute("totalUsers");
    Number totalAdmins = (Number) request.getAttribute("totalAdmins");
    Number totalAccounts = (Number) request.getAttribute("totalAccounts");
    Number totalTransactions = (Number) request.getAttribute("totalTransactions");

    Number todayTransactions = (Number) request.getAttribute("todayTransactions");
    Number successfulTransactions = (Number) request.getAttribute("successfulTransactions");
    Number failedTransactions = (Number) request.getAttribute("failedTransactions");

    Number totalBankBalance = (Number) request.getAttribute("totalBankBalance");
    Number totalTransactionAmount = (Number) request.getAttribute("totalTransactionAmount");
    Number todayTransactionAmount = (Number) request.getAttribute("todayTransactionAmount");

    List<Map<String, Object>> monthlyTransactions =
            (List<Map<String, Object>>) request.getAttribute("monthlyTransactions");

    List<Map<String, Object>> accountTypeDistribution =
            (List<Map<String, Object>>) request.getAttribute("accountTypeDistribution");

    List<Map<String, Object>> userRoleDistribution =
            (List<Map<String, Object>>) request.getAttribute("userRoleDistribution");

    List<Map<String, Object>> transactionStatusDistribution =
            (List<Map<String, Object>>) request.getAttribute("transactionStatusDistribution");

    List<Map<String, Object>> topAccounts =
            (List<Map<String, Object>>) request.getAttribute("topAccounts");

    List<Map<String, Object>> recentTransactions =
            (List<Map<String, Object>>) request.getAttribute("recentTransactions");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reports - DKS Bank</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=17">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body class="admin-body">

<div class="admin-layout">

    <!-- Sidebar -->
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

            <a href="${pageContext.request.contextPath}/admin/reports" class="active">
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

    <!-- Main -->
    <main class="admin-main">

        <header class="admin-topbar">

            <div class="admin-welcome">
                <h3>Reports & Analytics</h3>
                <p>View complete banking reports, charts and system insights.</p>
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
                <button type="button" class="admin-icon-btn">
                    <i class="bi bi-bell"></i>
                    <span>5</span>
                </button>

                <button type="button" class="admin-icon-btn">
                    <i class="bi bi-envelope"></i>
                    <span>2</span>
                </button>

                <div class="admin-profile-chip">
                    <span>
                        <%= admin != null && admin.getFullName() != null && !admin.getFullName().isEmpty()
                                ? admin.getFullName().substring(0, 1).toUpperCase()
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

        <section class="admin-content">

            <div class="admin-page-heading admin-report-heading">
                <div>
                    <h1>Admin Reports</h1>
                    <p>Banking system report with charts, financial activity and recent data.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/reports/export" class="admin-report-export-btn">
                    <i class="bi bi-download"></i>
                    Export CSV
                </a>
            </div>

            <!-- Report Summary Cards -->
            <div class="report-summary-grid">

                <div class="report-stat-card">
                    <div class="report-stat-icon green">
                        <i class="bi bi-people"></i>
                    </div>
                    <div>
                        <span>Total Users</span>
                        <h2><%= totalUsers %></h2>
                        <p>Registered customers</p>
                    </div>
                </div>

                <div class="report-stat-card">
                    <div class="report-stat-icon blue">
                        <i class="bi bi-person-badge"></i>
                    </div>
                    <div>
                        <span>Total Admins</span>
                        <h2><%= totalAdmins %></h2>
                        <p>Admin accounts</p>
                    </div>
                </div>

                <div class="report-stat-card">
                    <div class="report-stat-icon orange">
                        <i class="bi bi-wallet2"></i>
                    </div>
                    <div>
                        <span>Total Accounts</span>
                        <h2><%= totalAccounts %></h2>
                        <p>Bank accounts</p>
                    </div>
                </div>

                <div class="report-stat-card">
                    <div class="report-stat-icon green">
                        <i class="bi bi-arrow-left-right"></i>
                    </div>
                    <div>
                        <span>Total Transactions</span>
                        <h2><%= totalTransactions %></h2>
                        <p>All transaction records</p>
                    </div>
                </div>

            </div>

            <!-- Finance Report -->
            <div class="report-finance-grid">

                <div class="report-money-card">
                    <div>
                        <span>Total Bank Balance</span>
                        <h2>₹ <%= money(totalBankBalance) %></h2>
                        <p>Total balance available across all accounts.</p>
                    </div>
                    <i class="bi bi-bank"></i>
                </div>

                <div class="report-money-card">
                    <div>
                        <span>Total Transaction Amount</span>
                        <h2>₹ <%= money(totalTransactionAmount) %></h2>
                        <p>Total money transferred through the system.</p>
                    </div>
                    <i class="bi bi-cash-stack"></i>
                </div>

                <div class="report-money-card">
                    <div>
                        <span>Today Transaction Amount</span>
                        <h2>₹ <%= money(todayTransactionAmount) %></h2>
                        <p>Amount processed today.</p>
                    </div>
                    <i class="bi bi-calendar-check"></i>
                </div>

            </div>

            <!-- Transaction Health -->
            <div class="report-health-grid">

                <div class="report-health-card">
                    <span>Today Transactions</span>
                    <h2><%= todayTransactions %></h2>
                    <p>Transactions processed today</p>
                </div>

                <div class="report-health-card success">
                    <span>Successful</span>
                    <h2><%= successfulTransactions %></h2>
                    <p>Completed transactions</p>
                </div>

                <div class="report-health-card danger">
                    <span>Failed / Pending</span>
                    <h2><%= failedTransactions %></h2>
                    <p>Need attention</p>
                </div>

            </div>

            <!-- Charts -->
            <div class="report-chart-grid">

                <div class="report-chart-card wide">
                    <div class="report-card-head">
                        <div>
                            <h3>Monthly Transactions</h3>
                            <p>Transaction count and amount report for recent months.</p>
                        </div>
                        <i class="bi bi-bar-chart-line"></i>
                    </div>

                    <div class="report-chart-box">
                        <canvas id="monthlyChart"></canvas>
                    </div>
                </div>

                <div class="report-chart-card">
                    <div class="report-card-head">
                        <div>
                            <h3>Account Types</h3>
                            <p>Savings and Current account distribution.</p>
                        </div>
                        <i class="bi bi-pie-chart"></i>
                    </div>

                    <div class="report-chart-box small">
                        <canvas id="accountTypeChart"></canvas>
                    </div>
                </div>

                <div class="report-chart-card">
                    <div class="report-card-head">
                        <div>
                            <h3>User Roles</h3>
                            <p>User and admin account distribution.</p>
                        </div>
                        <i class="bi bi-people"></i>
                    </div>

                    <div class="report-chart-box small">
                        <canvas id="userRoleChart"></canvas>
                    </div>
                </div>

                <div class="report-chart-card">
                    <div class="report-card-head">
                        <div>
                            <h3>Transaction Status</h3>
                            <p>Success, failed and pending transaction status.</p>
                        </div>
                        <i class="bi bi-activity"></i>
                    </div>

                    <div class="report-chart-box small">
                        <canvas id="statusChart"></canvas>
                    </div>
                </div>

            </div>

            <!-- Tables -->
            <div class="report-table-grid">

                <div class="report-table-card">
                    <div class="report-table-head">
                        <h3>Top Accounts by Balance</h3>
                        <span>Top 5</span>
                    </div>

                    <div class="report-table-wrap">
                        <table class="report-table">
                            <thead>
                            <tr>
                                <th>Customer</th>
                                <th>Account No.</th>
                                <th>Type</th>
                                <th>Balance</th>
                            </tr>
                            </thead>

                            <tbody>
                            <% if (topAccounts != null && !topAccounts.isEmpty()) { %>
                                <% for (Map<String, Object> row : topAccounts) { %>
                                    <tr>
                                        <td>
                                            <b><%= row.get("fullName") != null ? row.get("fullName") : "Unknown" %></b>
                                            <small><%= row.get("customerId") != null ? row.get("customerId") : "-" %></small>
                                        </td>
                                        <td><%= row.get("accountNumber") %></td>
                                        <td><%= row.get("accountType") %></td>
                                        <td class="report-green">₹ <%= money(row.get("balance")) %></td>
                                    </tr>
                                <% } %>
                            <% } else { %>
                                <tr>
                                    <td colspan="4" class="report-empty">No account data found.</td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="report-table-card">
                    <div class="report-table-head">
                        <h3>Recent Transactions</h3>
                        <span>Latest 8</span>
                    </div>

                    <div class="report-table-wrap">
                        <table class="report-table">
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
                                <% for (Map<String, Object> row : recentTransactions) { %>
                                    <tr>
                                        <td>#<%= row.get("transactionId") %></td>
                                        <td>
                                            <b><%= row.get("senderName") != null ? row.get("senderName") : "Unknown" %></b>
                                            <small><%= row.get("senderAccount") %></small>
                                        </td>
                                        <td>
                                            <b><%= row.get("receiverName") != null ? row.get("receiverName") : "Unknown" %></b>
                                            <small><%= row.get("receiverAccount") %></small>
                                        </td>
                                        <td class="report-orange">₹ <%= money(row.get("amount")) %></td>
                                        <td>
                                            <span class="report-status">
                                                <%= row.get("status") != null ? row.get("status") : "Success" %>
                                            </span>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } else { %>
                                <tr>
                                    <td colspan="5" class="report-empty">No transaction data found.</td>
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

<script>
    const monthlyLabels = [
        <% if (monthlyTransactions != null) { for (int i = 0; i < monthlyTransactions.size(); i++) { %>
            '<%= js(monthlyTransactions.get(i).get("label")) %>'<%= i < monthlyTransactions.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const monthlyCounts = [
        <% if (monthlyTransactions != null) { for (int i = 0; i < monthlyTransactions.size(); i++) { %>
            <%= monthlyTransactions.get(i).get("count") %><%= i < monthlyTransactions.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const monthlyAmounts = [
        <% if (monthlyTransactions != null) { for (int i = 0; i < monthlyTransactions.size(); i++) { %>
            <%= monthlyTransactions.get(i).get("amount") %><%= i < monthlyTransactions.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const accountTypeLabels = [
        <% if (accountTypeDistribution != null) { for (int i = 0; i < accountTypeDistribution.size(); i++) { %>
            '<%= js(accountTypeDistribution.get(i).get("label")) %>'<%= i < accountTypeDistribution.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const accountTypeCounts = [
        <% if (accountTypeDistribution != null) { for (int i = 0; i < accountTypeDistribution.size(); i++) { %>
            <%= accountTypeDistribution.get(i).get("count") %><%= i < accountTypeDistribution.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const userRoleLabels = [
        <% if (userRoleDistribution != null) { for (int i = 0; i < userRoleDistribution.size(); i++) { %>
            '<%= js(userRoleDistribution.get(i).get("label")) %>'<%= i < userRoleDistribution.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const userRoleCounts = [
        <% if (userRoleDistribution != null) { for (int i = 0; i < userRoleDistribution.size(); i++) { %>
            <%= userRoleDistribution.get(i).get("count") %><%= i < userRoleDistribution.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const statusLabels = [
        <% if (transactionStatusDistribution != null) { for (int i = 0; i < transactionStatusDistribution.size(); i++) { %>
            '<%= js(transactionStatusDistribution.get(i).get("label")) %>'<%= i < transactionStatusDistribution.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const statusCounts = [
        <% if (transactionStatusDistribution != null) { for (int i = 0; i < transactionStatusDistribution.size(); i++) { %>
            <%= transactionStatusDistribution.get(i).get("count") %><%= i < transactionStatusDistribution.size() - 1 ? "," : "" %>
        <% }} %>
    ];

    const dksColors = [
        '#0b8a70',
        '#ff7a1a',
        '#2563eb',
        '#16a34a',
        '#ef4444',
        '#a855f7'
    ];

    new Chart(document.getElementById('monthlyChart'), {
        type: 'bar',
        data: {
            labels: monthlyLabels.length ? monthlyLabels : ['No Data'],
            datasets: [
                {
                    label: 'Transactions',
                    data: monthlyCounts.length ? monthlyCounts : [0],
                    backgroundColor: '#0b8a70',
                    borderRadius: 12,
                    yAxisID: 'y'
                },
                {
                    label: 'Amount',
                    data: monthlyAmounts.length ? monthlyAmounts : [0],
                    backgroundColor: '#ff7a1a',
                    borderRadius: 12,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    labels: {
                        font: {
                            family: 'Poppins',
                            weight: '700'
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        precision: 0
                    }
                },
                y1: {
                    beginAtZero: true,
                    position: 'right',
                    grid: {
                        drawOnChartArea: false
                    }
                }
            }
        }
    });

    new Chart(document.getElementById('accountTypeChart'), {
        type: 'doughnut',
        data: {
            labels: accountTypeLabels.length ? accountTypeLabels : ['No Data'],
            datasets: [{
                data: accountTypeCounts.length ? accountTypeCounts : [1],
                backgroundColor: dksColors,
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '68%'
        }
    });

    new Chart(document.getElementById('userRoleChart'), {
        type: 'pie',
        data: {
            labels: userRoleLabels.length ? userRoleLabels : ['No Data'],
            datasets: [{
                data: userRoleCounts.length ? userRoleCounts : [1],
                backgroundColor: dksColors,
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });

    new Chart(document.getElementById('statusChart'), {
        type: 'doughnut',
        data: {
            labels: statusLabels.length ? statusLabels : ['No Data'],
            datasets: [{
                data: statusCounts.length ? statusCounts : [1],
                backgroundColor: dksColors,
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '62%'
        }
    });
</script>

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
            <span id="dksComingFeature">Security Settings</span> is currently under development.
        </p>

        <button type="button" class="dks-popup-ok" onclick="closeComingSoon()">
            OK
        </button>

    </div>
</div>

<script>
    // Popup Open Karne ka function
    function comingSoon(featureName) {
        const overlay = document.getElementById("dksComingOverlay");
        const featureSpan = document.getElementById("dksComingFeature");

        if (featureSpan) {
            // Image ki tarah "Settings" word add karne ke liye
            featureSpan.textContent = featureName + " Settings"; 
        }

        if (overlay) {
            overlay.classList.add("show");
        }

        return false;
    }

    // Popup Close Karne ka function
    function closeComingSoon() {
        const overlay = document.getElementById("dksComingOverlay");
        if (overlay) {
            overlay.classList.remove("show");
        }
    }
</script>

</body>
</html>