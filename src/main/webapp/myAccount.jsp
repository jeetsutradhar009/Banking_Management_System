<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Account" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Account account = (Account) request.getAttribute("account");
    Boolean accountLoaded = (Boolean) request.getAttribute("accountLoaded");

    if (account == null && accountLoaded == null) {
        response.sendRedirect(request.getContextPath() + "/myAccount");
        return;
    }

    String fullName = user.getFullName() != null ? user.getFullName() : "User";
    String email = user.getEmail() != null ? user.getEmail() : "Not Available";
    String phone = user.getPhone() != null ? user.getPhone() : "Not Available";
    String role = user.getRole() != null ? user.getRole() : "USER";

    String initials = "U";
    String[] nameParts = fullName.trim().split(" ");

    if (nameParts.length >= 2) {
        initials = nameParts[0].substring(0, 1).toUpperCase()
                + nameParts[1].substring(0, 1).toUpperCase();
    } else if (fullName.length() >= 1) {
        initials = fullName.substring(0, 1).toUpperCase();
    }

    String accountNumber = "XXXXXXXXXXXX2384";
    String accountType = "Savings Account";
    double balance = 0.00;

    if (account != null) {
        if (account.getAccountNumber() != null) {
            accountNumber = account.getAccountNumber();
        }

        if (account.getAccountType() != null) {
            accountType = account.getAccountType();
        }

        balance = account.getBalance();
    }

    String maskedAccount = accountNumber;

    if (accountNumber != null && accountNumber.length() > 4) {
        maskedAccount = "XXXXXXXXXXXX" + accountNumber.substring(accountNumber.length() - 4);
    }

    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Account - DKS Bank</title>

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

            <a href="${pageContext.request.contextPath}/myAccount" class="active">
                <i class="bi bi-person-circle"></i>
                <span>My Account</span>
            </a>

            <a href="${pageContext.request.contextPath}/transfer">
                <i class="bi bi-send"></i>
                <span>Fund Transfer</span>
            </a>

            <a href="${pageContext.request.contextPath}/history">
                <i class="bi bi-receipt"></i>
                <span>Transaction History</span>
            </a>

            <!-- Changed from browser alert to custom modal -->
            <a href="#" onclick="return comingSoon('Cards');">
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

    <!-- Main Panel -->
    <main class="main-panel">

        <!-- Topbar -->
        <header class="topbar">

            <div class="welcome-box">
                <h3>My Account</h3>
                <p>View your profile, account and security information.</p>
            </div>

            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Search account, profile, services...">
            </div>

            <div class="top-actions">

                <button class="icon-btn" type="button" onclick="return comingSoon('Notifications');">
                    <i class="bi bi-bell"></i>
                    <span>3</span>
                </button>

                <button class="icon-btn" type="button" onclick="return comingSoon('Messages');">
                    <i class="bi bi-envelope"></i>
                    <span>8</span>
                </button>

                <button class="icon-btn no-badge" type="button" onclick="return comingSoon('Help Center');">
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

                        <a href="#" onclick="return comingSoon('Notifications');">
                            <i class="bi bi-bell"></i>
                            Notifications
                        </a>

                        <a href="#" onclick="return comingSoon('Profile Settings');">
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

            <div class="myacc-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <i class="bi bi-chevron-right"></i>
                <span>My Account</span>
            </div>

            <div class="myacc-header">

                <div>
                    <h1>My Account</h1>
                    <p>Manage your banking profile and account details in one place.</p>
                </div>

                <div class="myacc-header-actions">
                    <a href="${pageContext.request.contextPath}/history">
                        <i class="bi bi-receipt"></i>
                        View Statement
                    </a>

                    <a href="${pageContext.request.contextPath}/transfer.jsp">
                        <i class="bi bi-send"></i>
                        Transfer Money
                    </a>
                </div>

            </div>

            <!-- Hero Account Section -->
            <div class="myacc-hero-grid">

                <div class="myacc-profile-card">

                    <div class="myacc-avatar">
                        <%= initials %>
                    </div>

                    <h2><%= fullName %></h2>
                    <p><%= email %></p>

                    <div class="myacc-profile-tags">
                        <span><i class="bi bi-shield-check"></i> Verified User</span>
                        <span><i class="bi bi-check-circle"></i> KYC Completed</span>
                    </div>

                    <a href="${pageContext.request.contextPath}/changePassword.jsp" class="myacc-outline-btn">
                        <i class="bi bi-key"></i>
                        Change Password
                    </a>

                </div>

                <div class="myacc-bank-card">

                    <div class="myacc-bank-card-top">
                        <div>
                            <h3>Primary Account</h3>
                            <p><%= accountType %></p>
                        </div>

                        <i class="bi bi-bank2"></i>
                    </div>

                    <div class="myacc-card-number">
                        <span>Account Number</span>
                        <h2><%= maskedAccount %></h2>
                    </div>

                    <div class="myacc-card-bottom">
                        <div>
                            <span>Available Balance</span>
                            <h1>&#8377; <%= moneyFormat.format(balance) %></h1>
                        </div>

                        <div>
                            <span>IFSC</span>
                            <h4>DKSB0001886</h4>
                        </div>
                    </div>

                    <div class="myacc-metal-shine"></div>

                </div>

                <div class="myacc-status-card">

                    <h3>Account Health</h3>

                    <div class="health-ring">
                        <span>98%</span>
                    </div>

                    <p>Your DKS Bank account is secure and active.</p>

                    <div class="health-list">
                        <div>
                            <i class="bi bi-check-circle"></i>
                            Login Security Active
                        </div>

                        <div>
                            <i class="bi bi-check-circle"></i>
                            Mobile Verified
                        </div>

                        <div>
                            <i class="bi bi-check-circle"></i>
                            Email Verified
                        </div>
                    </div>

                </div>

            </div>

            <!-- Details Grid -->
            <div class="myacc-details-grid">

                <div class="myacc-panel">

                    <div class="myacc-panel-head">
                        <h3><i class="bi bi-person-lines-fill"></i> Personal Details</h3>
                    </div>

                    <div class="myacc-info-row">
                        <span>Full Name</span>
                        <b><%= fullName %></b>
                    </div>

                    <div class="myacc-info-row">
                        <span>Email ID</span>
                        <b><%= email %></b>
                    </div>

                    <div class="myacc-info-row">
                        <span>Mobile Number</span>
                        <b><%= phone %></b>
                    </div>

                    <div class="myacc-info-row">
                        <span>User Role</span>
                        <b><%= role %></b>
                    </div>

                </div>

                <div class="myacc-panel">

                    <div class="myacc-panel-head">
                        <h3><i class="bi bi-credit-card-2-front"></i> Account Details</h3>
                    </div>

                    <div class="myacc-info-row">
                        <span>Account Number</span>
                        <b><%= maskedAccount %></b>
                    </div>

                    <div class="myacc-info-row">
                        <span>Account Type</span>
                        <b><%= accountType %></b>
                    </div>

                    <div class="myacc-info-row">
                        <span>Available Balance</span>
                        <b class="green-text">&#8377; <%= moneyFormat.format(balance) %></b>
                    </div>

                    <div class="myacc-info-row">
                        <span>Branch</span>
                        <b>KADIGHAT, WB</b>
                    </div>

                    <div class="myacc-info-row">
                        <span>IFSC Code</span>
                        <b>DKSB0001886</b>
                    </div>

                </div>

                <div class="myacc-panel">

                    <div class="myacc-panel-head">
                        <h3><i class="bi bi-shield-lock"></i> Security Details</h3>
                    </div>

                    <div class="myacc-info-row">
                        <span>KYC Status</span>
                        <b class="success-text">Completed</b>
                    </div>

                    <div class="myacc-info-row">
                        <span>Password Status</span>
                        <b class="success-text">Active</b>
                    </div>

                    <div class="myacc-info-row">
                        <span>Transaction PIN</span>
                        <b class="success-text">Enabled</b>
                    </div>

                    <div class="myacc-info-row">
                        <span>Last Login</span>
                        <b>15-Jun-2026 01:00 PM</b>
                    </div>

                </div>

            </div>

            <!-- Quick Services -->
            <div class="myacc-panel myacc-services-panel">

                <div class="myacc-panel-head">
                    <h3><i class="bi bi-lightning-charge"></i> Quick Account Services</h3>
                </div>

                <div class="myacc-services-grid">

                    <a href="${pageContext.request.contextPath}/transfer">
                        <i class="bi bi-send"></i>
                        <span>Fund Transfer</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/history">
                        <i class="bi bi-file-earmark-text"></i>
                        <span>Mini Statement</span>
                    </a>

                    <a href="#" onclick="return comingSoon('Bill Payment');">
                        <i class="bi bi-receipt"></i>
                        <span>Bill Payment</span>
                    </a>

                    <a href="#" onclick="return comingSoon('Mobile Recharge');">
                        <i class="bi bi-phone"></i>
                        <span>Mobile Recharge</span>
                    </a>

                    <a href="#" onclick="return comingSoon('Cheque Book');">
                        <i class="bi bi-journal-text"></i>
                        <span>Cheque Book</span>
                    </a>

                    <a href="#" onclick="return comingSoon('Support');">
                        <i class="bi bi-headset"></i>
                        <span>Support</span>
                    </a>

                </div>

            </div>

        </section>

    </main>

</div>

<!-- DKS Custom Coming Soon Popup -->
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
            <span id="dksComingFeature">This feature</span>
            is currently under development.
        </p>

        <button type="button" class="dks-popup-ok" onclick="closeComingSoon()">
            OK
        </button>

    </div>
</div>

<script>
    // Profile Dropdown Toggle
    function toggleProfileDropdown() {
        const dropdown = document.getElementById("profileDropdown");
        if (dropdown) {
            dropdown.classList.toggle("show");
        }
    }

    // Coming Soon Modal Functions
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

    // Handle clicks outside of dropdown and modal
    document.addEventListener("click", function (event) {
        // Profile Dropdown hide logic
        if (!event.target.closest(".profile-menu")) {
            const dropdown = document.getElementById("profileDropdown");
            if (dropdown && dropdown.classList.contains("show")) {
                dropdown.classList.remove("show");
            }
        }

        // Modal hide logic
        const overlay = document.getElementById("dksComingOverlay");
        if (overlay && event.target === overlay) {
            closeComingSoon();
        }
    });

    // Handle escape key to close modal
    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            closeComingSoon();
        }
    });
</script>

</body>
</html>