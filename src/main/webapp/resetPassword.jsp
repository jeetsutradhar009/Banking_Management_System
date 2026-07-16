<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String token = (String) request.getAttribute("token");
    String error = (String) request.getAttribute("error");

    boolean hasValidToken = (token != null && !token.trim().isEmpty());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reset Password - DKS Bank</title>
    

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
                <small>Reset Password</small>
            </span>
        </a>

        <div class="auth-left-content">

            <span class="auth-badge">
                <i class="bi bi-shield-lock-fill"></i>
                Secure Password Reset
            </span>

            <h1>
                Set a new password.
            </h1>

            <p>
                Choose a new password for your online banking account. Once updated,
                use it the next time you login.
            </p>

            <div class="auth-feature-list">

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span>This link works only once</span>
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span>Link expires automatically</span>
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    <span>Login securely after reset</span>
                </div>

            </div>

        </div>

        <div class="auth-note">
            <i class="bi bi-info-circle"></i>
            <span>Never share your new password with anyone.</span>
        </div>

    </section>

    <section class="auth-right">

        <div class="auth-card">

            <div class="auth-card-head">
                <div class="auth-card-icon">
                    <i class="bi bi-shield-lock"></i>
                </div>

                <h2>Reset Password</h2>
                <p>
                    <% if (hasValidToken) { %>
                        Enter and confirm your new password.
                    <% } else { %>
                        This reset link could not be verified.
                    <% } %>
                </p>
            </div>

            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="auth-alert auth-alert-error">
                    <i class="bi bi-exclamation-circle"></i>
                    <span><%= error %></span>
                </div>
            <% } %>

            <% if (hasValidToken) { %>

                <form action="${pageContext.request.contextPath}/reset-password"
                      method="post"
                      class="auth-form"
                      id="resetPasswordForm">

                    <input type="hidden" name="token" value="<%= token %>">

                    <div class="auth-form-group">
                        <label>New Password</label>

                        <div class="auth-input-box">
                            <i class="bi bi-lock"></i>

                            <input type="password"
                                   name="newPassword"
                                   id="newPasswordInput"
                                   placeholder="Enter new password"
                                   minlength="6"
                                   required
                                   autocomplete="new-password">

                            <button type="button" class="auth-eye-btn" onclick="togglePassword('newPasswordInput', 'newPasswordEye')">
                                <i class="bi bi-eye" id="newPasswordEye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="auth-form-group">
                        <label>Confirm Password</label>

                        <div class="auth-input-box">
                            <i class="bi bi-lock"></i>

                            <input type="password"
                                   name="confirmPassword"
                                   id="confirmPasswordInput"
                                   placeholder="Re-enter new password"
                                   minlength="6"
                                   required
                                   autocomplete="new-password">

                            <button type="button" class="auth-eye-btn" onclick="togglePassword('confirmPasswordInput', 'confirmPasswordEye')">
                                <i class="bi bi-eye" id="confirmPasswordEye"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="auth-submit-btn">
                        <i class="bi bi-check-circle"></i>
                        Update Password
                    </button>

                </form>

            <% } else { %>

                <a href="${pageContext.request.contextPath}/forgot-password" class="auth-create-btn">
                    Request a New Reset Link
                </a>

            <% } %>

            <div class="auth-bottom-links">
                <a href="${pageContext.request.contextPath}/login.jsp">
                    <i class="bi bi-box-arrow-in-right"></i>
                    Back to Login
                </a>
            </div>

        </div>

    </section>

</div>

<script>
    function togglePassword(inputId, eyeId) {
        var input = document.getElementById(inputId);
        var eye = document.getElementById(eyeId);

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
