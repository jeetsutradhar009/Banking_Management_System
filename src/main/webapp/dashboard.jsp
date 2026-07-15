<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Account" %>

<%
    User user = (User) session.getAttribute("user");
    Account account = (Account) request.getAttribute("account");

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
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard - DKS Bank</title>
    
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

            <a href="${pageContext.request.contextPath}/dashboard" class="active">
                <i class="bi bi-house-door"></i>
                <span>Dashboard</span>
            </a>

            <a href="${pageContext.request.contextPath}/myAccount">
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
                <h3>Welcome back, <%= fullName %>!</h3>
                <p>Last login: 15-Jun-2026 01:00 PM IST</p>
            </div>

            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Search account, profile, services...">
            </div>

            <div class="top-actions" style="flex-wrap: nowrap; min-width: max-content;">

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

                        <a href="#" onclick="return comingSoon('Profile Overview');">
                            <i class="bi bi-person-badge"></i>
                            Profile Overview
                        </a>

                        <a href="${pageContext.request.contextPath}/myAccount">
                            <i class="bi bi-person"></i>
                            My Profile
                        </a>

                        <a href="${pageContext.request.contextPath}/change-password">
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

            <div class="page-heading">
                <h1>Dashboard</h1>
                <p>Manage your account, transfers and banking services from one place.</p>
            </div>

            <!-- Top Grid -->
            <div class="dks-top-grid">

                <!-- Primary Account Card -->
                <div class="dks-card primary-account-card">

                    <div class="card-head">
                        <h4>Primary Account</h4>
                        <span><%= accountType %></span>
                    </div>

                    <p class="label">Account Number</p>

                    <div class="account-no">
                        <%= maskedAccount %>
                        <i class="bi bi-copy clickable-icon"
                           onclick="return comingSoon('Copy Account Number');"></i>
                    </div>

                    <p class="label">Available Balance</p>

                    <div class="balance">
                        &#8377; <%= String.format("%.2f", balance) %>
                        <i class="bi bi-eye eye-icon clickable-icon"
                           onclick="return comingSoon('Balance Visibility');"></i>
                    </div>

                    <div class="card-actions">
                        <a href="${pageContext.request.contextPath}/transfer">Transfer Funds</a>
                        <a href="${pageContext.request.contextPath}/history">Account Statement</a>
                    </div>

                    <i class="bi bi-bank bg-icon"></i>

                </div>

                <!-- Consolidated Summary -->
                <div class="dks-card">

                    <div class="dks-section-head">
                        <h3>Consolidated Summary</h3>
                        <i class="bi bi-info-circle clickable-icon"
                           onclick="return comingSoon('Summary Info');"></i>
                    </div>

                    <div class="summary-content">

                        <div class="donut-chart">
                            <span>
                                &#8377;<br>
                                <%= String.format("%.0f", balance) %>
                            </span>
                        </div>

                        <div class="summary-list">
                            <p>
                                <span class="green-dot"></span>
                                Accounts
                                <b>&#8377; <%= String.format("%.2f", balance) %></b>
                            </p>

                            <p>
                                <span class="orange-dot"></span>
                                Deposits
                                <b>&#8377; 0.00</b>
                            </p>

                            <p>
                                <span class="blue-dot"></span>
                                Investments
                                <b>&#8377; 0.00</b>
                            </p>
                        </div>

                    </div>

                    <button class="outline-orange-btn" type="button"
                            onclick="return comingSoon('Consolidated Summary');">
                        View Summary
                    </button>

                </div>

                <!-- Account Overview -->
                <div class="dks-card">

                    <div class="dks-section-head">
                        <h3>Account Overview</h3>
                    </div>

                    <div class="profile-row">
                        <i class="bi bi-credit-card-2-front"></i>
                        <span>Account Type</span>
                        <b><%= accountType %></b>
                    </div>

                    <div class="profile-row">
                        <i class="bi bi-bank"></i>
                        <span>IFSC Code</span>
                        <b>DKSB0001886</b>
                    </div>

                    <div class="profile-row">
                        <i class="bi bi-geo-alt"></i>
                        <span>Branch</span>
                        <b>KADIGHAT, WB</b>
                    </div>

                    <div class="profile-row">
                        <i class="bi bi-phone"></i>
                        <span>Mobile</span>
                        <b>98XXXXXX45</b>
                    </div>

                    <div class="profile-row">
                        <i class="bi bi-envelope"></i>
                        <span>Email</span>
                        <b><%= user.getEmail() %></b>
                    </div>

                    <a href="${pageContext.request.contextPath}/myAccount" class="orange-full-btn">
                        Go to My Profile
                    </a>

                </div>

            </div>

            <!-- Account Table -->
            <div class="dks-panel">

                <div class="dks-section-head">
                    <h3>Your Accounts at a Glance</h3>
                    <a href="${pageContext.request.contextPath}/myAccount">
                        View All Accounts <i class="bi bi-chevron-right"></i>
                    </a>
                </div>

                <table class="dks-table">

                    <thead>
                    <tr>
                        <th>Account Number</th>
                        <th>Account Holder Name</th>
                        <th>Account Type</th>
                        <th>Available Balance</th>
                        <th>Linked A/c Balance</th>
                        <th>Effective A/c Balance</th>
                        <th>Actions</th>
                    </tr>
                    </thead>

                    <tbody>
                    <tr>
                        <td>
                            <b><%= maskedAccount %></b>
                            <small>Primary</small>
                        </td>

                        <td><%= fullName.toUpperCase() %></td>

                        <td><%= accountType %></td>

                        <td class="green-text">
                            &#8377; <%= String.format("%.2f", balance) %>
                        </td>

                        <td>&#8377; 0.00</td>

                        <td class="green-text">
                            &#8377; <%= String.format("%.2f", balance) %>
                        </td>

                        <td>
                            <i class="bi bi-three-dots-vertical clickable-icon"
                               onclick="return comingSoon('Account Actions');"></i>
                        </td>
                    </tr>
                    </tbody>

                </table>

            </div>

            <!-- Bottom Grid -->
            <div class="dks-bottom-grid">

                <!-- Recent Transactions -->
                <div class="dks-panel">

                    <div class="dks-section-head">
                        <h3>Recent Transactions</h3>
                        <a href="${pageContext.request.contextPath}/history">View All</a>
                    </div>

                    <div class="transaction-list">

                        <div class="transaction-item">
                            <span class="txn-icon credit">
                                <i class="bi bi-arrow-down"></i>
                            </span>

                            <div>
                                <h4>Interest Credit</h4>
                                <p>15-Jun-2026, 09:15 AM</p>
                            </div>

                            <b class="credit-text">+ &#8377; 500.00</b>
                        </div>

                        <div class="transaction-item">
                            <span class="txn-icon debit">
                                <i class="bi bi-arrow-up"></i>
                            </span>

                            <div>
                                <h4>UPI Payment</h4>
                                <p>14-Jun-2026, 04:35 PM</p>
                            </div>

                            <b class="debit-text">- &#8377; 1,500.00</b>
                        </div>

                        <div class="transaction-item">
                            <span class="txn-icon credit">
                                <i class="bi bi-arrow-down"></i>
                            </span>

                            <div>
                                <h4>Salary Credit</h4>
                                <p>14-Jun-2026, 09:00 AM</p>
                            </div>

                            <b class="credit-text">+ &#8377; 15,000.00</b>
                        </div>

                        <div class="transaction-item">
                            <span class="txn-icon debit">
                                <i class="bi bi-arrow-up"></i>
                            </span>

                            <div>
                                <h4>Electricity Bill</h4>
                                <p>13-Jun-2026, 07:20 PM</p>
                            </div>

                            <b class="debit-text">- &#8377; 1,250.00</b>
                        </div>

                    </div>

                </div>

                <!-- Scheduled Transactions -->
                <div class="dks-panel">

                    <div class="dks-section-head">
                        <h3>Scheduled Transactions</h3>
                        <a href="#" onclick="return comingSoon('Scheduled Transactions');">
                            View All
                        </a>
                    </div>

                    <div class="empty-state">
                        <i class="bi bi-calendar2-check"></i>
                        <h4>No Scheduled Transactions</h4>
                        <p>You do not have any scheduled transactions.</p>

                        <button class="orange-btn" type="button"
                                onclick="return comingSoon('Schedule a Transaction');">
                            Schedule a Transaction
                        </button>
                    </div>

                </div>

                <!-- Quick Actions -->
                <div class="dks-panel">

                    <div class="dks-section-head">
                        <h3>Quick Actions</h3>
                    </div>

                    <div class="quick-action-grid">

                        <a href="${pageContext.request.contextPath}/transfer" class="quick-action-card">
                            <i class="bi bi-send"></i>
                            <span>Fund Transfer</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/history" class="quick-action-card">
                            <i class="bi bi-file-earmark-text"></i>
                            <span>Account Statement</span>
                        </a>

                        <a href="#" onclick="return comingSoon('Bill Payment');" class="quick-action-card">
                            <i class="bi bi-receipt-cutoff"></i>
                            <span>Bill Payment</span>
                        </a>

                        <a href="#" onclick="return comingSoon('Recharge');" class="quick-action-card">
                            <i class="bi bi-phone"></i>
                            <span>Recharge</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/myAccount" class="quick-action-card">
                            <i class="bi bi-wallet2"></i>
                            <span>Check Balance</span>
                        </a>

                        <a href="#" onclick="return comingSoon('Manage Beneficiary');" class="quick-action-card">
                            <i class="bi bi-people"></i>
                            <span>Manage Beneficiary</span>
                        </a>

                        <a href="#" onclick="return comingSoon('Cheque Book');" class="quick-action-card">
                            <i class="bi bi-journal-text"></i>
                            <span>Cheque Book</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/services" class="quick-action-card">
                            <i class="bi bi-grid"></i>
                            <span>More Services</span>
                        </a>

                    </div>

                </div>

            </div>

            <!-- Security Tip -->
            <div class="security-tip">

                <div>
                    <i class="bi bi-shield-check"></i>
                </div>

                <div>
                    <h3>Security Tip</h3>
                    <p>
                        Never share your OTP, PIN or password with anyone.
                        DKS Bank will never ask for your confidential information.
                    </p>
                </div>

                <a href="#" onclick="return comingSoon('Security Tips');">
                    Know More <i class="bi bi-arrow-right"></i>
                </a>

            </div>

            <footer class="dks-footer">
                <p>© 2026 DKS Bank. All rights reserved.</p>

                <div>
                    <a href="#" onclick="return comingSoon('Privacy Policy');">Privacy Policy</a>
                    <a href="#" onclick="return comingSoon('Terms & Conditions');">Terms & Conditions</a>
                    <a href="#" onclick="return comingSoon('Security Tips');">Security Tips</a>
                    <a href="#" onclick="return comingSoon('Contact Us');">Contact Us</a>
                </div>
            </footer>

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

        const overlay = document.getElementById("dksComingOverlay");

        if (overlay && event.target === overlay) {
            closeComingSoon();
        }
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            closeComingSoon();
        }
    });
</script>

</body>
</html>
