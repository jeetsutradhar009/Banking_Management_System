<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");

    if (success == null) {
        success = (String) request.getAttribute("success");
    }

    String selectedLoginType = (String) request.getAttribute("selectedLoginType");

    if (selectedLoginType == null || selectedLoginType.trim().isEmpty()) {
        selectedLoginType = request.getParameter("loginType");
    }

    if (selectedLoginType == null || selectedLoginType.trim().isEmpty()) {
        selectedLoginType = "USER";
    }

    boolean adminSelected = "ADMIN".equalsIgnoreCase(selectedLoginType);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - DKS Bank</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
     <link rel="icon" type="image/png" href="images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=116">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">
</head>

<body class="auth-page <%= adminSelected ? "admin-login-mode" : "" %>">

<div class="auth-wrapper">

    <section class="auth-left">

        <a href="${pageContext.request.contextPath}/index.jsp" class="auth-brand">
            <span class="auth-brand-icon">
                <i class="bi bi-bank2"></i>
            </span>

            <span>
                <b>DKS Bank</b>
                <small id="leftSmallTitle">Customer ID Login</small>
            </span>
        </a>

        <div class="auth-left-content">

            <span class="auth-badge">
                <i class="bi bi-shield-lock-fill"></i>
                <span id="loginBadgeText">Secure Net Banking Login</span>
            </span>

            <h1 id="leftHeading">
                Login with Customer ID.
            </h1>

            <p id="leftPara">
                Use your generated Customer ID and password to access dashboard,
                fund transfer, transaction history and banking services.
            </p>

            <div class="auth-feature-list">

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span id="featureOne">Customer ID based login</span>
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span id="featureTwo">Secure dashboard access</span>
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span id="featureThree">Fund transfer and account history</span>
                </div>

            </div>

        </div>

        <div class="auth-note">
            <i class="bi bi-info-circle"></i>
            <span id="bottomNote">Never share your Customer ID password with anyone.</span>
        </div>

    </section>

    <section class="auth-right">

        <div class="auth-card">

            <div class="auth-card-head">
                <div class="auth-card-icon">
                    <i class="bi bi-person-lock" id="mainLoginIcon"></i>
                </div>

                <h2 id="cardTitle">Login to Account</h2>
                <p id="cardSubtitle">Enter your Customer ID and password.</p>
            </div>

            <div class="login-type-switch <%= adminSelected ? "admin-mode" : "user-mode" %>">

                <button type="button"
                        class="login-type-btn <%= adminSelected ? "" : "active" %>"
                        id="userLoginBtn"
                        onclick="setLoginType('USER')">
                    <i class="bi bi-person"></i>
                    User Login
                </button>

                <button type="button"
                        class="login-type-btn <%= adminSelected ? "active" : "" %>"
                        id="adminLoginBtn"
                        onclick="setLoginType('ADMIN')">
                    <i class="bi bi-shield-lock"></i>
                    Admin Login
                </button>

            </div>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="auth-alert auth-alert-error" id="loginAlert">
                    <i class="bi bi-exclamation-circle"></i>
                    <span><%= error %></span>
                </div>
            <% } %>

            <% if (success != null && !success.trim().isEmpty()) { %>
                <div class="auth-alert auth-alert-success" id="loginAlert">
                    <i class="bi bi-check-circle"></i>
                    <span><%= success %></span>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login"
                  method="post"
                  class="auth-form">

                <input type="hidden"
                       name="loginType"
                       id="loginType"
                       value="<%= adminSelected ? "ADMIN" : "USER" %>">

                <div class="auth-form-group">
                    <label id="loginIdLabel">Customer ID</label>

                    <div class="auth-input-box">
                        <i class="bi bi-person-vcard" id="loginIdIcon"></i>

                        <input type="text"
                               name="customerId"
                               id="loginIdInput"
                               placeholder="Enter Customer ID"
                               required
                               autocomplete="username"
                               onfocus="hideLoginAlert()"
                               oninput="hideLoginAlert()">
                    </div>
                </div>

                <div class="auth-form-group">
                    <label>Password</label>

                    <div class="auth-input-box">
                        <i class="bi bi-lock"></i>

                        <input type="password"
                               name="password"
                               id="passwordInput"
                               placeholder="Enter password"
                               required
                               autocomplete="current-password"
                               onfocus="hideLoginAlert()"
                               oninput="hideLoginAlert()">

                        <button type="button"
                                class="auth-eye-btn"
                                onclick="togglePassword()">
                            <i class="bi bi-eye" id="passwordEye"></i>
                        </button>
                    </div>
                </div>

                <div class="auth-bottom-links">
                    <a href="${pageContext.request.contextPath}/forgot-password">
                        <i class="bi bi-question-circle"></i>
                        Forgot Password?
                    </a>
                </div>

                <button type="submit" class="auth-submit-btn" id="loginSubmitBtn">
                    <i class="bi bi-box-arrow-in-right"></i>
                    Login Securely
                </button>

            </form>

            <div class="auth-divider">
                <span>New user?</span>
            </div>

            <a href="${pageContext.request.contextPath}/register.jsp" class="auth-create-btn">
                Register Online Banking
            </a>

            <div class="auth-bottom-links">
                <a href="${pageContext.request.contextPath}/open-account">
                    <i class="bi bi-bank"></i>
                    Open New Account
                </a>
            </div>

        </div>

    </section>

</div>

<script>
    let currentLoginType = "<%= adminSelected ? "ADMIN" : "USER" %>";
    let loginSwitchTimer = null;

    window.addEventListener("DOMContentLoaded", function () {
        applyLoginTypeContent(currentLoginType, false);
        updateLoginModeClass(currentLoginType);
    });

    function hideLoginAlert() {
        const alertBox = document.getElementById("loginAlert");

        if (alertBox) {
            alertBox.classList.add("hide-login-alert");

            setTimeout(function () {
                if (alertBox) {
                    alertBox.style.display = "none";
                }
            }, 220);
        }
    }

    function setLoginType(type) {
        if (type === currentLoginType) {
            hideLoginAlert();
            return;
        }

        hideLoginAlert();

        currentLoginType = type;

        const animatedElements = [
            document.querySelector(".auth-left-content"),
            document.querySelector(".auth-note"),
            document.querySelector(".auth-card-head"),
            document.querySelector(".auth-form"),
            document.querySelector(".auth-divider"),
            document.querySelector(".auth-create-btn"),
            document.querySelector(".auth-bottom-links")
        ];

        const cardIcon = document.querySelector(".auth-card-icon");

        animatedElements.forEach(function (element) {
            if (element) {
                element.classList.remove("login-slide-in-right");
                element.classList.add("login-slide-out-left");
            }
        });

        if (cardIcon) {
            cardIcon.classList.add("switching");
        }

        clearTimeout(loginSwitchTimer);

        loginSwitchTimer = setTimeout(function () {
            applyLoginTypeContent(type, true);
            updateLoginModeClass(type);

            animatedElements.forEach(function (element) {
                if (element) {
                    element.classList.remove("login-slide-out-left");
                    element.classList.add("login-slide-in-right");

                    requestAnimationFrame(function () {
                        element.classList.remove("login-slide-in-right");
                    });
                }
            });

            if (cardIcon) {
                cardIcon.classList.remove("switching");
            }
        }, 190);
    }

    function updateLoginModeClass(type) {
        const body = document.body;
        const switchBox = document.querySelector(".login-type-switch");

        if (type === "ADMIN") {
            body.classList.add("admin-login-mode");

            if (switchBox) {
                switchBox.classList.remove("user-mode");
                switchBox.classList.add("admin-mode");
            }

        } else {
            body.classList.remove("admin-login-mode");

            if (switchBox) {
                switchBox.classList.remove("admin-mode");
                switchBox.classList.add("user-mode");
            }
        }
    }

    function applyLoginTypeContent(type, clearInput) {
        const loginType = document.getElementById("loginType");

        const userLoginBtn = document.getElementById("userLoginBtn");
        const adminLoginBtn = document.getElementById("adminLoginBtn");

        const leftSmallTitle = document.getElementById("leftSmallTitle");
        const loginBadgeText = document.getElementById("loginBadgeText");
        const leftHeading = document.getElementById("leftHeading");
        const leftPara = document.getElementById("leftPara");

        const featureOne = document.getElementById("featureOne");
        const featureTwo = document.getElementById("featureTwo");
        const featureThree = document.getElementById("featureThree");
        const bottomNote = document.getElementById("bottomNote");

        const mainLoginIcon = document.getElementById("mainLoginIcon");
        const cardTitle = document.getElementById("cardTitle");
        const cardSubtitle = document.getElementById("cardSubtitle");

        const loginIdLabel = document.getElementById("loginIdLabel");
        const loginIdIcon = document.getElementById("loginIdIcon");
        const loginIdInput = document.getElementById("loginIdInput");
        const loginSubmitBtn = document.getElementById("loginSubmitBtn");

        loginType.value = type;

        if (clearInput && loginIdInput) {
            loginIdInput.value = "";
        }

        if (type === "ADMIN") {
            userLoginBtn.classList.remove("active");
            adminLoginBtn.classList.add("active");

            leftSmallTitle.textContent = "Admin Panel Login";
            loginBadgeText.textContent = "Secure Admin Login";
            leftHeading.textContent = "Login as Admin.";
            leftPara.textContent = "Use your admin credentials to access admin dashboard, users, accounts, reports and audit logs.";

            featureOne.textContent = "Admin dashboard access";
            featureTwo.textContent = "Manage users and accounts";
            featureThree.textContent = "Reports and audit logs";

            bottomNote.textContent = "Admin access is restricted to authorized users only.";

            mainLoginIcon.className = "bi bi-shield-lock";
            cardTitle.textContent = "Admin Login";
            cardSubtitle.textContent = "Enter admin email or Employee ID and password.";

            loginIdLabel.textContent = "Admin Email / Employee ID";
            loginIdIcon.className = "bi bi-person-badge";
            loginIdInput.placeholder = "Enter admin email or Employee ID";

            loginSubmitBtn.innerHTML = '<i class="bi bi-shield-lock"></i> Login as Admin';

        } else {
            adminLoginBtn.classList.remove("active");
            userLoginBtn.classList.add("active");

            leftSmallTitle.textContent = "Customer ID Login";
            loginBadgeText.textContent = "Secure Net Banking Login";
            leftHeading.textContent = "Login with Customer ID.";
            leftPara.textContent = "Use your generated Customer ID and password to access dashboard, fund transfer, transaction history and banking services.";

            featureOne.textContent = "Customer ID based login";
            featureTwo.textContent = "Secure dashboard access";
            featureThree.textContent = "Fund transfer and account history";

            bottomNote.textContent = "Never share your Customer ID password with anyone.";

            mainLoginIcon.className = "bi bi-person-lock";
            cardTitle.textContent = "Login to Account";
            cardSubtitle.textContent = "Enter your Customer ID and password.";

            loginIdLabel.textContent = "Customer ID";
            loginIdIcon.className = "bi bi-person-vcard";
            loginIdInput.placeholder = "Enter Customer ID";

            loginSubmitBtn.innerHTML = '<i class="bi bi-box-arrow-in-right"></i> Login Securely';
        }
    }

    function togglePassword() {
        const input = document.getElementById("passwordInput");
        const eye = document.getElementById("passwordEye");

        if (input.type === "password") {
            input.type = "text";
            eye.classList.remove("bi-eye");
            eye.classList.add("bi-eye-slash");
        } else {
            input.type = "password";
            eye.classList.remove("bi-eye-slash");
            eye.classList.add("bi-eye");
        }
    }
</script>

</body>
</html>