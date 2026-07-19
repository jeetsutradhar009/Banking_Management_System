<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Transaction" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String keyword = (String) request.getAttribute("keyword");
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");

    SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy hh:mm a");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Transactions - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=205">
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

            <a href="${pageContext.request.contextPath}/admin/accounts">
                <i class="bi bi-wallet2"></i>
                <span>Accounts</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/transactions" class="active">
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
                <h3>Transactions</h3>
                <p>Welcome, <%= fullName %></p>
            </div>

            <form action="${pageContext.request.contextPath}/admin/transactions" method="get" class="admin-search-box">
                <i class="bi bi-search"></i>
                <input type="text" name="q" placeholder="Search by sender, receiver, amount, status..."
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
                    <h1>All Transactions</h1>
                    <p>
                        <% if (keyword != null) { %>
                            Search results for "<%= keyword %>"
                        <% } else { %>
                            Complete transaction activity.
                        <% } %>
                    </p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/transactions/export<%= keyword != null && !keyword.trim().isEmpty() ? "?q=" + java.net.URLEncoder.encode(keyword.trim(), java.nio.charset.StandardCharsets.UTF_8) : "" %>"
                   class="admin-transactions-export-btn">
                    <i class="bi bi-download"></i>
                    Export
                </a>
            </div>

            <div class="admin-panel">

                <div class="admin-section-head">
                    <h3>Transaction List</h3>
                    <a href="${pageContext.request.contextPath}/admin/transactions">Clear Search</a>
                </div>

                <div class="admin-table-wrap">

                    <table class="admin-table">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Sender Account</th>
                            <th>Receiver Account</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                        </thead>

                        <tbody>
                        <%
                            if (transactions != null && !transactions.isEmpty()) {
                                for (Transaction t : transactions) {
                                    String dateText = t.getTransactionDate() != null
                                            ? sdf.format(t.getTransactionDate())
                                            : "-";
                        %>
                        <tr>
                            <td>#<%= t.getTransactionId() %></td>
                            <td><%= t.getSenderAccount() %></td>
                            <td><%= t.getReceiverAccount() %></td>
                            <td class="admin-green-text">₹ <%= String.format("%.2f", t.getAmount()) %></td>
                            <td><span class="admin-status-active"><%= t.getStatus() %></span></td>
                            <td><%= dateText %></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="6" class="admin-empty-row">No transactions found.</td>
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