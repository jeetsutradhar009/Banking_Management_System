<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

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

    String amount = request.getParameter("amount");

    if (amount == null || amount.trim().isEmpty() || amount.equals("null")) {
        Object amountObj = request.getAttribute("amount");
        amount = amountObj != null ? String.valueOf(amountObj) : null;
    }

    if (amount == null || amount.trim().isEmpty() || amount.equals("null")) {
        response.sendRedirect(request.getContextPath() + "/history");
        return;
    }

    String receiverAccount = request.getParameter("receiverAccount");
    if (receiverAccount == null || receiverAccount.trim().isEmpty() || receiverAccount.equals("null")) {
        Object receiverAccountObj = request.getAttribute("receiverAccount");
        receiverAccount = receiverAccountObj != null ? String.valueOf(receiverAccountObj) : "Not Available";
    }

    String receiverName = request.getParameter("receiverName");
    if (receiverName == null || receiverName.trim().isEmpty() || receiverName.equals("null")) {
        Object receiverNameObj = request.getAttribute("receiverName");
        receiverName = receiverNameObj != null ? String.valueOf(receiverNameObj) : "Beneficiary";
    }

    String maskedReceiver = receiverAccount;

    if (receiverAccount != null && receiverAccount.length() > 4 && !"Not Available".equals(receiverAccount)) {
        maskedReceiver = "XXXXXXXX" + receiverAccount.substring(receiverAccount.length() - 4);
    }

    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
    String formattedAmount = amount;

    try {
        formattedAmount = moneyFormat.format(Double.parseDouble(amount));
    } catch (Exception e) {
        formattedAmount = amount;
    }

    String transactionTime = new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(new Date());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Transfer Success - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=204">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">
</head>

<body>

<div class="app-layout">

    <!-- Sidebar -->
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

            <a href="${pageContext.request.contextPath}/myAccount.jsp">
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

            <a href="#">
                <i class="bi bi-credit-card"></i>
                <span>Cards</span>
            </a>

            <a href="#">
                <i class="bi bi-gear"></i>
                <span>Services</span>
            </a>

            <a href="${pageContext.request.contextPath}/changePassword.jsp">
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

    <!-- Main Panel -->
    <main class="main-panel">

        <!-- Topbar -->
        <header class="topbar">

            <div class="welcome-box">
                <h3>Transfer Successful</h3>
                <p>Your transaction has been completed securely.</p>
            </div>

            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Search transaction, account, services...">
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

        <!-- Page Content -->
        <section class="page-content">

            <div class="transfer-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <i class="bi bi-chevron-right"></i>
                <a href="${pageContext.request.contextPath}/transfer">Fund Transfer</a>
                <i class="bi bi-chevron-right"></i>
                <span>Success</span>
            </div>

            <div class="success-page-wrap">

                <div class="payment-success-card">

                    <div class="success-tick-ring">
                        <i class="bi bi-check-lg"></i>
                    </div>

                    <h1>Transfer Successful!</h1>
                    <p class="success-subtitle">
                        Your money has been transferred successfully through DKS Bank.
                    </p>

                    <div class="success-amount-box">
                        <span>Transferred Amount</span>
                        <h2>&#8377; <%= formattedAmount %></h2>
                    </div>

                    <div class="success-details-box">

                        <div class="success-detail-row">
                            <span>Receiver Name</span>
                            <b><%= receiverName %></b>
                        </div>

                        <div class="success-detail-row">
                            <span>Receiver Account</span>
                            <b><%= maskedReceiver %></b>
                        </div>

                        <div class="success-detail-row">
                            <span>Transfer Type</span>
                            <b>Internal DKS Transfer</b>
                        </div>

                        <div class="success-detail-row">
                            <span>Status</span>
                            <b class="success-status-text">
                                <i class="bi bi-check-circle"></i>
                                Completed
                            </b>
                        </div>

                        <div class="success-detail-row">
                            <span>Date & Time</span>
                            <b><%= transactionTime %></b>
                        </div>

                    </div>

                    <div class="success-note">
                        <i class="bi bi-info-circle"></i>
                        <p>
                            This transaction is saved in your transaction history.
                            You can view or download your mini statement anytime.
                        </p>
                    </div>

                    <div class="success-actions">

                        <a href="${pageContext.request.contextPath}/dashboard" class="success-main-btn">
                            <i class="bi bi-house-door"></i>
                            Back to Dashboard
                        </a>

                        <a href="${pageContext.request.contextPath}/history" class="success-outline-btn">
                            <i class="bi bi-receipt"></i>
                            View History
                        </a>

                        <a href="${pageContext.request.contextPath}/transfer" class="success-outline-btn">
                            <i class="bi bi-send"></i>
                            New Transfer
                        </a>

                    </div>

                </div>

                <div class="success-side">

                    <div class="transfer-side-card">
                        <i class="bi bi-shield-check"></i>
                        <h3>Secure Payment</h3>
                        <p>Your transaction was processed securely using DKS Bank session verification.</p>
                    </div>

                    <div class="transfer-side-card gold">
                        <i class="bi bi-file-earmark-text"></i>
                        <h3>Mini Statement</h3>
                        <p>You can download your transaction statement from history page.</p>
                    </div>

                    <div class="transfer-side-card danger">
                        <i class="bi bi-headset"></i>
                        <h3>Need Help?</h3>
                        <p>If this transaction was not done by you, contact support immediately.</p>
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