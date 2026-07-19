<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>DKS Bank - Secure Online Banking</title>
    
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=200">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">
</head>

<body class="index-page">

<!-- Top Notice Bar -->
<div class="index-top-alert">
    <div class="index-container">
        <p>
            <i class="bi bi-shield-check"></i>
            Never share your OTP, PIN, Customer ID password or account details with anyone.
        </p>

        <span>24x7 Secure Digital Banking</span>
    </div>
</div>

<!-- Navbar -->
<header class="index-navbar">
    <div class="index-container index-nav-inner">

        <a href="${pageContext.request.contextPath}/index.jsp" class="index-brand">
            <span class="index-brand-icon">
                <i class="bi bi-bank2"></i>
            </span>

            <span>
                <b>DKS Bank</b>
                <small>Personal & Digital Banking</small>
            </span>
        </a>

        <nav class="index-menu">
            <a href="${pageContext.request.contextPath}/index.jsp">Home</a>
            <a href="#banking-flow">How It Works</a>
            <a href="#services">Services</a>
            <a href="#security">Security</a>
            <a href="#contact">Contact</a>
        </nav>

        <div class="index-nav-actions">

    <div class="index-login-dropdown">

        <button type="button" class="index-login-btn index-login-drop-btn">
            Login
            <i class="bi bi-chevron-down"></i>
        </button>

        <div class="index-login-dropdown-menu">

            <a href="${pageContext.request.contextPath}/login">
                <i class="bi bi-box-arrow-in-right"></i>
                <span>
                    Login to Net Banking
                    <small>Customer ID + Password</small>
                </span>
            </a>

            <a href="${pageContext.request.contextPath}/register">
                <i class="bi bi-person-check"></i>
                <span>
                    Register Online Banking
                    <small>Use generated Customer ID</small>
                </span>
            </a>

        </div>

    </div>

    <a href="${pageContext.request.contextPath}/open-account" class="index-register-btn">
        Open Account
    </a>

</div>

    </div>
</header>

<!-- Hero Section -->
<section class="index-hero">

    <div class="index-container index-hero-grid">

        <div class="index-hero-left">

            <span class="index-badge">
                <i class="bi bi-lightning-charge-fill"></i>
                Open Account, Register & Login Securely
            </span>

            <h1>
                Smart banking starts with DKS Bank.
            </h1>

            <p>
                Open a new bank account, get your 10 digit Customer ID, register for online banking
                and login securely using Customer ID and password.
            </p>

            <div class="index-hero-buttons">

                <a href="${pageContext.request.contextPath}/open-account" class="index-main-btn">
                    <i class="bi bi-bank"></i>
                    Open New Account
                </a>

                <a href="${pageContext.request.contextPath}/register" class="index-outline-btn">
                    <i class="bi bi-person-check"></i>
                    Register Online Banking
                </a>

            </div>

            <div class="index-trust-row">
                <div>
                    <h3>10 Digit</h3>
                    <span>Customer ID</span>
                </div>

                <div>
                    <h3>Auto</h3>
                    <span>A/c No. & IFSC</span>
                </div>

                <div>
                    <h3>24x7</h3>
                    <span>Secure Access</span>
                </div>
            </div>

        </div>

        <div class="index-hero-right">

            <div class="index-bank-card">

                <div class="index-card-top">
                    <span>DKS BANK</span>
                    <i class="bi bi-wifi"></i>
                </div>

                <div class="index-chip-row">
                    <span class="index-chip"></span>
                    <i class="bi bi-credit-card-2-front"></i>
                </div>

                <h3>CUST ID: 1234567890</h3>

                <div class="index-card-bottom">
                    <div>
                        <small>Account Type</small>
                        <b>Savings / Current</b>
                    </div>

                    <div>
                        <small>IFSC</small>
                        <b>DKSB0001886</b>
                    </div>
                </div>

            </div>

            <div class="index-floating-card index-float-one">
                <i class="bi bi-person-vcard"></i>
                <div>
                    <b>Customer ID</b>
                    <span>Auto generated after account opening</span>
                </div>
            </div>

            <div class="index-floating-card index-float-two">
                <i class="bi bi-shield-lock"></i>
                <div>
                    <b>Secure Login</b>
                    <span>Login with Customer ID + password</span>
                </div>
            </div>

        </div>

    </div>

</section>

