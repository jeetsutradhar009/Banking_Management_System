<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Account" %>
<%@ page import="com.bank.model.Transaction" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String keyword = (String) request.getAttribute("keyword");

    List<User> users = (List<User>) request.getAttribute("users");
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");

    SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy hh:mm a");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Search Results - DKS Bank</title>
    
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

            <a href="${pageContext.request.contextPath}/admin/accounts">
                <i class="bi bi-wallet2"></i>
                <span>Accounts</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/transactions">
                <i class="bi bi-receipt"></i>
                <span>Transactions</span>
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
                <h3>Search Results</h3>
                <p>Welcome, <%= fullName %></p>
            </div>

            <form action="${pageContext.request.contextPath}/admin/search" method="get" class="admin-search-box">
                <i class="bi bi-search"></i>
                <input type="text" name="q" placeholder="Search users, accounts, transactions..."
                       value="<%= keyword != null ? keyword : "" %>" required>
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
                    <h1>Search Results</h1>
                    <p>Showing results for "<%= keyword %>"</p>
                </div>

                <button type="button" onclick="location.href='${pageContext.request.contextPath}/admin'">
                    <i class="bi bi-arrow-left"></i>
                    Back
                </button>
            </div>

            <div class="admin-panel">
                <div class="admin-section-head">
                    <h3>Users</h3>
                    <a href="${pageContext.request.contextPath}/admin/users?q=<%= keyword %>">View More</a>
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

            <div class="admin-panel">
                <div class="admin-section-head">
                    <h3>Accounts</h3>
                    <a href="${pageContext.request.contextPath}/admin/accounts?q=<%= keyword %>">View More</a>
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
                        </tr>
                        </thead>

                        <tbody>
                        <%
                            if (accounts != null && !accounts.isEmpty()) {
                                for (Account a : accounts) {
                        %>
                        <tr>
                            <td>#<%= a.getAccountId() %></td>
                            <td>#<%= a.getUserId() %></td>
                            <td><b><%= a.getAccountNumber() %></b></td>
                            <td><%= a.getAccountType() %></td>
                            <td class="admin-green-text">₹ <%= String.format("%.2f", a.getBalance()) %></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" class="admin-empty-row">No accounts found.</td>
                        </tr>
                        <%
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="admin-panel">
                <div class="admin-section-head">
                    <h3>Transactions</h3>
                    <a href="${pageContext.request.contextPath}/admin/transactions?q=<%= keyword %>">View More</a>
                </div>

                <div class="admin-table-wrap">
                    <table class="admin-table">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Sender</th>
                            <th>Receiver</th>
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

</body>
</html>