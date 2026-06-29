<%@ page import="com.bank.model.User" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String adminInitial = fullName.trim().length() > 0 ? fullName.trim().substring(0, 1).toUpperCase() : "A";

    String successMessage = request.getParameter("msg");
    String errorMessage = request.getParameter("err");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create Account - DKS Bank</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=211">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>

<body>

<div class="admin-page create-account-page">

    <div class="create-account-header">

        <div class="create-account-title-box">
            <h1>Create Account</h1>
            <p>Create a new customer profile and open a bank account from admin panel.</p>
        </div>

        <div class="create-account-header-actions">

            <div class="create-account-admin-chip">
                <span><%= adminInitial %></span>
                <div>
                    <small>Logged in as</small>
                    <strong><%= fullName %></strong>
                </div>
            </div>

            <a class="create-account-dashboard-btn" href="${pageContext.request.contextPath}/admin/accounts">
                <i class="bi bi-arrow-left"></i>
                Accounts
            </a>

        </div>

    </div>

    <% if (successMessage != null) { %>

        <div class="create-account-success-overlay show" id="createAccountSuccessOverlay">

            <div class="create-account-success-box">

                <button type="button" class="create-account-success-close" onclick="closeCreateAccountPopup()">
                    <i class="bi bi-x-lg"></i>
                </button>

                <div class="create-account-success-icon">
                    <i class="bi bi-check2-circle"></i>
                </div>

                <h2>Account Created</h2>

                <p><%= successMessage %></p>

                <button type="button" class="create-account-success-btn" onclick="closeCreateAccountPopup()">
                    OK
                </button>

            </div>

        </div>

    <% } %>

    <% if (errorMessage != null) { %>
        <div class="error"><%= errorMessage %></div>
    <% } %>

    <div class="create-account-layout">

        <div class="create-account-left-card">

            <div class="create-account-bank-icon">
                <i class="bi bi-bank2"></i>
            </div>

            <h2>Open New Bank Account</h2>

            <p>
                Fill customer details carefully. The system will create a customer profile
                and open a new bank account automatically.
            </p>

            <div class="create-account-points">

                <div class="create-account-point">
                    <span><i class="bi bi-person-plus"></i></span>
                    Create customer profile
                </div>

                <div class="create-account-point">
                    <span><i class="bi bi-wallet2"></i></span>
                    Generate account number
                </div>

                <div class="create-account-point">
                    <span><i class="bi bi-shield-check"></i></span>
                    Active account by default
                </div>

            </div>

            <div class="create-account-note-box">
                <small>Default Login Password</small>
                <strong>Password will be generated as Dks@last4digits of phone number.</strong>
            </div>

        </div>

        <div class="create-account-form-card">

            <div class="create-account-form-top">

                <div>
                    <div class="create-account-main-icon">
                        <i class="bi bi-bank2"></i>
                    </div>

                    <h2>Open New Account</h2>
                    <p>Enter customer details to create a bank account.</p>
                </div>

                <span class="create-account-secure-badge">
                    <i class="bi bi-lock-fill"></i>
                    Secure Entry
                </span>

            </div>

            <form method="post" action="${pageContext.request.contextPath}/admin/accounts/create">

                <div class="create-account-form-grid">

                    <div class="create-account-field">
                        <label>First Name</label>
                        <div class="create-account-input-wrap">
                            <i class="bi bi-person"></i>
                            <input type="text" name="firstName" placeholder="First name" required>
                        </div>
                    </div>

                    <div class="create-account-field">
                        <label>Last Name</label>
                        <div class="create-account-input-wrap">
                            <i class="bi bi-person"></i>
                            <input type="text" name="lastName" placeholder="Last name" required>
                        </div>
                    </div>

                    <div class="create-account-field">
                        <label>Date of Birth</label>
                        <div class="create-account-input-wrap">
                            <i class="bi bi-calendar"></i>
                            <input type="date" name="dob" required>
                        </div>
                    </div>

                    <div class="create-account-field">
                        <label>Phone Number</label>
                        <div class="create-account-input-wrap">
                            <i class="bi bi-phone"></i>
                            <input type="text" name="phone" placeholder="10 digit mobile number" maxlength="10" required>
                        </div>
                    </div>

                    <div class="create-account-field full">
                        <label>Email Address</label>
                        <div class="create-account-input-wrap">
                            <i class="bi bi-envelope"></i>
                            <input type="email" name="email" placeholder="Email address" required>
                        </div>
                    </div>

                    <div class="create-account-field full">
                        <label>Address</label>
                        <div class="create-account-textarea-wrap">
                            <i class="bi bi-geo-alt"></i>
                            <textarea name="address" placeholder="Full address" required></textarea>
                        </div>
                    </div>

                    <div class="create-account-field">
                        <label>Account Type</label>
                        <div class="create-account-input-wrap">
                            <i class="bi bi-wallet2"></i>
                            <select name="accountType" required>
                                <option value="">Select Account Type</option>
                                <option value="SAVINGS">SAVINGS</option>
                                <option value="CURRENT">CURRENT</option>
                            </select>
                        </div>
                    </div>

                    <div class="create-account-field">
                        <label>Initial Deposit</label>
                        <div class="create-account-input-wrap">
                            <i class="bi bi-currency-rupee"></i>
                            <input type="number" name="openingBalance" min="500" step="0.01" placeholder="Minimum ₹500" required>
                        </div>
                    </div>

                </div>

                <button type="submit" class="create-account-submit-btn">
                    <i class="bi bi-bank"></i>
                    Create Bank Account
                </button>

            </form>

        </div>

    </div>

</div>

<script>
    function closeCreateAccountPopup() {
        const overlay = document.getElementById("createAccountSuccessOverlay");

        if (overlay) {
            overlay.classList.remove("show");
        }

        const cleanUrl = window.location.pathname;
        window.history.replaceState({}, document.title, cleanUrl);
    }

    window.addEventListener("load", function () {
        const overlay = document.getElementById("createAccountSuccessOverlay");

        if (overlay) {
            setTimeout(function () {
                closeCreateAccountPopup();
            }, 4000);
        }
    });
</script>

</body>
</html>