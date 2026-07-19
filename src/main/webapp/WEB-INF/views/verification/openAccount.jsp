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

    <style>
        /* ---- Email inline verification (Verify button + badge, embedded inside the input box) ---- */
        .email-input-box {
            position: relative;
        }

        .email-input-box input {
            padding-right: 92px;
        }

        .email-verify-btn {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            padding: 0 16px;
            height: 32px;
            border-radius: 20px;
            border: none;
            background: #f97316;
            color: #ffffff;
            font-family: inherit;
            font-weight: 700;
            font-size: 12px;
            cursor: pointer;
            box-shadow: 0 6px 14px rgba(249, 115, 22, 0.28);
            transition: background 0.25s ease, box-shadow 0.25s ease, transform 0.2s ease;
        }

        .email-verify-btn:hover:not(:disabled) {
            background: #ea580c;
            box-shadow: 0 8px 18px rgba(234, 88, 12, 0.35);
            transform: translateY(-50%) scale(1.04);
        }

        .email-verify-btn:disabled {
            background: #94a3b8;
            box-shadow: none;
            cursor: not-allowed;
            transform: translateY(-50%);
        }

        .email-verified-badge {
            display: none;
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            align-items: center;
            gap: 4px;
            padding: 5px 12px;
            border-radius: 20px;
            background: #dcfce7;
            border: 1px solid #86efac;
            color: #16a34a;
            font-weight: 700;
            font-size: 11px;
            transition: opacity 0.25s ease;
        }

        .email-verify-msg {
            display: none;
            margin-top: 8px;
            font-size: 13px;
            font-weight: 600;
        }

        /* ---- Email OTP popup/modal ---- */
        .email-otp-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.55);
            align-items: center;
            justify-content: center;
            z-index: 999;
            padding: 16px;
        }

        .email-otp-modal {
            background: #ffffff;
            border-radius: 20px;
            padding: 28px;
            width: 100%;
            max-width: 380px;
            box-shadow: 0 20px 50px rgba(15, 23, 42, 0.35);
            font-family: 'Poppins', sans-serif;
        }

        .email-otp-modal-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 4px;
        }

        .email-otp-modal-head h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 700;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .email-otp-close {
            border: none;
            background: transparent;
            font-size: 22px;
            line-height: 1;
            color: #94a3b8;
            cursor: pointer;
        }

        .email-otp-subtext {
            margin: 10px 0 0;
            color: #64748b;
            font-size: 13px;
        }

        .email-otp-masked {
            margin: 2px 0 16px;
            color: #0f172a;
            font-weight: 700;
            font-size: 15px;
        }

        .email-otp-error {
            display: none;
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 13px;
            margin-bottom: 14px;
        }

        .email-otp-input-box {
            margin-bottom: 14px;
        }

        .email-otp-input-box input {
            letter-spacing: 4px;
            font-weight: 700;
        }

        .email-otp-timer-row {
            display: flex;
            justify-content: center;
            margin-bottom: 18px;
            font-size: 13px;
            color: #475569;
        }

        .email-otp-timer-row b {
            color: #2563eb;
            margin-left: 4px;
        }

        .email-otp-resend-btn {
            width: 100%;
            margin-top: 10px;
            padding: 12px;
            border-radius: 12px;
            border: none;
            background: #0f9d6c;
            color: #ffffff;
            font-family: 'Poppins', sans-serif;
            font-weight: 700;
            font-size: 13px;
            cursor: pointer;
            transition: background 0.25s ease, box-shadow 0.25s ease;
            box-shadow: 0 8px 18px rgba(15, 157, 108, 0.25);
        }

        .email-otp-resend-btn:disabled {
            cursor: not-allowed;
            background: #94a3b8;
            box-shadow: none;
        }

        .email-otp-resend-btn:not(:disabled):hover {
            background: #0b8a70;
            box-shadow: 0 10px 22px rgba(11, 138, 112, 0.32);
        }
    </style>
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

            <!-- <div style="display:flex; align-items:flex-start; gap:10px; background:#f1f5f9; border:1px solid #e2e8f0; border-radius:12px; padding:12px 14px; margin-bottom:18px; color:#475569; font-size:13px; line-height:1.6;">
                <i class="bi bi-envelope-check" style="color:#2563eb; font-size:16px; margin-top:1px;"></i>
                <span>
                    Please verify your email address using the <b>Verify</b> button below before
                    filling the rest of the form. Your account is created only after your email
                    is successfully verified.
                </span>
            </div> -->

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

                    <a href="${pageContext.request.contextPath}/register">
                        Register Online Banking
                    </a>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/open-account"
                  method="post"
                  class="register-form"
                  id="openAccountForm">

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

                    <div class="register-input-box email-input-box" id="emailInputBox">
                        <i class="bi bi-envelope"></i>
                        <input type="email" name="email" id="emailInput" placeholder="Email address" required>

                        <button type="button" class="email-verify-btn" id="emailVerifyBtn">
                            Verify
                        </button>

                        <span class="email-verified-badge" id="emailVerifiedBadge">
                            <i class="bi bi-patch-check-fill"></i>
                            Verified
                        </span>
                    </div>

                    <div class="email-verify-msg" id="emailVerifyMsg"></div>

                    <input type="hidden" name="verificationToken" id="verificationTokenInput" value="">
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

            <a href="${pageContext.request.contextPath}/register" class="register-login-btn">
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

