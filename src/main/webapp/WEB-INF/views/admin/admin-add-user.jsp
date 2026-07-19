<%@ page import="com.bank.model.User" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";

    String popupType = request.getParameter("type");
    String custId = request.getParameter("custId");
    String adminId = request.getParameter("adminId");
    String emailWarning = request.getParameter("emailWarning");
    String errorMessage = request.getParameter("err");

    boolean showCustomerPopup = "customer".equalsIgnoreCase(popupType);
    boolean showAdminPopup = "admin".equalsIgnoreCase(popupType);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add User - DKS Bank</title>

    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=214">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
        .add-user-hidden {
            display: none !important;
        }
    </style>
</head>

<body>

<div class="admin-page add-user-page">

    <div class="add-user-header">
        <div class="add-user-title">
            <h1>Add User</h1>
            <p>Create a new customer or admin account for DKS Bank.</p>
        </div>

        <a class="add-user-dashboard-btn" href="${pageContext.request.contextPath}/admin">
            <i class="bi bi-arrow-left"></i>
            Dashboard
        </a>
    </div>

    <% if (showCustomerPopup) { %>
        <div class="create-account-success-overlay show" id="successOverlay">
            <div class="create-account-success-box">
                <div class="create-account-success-icon">
                    <i class="bi bi-check2-circle"></i>
                </div>

                <h2>Activation Complete Successfully</h2>

                <div class="create-account-success-details">
                    <div class="create-account-success-detail-row">
                        <small>Status</small>
                        <strong>New user has been activated successfully.</strong>
                    </div>
                    <div class="create-account-success-detail-row">
                        <small>Customer ID</small>
                        <strong><%= custId %></strong>
                    </div>
                </div>

                <% if (emailWarning != null && !emailWarning.trim().isEmpty()) { %>
                    <p class="create-account-success-note"><%= emailWarning %></p>
                <% } else { %>
                    <p class="create-account-success-note">Login details have been emailed to the customer.</p>
                <% } %>

                <button type="button" class="create-account-success-btn" onclick="closeSuccessPopup()">Close</button>
            </div>
        </div>
    <% } else if (showAdminPopup) { %>
        <div class="create-account-success-overlay show" id="successOverlay">
            <div class="create-account-success-box">
                <div class="create-account-success-icon">
                    <i class="bi bi-check2-circle"></i>
                </div>

                <h2>New Admin Added</h2>

                <div class="create-account-success-details">
                    <div class="create-account-success-detail-row">
                        <small>Status</small>
                        <strong>Admin account created successfully.</strong>
                    </div>
                    <div class="create-account-success-detail-row">
                        <small>Admin / Customer ID</small>
                        <strong><%= adminId %></strong>
                    </div>
                </div>

                <p class="create-account-success-note">The admin can log in immediately using this ID and the password that was set.</p>

                <button type="button" class="create-account-success-btn" onclick="closeSuccessPopup()">Close</button>
            </div>
        </div>
    <% } %>

    <% if (errorMessage != null) { %>
        <div class="error"><%= errorMessage %></div>
    <% } %>

    <div class="add-user-layout">

        <div class="add-user-info-card">
            <div class="add-user-info-content">

                <div class="add-user-bank-icon">
                    <i class="bi bi-bank2"></i>
                </div>

                <h2>Create Secure User Profile</h2>

                <p>
                    Choose a role to switch modes: activate online banking for an
                    existing customer, or add a brand new admin.
                </p>

                <div class="add-user-points">
                    <div class="add-user-point">
                        <span><i class="bi bi-shield-check"></i></span>
                        Role-based access
                    </div>

                    <div class="add-user-point">
                        <span><i class="bi bi-person-check"></i></span>
                        Customer online banking activation
                    </div>

                    <div class="add-user-point">
                        <span><i class="bi bi-clock-history"></i></span>
                        Admin activity tracking
                    </div>
                </div>

                <div class="add-user-admin-chip">
                    <small>Logged in as</small>
                    <strong><%= fullName %></strong>
                </div>

            </div>
        </div>

        <div class="add-user-form-card">

            <div class="add-user-form-top">
                <div>
                    <h2>User Details</h2>
                    <p>Select a role first - the form will change based on your selection.</p>
                </div>

                <span class="add-user-secure-badge">
                    <i class="bi bi-lock-fill"></i>
                    Secure Entry
                </span>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/admin/add-user" id="addUserForm">

                <div class="add-user-form-grid">

                    <div class="add-user-field full">
                        <label>Role</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-person-badge"></i>
                            <select name="role" id="roleSelect" required onchange="handleRoleChange()">
                                <option value="" disabled selected>-- Select Role --</option>
                                <option value="CUSTOMER">CUSTOMER</option>
                                <option value="ADMIN">ADMIN</option>
                            </select>
                        </div>
                    </div>

                    <!-- ===== CUSTOMER activation fields ===== -->
                    <div class="add-user-field full add-user-hidden" id="customerDisplayNameField">
                        <label>Full Name <span style="font-weight:600;color:#64748b;">(for your reference only)</span></label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-person"></i>
                            <input type="text" id="customerDisplayNameInput" placeholder="Customer's name (optional, not submitted)">
                        </div>
                    </div>

                    <div class="add-user-field add-user-hidden" id="verifyCustomerIdField">
                        <label>Customer ID</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-credit-card-2-front"></i>
                            <input type="text" name="verifyCustomerId" id="verifyCustomerIdInput"
                                   placeholder="Enter existing Customer ID">
                        </div>
                    </div>

                    <div class="add-user-field add-user-hidden" id="accountNumberField">
                        <label>Account Number</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-wallet2"></i>
                            <input type="text" name="accountNumber" id="accountNumberInput"
                                   placeholder="Enter account number linked to this customer">
                        </div>
                        <div class="add-user-help">
                            Both values must belong to the same customer. A temporary password
                            will be generated automatically and emailed - you do not need to set one.
                        </div>
                    </div>

                    <!-- ===== ADMIN creation fields ===== -->
                    <div class="add-user-field add-user-hidden" id="firstNameField">
                        <label>First Name</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-person"></i>
                            <input type="text" name="firstName" id="firstNameInput" placeholder="Enter first name">
                        </div>
                    </div>

                    <div class="add-user-field add-user-hidden" id="lastNameField">
                        <label>Last Name</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-person"></i>
                            <input type="text" name="lastName" id="lastNameInput" placeholder="Enter last name">
                        </div>
                    </div>

                    <div class="add-user-field add-user-hidden" id="emailField">
                        <label>Email</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-envelope"></i>
                            <input type="email" name="email" id="emailInput" placeholder="Enter email address">
                        </div>
                    </div>

                    <div class="add-user-field add-user-hidden" id="phoneField">
                        <label>Phone</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-telephone"></i>
                            <input type="text" name="phone" id="phoneInput" placeholder="Enter phone number">
                        </div>
                    </div>

                    <div class="add-user-field add-user-hidden" id="dobField">
                        <label>Date of Birth</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-calendar"></i>
                            <input type="date" name="dob" id="dobInput">
                        </div>
                    </div>

                    <div class="add-user-field full add-user-hidden" id="addressField">
                        <label>Address</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-geo-alt"></i>
                            <input type="text" name="address" id="addressInput" placeholder="Enter address">
                        </div>
                    </div>

                    <div class="add-user-field add-user-hidden" id="adminCustomerIdField">
                        <label>Admin ID / Customer ID</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-credit-card-2-front"></i>
                            <input type="text" name="adminCustomerId" id="adminCustomerIdInput"
                                   placeholder="Leave blank to auto-generate">
                        </div>
                    </div>

                    <div class="add-user-field full add-user-hidden" id="passwordField">
                        <label>Password</label>
                        <div class="add-user-input-wrap">
                            <i class="bi bi-key"></i>
                            <input type="password" name="password" id="passwordInput" placeholder="Create password" autocomplete="new-password">

                            <button type="button" class="password-toggle" onclick="togglePassword()">
                                <i class="bi bi-eye" id="passwordIcon"></i>
                            </button>
                        </div>

                        <div class="add-user-help">
                            Use a strong password for better account security.
                        </div>
                    </div>

                </div>

                <div class="add-user-submit-row">
                    <div class="add-user-note">
                        <i class="bi bi-info-circle"></i>
                        <span id="formHintText">Select a role above to continue.</span>
                    </div>

                    <button type="submit" class="add-user-submit-btn" id="submitBtn" disabled>
                        <i class="bi bi-person-plus"></i>
                        <span id="submitBtnText">Continue</span>
                    </button>
                </div>

            </form>

        </div>

    </div>

