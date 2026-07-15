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
        response.sendRedirect(request.getContextPath() + "/transfer");
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

    String accountNumber = "Account Not Found";
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

    if (accountNumber != null && accountNumber.length() > 4 && !"Account Not Found".equals(accountNumber)) {
        maskedAccount = "XXXXXXXXXXXX" + accountNumber.substring(accountNumber.length() - 4);
    }

    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");

    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Fund Transfer - DKS Bank</title>
    
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

    <main class="main-panel">

        <header class="topbar">

            <div class="welcome-box">
                <h3>Fund Transfer</h3>
                <p>Fill transfer details and continue to confirmation.</p>
            </div>

            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Search beneficiary, account, services...">
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

        <section class="page-content">

            <div class="transfer-breadcrumb">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <i class="bi bi-chevron-right"></i>
                <span>Fund Transfer</span>
            </div>

            <div class="transfer-header">

                <div>
                    <h1>Fund Transfer</h1>
                    <p>Enter receiver account number. Holder name will auto-fill from database.</p>
                </div>

                <a href="${pageContext.request.contextPath}/history" class="transfer-outline-btn">
                    <i class="bi bi-receipt"></i>
                    View History
                </a>

            </div>

            <% if (error != null) { %>
                <div class="transfer-alert error">
                    <i class="bi bi-exclamation-circle"></i>
                    <%= error %>
                </div>
            <% } %>

            <div class="transfer-layout">

                <div class="transfer-left">

                    <div class="transfer-account-card">

                        <div class="transfer-account-top">
                            <div>
                                <h3>From Account</h3>
                                <p><%= accountType %></p>
                            </div>

                            <i class="bi bi-bank2"></i>
                        </div>

                        <div class="transfer-account-number">
                            <span>Account Number</span>
                            <h2><%= maskedAccount %></h2>
                        </div>

                        <div class="transfer-balance">
                            <span>Available Balance</span>
                            <h1>&#8377; <%= moneyFormat.format(balance) %></h1>
                        </div>

                        <div class="transfer-owner">
                            <i class="bi bi-person-circle"></i>
                            <div>
                                <span>Account Holder</span>
                                <b><%= fullName.toUpperCase() %></b>
                            </div>
                        </div>

                        <i class="bi bi-send transfer-bg-icon"></i>

                    </div>

                    <div class="transfer-tip-card">
                        <i class="bi bi-shield-check"></i>
                        <div>
                            <h3>Secure Transfer</h3>
                            <p>Receiver holder name will be fetched automatically from database.</p>
                        </div>
                    </div>

                    <div class="transfer-limit-card">
                        <h3>Transfer Limits</h3>

                        <div>
                            <span>Minimum Transfer</span>
                            <b>&#8377; 1.00</b>
                        </div>

                        <div>
                            <span>Daily Limit</span>
                            <b>&#8377; 1,00,000.00</b>
                        </div>

                        <div>
                            <span>Transfer Mode</span>
                            <b>Internal DKS</b>
                        </div>
                    </div>

                </div>

                <div class="transfer-form-card">

                    <div class="transfer-form-head">
                        <div>
                            <h2>Transfer Details</h2>
                            <p>Account holder name will auto-fill after account verification.</p>
                        </div>

                        <div class="transfer-lock">
                            <i class="bi bi-lock"></i>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/transfer" method="post">

                        <div class="transfer-form-group">
                            <label>Receiver Account Number</label>

                            <div class="transfer-input">
                                <i class="bi bi-credit-card-2-front"></i>
                                <input type="text"
                                       name="receiverAccount"
                                       id="receiverAccount"
                                       placeholder="Enter receiver account number"
                                       autocomplete="off"
                                       required>
                            </div>

                            <small id="accountCheckMsg" class="account-check-msg"></small>
                        </div>

                        <div class="transfer-form-group">
                            <label>Account Holder Name</label>

                            <div class="transfer-input">
                                <i class="bi bi-person"></i>
                                <input type="text"
                                       name="receiverName"
                                       id="receiverName"
                                       placeholder="Account holder name will auto-fill"
                                       readonly
                                       required>
                            </div>
                        </div>

                        <div class="transfer-form-group">
                            <label>Amount</label>

                            <div class="transfer-input">
                                <i class="bi bi-currency-rupee"></i>
                                <input type="number"
                                       name="amount"
                                       step="0.01"
                                       min="1"
                                       placeholder="Enter amount"
                                       required>
                            </div>
                        </div>

                        <div class="transfer-review-box">
                            <div>
                                <i class="bi bi-info-circle"></i>
                            </div>

                            <p>
                                Click <b>Transfer Now</b> to review details on confirmation page.
                                Money will be transferred only after final confirmation.
                            </p>
                        </div>

                        <div class="transfer-buttons">
                            <button type="reset" class="transfer-cancel-btn" onclick="resetAccountCheck()">
                                <i class="bi bi-x-circle"></i>
                                Clear
                            </button>

                            <button type="submit" class="transfer-submit-btn">
                                <i class="bi bi-send"></i>
                                Transfer Now
                            </button>
                        </div>

                    </form>

                </div>

                <div class="transfer-right">

                    <div class="transfer-side-card">
                        <i class="bi bi-person-check"></i>
                        <h3>Auto Verification</h3>
                        <p>Receiver name will be filled automatically using saved account details.</p>
                    </div>

                    <div class="transfer-side-card gold">
                        <i class="bi bi-lightning-charge"></i>
                        <h3>Confirm First</h3>
                        <p>Your final transfer happens only after confirm page approval.</p>
                    </div>

                    <div class="transfer-side-card danger">
                        <i class="bi bi-exclamation-triangle"></i>
                        <h3>Fraud Alert</h3>
                        <p>Do not transfer money for unknown calls, fake offers or suspicious links.</p>
                    </div>

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
    const receiverAccountInput = document.getElementById("receiverAccount");
    const receiverNameInput = document.getElementById("receiverName");
    const accountCheckMsg = document.getElementById("accountCheckMsg");

    let typingTimer;

    receiverAccountInput.addEventListener("input", function () {
        clearTimeout(typingTimer);

        const accountNumber = receiverAccountInput.value.trim();

        receiverNameInput.value = "";
        accountCheckMsg.textContent = "";
        accountCheckMsg.className = "account-check-msg";

        if (accountNumber.length < 5) {
            return;
        }

        accountCheckMsg.textContent = "Checking account...";
        accountCheckMsg.className = "account-check-msg checking";

        typingTimer = setTimeout(function () {
            fetch("${pageContext.request.contextPath}/check-account?accountNumber=" + encodeURIComponent(accountNumber))
                .then(function (response) {
                    return response.json();
                })
                .then(function (data) {
                    if (data.found) {
                        receiverNameInput.value = data.holderName;
                        accountCheckMsg.textContent = "Account verified";
                        accountCheckMsg.className = "account-check-msg success";
                    } else {
                        receiverNameInput.value = "";
                        accountCheckMsg.textContent = data.message || "Account not found";
                        accountCheckMsg.className = "account-check-msg error";
                    }
                })
                .catch(function () {
                    receiverNameInput.value = "";
                    accountCheckMsg.textContent = "Unable to verify account";
                    accountCheckMsg.className = "account-check-msg error";
                });
        }, 500);
    });

    function resetAccountCheck() {
        receiverNameInput.value = "";
        accountCheckMsg.textContent = "";
        accountCheckMsg.className = "account-check-msg";
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

    // Coming Soon Popup Functions
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

    // Close modal on click outside
    document.addEventListener("click", function (event) {
        const overlay = document.getElementById("dksComingOverlay");
        if (overlay && event.target === overlay) {
            closeComingSoon();
        }
    });

    // Close modal on escape key
    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            closeComingSoon();
        }
    });
</script>

</body>
</html>