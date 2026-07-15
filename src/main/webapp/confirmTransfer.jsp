<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String fullName = user.getFullName() != null ? user.getFullName() : "User";

    String initials = "U";
    String[] nameParts = fullName.trim().split(" ");

    if (nameParts.length >= 2) {
        initials = nameParts[0].substring(0, 1).toUpperCase()
                + nameParts[1].substring(0, 1).toUpperCase();
    } else if (fullName.length() >= 1) {
        initials = fullName.substring(0, 1).toUpperCase();
    }

    String receiverAccount = request.getParameter("receiverAccount");
    String receiverName = request.getParameter("receiverName");
    String amount = request.getParameter("amount");

    if (receiverAccount == null || receiverAccount.trim().isEmpty()) {
        receiverAccount = (String) request.getAttribute("receiverAccount");
    }

    if (receiverName == null || receiverName.trim().isEmpty()) {
        receiverName = (String) request.getAttribute("receiverName");
    }

    if (amount == null || amount.trim().isEmpty()) {
        Object amountObj = request.getAttribute("amount");
        amount = amountObj != null ? String.valueOf(amountObj) : null;
    }

    if (receiverAccount == null || receiverName == null || amount == null) {
        response.sendRedirect(request.getContextPath() + "/transfer");
        return;
    }

    String maskedReceiver = receiverAccount;

    if (receiverAccount.length() > 4) {
        maskedReceiver = "XXXXXXXX" + receiverAccount.substring(receiverAccount.length() - 4);
    }

    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
    String formattedAmount = amount;

    try {
        formattedAmount = moneyFormat.format(Double.parseDouble(amount));
    } catch (Exception e) {
        formattedAmount = amount;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Confirm Transfer - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=204">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">
</head>

<body>

<div class="app-layout">

    <aside class="sidebar">

        <div class="logo">
            <div class="logo-icon">
                <i class="bi bi-bank2"></i>
            </div>

            <div>
                <h2>DKS Bank</h2>
                <p>Online Banking</p>
            </div>
        </div>

        <nav class="side-menu">

    <a href="${pageContext.request.contextPath}/dashboard">
        <i class="bi bi-house-door"></i>
        <span>Dashboard</span>
    </a>

    <a href="${pageContext.request.contextPath}/myAccount">
        <i class="bi bi-person-circle"></i>
        <span>My Account</span>
    </a>

    <a href="${pageContext.request.contextPath}/transfer" class="active">
        <i class="bi bi-send"></i>
        <span>Fund Transfer</span>
    </a>

    <a href="${pageContext.request.contextPath}/history">
        <i class="bi bi-receipt"></i>
        <span>Transaction History</span>
    </a>

    <a href="#" onclick="alert('Cards - Coming Soon!'); return false;">
        <i class="bi bi-credit-card"></i>
        <span>Cards</span>
    </a>

    <a href="${pageContext.request.contextPath}/services">
        <i class="bi bi-gear"></i>
        <span>Services</span>
    </a>

    <a href="${pageContext.request.contextPath}/change-password">
        <i class="bi bi-key"></i>
        <span>Change Password</span>
    </a>

    <a href="${pageContext.request.contextPath}/logout">
        <i class="bi bi-box-arrow-right"></i>
        <span>Logout</span>
    </a>

</nav>

        <div class="support-box">
            <i class="bi bi-headset"></i>
            <p>Need Help?</p>
            <h4>24x7 Support</h4>
        </div>

    </aside>

    <main class="main-panel">

        <header class="topbar">

            <div class="welcome-box">
                <h3>Confirm Transfer</h3>
                <p>Review details before completing transaction.</p>
            </div>

            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Search account, transfer, services...">
            </div>

            <div class="top-actions">

                <button class="icon-btn" type="button">
                    <i class="bi bi-bell"></i>
                    <span>3</span>
                </button>

                <button class="icon-btn" type="button">
                    <i class="bi bi-envelope"></i>
                    <span>8</span>
                </button>

                <button class="icon-btn no-badge" type="button">
                    <i class="bi bi-question-circle"></i>
                </button>

                <div class="profile-menu">

                    <button class="profile-btn" onclick="toggleProfileDropdown()" type="button">
                        <span class="profile-avatar"><%= initials %></span>
                        <i class="bi bi-chevron-down"></i>
                    </button>

                    <div class="profile-dropdown" id="profileDropdown">

                        <div class="profile-head">
                            <h4><%= fullName.toUpperCase() %></h4>
                            <p>Last Login: 15-06-2026 01:00 PM IST</p>
                        </div>

                        <a href="${pageContext.request.contextPath}/profileOverview.jsp">
                            <i class="bi bi-person-badge"></i>
                            Profile Overview
                        </a>

                        <a href="${pageContext.request.contextPath}/myAccount.jsp">
                            <i class="bi bi-person"></i>
                            My Profile
                        </a>

                        <a href="${pageContext.request.contextPath}/changePassword.jsp">
                            <i class="bi bi-key"></i>
                            Change Password
                        </a>

                        <a href="#">
                            <i class="bi bi-bell"></i>
                            Notifications
                        </a>

                        <a href="#">
                            <i class="bi bi-gear"></i>
                            Profile Settings
                        </a>

                        <a href="${pageContext.request.contextPath}/logout" class="dropdown-logout">
                            <i class="bi bi-box-arrow-right"></i>
                            Logout
                        </a>

                    </div>

                </div>

                <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                    <i class="bi bi-power"></i>
                    Logout
                </a>

            </div>

        </header>

        <section class="page-content">

            <div class="transfer-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <i class="bi bi-chevron-right"></i>
                <a href="${pageContext.request.contextPath}/transfer">Fund Transfer</a>
                <i class="bi bi-chevron-right"></i>
                <span>Confirm Transfer</span>
            </div>

            <div class="confirm-page-wrap">

                <div class="confirm-card">

                    <div class="confirm-icon">
                        <i class="bi bi-shield-check"></i>
                    </div>

                    <h1>Confirm Transfer</h1>
                    <p>Please verify receiver details before final confirmation.</p>

                    <div class="confirm-amount-box">
                        <span>Transfer Amount</span>
                        <h2>&#8377; <%= formattedAmount %></h2>
                    </div>

                    <div class="confirm-details">

                        <div class="confirm-row">
                            <span>Receiver Account Number</span>
                            <b><%= maskedReceiver %></b>
                        </div>

                        <div class="confirm-row">
                            <span>Account Holder Name</span>
                            <b><%= receiverName %></b>
                        </div>

                        <div class="confirm-row">
                            <span>Transfer Type</span>
                            <b>Internal DKS Transfer</b>
                        </div>

                        <div class="confirm-row">
                            <span>Status</span>
                            <b class="confirm-pending">Pending Confirmation</b>
                        </div>

                    </div>

                    <div class="confirm-warning">
                        <i class="bi bi-exclamation-triangle"></i>
                        <p>
                            Once confirmed, this amount will be debited from your account.
                            Please check all details carefully.
                        </p>
                    </div>

                    <form action="${pageContext.request.contextPath}/confirm-transfer" method="post">

                        <input type="hidden" name="receiverAccount" value="<%= receiverAccount %>">
                        <input type="hidden" name="receiverName" value="<%= receiverName %>">
                        <input type="hidden" name="amount" value="<%= amount %>">

                        <div class="confirm-buttons">
                            <a href="${pageContext.request.contextPath}/transfer" class="confirm-cancel-btn">
                                <i class="bi bi-x-circle"></i>
                                Cancel
                            </a>

                            <button type="submit" class="confirm-submit-btn">
                                <i class="bi bi-check-circle"></i>
                                Confirm Transfer
                            </button>
                        </div>

                    </form>

                </div>

                <div class="confirm-side">

                    <div class="transfer-side-card">
                        <i class="bi bi-lock"></i>
                        <h3>Secure Confirmation</h3>
                        <p>Your transfer is protected with session based authentication.</p>
                    </div>

                    <div class="transfer-side-card gold">
                        <i class="bi bi-receipt"></i>
                        <h3>Transaction Record</h3>
                        <p>After confirmation, this transaction will appear in your history.</p>
                    </div>

                    <div class="transfer-side-card danger">
                        <i class="bi bi-shield-exclamation"></i>
                        <h3>Verify Details</h3>
                        <p>Wrong receiver details may send money to another account.</p>
                    </div>

                </div>

            </div>

        </section>

    </main>

</div>

<script>
    function toggleProfileDropdown() {
        const dropdown = document.getElementById("profileDropdown");
        dropdown.classList.toggle("show");
    }

    window.onclick = function(event) {
        if (!event.target.closest(".profile-menu")) {
            const dropdown = document.getElementById("profileDropdown");

            if (dropdown && dropdown.classList.contains("show")) {
                dropdown.classList.remove("show");
            }
        }
    }
</script>

<script>
    function toggleProfileDropdown() {
        const dropdown = document.getElementById("profileDropdown");

        if (dropdown) {
            dropdown.classList.toggle("show");
        }
    }

    document.addEventListener("click", function (event) {
        if (!event.target.closest(".profile-menu")) {
            const dropdown = document.getElementById("profileDropdown");

            if (dropdown && dropdown.classList.contains("show")) {
                dropdown.classList.remove("show");
            }
        }
    });
</script>

</body>
</html>