</div>

<script>
    function togglePassword() {
        const input = document.getElementById("passwordInput");
        const icon = document.getElementById("passwordIcon");

        if (input.type === "password") {
            input.type = "text";
            icon.className = "bi bi-eye-slash";
        } else {
            input.type = "password";
            icon.className = "bi bi-eye";
        }
    }

    const customerOnlyFieldIds = ["customerDisplayNameField", "verifyCustomerIdField", "accountNumberField"];
    const adminOnlyFieldIds = ["firstNameField", "lastNameField", "emailField", "phoneField", "dobField",
        "addressField", "adminCustomerIdField", "passwordField"];

    const customerRequiredInputs = ["verifyCustomerIdInput", "accountNumberInput"];
    const adminRequiredInputs = ["firstNameInput", "lastNameInput", "emailInput", "phoneInput", "passwordInput"];

    function showFields(ids) {
        ids.forEach(function (id) {
            document.getElementById(id).classList.remove("add-user-hidden");
        });
    }

    function hideAndDisableFields(ids) {
        ids.forEach(function (id) {
            const field = document.getElementById(id);
            field.classList.add("add-user-hidden");

            const input = field.querySelector("input");
            if (input) {
                input.disabled = true;
                input.required = false;
            }
        });
    }

    function enableRequired(inputIds) {
        inputIds.forEach(function (id) {
            const input = document.getElementById(id);
            input.disabled = false;
            input.required = true;
        });
    }

    function handleRoleChange() {
        const role = document.getElementById("roleSelect").value;
        const submitBtn = document.getElementById("submitBtn");
        const submitBtnText = document.getElementById("submitBtnText");
        const formHintText = document.getElementById("formHintText");

        if (role === "CUSTOMER") {
            hideAndDisableFields(adminOnlyFieldIds);
            showFields(customerOnlyFieldIds);
            enableRequired(customerRequiredInputs);

            submitBtnText.textContent = "Activate User";
            formHintText.textContent = "Verify the Customer ID and Account Number to activate online banking.";
            submitBtn.disabled = false;

        } else if (role === "ADMIN") {
            hideAndDisableFields(customerOnlyFieldIds);
            showFields(adminOnlyFieldIds);
            enableRequired(adminRequiredInputs);

            submitBtnText.textContent = "Add Admin";
            formHintText.textContent = "Admin will be stored in the database and can log in immediately.";
            submitBtn.disabled = false;

        } else {
            hideAndDisableFields(customerOnlyFieldIds);
            hideAndDisableFields(adminOnlyFieldIds);

            submitBtnText.textContent = "Continue";
            formHintText.textContent = "Select a role above to continue.";
            submitBtn.disabled = true;
        }
    }

    function closeSuccessPopup() {
        const overlay = document.getElementById("successOverlay");

        if (overlay) {
            overlay.classList.remove("show");
        }

        document.body.style.overflow = "";

        const cleanUrl = window.location.pathname;
        window.history.replaceState({}, document.title, cleanUrl);
    }

    window.addEventListener("load", function () {
        handleRoleChange();

        const overlay = document.getElementById("successOverlay");
        if (overlay) {
            // Popup stays open until the admin explicitly clicks Close -
            // no auto-close, no outside-click close, no ESC close.
            document.body.style.overflow = "hidden";
        }
    });
</script>

</body>
</html>
