<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.Payment" %>

<%
    String error = (String) request.getAttribute("error");
    Boolean alreadyCompleted = (Boolean) request.getAttribute("alreadyCompleted");
    Payment payment = (Payment) request.getAttribute("payment");
    String requestId = (String) request.getAttribute("requestId");
    String qrUrl = (String) request.getAttribute("qrUrl");

    boolean hasPayment = (payment != null && error == null);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Complete Payment - DKS Bank</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="icon" type="image/png" href="images/logo.png">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=116">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

    <style>
        * { box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { margin: 0; background: #f4f7f5; }

        .pay-page-header {
            display: flex; justify-content: space-between; align-items: center;
            padding: 18px 28px;
            background: linear-gradient(120deg, #0d3b2e, #14532d 55%, #1f6b4a);
            color: #fff;
        }
        .pay-brand { display: flex; align-items: center; gap: 10px; }
        .pay-brand-icon {
            width: 40px; height: 40px; border-radius: 10px;
            background: rgba(255,255,255,0.15);
            display: flex; align-items: center; justify-content: center; font-size: 1.2rem;
        }
        .pay-brand b { display: block; font-size: 1.05rem; }
        .pay-brand small { opacity: .85; font-size: .78rem; }
        .pay-secure-badge {
            display: flex; align-items: center; gap: 6px;
            background: rgba(255,255,255,0.15);
            padding: 6px 14px; border-radius: 999px; font-size: .8rem; font-weight: 600;
        }

        .pay-wrapper {
            display: grid; grid-template-columns: 380px 1fr; gap: 24px;
            max-width: 1180px; margin: 24px auto; padding: 0 20px 40px;
        }

        .pay-left {
            background: linear-gradient(160deg, #0d3b2e, #1f6b4a 120%);
            color: #fff; border-radius: 18px; padding: 28px; height: fit-content;
        }
        .pay-left-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: rgba(255,255,255,0.14); padding: 6px 12px; border-radius: 999px;
            font-size: .78rem; font-weight: 600; margin-bottom: 16px;
        }
        .pay-left h1 { font-size: 1.7rem; margin: 0 0 10px; line-height: 1.25; }
        .pay-left p.lead { opacity: .9; font-size: .92rem; margin: 0 0 22px; }

        .pay-feature-list { display: flex; flex-direction: column; gap: 12px; margin-bottom: 22px; }
        .pay-feature-list div { display: flex; align-items: flex-start; gap: 10px; }
        .pay-feature-list i { margin-top: 3px; color: #ffb547; }
        .pay-feature-list strong { display: block; font-size: .88rem; }
        .pay-feature-list span.desc { font-size: .78rem; opacity: .85; }

        .pay-summary-box {
            background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.18);
            border-radius: 14px; padding: 16px;
        }
        .pay-summary-box h3 { margin: 0 0 12px; font-size: .95rem; display: flex; align-items: center; gap: 8px; }
        .pay-summary-row { display: flex; justify-content: space-between; font-size: .85rem; padding: 6px 0; opacity: .92; }
        .pay-summary-total { border-top: 1px dashed rgba(255,255,255,0.3); margin-top: 8px; padding-top: 10px; font-size: 1.05rem; font-weight: 700; }

        .pay-right { background: #fff; border-radius: 18px; padding: 24px; box-shadow: 0 8px 30px rgba(13,59,46,0.08); }
        .pay-right h2 { margin: 0 0 4px; color: #0d3b2e; }
        .pay-right > p.sub { margin: 0 0 20px; color: #64766e; font-size: .88rem; }

        .pay-methods-grid { display: grid; grid-template-columns: 220px 1fr; gap: 20px; }

        .pay-method-list { display: flex; flex-direction: column; gap: 8px; }
        .pay-method-item {
            display: flex; align-items: center; gap: 12px; padding: 12px 14px;
            border-radius: 12px; border: 1px solid #e4ece7; cursor: pointer; background: #fafcfb;
            transition: all .15s ease;
        }
        .pay-method-item.active { border-color: #14532d; background: #eef7f1; }
        .pay-method-item .icon {
            width: 38px; height: 38px; border-radius: 10px; background: #eef7f1;
            display: flex; align-items: center; justify-content: center; color: #14532d; font-size: 1.1rem;
        }
        .pay-method-item strong { display: block; font-size: .88rem; color: #14300f; }
        .pay-method-item span { font-size: .74rem; color: #7c8a83; }

        .pay-upi-panel { border: 1px solid #e4ece7; border-radius: 14px; padding: 20px; }
        .pay-upi-head { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; }
        .pay-upi-head h3 { margin: 0 0 4px; font-size: 1.02rem; color: #14300f; }
        .pay-upi-head p { margin: 0; font-size: .82rem; color: #7c8a83; }
        .pay-timer { background: #fef3e2; color: #a3620a; font-weight: 700; font-size: .82rem; padding: 6px 12px; border-radius: 10px; text-align: center; }
        .pay-timer small { display: block; font-weight: 500; font-size: .68rem; }

        .pay-qr-box {
            background: #f3f8f5; border: 1px solid #dcece3; border-radius: 14px;
            padding: 18px; display: flex; gap: 20px; align-items: center; flex-wrap: wrap; justify-content: center;
        }
        #qrCodeCanvas { background: #fff; padding: 10px; border-radius: 10px; }
        .pay-qr-apps { display: flex; gap: 14px; margin-top: 10px; flex-wrap: wrap; }
        .pay-qr-apps span { font-size: .72rem; color: #5a6b63; text-align: center; display: block; margin-top: 4px; }

        .pay-divider { display: flex; align-items: center; gap: 10px; margin: 18px 0; color: #9caaa3; font-size: .8rem; }
        .pay-divider::before, .pay-divider::after { content: ""; flex: 1; height: 1px; background: #e4ece7; }

        .pay-upi-input-wrap { display: flex; align-items: center; border: 1px solid #dcece3; border-radius: 10px; padding: 10px 14px; }
        .pay-upi-input-wrap input { border: none; outline: none; flex: 1; font-size: .92rem; }

        .pay-note { display: flex; align-items: center; gap: 8px; color: #1f6b4a; font-size: .82rem; margin: 14px 0; }

        .pay-btn {
            width: 100%; border: none; border-radius: 12px; padding: 14px;
            background: linear-gradient(120deg, #14532d, #1f6b4a); color: #fff;
            font-weight: 700; font-size: 1rem; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .pay-btn:disabled { opacity: .7; cursor: not-allowed; }

        .pay-demo-banner {
            margin-top: 20px; background: #eef7f1; border: 1px solid #cfe7d8; border-radius: 14px;
            padding: 14px 16px; display: flex; gap: 10px; align-items: flex-start; color: #14532d; font-size: .84rem;
        }
        .pay-demo-banner strong { display: block; margin-bottom: 2px; }

        /* Processing / success overlay */
        .pay-overlay {
            position: fixed; inset: 0; background: rgba(13,59,46,0.55);
            display: none; align-items: center; justify-content: center; z-index: 999; padding: 16px;
        }
        .pay-overlay.show { display: flex; }
        .pay-overlay-box {
            background: #fff; border-radius: 18px; padding: 30px; max-width: 380px; width: 100%;
            text-align: center;
        }
        .pay-step-list { text-align: left; margin: 20px 0; display: flex; flex-direction: column; gap: 12px; }
        .pay-step { display: flex; align-items: center; gap: 10px; font-size: .9rem; color: #9caaa3; }
        .pay-step .dot {
            width: 22px; height: 22px; border-radius: 50%; border: 2px solid #dcece3;
            display: flex; align-items: center; justify-content: center; font-size: .7rem; flex-shrink: 0;
        }
        .pay-step.done { color: #14532d; font-weight: 600; }
        .pay-step.done .dot { background: #14532d; border-color: #14532d; color: #fff; }
        .pay-step.active { color: #14532d; font-weight: 600; }
        .pay-step.active .dot { border-color: #14532d; }

        .pay-success-icon { font-size: 3rem; color: #14532d; }
        .pay-success-details { text-align: left; background: #f3f8f5; border-radius: 12px; padding: 14px; margin: 16px 0; }
        .pay-success-row { display: flex; justify-content: space-between; padding: 5px 0; font-size: .86rem; }
        .pay-success-row strong { color: #0d3b2e; }

        /* Coming soon modal */
        .pay-modal-overlay {
            position: fixed; inset: 0; background: rgba(13,59,46,0.5);
            display: none; align-items: center; justify-content: center; z-index: 999; padding: 16px;
        }
        .pay-modal-overlay.show { display: flex; }
        .pay-modal-box { background: #fff; border-radius: 16px; padding: 26px; max-width: 340px; width: 100%; text-align: center; }
        .pay-modal-box i { font-size: 2.4rem; color: #a3620a; }
        .pay-modal-box h3 { margin: 12px 0 6px; color: #14300f; }
        .pay-modal-box p { margin: 0 0 18px; color: #7c8a83; font-size: .86rem; }
        .pay-modal-box button {
            border: none; background: #14532d; color: #fff; padding: 10px 22px;
            border-radius: 10px; font-weight: 600; cursor: pointer;
        }

        @media (max-width: 900px) {
            .pay-wrapper { grid-template-columns: 1fr; }
            .pay-methods-grid { grid-template-columns: 1fr; }
            .pay-method-list { flex-direction: row; overflow-x: auto; }
            .pay-method-item { min-width: 160px; }
        }
    </style>
</head>
<body>

<header class="pay-page-header">
    <div class="pay-brand">
        <span class="pay-brand-icon"><i class="bi bi-bank2"></i></span>
        <span>
            <b>DKS Bank</b>
            <small>Secure Payment</small>
        </span>
    </div>
    <span class="pay-secure-badge"><i class="bi bi-lock-fill"></i> Secure &amp; Encrypted</span>
</header>

<% if (!hasPayment) { %>

    <div style="max-width:520px;margin:60px auto;background:#fff;border-radius:16px;padding:30px;text-align:center;box-shadow:0 8px 30px rgba(13,59,46,0.08);">
        <i class="bi bi-exclamation-circle" style="font-size:2.4rem;color:#c0392b;"></i>
        <h2 style="color:#14300f;margin:12px 0 6px;">Payment Link Not Available</h2>
        <p style="color:#7c8a83;"><%= error != null ? error : "This payment link is invalid or has expired." %></p>
        <a href="${pageContext.request.contextPath}/open-account"
           style="display:inline-block;margin-top:10px;background:#14532d;color:#fff;padding:10px 22px;border-radius:10px;text-decoration:none;font-weight:600;">
            Start a New Application
        </a>
    </div>

<% } else { %>

    <div class="pay-wrapper">

        <section class="pay-left">
            <span class="pay-left-badge"><i class="bi bi-house-door"></i> Account Opening</span>
            <h1>Complete your initial deposit</h1>
            <p class="lead">Your account will be created after successful payment.</p>

            <div class="pay-feature-list">
                <div>
                    <i class="bi bi-shield-check"></i>
                    <span><strong>100% Secure Payment</strong><span class="desc">Your payment is protected with bank-level security</span></span>
                </div>
                <div>
                    <i class="bi bi-check2-circle"></i>
                    <span><strong>Instant Confirmation</strong><span class="desc">Payment will be verified instantly (Simulation)</span></span>
                </div>
                <div>
                    <i class="bi bi-credit-card"></i>
                    <span><strong>No Real Transaction</strong><span class="desc">This is a simulation for demonstration purposes only</span></span>
                </div>
            </div>

            <div class="pay-summary-box">
                <h3><i class="bi bi-receipt"></i> Payment Summary</h3>
                <div class="pay-summary-row"><span>Account Type</span><span><%= payment.getAccountType() %></span></div>
                <div class="pay-summary-row"><span>Initial Deposit</span><span>\u20B9<%= String.format("%,.2f", payment.getAmount()) %></span></div>
                <div class="pay-summary-row"><span>Transaction Charges</span><span>\u20B90.00</span></div>
                <div class="pay-summary-row pay-summary-total"><span>Total Payable</span><span>\u20B9<%= String.format("%,.2f", payment.getAmount()) %></span></div>
            </div>
        </section>

        <section class="pay-right" id="paymentRightPanel">

            <% if (alreadyCompleted != null && alreadyCompleted) { %>

                <div style="text-align:center;padding:30px 10px;">
                    <i class="bi bi-check2-circle" style="font-size:2.6rem;color:#14532d;"></i>
                    <h2 style="margin:12px 0 6px;">Payment Already Completed</h2>
                    <p style="color:#7c8a83;">This payment link has already been used successfully. If you did not receive your account details, please contact support.</p>
                    <a href="${pageContext.request.contextPath}/login" style="display:inline-block;margin-top:10px;background:#14532d;color:#fff;padding:10px 22px;border-radius:10px;text-decoration:none;font-weight:600;">Back to Login</a>
                </div>

            <% } else { %>

                <h2>Choose Payment Method</h2>
                <p class="sub">Select a payment option to add initial deposit</p>

                <div class="pay-methods-grid">

                    <div class="pay-method-list">
                        <div class="pay-method-item active" data-method="upi" onclick="selectMethod('upi', this)">
                            <span class="icon"><i class="bi bi-qr-code"></i></span>
                            <span><strong>UPI</strong><br><span>Pay using any UPI app</span></span>
                        </div>
                        <div class="pay-method-item" data-method="card" onclick="showComingSoon()">
                            <span class="icon"><i class="bi bi-credit-card-2-front"></i></span>
                            <span><strong>Debit / Credit Card</strong><br><span>Pay using card</span></span>
                        </div>
                        <div class="pay-method-item" data-method="netbanking" onclick="showComingSoon()">
                            <span class="icon"><i class="bi bi-bank"></i></span>
                            <span><strong>Net Banking</strong><br><span>Pay using your bank</span></span>
                        </div>
                        <div class="pay-method-item" data-method="wallet" onclick="showComingSoon()">
                            <span class="icon"><i class="bi bi-wallet2"></i></span>
                            <span><strong>Wallet</strong><br><span>Pay using wallet</span></span>
                        </div>
                        <div class="pay-method-item" data-method="banktransfer" onclick="showComingSoon()">
                            <span class="icon"><i class="bi bi-arrow-left-right"></i></span>
                            <span><strong>Bank Transfer</strong><br><span>Transfer from your bank</span></span>
                        </div>
                    </div>

                    <div class="pay-upi-panel">
                        <div class="pay-upi-head">
                            <div>
                                <h3><i class="bi bi-qr-code-scan"></i> Pay using UPI</h3>
                                <p>Scan QR code or enter your UPI ID to pay</p>
                            </div>
                            <div class="pay-timer" id="payTimer">
                                05:00
                                <small>Time remaining</small>
                            </div>
                        </div>

                        <div class="pay-qr-box">
                            <div id="qrCodeCanvas"></div>
                            <div>
                                <strong style="display:block;margin-bottom:8px;color:#14300f;">Scan this QR with any UPI app</strong>
                                <div class="pay-qr-apps">
                                    <div><i class="bi bi-google" style="font-size:1.3rem;color:#4285F4;"></i><span>GPay</span></div>
                                    <div><i class="bi bi-phone" style="font-size:1.3rem;color:#5f259f;"></i><span>PhonePe</span></div>
                                    <div><i class="bi bi-wallet2" style="font-size:1.3rem;color:#00baf2;"></i><span>Paytm</span></div>
                                    <div><i class="bi bi-bank2" style="font-size:1.3rem;color:#f37021;"></i><span>BHIM</span></div>
                                </div>
                            </div>
                        </div>

                        <div class="pay-divider">OR</div>

                        <label style="font-size:.85rem;font-weight:600;color:#14300f;">Enter UPI ID</label>
                        <div class="pay-upi-input-wrap" style="margin-top:8px;">
                            <input type="text" id="upiIdInput" placeholder="example@upi">
                            <i class="bi bi-check-circle" style="color:#c7d3ce;"></i>
                        </div>

                        <div class="pay-note"><i class="bi bi-shield-check"></i> You will be redirected to your UPI app to complete the payment</div>

                        <button type="button" class="pay-btn" id="payBtn" onclick="startUpiPayment()">
                            <i class="bi bi-lock-fill"></i> Pay \u20B9<%= String.format("%,.2f", payment.getAmount()) %>
                        </button>
                    </div>

                </div>

                <div class="pay-demo-banner">
                    <i class="bi bi-shield-check"></i>
                    <div>
                        <strong>Demo / Simulation Mode</strong>
                        This is a simulated payment page. No real money will be deducted. Click "Pay" to simulate a successful payment.
                    </div>
                </div>

            <% } %>

        </section>

    </div>

    <!-- Processing / Success overlay -->
    <div class="pay-overlay" id="processingOverlay">
        <div class="pay-overlay-box" id="processingBox">

            <div id="processingSteps">
                <i class="bi bi-arrow-repeat" style="font-size:2rem;color:#14532d;"></i>
                <h3 style="margin:10px 0 0;color:#14300f;">Processing Payment...</h3>

                <div class="pay-step-list">
                    <div class="pay-step" id="stepConnect"><span class="dot">1</span> Connecting to UPI</div>
                    <div class="pay-step" id="stepVerify"><span class="dot">2</span> Verifying Payment</div>
                    <div class="pay-step" id="stepSuccess"><span class="dot">3</span> Payment Successful</div>
                </div>
            </div>

            <div id="processingResult" style="display:none;"></div>

        </div>
    </div>

    <!-- Coming Soon modal -->
    <div class="pay-modal-overlay" id="comingSoonModal">
        <div class="pay-modal-box">
            <i class="bi bi-hourglass-split"></i>
            <h3>Feature Coming Soon</h3>
            <p>This payment method will be available in future updates.</p>
            <button type="button" onclick="closeComingSoon()">Got it</button>
        </div>
    </div>

    <script>
        var qrUrl = "<%= qrUrl %>";
        var requestId = "<%= requestId %>";
        var contextPath = "${pageContext.request.contextPath}";

        if (document.getElementById("qrCodeCanvas")) {
            new QRCode(document.getElementById("qrCodeCanvas"), {
                text: qrUrl,
                width: 160,
                height: 160
            });
        }

        function selectMethod(method, el) {
            document.querySelectorAll(".pay-method-item").forEach(function (item) {
                item.classList.remove("active");
            });
            el.classList.add("active");
        }

        function showComingSoon() {
            document.getElementById("comingSoonModal").classList.add("show");
        }

        function closeComingSoon() {
            document.getElementById("comingSoonModal").classList.remove("show");
        }

        // Countdown timer (visual only, demo)
        (function startTimer() {
            var timerEl = document.getElementById("payTimer");
            if (!timerEl) return;

            var seconds = 5 * 60;

            var interval = setInterval(function () {
                seconds--;
                if (seconds <= 0) {
                    clearInterval(interval);
                    seconds = 0;
                }
                var m = Math.floor(seconds / 60);
                var s = seconds % 60;
                timerEl.childNodes[0].textContent =
                        (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s) + " ";
            }, 1000);
        })();

        function startUpiPayment() {
            var payBtn = document.getElementById("payBtn");
            payBtn.disabled = true;

            document.getElementById("processingOverlay").classList.add("show");
            document.getElementById("processingSteps").style.display = "block";
            document.getElementById("processingResult").style.display = "none";

            var stepConnect = document.getElementById("stepConnect");
            var stepVerify = document.getElementById("stepVerify");
            var stepSuccess = document.getElementById("stepSuccess");

            [stepConnect, stepVerify, stepSuccess].forEach(function (s) { s.classList.remove("active", "done"); });

            stepConnect.classList.add("active");

            setTimeout(function () {
                stepConnect.classList.remove("active");
                stepConnect.classList.add("done");
                stepVerify.classList.add("active");
            }, 900);

            setTimeout(function () {
                stepVerify.classList.remove("active");
                stepVerify.classList.add("done");
                stepSuccess.classList.add("active");
            }, 1900);

            setTimeout(function () {
                submitPayment();
            }, 2700);
        }

        function submitPayment() {
            var formData = new URLSearchParams();
            formData.append("requestId", requestId);

            fetch(contextPath + "/payment/process", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData.toString()
            })
            .then(function (res) { return res.json(); })
            .then(function (data) {
                var stepSuccess = document.getElementById("stepSuccess");
                stepSuccess.classList.remove("active");

                if (data.success) {
                    stepSuccess.classList.add("done");
                    setTimeout(function () { showSuccessResult(data); }, 500);
                } else {
                    showErrorResult(data.message);
                }
            })
            .catch(function () {
                showErrorResult("Network error. Please try again.");
            });
        }

        function showSuccessResult(data) {
            document.getElementById("processingSteps").style.display = "none";
            var resultBox = document.getElementById("processingResult");

            resultBox.innerHTML =
                '<i class="bi bi-check2-circle pay-success-icon"></i>' +
                '<h3 style="margin:10px 0 4px;color:#14300f;">Account Created Successfully</h3>' +
                '<p style="color:#7c8a83;font-size:.86rem;margin:0 0 6px;">Ref: ' + data.transactionReference + '</p>' +
                '<div class="pay-success-details">' +
                    '<div class="pay-success-row"><span>Customer ID</span><strong>' + data.customerId + '</strong></div>' +
                    '<div class="pay-success-row"><span>Account Number</span><strong>' + data.accountNumber + '</strong></div>' +
                    '<div class="pay-success-row"><span>IFSC Code</span><strong>' + data.ifscCode + '</strong></div>' +
                '</div>' +
                '<p style="font-size:.78rem;color:#1f6b4a;margin:0 0 16px;"><i class="bi bi-envelope-check"></i> These details have also been emailed to you.</p>' +
                '<button type="button" class="pay-btn" onclick="window.location.href=contextPath+\'/register\'">Register for Online Banking</button>';

            resultBox.style.display = "block";
        }

        function showErrorResult(message) {
            document.getElementById("processingSteps").style.display = "none";
            var resultBox = document.getElementById("processingResult");

            resultBox.innerHTML =
                '<i class="bi bi-x-circle" style="font-size:2.4rem;color:#c0392b;"></i>' +
                '<h3 style="margin:10px 0 4px;color:#14300f;">Payment Failed</h3>' +
                '<p style="color:#7c8a83;font-size:.86rem;margin:0 0 16px;">' + message + '</p>' +
                '<button type="button" class="pay-btn" onclick="document.getElementById(\'processingOverlay\').classList.remove(\'show\');document.getElementById(\'payBtn\').disabled=false;">Try Again</button>';

            resultBox.style.display = "block";
        }
    </script>

<% } %>

</body>
</html>
