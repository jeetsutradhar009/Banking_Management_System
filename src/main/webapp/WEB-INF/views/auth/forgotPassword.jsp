<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Forgot Password - DKS Bank</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
     <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=116">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">
</head>

<body class="auth-page">

<div class="auth-wrapper">

    <section class="auth-left">

        <a href="${pageContext.request.contextPath}/index.jsp" class="auth-brand">
            <span class="auth-brand-icon">
                <i class="bi bi-bank2"></i>
            </span>

            <span>
                <b>DKS Bank</b>
                <small>Forgot Password</small>
            </span>
        </a>

        <div class="auth-left-content">

            <span class="auth-badge">
                <i class="bi bi-shield-lock-fill"></i>
                Account Recovery
            </span>

            <h1>
                Forgot your password?
            </h1>

            <p>
                Enter the email address you used while opening your bank account.
                If it is registered with us, we will email you a secure link to reset
                your password.
            </p>

            <div class="auth-feature-list">

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span>Reset link sent to your registered email</span>
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span>Link works only once and expires automatically</span>
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span>Your current password stays unchanged until reset</span>
                </div>

            </div>

        </div>

        <div class="auth-note">
            <i class="bi bi-info-circle"></i>
            <span>Never share your reset link with anyone.</span>
        </div>

    </section>

    <section class="auth-right">

        <div class="auth-card">

            <div class="auth-card-head">
                <div class="auth-card-icon">
                    <i class="bi bi-key"></i>
                </div>

                <h2>Reset Your Password</h2>
                <p>Enter your registered email and we will send you a reset link.</p>
            </div>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="auth-alert auth-alert-error">
                    <i class="bi bi-exclamation-circle"></i>
                    <span><%= error %></span>
                </div>
            <% } %>

            <% if (success != null && !success.trim().isEmpty()) { %>
                <div class="auth-alert auth-alert-success">
                    <i class="bi bi-check-circle"></i>
                    <span><%= success %></span>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/forgot-password"
                  method="post"
                  class="auth-form"
                  id="forgotPasswordForm">

                <div class="auth-form-group">
                    <label>Registered Email Address</label>

                    <div class="auth-input-box">
                        <i class="bi bi-envelope"></i>

                        <input type="email"
                               name="email"
                               id="forgotEmailInput"
                               placeholder="Enter your registered email"
                               required
                               autocomplete="email">
                    </div>
                </div>

                <button type="submit" class="auth-submit-btn" id="forgotSubmitBtn">
                    <i class="bi bi-send"></i>
                    Send Reset Link
                </button>

            </form>

            <div class="auth-divider">
                <span>Remembered your password?</span>
            </div>

            <a href="${pageContext.request.contextPath}/login" class="auth-create-btn">
                Back to Login
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
    // After a successful submit, the form is intentionally not
    // pre-filled or auto-resubmitted, and the email is not retained
    // in any browser storage - only the standard browser autofill
    // (if the user's own browser offers it) applies, same as login.jsp.
    var forgotPasswordForm = document.getElementById("forgotPasswordForm");

    if (forgotPasswordForm) {
        forgotPasswordForm.addEventListener("submit", function () {
            var submitBtn = document.getElementById("forgotSubmitBtn");
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="bi bi-send"></i> Sending...';
        });
    }
</script>

</body>
</html>
