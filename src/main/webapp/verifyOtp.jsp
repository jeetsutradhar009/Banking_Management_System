<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String token = (String) request.getAttribute("token");
    String email = (String) request.getAttribute("email");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");

    String maskedEmail = "";

    if (email != null && email.contains("@")) {
        String[] parts = email.split("@", 2);
        String namePart = parts[0];
        String domainPart = parts[1];

        if (namePart.length() <= 2) {
            maskedEmail = namePart.charAt(0) + "***@" + domainPart;
        } else {
            maskedEmail = namePart.substring(0, 2) + "***@" + domainPart;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Verify OTP - DKS Bank</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
     <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=204">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">
</head>

<body class="register-page">

<div class="register-wrapper">

    <section class="register-left">

        <a href="${pageContext.request.contextPath}/index.jsp" class="register-brand">
            <span class="register-brand-icon">
                <i class="bi bi-bank2"></i>
            </span>

            <span>
                <b>DKS Bank</b>
                <small>Account Verification</small>
            </span>
        </a>

        <div class="register-left-content">

            <span class="register-badge">
                <i class="bi bi-shield-check"></i>
                Email Verification
            </span>

            <h1>
                Verify your email to finish opening your account.
            </h1>

            <p>
                We have sent a 6 digit OTP to your email address. Enter it below to
                confirm your identity - your account is created only after this
                verification is successful.
            </p>

            <div class="register-benefits">
                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    OTP is valid for a limited time
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Account is created only after verification
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Didn't get it? You can request a new OTP
                </div>
            </div>

        </div>

        <div class="register-note">
            <i class="bi bi-shield-lock"></i>
            Never share your OTP with anyone, including DKS Bank staff.
        </div>

    </section>

    <section class="register-right">

        <div class="register-card">

            <div class="register-card-head">
                <div class="register-card-icon">
                    <i class="bi bi-envelope-check"></i>
                </div>

                <h2>Enter OTP</h2>
                <p>
                    <% if (!maskedEmail.isEmpty()) { %>
                        OTP sent to <b><%= maskedEmail %></b>
                    <% } else { %>
                        Enter the OTP sent to your email address.
                    <% } %>
                </p>
            </div>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="register-alert register-alert-error">
                    <i class="bi bi-exclamation-circle"></i>
                    <span><%= error %></span>
                </div>
            <% } %>

            <% if (success != null && !success.trim().isEmpty()) { %>
                <div class="register-alert register-alert-success">
                    <i class="bi bi-check-circle"></i>
                    <span><%= success %></span>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/verify-otp"
                  method="post"
                  class="register-form">

                <input type="hidden" name="token" value="<%= token != null ? token : "" %>">

                <div class="register-form-group">
                    <label>One-Time Password (OTP)</label>
                    <div class="register-input-box">
                        <i class="bi bi-key"></i>
                        <input type="text" name="otp" placeholder="Enter 6 digit OTP"
                               maxlength="6" pattern="[0-9]{6}" inputmode="numeric" required autofocus>
                    </div>
                </div>

                <button type="submit" class="register-submit-btn">
                    <i class="bi bi-shield-check"></i>
                    Verify OTP
                </button>

            </form>

            <div class="register-divider">
                <span>Didn't receive the OTP?</span>
            </div>

            <form action="${pageContext.request.contextPath}/resend-otp"
                  method="post">

                <input type="hidden" name="token" value="<%= token != null ? token : "" %>">

                <button type="submit" class="register-login-btn">
                    <i class="bi bi-arrow-repeat"></i>
                    Resend OTP
                </button>

            </form>

            <div class="register-bottom-links">
                <a href="${pageContext.request.contextPath}/openAccount.jsp">
                    <i class="bi bi-arrow-left"></i>
                    Back to Account Opening
                </a>
            </div>

        </div>

    </section>

</div>

</body>
</html>
