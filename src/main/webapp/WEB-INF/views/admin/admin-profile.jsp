<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Profile - DKS Bank Admin</title>

    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=21">

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet">

    <style>
        /* Admin Profile - Hero card */
        .ap-hero {
            background: linear-gradient(135deg, #0d3b2e, #1f6b4a 130%);
            border-radius: 18px;
            padding: 24px 28px;
            color: #fff;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 20px;
        }

        .ap-hero-left { display: flex; align-items: center; gap: 18px; }

        .ap-avatar-wrap { position: relative; }

        .ap-avatar {
            width: 76px; height: 76px; border-radius: 50%;
            background: rgba(255,255,255,0.14);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem; font-weight: 700; color: #fff;
            border: 2px solid rgba(255,255,255,0.3);
        }

        .ap-avatar-badge {
            position: absolute; bottom: 0; right: 0;
            width: 24px; height: 24px; border-radius: 50%;
            background: #22c55e; color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: .7rem; border: 2px solid #0d3b2e;
        }

        .ap-hero-name-row { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .ap-hero-name-row h2 { margin: 0; font-size: 1.3rem; color: #fff; }

        .ap-role-pill {
            background: rgba(255,255,255,0.16);
            padding: 4px 12px; border-radius: 999px;
            font-size: .74rem; font-weight: 600;
            color: #fff;
        }

        .ap-hero-meta { display: flex; gap: 18px; margin-top: 8px; flex-wrap: wrap; font-size: .84rem; opacity: .9; color: #fff; }
        .ap-hero-meta i { margin-right: 5px; }

        .ap-hero-right { display: flex; gap: 16px; flex-wrap: wrap; }

        .ap-hero-stat {
            display: flex; align-items: center; gap: 10px;
            background: rgba(255,255,255,0.1);
            padding: 10px 16px; border-radius: 12px;
            color: #fff;
        }
        .ap-hero-stat i { font-size: 1.1rem; }
        .ap-hero-stat small { display: block; font-size: .72rem; opacity: .85; color: #fff; }
        .ap-hero-stat b { font-size: .92rem; color: #fff; }

        /* Quick Actions grid */
        .ap-quick-actions {
            display: grid; grid-template-columns: repeat(2, 1fr);
            gap: 12px; padding: 16px;
        }

        .ap-quick-action {
            display: flex; flex-direction: column; align-items: center; gap: 8px;
            padding: 16px 10px; border-radius: 12px;
            background: #f3f8f5; border: 1px solid #dcece3;
            text-decoration: none; color: #0d3b2e; font-size: .8rem; font-weight: 600;
            text-align: center;
            white-space: normal;
            line-height: 1.3;
        }
        .ap-quick-action i { font-size: 1.3rem; color: #14532d; }

        @media (min-width: 1300px) {
            .ap-quick-actions { grid-template-columns: repeat(4, 1fr); }
            .ap-quick-action { font-size: .74rem; padding: 14px 6px; }
        }

        /* Dummy-data tag (inline, e.g. next to Joined Date) */
        .ap-dummy-tag {
            font-size: .68rem; font-style: normal; opacity: .75; margin-left: 2px;
        }

        /* Dummy-data disclaimer note (bottom of a card/section) */
        .ap-dummy-note {
            display: flex; align-items: flex-start; gap: 8px;
            padding: 10px 16px 16px;
            color: #7c8a83; font-size: .76rem; line-height: 1.4;
            border-top: 1px dashed #e4ece7; margin-top: 4px;
        }
        .ap-dummy-note i { color: #5a8f7b; margin-top: 1px; }

        .ap-status-pill {
            display: inline-block; background: #eaf7ee; color: #14532d;
            padding: 3px 12px; border-radius: 999px; font-size: .78rem; font-weight: 600;
        }

        .ap-activity-item {
            display: flex; gap: 12px; padding: 12px 16px;
            border-bottom: 1px solid #eef3f0;
        }
        .ap-activity-icon { color: #14532d; font-size: 1.1rem; margin-top: 2px; }
        .ap-activity-main { flex: 1; }
        .ap-activity-top { display: flex; justify-content: space-between; align-items: center; gap: 8px; flex-wrap: wrap; }
        .ap-activity-main small { color: #8a958f; font-size: .78rem; }

        @media (max-width: 900px) {
            .ap-hero { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>

<body class="admin-body">

<div class="admin-layout">

    <aside class="admin-sidebar">

        <div class="admin-logo">
            <span class="admin-logo-icon">
                <i class="bi bi-bank2"></i>
            </span>

            <div>
                <h2>DKS Bank</h2>
                <p>Admin Console</p>
            </div>
        </div>

        <nav class="admin-menu">

            <a href="${pageContext.request.contextPath}/admin">
                <i class="bi bi-speedometer2"></i>
                <span>Admin Dashboard</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/users">
                <i class="bi bi-people"></i>
                <span>User Management</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/accounts">
                <i class="bi bi-wallet2"></i>
                <span>Accounts</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/transactions">
                <i class="bi bi-receipt"></i>
                <span>Transactions</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/reports">
                <i class="bi bi-bar-chart-line"></i>
                <span>Reports</span>
            </a>

            <a href="javascript:void(0)" onclick="return comingSoon('Security');">
                <i class="bi bi-shield-lock"></i>
                <span>Security</span>
            </a>

            <a href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-box-arrow-right"></i>
                <span>Logout</span>
            </a>

        </nav>

        <div class="admin-support-box">
            <i class="bi bi-shield-check"></i>
            <p>Admin Access</p>
            <h4>Secured Panel</h4>
        </div>

    </aside>

    <main class="admin-main">

        <header class="admin-topbar">

            <div class="admin-welcome">
                <h3>My Profile</h3>
                <p>Your admin account details.</p>
            </div>

            <form action="${pageContext.request.contextPath}/admin/search"
                  method="get"
                  class="admin-search-box">
                <i class="bi bi-search"></i>
                <input type="text"
                       name="q"
                       placeholder="Search users, accounts, transactions..."
                       required>
            </form>

            <div class="admin-top-actions">

                <button type="button"
                        class="admin-icon-btn"
                        onclick="return comingSoon('Notifications');">
                    <i class="bi bi-bell"></i>
                    <span>5</span>
                </button>

                <button type="button"
                        class="admin-icon-btn"
                        onclick="return comingSoon('Messages');">
                    <i class="bi bi-envelope"></i>
                    <span>2</span>
                </button>

                <div class="profile-menu">

                    <div class="admin-profile-chip"
                         onclick="toggleAdminProfileDropdown()"
                         style="cursor: pointer;">
                        <span>${adminInitial}</span>
                        <i class="bi bi-chevron-down"></i>
                    </div>

                    <div class="profile-dropdown" id="adminProfileDropdown">

                        <div class="profile-head">
                            <h4>${empty adminFullName ? "ADMIN" : adminFullName.toUpperCase()}</h4>
                            <p>Admin Access</p>
                        </div>

                        <a href="${pageContext.request.contextPath}/admin/admin-profile-overview">
                            <i class="bi bi-person-badge"></i>
                            Profile Overview
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/profile">
                            <i class="bi bi-person"></i>
                            My Profile
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/change-password">
                            <i class="bi bi-key"></i>
                            Change Password
                        </a>

                        <a href="javascript:void(0)" onclick="return comingSoon('Notifications');">
                            <i class="bi bi-bell"></i>
                            Notifications
                        </a>

                        <a href="javascript:void(0)" onclick="return comingSoon('Profile Settings');">
                            <i class="bi bi-gear"></i>
                            Profile Settings
                        </a>

                        <a href="${pageContext.request.contextPath}/logout" class="dropdown-logout">
                            <i class="bi bi-box-arrow-right"></i>
                            Logout
                        </a>

                    </div>

                </div>

                <a href="${pageContext.request.contextPath}/logout" class="admin-logout-btn">
                    <i class="bi bi-power"></i>
                    Logout
                </a>

            </div>

        </header>

        <section class="admin-content">

            <div class="admin-page-heading">
                <div>
                    <h1>My Profile</h1>
                    <p>Your personal admin account information.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin" class="admin-export-btn">
                    <i class="bi bi-arrow-left"></i>
                    Back to Dashboard
                </a>
            </div>

            <!-- Hero / summary card (all REAL data) -->
            <div class="ap-hero">

                <div class="ap-hero-left">
                    <div class="ap-avatar-wrap">
                        <div class="ap-avatar">${adminInitial}</div>
                        <span class="ap-avatar-badge"><i class="bi bi-check-lg"></i></span>
                    </div>

                    <div class="ap-hero-info">
                        <div class="ap-hero-name-row">
                            <h2>${empty adminFullName ? "-" : adminFullName}</h2>
                            <span class="ap-role-pill">${adminRole == "ADMIN" ? "Administrator" : adminRole}</span>
                        </div>

                        <div class="ap-hero-meta">
                            <span><i class="bi bi-envelope"></i> ${empty adminEmail ? "-" : adminEmail}</span>
                            <span><i class="bi bi-telephone"></i> ${empty adminPhone ? "-" : adminPhone}</span>
                            <span>
                                <i class="bi bi-calendar-check"></i> Joined on ${dummyJoinedDate}
                                <em class="ap-dummy-tag" title="Demo value">(demo)</em>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="ap-hero-right">
                    <div class="ap-hero-stat">
                        <i class="bi bi-person-vcard"></i>
                        <div>
                            <small>Admin ID</small>
                            <b>${empty adminId ? "-" : adminId}</b>
                        </div>
                    </div>

                    <div class="ap-hero-stat">
                        <i class="bi bi-shield-lock"></i>
                        <div>
                            <small>Role</small>
                            <b>${empty adminRole ? "-" : adminRole}</b>
                        </div>
                    </div>
                </div>

            </div>

            <div class="myacc-details-grid">

                <div>

                    <!-- Personal Information: mostly REAL data, 3 dummy rows clearly marked -->
                    <div class="myacc-panel">

                        <div class="myacc-panel-head" style="display:flex;justify-content:space-between;align-items:center;">
                            <h3><i class="bi bi-person-lines-fill"></i> Personal Information</h3>

                            <button type="button" class="admin-export-btn" onclick="return comingSoon('Edit Profile');">
                                <i class="bi bi-pencil"></i>
                                Edit Profile
                            </button>
                        </div>

                        <div class="myacc-info-row">
                            <span>Full Name</span>
                            <b>${empty adminFullName ? "-" : adminFullName}</b>
                        </div>

                        <div class="myacc-info-row">
                            <span>Email Address</span>
                            <b>${empty adminEmail ? "-" : adminEmail}</b>
                        </div>

                        <div class="myacc-info-row">
                            <span>Phone Number</span>
                            <b>${empty adminPhone ? "-" : adminPhone}</b>
                        </div>

                        <div class="myacc-info-row">
                            <span>Date of Birth</span>
                            <b>${empty adminDob ? "-" : adminDob}</b>
                        </div>

                        <div class="myacc-info-row">
                            <span>Address</span>
                            <b>${empty adminAddress ? "-" : adminAddress}</b>
                        </div>

                        <div class="myacc-info-row">
                            <span>Employee ID</span>
                            <b>${dummyEmployeeId}</b>
                        </div>

                        <div class="myacc-info-row">
                            <span>Department</span>
                            <b>${dummyDepartment}</b>
                        </div>

                        <div class="ap-dummy-note">
                            <i class="bi bi-info-circle"></i>
                            <span>This is dummy data. Actual information will be added soon.</span>
                        </div>

                    </div>

                    <div class="myacc-panel">

                        <div class="myacc-panel-head">
                            <h3><i class="bi bi-lightning-charge"></i> Quick Actions</h3>
                        </div>

                        <div class="ap-quick-actions">

                            <a href="${pageContext.request.contextPath}/admin/change-password" class="ap-quick-action">
                                <i class="bi bi-key"></i>
                                <span>Change Password</span>
                            </a>

                            <a href="javascript:void(0)" class="ap-quick-action" onclick="return comingSoon('Security Settings');">
                                <i class="bi bi-shield-check"></i>
                                <span>Security Settings</span>
                            </a>

                            <a href="javascript:void(0)" class="ap-quick-action" onclick="return comingSoon('Notification Settings');">
                                <i class="bi bi-bell"></i>
                                <span>Notification Settings</span>
                            </a>

                            <a href="javascript:void(0)" class="ap-quick-action" onclick="return comingSoon('Activity Log');">
                                <i class="bi bi-clock-history"></i>
                                <span>Activity Log</span>
                            </a>

                        </div>

                    </div>

                </div>

                <div>

                    <!-- Security Information: fully dummy, clearly disclaimed -->
                    <div class="myacc-panel">

                        <div class="myacc-panel-head">
                            <h3><i class="bi bi-shield-lock"></i> Security Information</h3>
                        </div>

                        <div class="myacc-info-row">
                            <span>Last Login</span>
                            <b>${dummyLastLogin}</b>
                        </div>

                        <div class="myacc-info-row">
                            <span>Password Last Changed</span>
                            <b>${dummyPasswordChanged}</b>
                        </div>

                        <div class="myacc-info-row">
                            <span>Two Factor Authentication</span>
                            <span class="ap-status-pill">${dummyTwoFactorStatus}</span>
                        </div>

                        <div class="myacc-info-row">
                            <span>Login Status</span>
                            <span class="ap-status-pill">${dummyLoginStatus}</span>
                        </div>

                        <div class="ap-dummy-note">
                            <i class="bi bi-info-circle"></i>
                            <span>This is dummy data. Actual security tracking will be available soon.</span>
                        </div>

                    </div>

                    <!-- Recent Login Activity: fully dummy, clearly disclaimed -->
                    <div class="myacc-panel">

                        <div class="myacc-panel-head" style="display:flex;justify-content:space-between;align-items:center;">
                            <h3><i class="bi bi-clock-history"></i> Recent Login Activity</h3>

                            <a href="javascript:void(0)" onclick="return comingSoon('Login Activity');" style="font-size:0.85rem;">
                                View All
                            </a>
                        </div>

                        ${loginActivityHtml}

                        <div class="ap-dummy-note">
                            <i class="bi bi-info-circle"></i>
                            <span>This is dummy login activity. Real login history will be displayed soon.</span>
                        </div>

                    </div>

                </div>

            </div>

        </section>

    </main>

</div>

<div class="dks-popup-overlay" id="dksComingOverlay">
    <div class="dks-popup-box">

        <button type="button" class="dks-popup-close" onclick="closeComingSoon()">
            <i class="bi bi-x-lg"></i>
        </button>

        <div class="dks-popup-icon">
            <i class="bi bi-hourglass-split"></i>
        </div>

        <h2>Coming Soon!</h2>

        <p>
            <span id="dksComingFeature">This feature</span>
            is currently under development.
        </p>

        <button type="button" class="dks-popup-ok" onclick="closeComingSoon()">
            OK
        </button>

    </div>
</div>

<script>
    function comingSoon(featureName) {
        const overlay = document.getElementById("dksComingOverlay");
        const feature = document.getElementById("dksComingFeature");

        if (feature) {
            feature.textContent = featureName || "This feature";
        }

        if (overlay) {
            overlay.classList.add("show");
        }

        return false;
    }

    function closeComingSoon() {
        const overlay = document.getElementById("dksComingOverlay");

        if (overlay) {
            overlay.classList.remove("show");
        }
    }

    function toggleAdminProfileDropdown() {
        const dropdown = document.getElementById("adminProfileDropdown");

        if (dropdown) {
            dropdown.classList.toggle("show");
        }
    }

    document.addEventListener("click", function (event) {
        if (!event.target.closest(".profile-menu")) {
            const dropdown = document.getElementById("adminProfileDropdown");

            if (dropdown && dropdown.classList.contains("show")) {
                dropdown.classList.remove("show");
            }
        }
    });
</script>

</body>
</html>