<!-- Banking Flow Section -->
<section class="index-section" id="banking-flow">

    <div class="index-container">

        <div class="index-section-head">
            <span>Simple Banking Flow</span>
            <h2>How DKS Online Banking works</h2>
            <p>
                First open your bank account, then register for online banking using your generated Customer ID.
            </p>
        </div>

        <div class="index-service-grid">

            <div class="index-service-card">
                <i class="bi bi-bank"></i>
                <h3>1. Open New Account</h3>
                <p>
                    Fill first name, last name, DOB, address, email, mobile, account type and initial deposit.
                </p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-person-vcard"></i>
                <h3>2. Get Customer ID</h3>
                <p>
                    System will generate 10 digit Customer ID, Account Number and IFSC code automatically.
                </p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-person-check"></i>
                <h3>3. Register Online Banking</h3>
                <p>
                    Enter Customer ID, fetch account details automatically and set your password.
                </p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-box-arrow-in-right"></i>
                <h3>4. Login Securely</h3>
                <p>
                    Login using Customer ID and password to access dashboard and banking services.
                </p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-send"></i>
                <h3>5. Fund Transfer</h3>
                <p>
                    Transfer money securely from your account to another account with confirmation.
                </p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-receipt"></i>
                <h3>6. Track Transactions</h3>
                <p>
                    View debit, credit, transaction history and download mini statement.
                </p>
            </div>

        </div>

    </div>

</section>

<!-- Quick Services -->
<section class="index-section" id="services">

    <div class="index-container">

        <div class="index-section-head">
            <span>Banking Services</span>
            <h2>Everything you need in one place</h2>
            <p>
                DKS Bank gives you a clean and secure digital banking experience.
            </p>
        </div>

        <div class="index-service-grid">

            <div class="index-service-card">
                <i class="bi bi-wallet2"></i>
                <h3>Account Dashboard</h3>
                <p>Check balance, account type, account number and profile details.</p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-arrow-left-right"></i>
                <h3>Money Transfer</h3>
                <p>Send money to another account with proper debit and credit transaction records.</p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-file-earmark-pdf"></i>
                <h3>Mini Statement</h3>
                <p>Download account statement PDF in a banking-style statement format.</p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-credit-card"></i>
                <h3>Card Services</h3>
                <p>Debit card, credit card and card-related services section.</p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-gear"></i>
                <h3>Banking Services</h3>
                <p>Apply, account services, cheque services, investments and payments.</p>
            </div>

            <div class="index-service-card">
                <i class="bi bi-headset"></i>
                <h3>24x7 Support</h3>
                <p>Get help for digital banking, account and security related issues.</p>
            </div>

        </div>

    </div>

</section>

<!-- Security Section -->
<section class="index-security" id="security">

    <div class="index-container index-security-grid">

        <div class="index-security-left">

            <span class="index-badge">
                <i class="bi bi-shield-lock-fill"></i>
                Advanced Security
            </span>

            <h2>Your online banking security is our priority.</h2>

            <p>
                DKS Bank uses Customer ID based registration and protected login workflow.
                Always keep your password private and never share your details with anyone.
            </p>

            <div class="index-security-list">

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Customer ID based online banking registration
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Auto-filled account details during registration
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Protected login session
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Transaction confirmation before transfer
                </div>

            </div>

        </div>

        <div class="index-security-box">

            <div class="index-lock-circle">
                <i class="bi bi-lock-fill"></i>
            </div>

            <h3>Safe Banking Tips</h3>

            <p>
                Never share your Customer ID password, OTP, PIN or account details with anyone.
            </p>

            <a href="${pageContext.request.contextPath}/login">
                Secure Login
                <i class="bi bi-arrow-right"></i>
            </a>

        </div>

    </div>

</section>

<!-- CTA Section -->
<section class="index-cta">

    <div class="index-container">

        <div class="index-cta-box">
            <div>
                <h2>Start your digital banking journey today.</h2>
                <p>
                    Open your account first, then register for online banking and login with Customer ID.
                </p>
            </div>

            <div class="index-cta-actions">

                <a href="${pageContext.request.contextPath}/open-account" class="index-main-btn">
                    Open Account
                </a>

                <a href="${pageContext.request.contextPath}/register" class="index-outline-light-btn">
                    Register Online Banking
                </a>

            </div>
        </div>

    </div>

</section>

<!-- Footer -->
<footer class="index-footer" id="contact">

    <div class="index-container index-footer-grid">

        <div>
            <h3>DKS Bank</h3>
            <p>
                Secure online banking platform for account opening, online banking registration,
                fund transfer and transaction management.
            </p>
        </div>

        <div>
            <h4>Quick Links</h4>
            <a href="${pageContext.request.contextPath}/index.jsp">Home</a>
            <a href="${pageContext.request.contextPath}/open-account">Open Account</a>
            <a href="${pageContext.request.contextPath}/register">Register Online Banking</a>
            <a href="${pageContext.request.contextPath}/login">Login</a>
        </div>

        <div>
            <h4>Services</h4>
            <a href="#banking-flow">Customer ID Registration</a>
            <a href="#services">Fund Transfer</a>
            <a href="#services">Mini Statement</a>
            <a href="#services">Card Services</a>
        </div>

        <div>
            <h4>Contact</h4>
            <p>Email: support@dksbank.com</p>
            <p>Helpline: 1800-000-DKS</p>
            <p>Available: 24x7</p>
        </div>

    </div>

    <div class="index-footer-bottom">
        <p>© 2026 DKS Bank. All rights reserved.</p>
    </div>

</footer>

</body>
</html>