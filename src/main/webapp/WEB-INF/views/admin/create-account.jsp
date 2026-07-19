<%@ page import="com.bank.model.User" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String adminInitial = fullName.trim().length() > 0 ? fullName.trim().substring(0, 1).toUpperCase() : "A";

    String customerId = request.getParameter("custId");
    String accountNumber = request.getParameter("accNo");
    String ifscCode = request.getParameter("ifsc");
    String accountType = request.getParameter("accType");
    String emailWarning = request.getParameter("emailWarning");

    boolean hasSuccess = (customerId != null && !customerId.trim().isEmpty());

    String errorMessage = request.getParameter("err");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create Account - DKS Bank</title>
    
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=212">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
        .create-account-success-details {
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin: 16px 0;
        }
        .create-account-success-detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #f3f8f5;
            border: 1px solid #dcece3;
            border-radius: 10px;
            padding: 10px 14px;
        }
        .create-account-success-detail-row small {
            color: #5a6b63;
            font-weight: 600;
        }
        .create-account-success-detail-row strong {
            color: #0d3b2e;
        }
        .create-account-success-note {
            font-size: 0.85rem;
            color: #5a6b63;
            margin: 0 0 12px;
        }
    </style>
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

    <% if (hasSuccess) { %>

        <div class="create-account-success-overlay show" id="createAccountSuccessOverlay">

            <div class="create-account-success-box">

                <div class="create-account-success-icon">
                    <i class="bi bi-check2-circle"></i>
                </div>

                <h2>New Account Created Successfully</h2>

                <div class="create-account-success-details">

                    <div class="create-account-success-detail-row">
                        <small>Customer ID</small>
                        <strong><%= customerId %></strong>
                    </div>

                    <div class="create-account-success-detail-row">
                        <small>Account Number</small>
                        <strong><%= accountNumber %></strong>
                    </div>

                    <div class="create-account-success-detail-row">
                        <small>IFSC Code</small>
                        <strong><%= ifscCode %></strong>
                    </div>

                    <div class="create-account-success-detail-row">
                        <small>Account Type</small>
                        <strong><%= accountType %></strong>
                    </div>

                </div>

                <% if (emailWarning != null && !emailWarning.trim().isEmpty()) { %>
                    <p class="create-account-success-note"><%= emailWarning %></p>
                <% } else { %>
                    <p class="create-account-success-note">These details have also been emailed to the customer.</p>
                <% } %>

                <button type="button" class="create-account-success-btn" onclick="closeCreateAccountPopup()">
                    Done
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
                    Customer registers online banking themselves later
                </div>

            </div>

            <div class="create-account-note-box">
                <small>Login Password</small>
                <strong>No password is set here — the customer creates their own password by registering at /register.</strong>
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
    // The success popup only closes when the admin explicitly clicks
    // "Done" - there is no auto-close timeout, no outside-click close,
    // and no ESC-key close, so the confirmation can't be missed.
    function closeCreateAccountPopup() {
        const overlay = document.getElementById("createAccountSuccessOverlay");

        if (overlay) {
            overlay.classList.remove("show");
        }

        // Re-enable background interaction/scrolling now that the
        // overlay is gone.
        document.body.style.overflow = "";

        // Existing behavior preserved: clear the success params from the
        // URL so refreshing the page doesn't reopen the popup.
        const cleanUrl = window.location.pathname;
        window.history.replaceState({}, document.title, cleanUrl);
    }

    window.addEventListener("load", function () {
        const overlay = document.getElementById("createAccountSuccessOverlay");

        if (overlay) {
            // Disable background scrolling/interaction while the popup
            // is open. The overlay itself (full-screen, high z-index)
            // already blocks clicks from reaching the form underneath.
            document.body.style.overflow = "hidden";
        }
    });
</script>

</body>
</html>