<!-- Email OTP verification popup/modal -->
<div class="email-otp-overlay" id="emailOtpOverlay">
    <div class="email-otp-modal">

        <div class="email-otp-modal-head">
            <h3><i class="bi bi-envelope-check"></i> Verify Email</h3>
            <button type="button" class="email-otp-close" id="emailOtpCloseBtn">&times;</button>
        </div>

        <p class="email-otp-subtext">OTP sent to:</p>
        <p class="email-otp-masked" id="emailOtpMaskedEmail">-</p>

        <div class="email-otp-error" id="emailOtpError"></div>

        <div class="register-input-box email-otp-input-box">
            <i class="bi bi-key"></i>
            <input type="text" id="emailOtpCodeInput" maxlength="6" inputmode="numeric"
                   pattern="[0-9]{6}" placeholder="Enter 6 digit OTP">
        </div>

        <div class="email-otp-timer-row">
            <span>OTP expires in:</span>
            <b id="emailOtpExpiryTimer">05:00</b>
        </div>

        <button type="button" class="register-submit-btn" id="emailOtpVerifyBtn">
            <i class="bi bi-shield-check"></i>
            Verify OTP
        </button>

        <button type="button" class="email-otp-resend-btn" id="emailOtpResendBtn" disabled>
            Resend OTP in <span id="emailOtpResendTimer">30</span>s
        </button>

    </div>
</div>

