<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");

    if (success == null) {
        success = (String) request.getAttribute("success");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register Online Banking - DKS Bank</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link rel="icon" type="image/png" href="images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=204">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">

    <!-- <style>
        .register-password-msg {
            display: block;
            font-size: 12px;
            font-weight: 500;
            margin-top: 6px;
            margin-left: 5px;
            transition: all 0.3s ease;
        }

        .register-password-msg.success {
            color: #0b8a70;
        }

        .register-password-msg.error {
            color: #ef4444;
        }
    </style> -->
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
                <small>Online Banking Registration</small>
            </span>
        </a>

        <div class="register-left-content">

            <span class="register-badge">
                <i class="bi bi-person-check-fill"></i>
                Register Net Banking
            </span>

            <h1>
                Activate your online banking.
            </h1>

            <p>
                Enter your generated Customer ID. Your name, account number, IFSC, email and mobile number
                will be filled automatically.
            </p>

            <div class="register-benefits">
                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Customer ID based registration
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Auto-fill customer and account details
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Set password for online banking login
                </div>

                <div>
                    <i class="bi bi-check-circle-fill"></i>
                    Login with Customer ID and password
                </div>
            </div>

        </div>

        <div class="register-note">
            <i class="bi bi-shield-lock"></i>
            Register only with your own Customer ID.
        </div>

    </section>

    <section class="register-right">

        <div class="register-card">

            <div class="register-card-head">
                <div class="register-card-icon">
                    <i class="bi bi-person-add"></i>
                </div>

                <h2>Register Online Banking</h2>
                <p>Enter Customer ID and set your password.</p>
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

            <form action="${pageContext.request.contextPath}/register"
                  method="post"
                  class="register-form"
                  onsubmit="return validateRegisterForm();">

                <div class="register-form-group">
                    <label>Customer ID</label>

                    <div class="register-input-box">
                        <i class="bi bi-person-vcard"></i>
                        <input type="text"
                               name="customerId"
                               id="customerId"
                               placeholder="Enter 10 digit Customer ID"
                               maxlength="10"
                               pattern="[0-9]{10}"
                               required>

                        <button type="button" class="lookup-btn" onclick="lookupCustomer()">
                            Fetch
                        </button>
                    </div>

                    <small id="lookupMsg" class="register-password-msg"></small>
                </div>

                <div class="register-readonly-grid">

                    <div class="register-form-group">
                        <label>Full Name</label>
                        <div class="register-input-box">
                            <i class="bi bi-person"></i>
                            <input type="text" id="fullName" readonly>
                        </div>
                    </div>

                    <div class="register-form-group">
                        <label>Account Number</label>
                        <div class="register-input-box">
                            <i class="bi bi-wallet2"></i>
                            <input type="text" id="accountNumber" readonly>
                        </div>
                    </div>

                    <div class="register-form-group">
                        <label>IFSC Code</label>
                        <div class="register-input-box">
                            <i class="bi bi-bank"></i>
                            <input type="text" id="ifscCode" readonly>
                        </div>
                    </div>

                    <div class="register-form-group">
                        <label>Mobile Number</label>
                        <div class="register-input-box">
                            <i class="bi bi-phone"></i>
                            <input type="text" id="phone" readonly>
                        </div>
                    </div>

                    <div class="register-form-group full-width">
                        <label>Email Address</label>
                        <div class="register-input-box">
                            <i class="bi bi-envelope"></i>
                            <input type="text" id="email" readonly>
                        </div>
                    </div>

                </div>

                <div class="register-form-row">

                    <div class="register-form-group">
                        <label>Password</label>

                        <div class="register-input-box">
                            <i class="bi bi-lock"></i>
                            <input type="password"
                                   name="password"
                                   id="passwordInput"
                                   placeholder="Create password"
                                   minlength="6"
                                   required>

                            <button type="button" class="register-eye-btn" onclick="togglePassword('passwordInput', 'passwordEye')">
                                <i class="bi bi-eye" id="passwordEye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="register-form-group">
                        <label>Confirm Password</label>

                        <div class="register-input-box">
                            <i class="bi bi-lock-fill"></i>
                            <input type="password"
                                   name="confirmPassword"
                                   id="confirmPasswordInput"
                                   placeholder="Confirm password"
                                   minlength="6"
                                   required>

                            <button type="button" class="register-eye-btn" onclick="togglePassword('confirmPasswordInput', 'confirmPasswordEye')">
                                <i class="bi bi-eye" id="confirmPasswordEye"></i>
                            </button>
                        </div>
                    </div>

                </div>

                <small id="passwordMatchMsg" class="register-password-msg"></small>

                <label class="register-terms">
                    <input type="checkbox" required>
                    <span>I confirm that the fetched account details are mine.</span>
                </label>

                <button type="submit" class="register-submit-btn">
                    <i class="bi bi-person-check"></i>
                    Complete Registration
                </button>

            </form>

            <div class="register-divider">
                <span>Already registered?</span>
            </div>

            <a href="${pageContext.request.contextPath}/login.jsp" class="register-login-btn">
                Login Now
            </a>

            <div class="register-bottom-links">
                <a href="${pageContext.request.contextPath}/open-account">
                    <i class="bi bi-bank"></i>
                    Open New Account
                </a>
            </div>

        </div>

    </section>

</div>

<script>
    let customerFetched = false;
    const customerIdInput = document.getElementById("customerId");
    const lookupMsg = document.getElementById("lookupMsg");

    function lookupCustomer() {
        const customerId = customerIdInput.value.trim();
        customerFetched = false;
        clearCustomerFields();

        if (!/^[0-9]{10}$/.test(customerId)) {
            lookupMsg.textContent = "Enter valid 10 digit Customer ID";
            lookupMsg.className = "register-password-msg error";
            return;
        }

        lookupMsg.textContent = "Fetching customer details...";
        lookupMsg.className = "register-password-msg";

        fetch("${pageContext.request.contextPath}/customer-lookup?customerId=" + encodeURIComponent(customerId))
            .then(response => response.json())
            .then(data => {
                if (data.found) {
                    document.getElementById("fullName").value = data.fullName;
                    document.getElementById("accountNumber").value = data.accountNumber;
                    document.getElementById("ifscCode").value = data.ifscCode;
                    document.getElementById("phone").value = data.phone;
                    document.getElementById("email").value = data.email;

                    customerFetched = true;
                    lookupMsg.textContent = "Customer details fetched successfully";
                    lookupMsg.className = "register-password-msg success";
                } else {
                    lookupMsg.textContent = data.message || "Customer not found";
                    lookupMsg.className = "register-password-msg error";
                }
            })
            .catch(() => {
                lookupMsg.textContent = "Unable to fetch customer details";
                lookupMsg.className = "register-password-msg error";
            });
    }

    function clearCustomerFields() {
        document.getElementById("fullName").value = "";
        document.getElementById("accountNumber").value = "";
        document.getElementById("ifscCode").value = "";
        document.getElementById("phone").value = "";
        document.getElementById("email").value = "";
    }

    // Auto-clear message and fetched fields if input is empty
    customerIdInput.addEventListener("input", function() {
        if (this.value.trim() === "") {
            lookupMsg.textContent = ""; 
            lookupMsg.className = "register-password-msg"; 
            clearCustomerFields(); 
            customerFetched = false;
        }
    });

    function togglePassword(inputId, eyeId) {
        const input = document.getElementById(inputId);
        const eye = document.getElementById(eyeId);

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

    const passwordInput = document.getElementById("passwordInput");
    const confirmPasswordInput = document.getElementById("confirmPasswordInput");
    const passwordMatchMsg = document.getElementById("passwordMatchMsg");

    function checkPasswordMatch() {
        if (confirmPasswordInput.value.length === 0) {
            passwordMatchMsg.textContent = "";
            passwordMatchMsg.className = "register-password-msg";
            return;
        }

        if (passwordInput.value === confirmPasswordInput.value) {
            passwordMatchMsg.textContent = "Password matched";
            passwordMatchMsg.className = "register-password-msg success";
        } else {
            passwordMatchMsg.textContent = "Password and confirm password do not match";
            passwordMatchMsg.className = "register-password-msg error";
        }
    }

    passwordInput.addEventListener("input", checkPasswordMatch);
    confirmPasswordInput.addEventListener("input", checkPasswordMatch);

    function validateRegisterForm() {
        if (!customerFetched) {
            alert("Please fetch valid Customer ID details first.");
            return false;
        }

        if (passwordInput.value.length < 6) {
            alert("Password must be at least 6 characters.");
            return false;
        }

        if (passwordInput.value !== confirmPasswordInput.value) {
            alert("Password and Confirm Password do not match.");
            return false;
        }

        return true;
    }
</script>

</body>
</html>