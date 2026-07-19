<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>

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
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Services - DKS Bank</title>
    
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

            <a href="${pageContext.request.contextPath}/history">
                <i class="bi bi-receipt"></i>
                <span>Transaction History</span>
            </a>

            <a href="#" onclick="return comingSoon('Cards');">
                <i class="bi bi-credit-card"></i>
                <span>Cards</span>
            </a>

            <a href="${pageContext.request.contextPath}/services" class="active">
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
                <h3>Services</h3>
                <p>Welcome, <%= fullName %>. Choose a banking service.</p>
            </div>

            <div class="search-box">
                <i class="bi bi-search"></i>
                <input type="text" placeholder="Search services, payments, cards...">
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

                        <a href="${pageContext.request.contextPath}/profileOverview">
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

            <div class="services-main-heading">
                <div>
                    <h1>Banking Services</h1>
                    <p>Apply, pay, invest and manage all banking services from one place.</p>
                </div>

                <a href="${pageContext.request.contextPath}/dashboard" class="back-dashboard-btn">
                    <i class="bi bi-arrow-left"></i>
                    Back to Dashboard
                </a>
            </div>

            <div class="service-wrapper">

                <!-- Apply -->
                <div class="service-block">

                    <div class="service-block-head">
                        <h3>Apply</h3>
                        <button type="button" onclick="return comingSoon('Apply Services');">VIEW ALL</button>
                    </div>

                    <div class="service-grid">

                        <button type="button" class="service-card" onclick="return comingSoon('Purchase Gift Card');">
                            <i class="bi bi-gift"></i>
                            <span>Purchase Gift Card</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Online Loan Application');">
                            <i class="bi bi-file-earmark-text"></i>
                            <span>Online Loan Application</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Apply Now');">
                            <i class="bi bi-pencil-square"></i>
                            <span>Apply Now</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Apply for PMJJBY / PMSBY');">
                            <i class="bi bi-umbrella"></i>
                            <span>Apply for PMJJBY / PMSBY</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Health Insurance');">
                            <i class="bi bi-heart-pulse"></i>
                            <span>Health Insurance</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('General Insurance');">
                            <i class="bi bi-shield-check"></i>
                            <span>General Insurance</span>
                        </button>

                    </div>

                </div>

                <!-- Account Services -->
                <div class="service-block">

                    <div class="service-block-head">
                        <h3>Account Services</h3>
                        <button type="button" onclick="return comingSoon('Account Services');">VIEW ALL</button>
                    </div>

                    <div class="service-grid">

                        <button type="button" class="service-card" onclick="return comingSoon('Account Statement Request');">
                            <i class="bi bi-file-earmark-bar-graph"></i>
                            <span>A/c Statement Request</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('TDS Certificate Request');">
                            <i class="bi bi-receipt-cutoff"></i>
                            <span>TDS Certificate Request</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Register for Email Statement');">
                            <i class="bi bi-envelope-check"></i>
                            <span>Register for Email Statement</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Submit Re-KYC');">
                            <i class="bi bi-person-vcard"></i>
                            <span>Submit Re-KYC</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Submit Form 15G/H');">
                            <i class="bi bi-file-earmark-check"></i>
                            <span>Submit Form 15G/H</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Update Email ID');">
                            <i class="bi bi-envelope-at"></i>
                            <span>Update Email ID</span>
                        </button>

                    </div>

                </div>

                <!-- Cheque Services -->
                <div class="service-block">

                    <div class="service-block-head">
                        <h3>Cheque Services</h3>
                        <button type="button" onclick="return comingSoon('Cheque Services');">VIEW ALL</button>
                    </div>

                    <div class="service-grid">

                        <button type="button" class="service-card" onclick="return comingSoon('Stop Cheque');">
                            <i class="bi bi-x-square"></i>
                            <span>Stop Cheque</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Cheque Status');">
                            <i class="bi bi-search"></i>
                            <span>Cheque Status</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Cheque Book Request');">
                            <i class="bi bi-journal-text"></i>
                            <span>Cheque Book Request</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Positive Pay Confirm Cheque');">
                            <i class="bi bi-check2-square"></i>
                            <span>Positive Pay Confirm Cheque</span>
                        </button>

                    </div>

                </div>

                <!-- Investments -->
                <div class="service-block">

                    <div class="service-block-head">
                        <h3>Investments</h3>
                        <button type="button" onclick="return comingSoon('Investments');">VIEW ALL</button>
                    </div>

                    <div class="service-grid">

                        <button type="button" class="service-card" onclick="return comingSoon('Open FD');">
                            <i class="bi bi-safe2"></i>
                            <span>Open FD</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Open SSP / PPF Plus');">
                            <i class="bi bi-piggy-bank"></i>
                            <span>Open SSP / PPF Plus</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Renew FD');">
                            <i class="bi bi-arrow-repeat"></i>
                            <span>Renew FD</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Apply For APY');">
                            <i class="bi bi-graph-up-arrow"></i>
                            <span>Apply For APY</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Apply for IPO ASBA');">
                            <i class="bi bi-bar-chart-line"></i>
                            <span>Apply for IPO ASBA</span>
                        </button>

                    </div>

                </div>

                <!-- Pay Now -->
                <div class="service-block">

                    <div class="service-block-head">
                        <h3>Pay Now</h3>
                        <button type="button" onclick="return comingSoon('Pay Now');">VIEW ALL</button>
                    </div>

                    <div class="service-grid">

                        <button type="button" class="service-card" onclick="return comingSoon('Self Account Transfer');">
                            <i class="bi bi-person-check"></i>
                            <span>Self Account Transfer</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('DKS Bank Account Transfer');">
                            <i class="bi bi-bank"></i>
                            <span>DKS Bank A/c Transfer</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('NEFT / RTGS Payment');">
                            <i class="bi bi-cash-coin"></i>
                            <span>NEFT / RTGS Payment</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('IMPS Payment');">
                            <i class="bi bi-lightning-charge"></i>
                            <span>IMPS Payment</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Visa Card Payment');">
                            <i class="bi bi-credit-card-2-front"></i>
                            <span>Visa Card Payment</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('DKS Card Payment');">
                            <i class="bi bi-credit-card"></i>
                            <span>DKS Card Payment</span>
                        </button>

                    </div>

                </div>

                <!-- Card Services -->
                <div class="service-block">

                    <div class="service-block-head">
                        <h3>Card Services</h3>
                        <button type="button" onclick="return comingSoon('Card Services');">VIEW ALL</button>
                    </div>

                    <div class="service-grid">

                        <button type="button" class="service-card" onclick="return comingSoon('Debit Card');">
                            <i class="bi bi-credit-card"></i>
                            <span>Debit Card</span>
                        </button>

                        <button type="button" class="service-card" onclick="return comingSoon('Credit Card');">
                            <i class="bi bi-credit-card-2-back"></i>
                            <span>Credit Card</span>
                        </button>

                    </div>

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