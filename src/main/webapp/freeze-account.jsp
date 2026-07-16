<%@ page import="java.util.*" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Account" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String adminInitial = fullName.trim().length() > 0 ? fullName.trim().substring(0, 1).toUpperCase() : "A";

    List<Account> accounts = (List<Account>) request.getAttribute("accounts");

    int totalAccounts = 0;
    int activeAccounts = 0;
    int frozenAccounts = 0;
    double totalBalance = 0.0;

    if (accounts != null) {
        totalAccounts = accounts.size();

        for (Account account : accounts) {
            String status = account.getStatus();

            if (status == null || status.trim().isEmpty()) {
                status = "ACTIVE";
            }

            if ("FROZEN".equalsIgnoreCase(status)) {
                frozenAccounts++;
            } else {
                activeAccounts++;
            }

            totalBalance += account.getBalance();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Freeze Account - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=206">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>

<body>

<div class="admin-page freeze-page">

    <div class="freeze-header">

        <div class="freeze-title-box">
            <h1>Freeze / Unfreeze Account</h1>
            <p>Manage account access safely from the admin control panel.</p>
        </div>

        <div class="freeze-header-actions">

            <div class="freeze-admin-chip">
                <span><%= adminInitial %></span>
                <div>
                    <small>Logged in as</small>
                    <strong><%= fullName %></strong>
                </div>
            </div>

            <a class="freeze-dashboard-btn" href="${pageContext.request.contextPath}/admin">
                <i class="bi bi-arrow-left"></i>
                Dashboard
            </a>

        </div>

    </div>

    <% if (request.getParameter("msg") != null) { %>
        <div class="success"><%= request.getParameter("msg") %></div>
    <% } %>

    <% if (request.getParameter("err") != null) { %>
        <div class="error"><%= request.getParameter("err") %></div>
    <% } %>

    <div class="freeze-stats-grid">

        <div class="freeze-stat-card">
            <div class="freeze-stat-icon total">
                <i class="bi bi-wallet2"></i>
            </div>
            <div>
                <h4>Total Accounts</h4>
                <h2><%= totalAccounts %></h2>
                <p>Bank accounts</p>
            </div>
        </div>

        <div class="freeze-stat-card">
            <div class="freeze-stat-icon active">
                <i class="bi bi-check-circle"></i>
            </div>
            <div>
                <h4>Active Accounts</h4>
                <h2><%= activeAccounts %></h2>
                <p>Currently usable</p>
            </div>
        </div>

        <div class="freeze-stat-card">
            <div class="freeze-stat-icon frozen">
                <i class="bi bi-lock"></i>
            </div>
            <div>
                <h4>Frozen Accounts</h4>
                <h2><%= frozenAccounts %></h2>
                <p>Access restricted</p>
            </div>
        </div>

        <div class="freeze-stat-card">
            <div class="freeze-stat-icon balance">
                <i class="bi bi-cash-stack"></i>
            </div>
            <div>
                <h4>Total Balance</h4>
                <h2>₹<%= String.format("%.2f", totalBalance) %></h2>
                <p>Available funds</p>
            </div>
        </div>

    </div>

    <div class="freeze-main-card">

        <div class="freeze-section-head">

            <div>
                <h2>Account Control List</h2>
                <p>Freeze suspicious accounts or unfreeze verified accounts.</p>
            </div>

            <div class="freeze-search-box">
                <i class="bi bi-search"></i>
                <input type="text"
                       id="freezeSearchInput"
                       placeholder="Search by account number, type, status..."
                       onkeyup="filterFreezeTable()">
            </div>

        </div>

        <div class="freeze-table-wrap">

            <table class="freeze-table" id="freezeAccountTable">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>User ID</th>
                    <th>Account Number</th>
                    <th>Type</th>
                    <th>Balance</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
                </thead>

                <tbody>
                <%
                    if (accounts != null && !accounts.isEmpty()) {
                        for (Account account : accounts) {

                            String status = account.getStatus();

                            if (status == null || status.trim().isEmpty()) {
                                status = "ACTIVE";
                            }

                            status = status.toUpperCase();

                            String accountNo = account.getAccountNumber();

                            String nextStatus = "FROZEN".equalsIgnoreCase(status) ? "ACTIVE" : "FROZEN";
                            String btnText = "FROZEN".equalsIgnoreCase(status) ? "Unfreeze" : "Freeze";

                            String statusClass = "FROZEN".equalsIgnoreCase(status)
                                    ? "freeze-status-badge freeze-status-frozen"
                                    : "freeze-status-badge freeze-status-active";

                            String buttonClass = "FROZEN".equalsIgnoreCase(status)
                                    ? "freeze-btn-green"
                                    : "freeze-btn-orange";

                            String buttonIcon = "FROZEN".equalsIgnoreCase(status)
                                    ? "bi bi-unlock"
                                    : "bi bi-lock";
                %>

                <tr>
                    <td>#<%= account.getAccountId() %></td>

                    <td>#<%= account.getUserId() %></td>

                    <td>
                        <div class="freeze-account-number">
                            <i class="bi bi-credit-card-2-front"></i>
                            <b><%= accountNo %></b>
                        </div>
                    </td>

                    <td><%= account.getAccountType() %></td>

                    <td class="freeze-balance-green">
                        ₹<%= String.format("%.2f", account.getBalance()) %>
                    </td>

                    <td>
                        <span class="<%= statusClass %>"><%= status %></span>
                    </td>

                    <td>
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/freeze-account"
                              class="freeze-action-form"
                              onsubmit="return openFreezeConfirm(this);">

                            <input type="hidden" name="accountNumber" value="<%= accountNo %>">
                            <input type="hidden" name="newStatus" value="<%= nextStatus %>">

                            <button type="submit" class="<%= buttonClass %>">
                                <i class="<%= buttonIcon %>"></i>
                                <%= btnText %>
                            </button>

                        </form>
                    </td>
                </tr>

                <%
                        }
                    } else {
                %>

                <tr>
                    <td colspan="7" class="freeze-empty-row">
                        <i class="bi bi-wallet2"></i>
                        <span>No accounts found.</span>
                    </td>
                </tr>

                <%
                    }
                %>
                </tbody>
            </table>

        </div>

    </div>


    <!-- Custom Freeze / Unfreeze Confirm Modal START -->
    <div class="freeze-confirm-overlay" id="freezeConfirmOverlay">

        <div class="freeze-confirm-box">

            <button type="button" class="freeze-confirm-close" onclick="closeFreezeConfirm()">
                <i class="bi bi-x-lg"></i>
            </button>

            <div class="freeze-confirm-icon" id="freezeConfirmIcon">
                <i class="bi bi-lock"></i>
            </div>

            <h2 id="freezeConfirmTitle">Confirm Action</h2>

            <p id="freezeConfirmMessage">
                Are you sure you want to continue?
            </p>

            <div class="freeze-confirm-actions">
                <button type="button" class="freeze-cancel-btn" onclick="closeFreezeConfirm()">
                    Cancel
                </button>

                <button type="button" class="freeze-confirm-btn" id="freezeConfirmBtn" onclick="submitFreezeForm()">
                    Yes, Continue
                </button>
            </div>

        </div>

    </div>
    <!-- Custom Freeze / Unfreeze Confirm Modal END -->


</div>

<script>
    let selectedFreezeForm = null;

    function filterFreezeTable() {
        const input = document.getElementById("freezeSearchInput");
        const filter = input.value.toLowerCase();
        const table = document.getElementById("freezeAccountTable");
        const rows = table.getElementsByTagName("tr");

        for (let i = 1; i < rows.length; i++) {
            const rowText = rows[i].innerText.toLowerCase();

            if (rowText.indexOf("no accounts found") !== -1) {
                continue;
            }

            rows[i].style.display = rowText.includes(filter) ? "" : "none";
        }
    }

    function openFreezeConfirm(form) {
        selectedFreezeForm = form;

        const accountNumber = form.querySelector("input[name='accountNumber']").value;
        const newStatus = form.querySelector("input[name='newStatus']").value;

        const overlay = document.getElementById("freezeConfirmOverlay");
        const icon = document.getElementById("freezeConfirmIcon");
        const title = document.getElementById("freezeConfirmTitle");
        const message = document.getElementById("freezeConfirmMessage");
        const confirmBtn = document.getElementById("freezeConfirmBtn");

        if (newStatus === "FROZEN") {
            icon.innerHTML = '<i class="bi bi-lock-fill"></i>';
            icon.className = "freeze-confirm-icon icon-danger";

            title.textContent = "Freeze Account?";
            message.textContent = "Are you sure you want to freeze account " + accountNumber + "?";

            confirmBtn.textContent = "Yes, Freeze";
            confirmBtn.className = "freeze-confirm-btn confirm-danger";
        } else {
            icon.innerHTML = '<i class="bi bi-unlock-fill"></i>';
            icon.className = "freeze-confirm-icon icon-success";

            title.textContent = "Unfreeze Account?";
            message.textContent = "Are you sure you want to unfreeze account " + accountNumber + "?";

            confirmBtn.textContent = "Yes, Unfreeze";
            confirmBtn.className = "freeze-confirm-btn confirm-success";
        }

        overlay.classList.add("show");
        return false;
    }

    function closeFreezeConfirm() {
        const overlay = document.getElementById("freezeConfirmOverlay");

        if (overlay) {
            overlay.classList.remove("show");
        }

        selectedFreezeForm = null;
    }

    function submitFreezeForm() {
        if (selectedFreezeForm) {
            selectedFreezeForm.submit();
        }
    }
</script>

</body>
</html>