<script>
(function () {
    var contextPath = "${pageContext.request.contextPath}";

    var emailInput = document.getElementById("emailInput");
    var verifyBtn = document.getElementById("emailVerifyBtn");
    var verifiedBadge = document.getElementById("emailVerifiedBadge");
    var verifyMsg = document.getElementById("emailVerifyMsg");
    var tokenInput = document.getElementById("verificationTokenInput");

    var overlay = document.getElementById("emailOtpOverlay");
    var closeBtn = document.getElementById("emailOtpCloseBtn");
    var maskedEmailEl = document.getElementById("emailOtpMaskedEmail");
    var otpError = document.getElementById("emailOtpError");
    var otpInput = document.getElementById("emailOtpCodeInput");
    var expiryTimerEl = document.getElementById("emailOtpExpiryTimer");
    var verifyOtpBtn = document.getElementById("emailOtpVerifyBtn");
    var resendBtn = document.getElementById("emailOtpResendBtn");
    var resendTimerEl = document.getElementById("emailOtpResendTimer");

    var openAccountForm = document.getElementById("openAccountForm");

    var expiryInterval = null;
    var resendInterval = null;
    var isEmailVerified = false;

    function showVerifyMsg(text, isError) {
        verifyMsg.style.display = "block";
        verifyMsg.textContent = text;
        verifyMsg.style.color = isError ? "#dc2626" : "#059669";
    }

    function hideVerifyMsg() {
        verifyMsg.style.display = "none";
    }

    function showOtpError(text) {
        otpError.style.display = "block";
        otpError.textContent = text;
    }

    function hideOtpError() {
        otpError.style.display = "none";
    }

    function resetVerificationState() {
        isEmailVerified = false;
        tokenInput.value = "";
        verifiedBadge.style.display = "none";
        verifyBtn.style.display = "inline-block";
        emailInput.readOnly = false;
    }

    emailInput.addEventListener("input", function () {
        if (isEmailVerified) {
            resetVerificationState();
            showVerifyMsg("Email changed - please verify again.", true);
        }
    });

    function formatTime(totalSeconds) {
        var m = Math.floor(totalSeconds / 60);
        var s = totalSeconds % 60;
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    function startExpiryCountdown(totalSeconds) {
        clearInterval(expiryInterval);
        var remaining = totalSeconds;
        expiryTimerEl.textContent = formatTime(remaining);

        expiryInterval = setInterval(function () {
            remaining--;

            if (remaining <= 0) {
                clearInterval(expiryInterval);
                remaining = 0;
                showOtpError("This OTP has expired. Please resend a new OTP.");
            }

            expiryTimerEl.textContent = formatTime(Math.max(remaining, 0));
        }, 1000);
    }

    function startResendCountdown(totalSeconds) {
        clearInterval(resendInterval);
        var remaining = totalSeconds;
        resendBtn.disabled = true;
        resendBtn.textContent = "Resend OTP in " + remaining + "s";

        resendInterval = setInterval(function () {
            remaining--;

            if (remaining <= 0) {
                clearInterval(resendInterval);
                resendBtn.disabled = false;
                resendBtn.textContent = "Resend OTP";
                return;
            }

            resendBtn.textContent = "Resend OTP in " + remaining + "s";
        }, 1000);
    }

    function openModal() {
        overlay.style.display = "flex";
        otpInput.value = "";
        hideOtpError();
        otpInput.focus();
    }

    function closeModal() {
        overlay.style.display = "none";
        clearInterval(expiryInterval);
        clearInterval(resendInterval);
    }

    closeBtn.addEventListener("click", closeModal);

    verifyBtn.addEventListener("click", function () {
        var email = emailInput.value.trim();

        if (!email) {
            showVerifyMsg("Please enter your email address first.", true);
            return;
        }

        verifyBtn.disabled = true;
        verifyBtn.textContent = "Sending...";
        hideVerifyMsg();

        var body = new URLSearchParams();
        body.append("email", email);

        fetch(contextPath + "/send-email-verification", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: body.toString()
        })
        .then(function (res) { return res.json(); })
        .then(function (data) {
            verifyBtn.disabled = false;
            verifyBtn.textContent = "Verify";

            if (!data.success) {
                showVerifyMsg(data.message || "Unable to send OTP.", true);
                return;
            }

            tokenInput.value = data.token;
            maskedEmailEl.textContent = data.maskedEmail;

            openModal();
            startExpiryCountdown(data.expiresInSeconds || 300);
            startResendCountdown(data.resendCooldownSeconds || 30);
        })
        .catch(function () {
            verifyBtn.disabled = false;
            verifyBtn.textContent = "Verify";
            showVerifyMsg("Network error. Please try again.", true);
        });
    });

    verifyOtpBtn.addEventListener("click", function () {
        var otp = otpInput.value.trim();
        var token = tokenInput.value;

        if (!otp) {
            showOtpError("Please enter the OTP.");
            return;
        }

        verifyOtpBtn.disabled = true;
        verifyOtpBtn.textContent = "Verifying...";

        var body = new URLSearchParams();
        body.append("token", token);
        body.append("otp", otp);

        fetch(contextPath + "/verify-email-otp", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: body.toString()
        })
        .then(function (res) { return res.json(); })
        .then(function (data) {
            verifyOtpBtn.disabled = false;
            verifyOtpBtn.innerHTML = '<i class="bi bi-shield-check"></i> Verify OTP';

            if (!data.success) {
                showOtpError(data.message || "Invalid OTP.");
                return;
            }

            isEmailVerified = true;
            closeModal();

            verifyBtn.style.display = "none";
            verifiedBadge.style.display = "inline-flex";
            hideVerifyMsg();
            emailInput.readOnly = true;
        })
        .catch(function () {
            verifyOtpBtn.disabled = false;
            verifyOtpBtn.innerHTML = '<i class="bi bi-shield-check"></i> Verify OTP';
            showOtpError("Network error. Please try again.");
        });
    });

    resendBtn.addEventListener("click", function () {
        if (resendBtn.disabled) {
            return;
        }

        var token = tokenInput.value;

        var body = new URLSearchParams();
        body.append("token", token);

        fetch(contextPath + "/resend-email-otp", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: body.toString()
        })
        .then(function (res) { return res.json(); })
        .then(function (data) {
            if (!data.success) {
                showOtpError(data.message || "Unable to resend OTP.");

                if (data.resendCooldownSeconds > 0) {
                    startResendCountdown(data.resendCooldownSeconds);
                }
                return;
            }

            hideOtpError();
            otpInput.value = "";
            startExpiryCountdown(300);
            startResendCountdown(data.resendCooldownSeconds || 30);
        })
        .catch(function () {
            showOtpError("Network error. Please try again.");
        });
    });

    openAccountForm.addEventListener("submit", function (e) {
        if (!isEmailVerified || !tokenInput.value) {
            e.preventDefault();
            showVerifyMsg("Please verify your email before creating an account.", true);
            emailInput.scrollIntoView({ behavior: "smooth", block: "center" });
        }
    });
})();
</script>

</body>
</html>
