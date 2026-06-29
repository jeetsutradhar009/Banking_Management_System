<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    String customerId = (String) request.getAttribute("customerId");
    String accountNumber = (String) request.getAttribute("accountNumber");
    String ifscCode = (String) request.getAttribute("ifscCode");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Open Account - DKS Bank</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

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
                <small>Open New Bank Account</small>
            </span>
        </a>

        <div class="register-left-content">

            <span class="register-badge">
                <i class="bi bi-wallet2"></i>
                New Account Opening
            </span>

            <h1>
                Open your DKS Bank account.
            </h1>

            <p>
                Fill your personal details, choose account type and add initial deposit.
                Your Customer ID, Account Number and IFSC will be generated automatically.
            </p>

            <div class="register-benefits">
                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Auto generated 10 digit Customer ID
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Instant account number and IFSC code
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Initial deposit will show as account balance
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Register online banking after account opening
                </div>
            </div>

        </div>

        <div class="register-note">
            <i class="bi bi-shield-lock"></i>
            Keep your Customer ID safe. You will need it for online banking registration.
        </div>

    </section>

    <section class="register-right">

        <div class="register-card">

            <div class="register-card-head">
                <div class="register-card-icon">
                    <i class="bi bi-bank"></i>
                </div>

                <h2>Open New Account</h2>
                <p>Enter customer details to create a bank account.</p>
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

                <div class="open-result-card">
                    <h3>Account Created Successfully</h3>

                    <p><span>Customer ID</span><b><%= customerId %></b></p>
                    <p><span>Account Number</span><b><%= accountNumber %></b></p>
                    <p><span>IFSC Code</span><b><%= ifscCode %></b></p>

                    <a href="${pageContext.request.contextPath}/register.jsp">
                        Register Online Banking
                    </a>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/open-account"
                  method="post"
                  class="register-form">

                <div class="register-form-row">

                    <div class="register-form-group">
                        <label>First Name</label>
                        <div class="register-input-box">
                            <i class="bi bi-person"></i>
                            <input type="text" name="firstName" placeholder="First name" required>
                        </div>
                    </div>

                    <div class="register-form-group">
                        <label>Last Name</label>
                        <div class="register-input-box">
                            <i class="bi bi-person"></i>
                            <input type="text" name="lastName" placeholder="Last name" required>
                        </div>
                    </div>

                </div>

                <div class="register-form-row">

                    <div class="register-form-group">
                        <label>Date of Birth</label>
                        <div class="register-input-box">
                            <i class="bi bi-calendar"></i>
                            <input type="date" name="dob" required>
                        </div>
                    </div>

                    <div class="register-form-group">
                        <label>Phone Number</label>
                        <div class="register-input-box">
                            <i class="bi bi-phone"></i>
                            <input type="tel" name="phone" placeholder="10 digit mobile number"
                                   maxlength="10" pattern="[0-9]{10}" required>
                        </div>
                    </div>

                </div>

                <div class="register-form-group">
                    <label>Email Address</label>
                    <div class="register-input-box">
                        <i class="bi bi-envelope"></i>
                        <input type="email" name="email" placeholder="Email address" required>
                    </div>
                </div>

                <div class="register-form-group">
                    <label>Address</label>
                    <div class="register-input-box register-textarea-box">
                        <i class="bi bi-geo-alt"></i>
                        <textarea name="address" placeholder="Full address" required></textarea>
                    </div>
                </div>

                <div class="register-form-row">

                    <div class="register-form-group">
                        <label>Account Type</label>
                        <div class="register-input-box">
                            <i class="bi bi-wallet2"></i>
                            <select name="accountType" required>
                                <option value="">Select Account Type</option>
                                <option value="SAVINGS">Savings Account</option>
                                <option value="CURRENT">Current Account</option>
                            </select>
                        </div>
                    </div>

                    <div class="register-form-group">
                        <label>Initial Deposit</label>
                        <div class="register-input-box">
                            <i class="bi bi-cash-coin"></i>
                            <input type="number" name="initialDeposit" min="500" step="0.01"
                                   placeholder="Minimum ₹500" required>
                        </div>
                    </div>

                </div>

                <button type="submit" class="register-submit-btn">
                    <i class="bi bi-bank"></i>
                    Create Bank Account
                </button>

            </form>

            <div class="register-divider">
                <span>Already opened account?</span>
            </div>

            <a href="${pageContext.request.contextPath}/register.jsp" class="register-login-btn">
                Register Online Banking
            </a>

            <div class="register-bottom-links">
                <a href="${pageContext.request.contextPath}/index.jsp">
                    <i class="bi bi-house"></i>
                    Back to Home
                </a>
            </div>

        </div>

    </section>

</div>

</body>
</html>