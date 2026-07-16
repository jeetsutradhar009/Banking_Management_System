<%@ page import="java.util.*" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Account" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%!
    private String safe(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String getMapValue(Map<String, Object> map, String key1, String key2, String key3) {
        if (map == null) {
            return "";
        }

        Object value = map.get(key1);

        if (value == null && key2 != null) {
            value = map.get(key2);
        }

        if (value == null && key3 != null) {
            value = map.get(key3);
        }

        return safe(value);
    }

    private String formatAmount(Object value) {
        if (value == null) {
            return "0.00";
        }

        try {
            double amount = Double.parseDouble(String.valueOf(value));
            return String.format("%.2f", amount);
        } catch (Exception e) {
            return String.valueOf(value);
        }
    }
%>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String adminInitial = fullName.trim().length() > 0 ? fullName.trim().substring(0, 1).toUpperCase() : "A";

    String successMessage = request.getParameter("msg");
    boolean balanceAddedSuccess = successMessage != null && !successMessage.trim().isEmpty();

    Object accountObj = request.getAttribute("account");

    String accountNumber = "";
    String accountId = "";
    String userId = "";
    String accountType = "";
    String balance = "";
    String status = "ACTIVE";

    boolean accountFound = false;

    /*
       Important:
       balanceAddedSuccess true hone par Account Details aur Add Amount section hide hoga.
       Isse balance add hone ke baad page clean/refresh jaisa dikhega.
    */
    if (accountObj != null && !balanceAddedSuccess) {
        accountFound = true;

        if (accountObj instanceof Account) {
            Account account = (Account) accountObj;

            accountId = String.valueOf(account.getAccountId());
            userId = String.valueOf(account.getUserId());
            accountNumber = safe(account.getAccountNumber());
            accountType = safe(account.getAccountType());
            balance = String.format("%.2f", account.getBalance());
            status = safe(account.getStatus());

            if (status == null || status.trim().isEmpty()) {
                status = "ACTIVE";
            }

        } else if (accountObj instanceof Map) {
            Map<String, Object> accountMap = (Map<String, Object>) accountObj;

            accountId = getMapValue(accountMap, "account_id", "accountId", "id");
            userId = getMapValue(accountMap, "user_id", "userId", "customerId");
            accountNumber = getMapValue(accountMap, "account_number", "accountNumber", "accountNo");
            accountType = getMapValue(accountMap, "account_type", "accountType", "type");
            balance = formatAmount(accountMap.get("balance"));
            status = getMapValue(accountMap, "status", "accountStatus", null);

            if (status == null || status.trim().isEmpty()) {
                status = "ACTIVE";
            }
        }
    }

    String accountNoInputValue = balanceAddedSuccess ? "" : safe(request.getParameter("accountNo"));
    String customerIdInputValue = balanceAddedSuccess ? "" : safe(request.getParameter("customerId"));
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Balance - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=210">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>

<body>

<div class="admin-page balance-page">

    <div class="balance-header">

        <div class="balance-title-box">
            <h1>Add Balance</h1>
            <p>Search an account and safely credit balance from the admin panel.</p>
        </div>

        <div class="balance-header-actions">

            <div class="balance-admin-chip">
                <span><%= adminInitial %></span>
                <div>
                    <small>Logged in as</small>
                    <strong><%= fullName %></strong>
                </div>
            </div>

            <a class="balance-dashboard-btn" href="${pageContext.request.contextPath}/admin">
                <i class="bi bi-arrow-left"></i>
                Dashboard
            </a>

        </div>

    </div>

    <% if (balanceAddedSuccess) { %>

        <div class="balance-success-overlay show" id="balanceSuccessOverlay">

            <div class="balance-success-box">

                <button type="button" class="balance-success-close" onclick="closeBalanceSuccessPopup()">
                    <i class="bi bi-x-lg"></i>
                </button>

                <div class="balance-success-icon">
                    <i class="bi bi-check2-circle"></i>
                </div>

                <h2>Success</h2>

                <p><%= safe(successMessage) %></p>

                <button type="button" class="balance-success-btn" onclick="closeBalanceSuccessPopup()">
                    OK
                </button>

            </div>

        </div>

    <% } %>

    <% if (request.getParameter("err") != null) { %>
        <div class="error"><%= safe(request.getParameter("err")) %></div>
    <% } %>

    <div class="balance-layout">

        <div class="balance-left-card">

            <div class="balance-card-icon">
                <i class="bi bi-cash-stack"></i>
            </div>

            <h2>Quick Balance Credit</h2>

            <p>
                Use account number or customer/user ID to find the correct account.
                After verification, enter the amount to add balance.
            </p>

            <div class="balance-points">

                <div class="balance-point">
                    <span><i class="bi bi-search"></i></span>
                    Search account securely
                </div>

                <div class="balance-point">
                    <span><i class="bi bi-shield-check"></i></span>
                    Verify account details
                </div>

                <div class="balance-point">
                    <span><i class="bi bi-plus-circle"></i></span>
                    Add balance instantly
                </div>

            </div>

            <div class="balance-note-box">
                <small>Security Note</small>
                <strong>Always verify account number before crediting balance.</strong>
            </div>

        </div>

        <div class="balance-right-area">

            <div class="balance-search-card">

                <div class="balance-section-head">
                    <div>
                        <h2>Search Account</h2>
                        <p>Enter account number or customer/user ID.</p>
                    </div>

                    <span class="balance-secure-badge">
                        <i class="bi bi-lock-fill"></i>
                        Secure Search
                    </span>
                </div>

                <form method="get" action="${pageContext.request.contextPath}/admin/add-balance">

                    <div class="balance-search-grid">

                        <div class="balance-field">
                            <label>Account Number</label>

                            <div class="balance-input-wrap">
                                <i class="bi bi-credit-card-2-front"></i>
                                <input type="text"
                                       name="accountNo"
                                       placeholder="Example: ACC473056523969"
                                       value="<%= accountNoInputValue %>">
                            </div>
                        </div>

                        <div class="balance-field">
                            <label>OR Customer/User ID</label>

                            <div class="balance-input-wrap">
                                <i class="bi bi-person-badge"></i>
                                <input type="text"
                                       name="customerId"
                                       placeholder="Example: 6"
                                       value="<%= customerIdInputValue %>">
                            </div>
                        </div>

                    </div>

                    <button type="submit" class="balance-search-btn">
                        <i class="bi bi-search"></i>
                        Search Account
                    </button>

                </form>

            </div>

            <% if (accountFound) { %>

            <div class="balance-result-grid">

                <div class="balance-account-card">

                    <div class="balance-account-top">
                        <div>
                            <h2>Account Details</h2>
                            <p>Verify details before adding balance.</p>
                        </div>

                        <span class="<%= "FROZEN".equalsIgnoreCase(status) ? "balance-status-badge frozen" : "balance-status-badge active" %>">
                            <%= status.toUpperCase() %>
                        </span>
                    </div>

                    <div class="balance-detail-grid">

                        <div class="balance-detail-box">
                            <small>Account ID</small>
                            <strong>#<%= accountId %></strong>
                        </div>

                        <div class="balance-detail-box">
                            <small>User ID</small>
                            <strong>#<%= userId %></strong>
                        </div>

                        <div class="balance-detail-box full">
                            <small>Account Number</small>
                            <strong><%= accountNumber %></strong>
                        </div>

                        <div class="balance-detail-box">
                            <small>Account Type</small>
                            <strong><%= accountType %></strong>
                        </div>

                        <div class="balance-detail-box amount">
                            <small>Current Balance</small>
                            <strong>₹<%= balance %></strong>
                        </div>

                    </div>

                </div>

                <div class="balance-add-card">

                    <div class="balance-add-icon">
                        <i class="bi bi-plus-circle"></i>
                    </div>

                    <h2>Add Amount</h2>
                    <p>Enter amount to credit into selected account.</p>

                    <form method="post" action="${pageContext.request.contextPath}/admin/add-balance">

                        <input type="hidden" name="accountNumber" value="<%= accountNumber %>">

                        <div class="balance-field">
                            <label>Amount</label>

                            <div class="balance-input-wrap">
                                <i class="bi bi-currency-rupee"></i>
                                <input type="number"
                                       name="amount"
                                       step="0.01"
                                       min="1"
                                       placeholder="Enter amount"
                                       required>
                            </div>
                        </div>

                        <div class="balance-field">
                            <label>Note</label>

                            <div class="balance-input-wrap">
                                <i class="bi bi-pencil-square"></i>
                                <input type="text"
                                       name="note"
                                       placeholder="Example: Admin balance credit">
                            </div>
                        </div>

                        <button type="submit" class="balance-add-btn">
                            <i class="bi bi-plus-circle"></i>
                            Add Balance
                        </button>

                    </form>

                </div>

            </div>

            <% } %>

        </div>

    </div>

</div>

<script>
    function closeBalanceSuccessPopup() {
        const overlay = document.getElementById("balanceSuccessOverlay");

        if (overlay) {
            overlay.classList.remove("show");
        }

        /*
           URL se msg/accountNo remove karne ke liye.
           Isse refresh karne par popup dobara nahi aayega.
        */
        const cleanUrl = window.location.pathname;
        window.history.replaceState({}, document.title, cleanUrl);
    }

    window.addEventListener("load", function () {
        const overlay = document.getElementById("balanceSuccessOverlay");

        if (overlay) {
            setTimeout(function () {
                closeBalanceSuccessPopup();
            }, 3500);
        }
    });
</script>

</body>
</html>