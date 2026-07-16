<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.bank.model.User" %>
<%@ page import="com.bank.model.Transaction" %>
<%@ page import="com.bank.model.Account" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Transaction> txList = (List<Transaction>) request.getAttribute("txList");

    if (txList == null) {
        txList = (List<Transaction>) request.getAttribute("transactions");
    }

    Account account = (Account) request.getAttribute("account");

    String fullName = user.getFullName() != null ? user.getFullName() : "User";

    String initials = "U";
    String[] nameParts = fullName.trim().split(" ");

    if (nameParts.length >= 2) {
        initials = nameParts[0].substring(0, 1).toUpperCase()
                + nameParts[1].substring(0, 1).toUpperCase();
    } else if (fullName.length() >= 1) {
        initials = fullName.substring(0, 1).toUpperCase();
    }

    String accountNumber = "";
    String maskedAccount = "XXXXXXXXXXXX2384";
    String accountType = "Savings Account";
    double balance = 0.00;

    if (account != null) {
        accountNumber = account.getAccountNumber();

        if (account.getAccountType() != null) {
            accountType = account.getAccountType();
        }

        balance = account.getBalance();

        if (accountNumber != null && accountNumber.length() > 4) {
            maskedAccount = "XXXXXXXXXXXX" + accountNumber.substring(accountNumber.length() - 4);
        }
    }

    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");

    int totalEntries = txList == null ? 0 : txList.size();
    int showingEntries = Math.min(totalEntries, 10);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Transaction History - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

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

            <a href="${pageContext.request.contextPath}/myAccount">
                <i class="bi bi-person-circle"></i>
                <span>My Account</span>
            </a>

            <a href="${pageContext.request.contextPath}/transfer">
                <i class="bi bi-send"></i>
                <span>Fund Transfer</span>
            </a>

            <a href="${pageContext.request.contextPath}/history" class="active">
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
                <h3>Mini Statement</h3>
                <p>View your recent account transactions.</p>
            </div>

            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Search transactions, amount, account...">
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

            <div class="history-layout">

                <!-- Main History Area -->
                <div class="history-main">

                    <div class="history-breadcrumb">
                        <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                        <i class="bi bi-chevron-right"></i>
                        <span>Mini Statement</span>
                    </div>

                    <div class="history-title-row">

                        <div>
                            <a href="${pageContext.request.contextPath}/dashboard" class="back-link">
                                <i class="bi bi-arrow-left"></i>
                            </a>

                            <div>
                                <h1>Mini Statement</h1>
                                <p>Recent account transactions with credit/debit status.</p>
                            </div>
                        </div>

                        <div class="history-actions">
                            <!-- Added Coming Soon to Filter -->
                            <button type="button" onclick="return comingSoon('Filter Transactions');">
                                <i class="bi bi-filter"></i>
                                Filter
                            </button>

                            <a href="${pageContext.request.contextPath}/mini-statement" class="history-download-btn">
                                <i class="bi bi-download"></i>
                                Download PDF
                            </a>
                        </div>

                    </div>

                    <!-- Mini Account Card -->
                    <div class="mini-account-card">

                        <div class="mini-card-left">
                            <h3><%= accountType %></h3>
                            <h2><%= maskedAccount %></h2>
                            <p><%= fullName.toUpperCase() %></p>
                        </div>

                        <div class="mini-balance-circle">
                            <span>Total Avbl Balance</span>
                            <h4>&#8377; <%= moneyFormat.format(balance) %></h4>
                        </div>

                        <i class="bi bi-bank mini-bg-icon"></i>

                    </div>

                    <!-- Transaction Table -->
                    <div class="history-table-card">

                        <div class="history-table-top">

                            <h3>Transaction Details</h3>

                            <div class="small-search">
                                <i class="bi bi-search"></i>
                                <input type="text" placeholder="Search...">
                            </div>

                        </div>

                        <table class="history-table">

                            <thead>
                            <tr>
                                <th>Date <i class="bi bi-arrow-down-up"></i></th>
                                <th>Transaction Details</th>
                                <th>Amount <i class="bi bi-arrow-down-up"></i></th>
                                <th>Status</th>
                            </tr>
                            </thead>

                            <tbody>

                            <%
                                if (txList != null && !txList.isEmpty()) {

                                    int count = 0;

                                    for (Transaction tx : txList) {

                                        if (count >= 10) {
                                            break;
                                        }

                                        count++;

                                        boolean isDebit = tx.getSenderAccount() != null
                                                && tx.getSenderAccount().equals(accountNumber);

                                        boolean isCredit = tx.getReceiverAccount() != null
                                                && tx.getReceiverAccount().equals(accountNumber);

                                        String displayType;

                                        if (isDebit) {
                                            displayType = "Debit";
                                        } else if (isCredit) {
                                            displayType = "Credit";
                                        } else {
                                            displayType = "Transaction";
                                        }

                                        String amountClass = isDebit ? "hist-debit" : "hist-credit";
                                        String sign = isDebit ? "- " : "+ ";
                                        String crDr = isDebit ? "Dr" : "Cr";

                                        String otherName;
                                        String otherAccount;
                                        String details;
                                        String subDetails;

                                        if (isDebit) {
                                            otherName = tx.getReceiverName();
                                            otherAccount = tx.getReceiverAccount();

                                            if (otherName == null || otherName.trim().isEmpty()) {
                                                otherName = "Account Holder";
                                            }

                                            details = "Paid to " + otherName;

                                        } else if (isCredit) {
                                            otherName = tx.getSenderName();
                                            otherAccount = tx.getSenderAccount();

                                            if (otherName == null || otherName.trim().isEmpty()) {
                                                otherName = "Account Holder";
                                            }

                                            details = "Received from " + otherName;

                                        } else {
                                            otherName = "Account Holder";
                                            otherAccount = "";
                                            details = "DKS Transaction";
                                        }

                                        String maskedOtherAccount = otherAccount;

                                        if (otherAccount != null && otherAccount.length() > 4) {
                                            maskedOtherAccount = "XXXXXXXX" + otherAccount.substring(otherAccount.length() - 4);
                                        }

                                        subDetails = "A/c: " + maskedOtherAccount;

                                        String rawDate = String.valueOf(tx.getTransactionDate());
                                        String dateText = rawDate;

                                        if (rawDate != null && rawDate.length() >= 10 && rawDate.charAt(4) == '-') {
                                            dateText = rawDate.substring(8, 10) + "/"
                                                    + rawDate.substring(5, 7) + "/"
                                                    + rawDate.substring(0, 4);
                                        }

                                        String statusText = tx.getStatus() != null ? tx.getStatus() : "Success";
                            %>

                            <tr>
                                <td><%= dateText %></td>

                                <td>
                                    <div class="txn-detail-text">
                                        <strong><%= details %></strong>
                                        <span><%= subDetails %></span>
                                    </div>
                                </td>

                                <td class="<%= amountClass %>">
                                    <%= sign %>&#8377; <%= moneyFormat.format(tx.getAmount()) %>
                                    <small><%= crDr %></small>
                                </td>

                                <td>
                                    <span class="history-status-badge">
                                        <%= statusText %>
                                    </span>
                                </td>
                            </tr>

                            <%
                                    }

                                } else {
                            %>

                            <tr>
                                <td colspan="4">
                                    <div class="empty-history">
                                        <i class="bi bi-receipt"></i>
                                        <h3>No Transactions Found</h3>
                                        <p>Your transaction history will appear here.</p>
                                    </div>
                                </td>
                            </tr>

                            <%
                                }
                            %>

                            </tbody>

                        </table>

                        <div class="history-pagination">

                            <p>
                                Showing
                                <b><%= totalEntries == 0 ? 0 : 1 %></b>
                                to
                                <b><%= showingEntries %></b>
                                of
                                <b><%= totalEntries %></b>
                                entries
                            </p>

                            <div class="pager">
                                <button type="button">Previous</button>
                                <button type="button" class="active">1</button>
                                <button type="button">2</button>
                                <button type="button">Next</button>
                            </div>

                        </div>

                    </div>

                </div>

                <!-- Right Panel (Commented out securely) -->
                <!-- 
                <aside class="history-right-panel">
                    <div class="safe-card danger">
                        <i class="bi bi-shield-lock"></i>
                        <h3>Beware of Digital Scams</h3>
                        <p>Never share OTP, PIN, password or CVV with anyone.</p>
                    </div>

                    <div class="safe-card">
                        <i class="bi bi-graph-up-arrow"></i>
                        <h3>Fake Investment Alert</h3>
                        <p>DKS Bank never asks you to invest through unknown links.</p>
                    </div>

                    <div class="safe-card gold">
                        <i class="bi bi-house-check"></i>
                        <h3>DKS Bank Home Loan</h3>
                        <p>Secure, simple and trusted banking support.</p>
                    </div>

                    <div class="safe-card">
                        <i class="bi bi-headset"></i>
                        <h3>Need Help?</h3>
                        <p>Contact 24x7 DKS customer support anytime.</p>
                    </div>
                </aside>
                -->

            </div> <!-- END history-layout -->

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