<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.bank.model.User" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%!
    private String safe(Object value) {
        if (value == null) {
            return "";
        }

        String text = String.valueOf(value);

        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;");
    }

    private String getValue(Map<String, Object> map, String key1, String key2, String key3) {
        if (map == null) {
            return "";
        }

        Object value = map.get(key1);

        if (value == null && key2 != null) {
            value = map.get(key2);
        }

        if (value == null && key3 != null) {
            value = map.get(key3);
        }

        return safe(value);
    }

    private String formatDate(Object value) {
        if (value == null) {
            return "";
        }

        try {
            if (value instanceof java.util.Date) {
                SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
                return sdf.format((java.util.Date) value);
            }
        } catch (Exception e) {
            return String.valueOf(value);
        }

        return String.valueOf(value).replace(".0", "");
    }
%>

<%
    User admin = (User) session.getAttribute("user");

    if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = admin.getFullName() != null ? admin.getFullName() : "Admin";
    String adminInitial = fullName.trim().length() > 0 ? fullName.trim().substring(0, 1).toUpperCase() : "A";

    List<Map<String, Object>> logs = (List<Map<String, Object>>) request.getAttribute("logs");

    int totalLogs = 0;
    int accountStatusLogs = 0;
    int activeLogs = 0;
    int frozenLogs = 0;

    if (logs != null) {
        totalLogs = logs.size();

        for (Map<String, Object> log : logs) {
            String action = String.valueOf(log.get("action"));
            String description = String.valueOf(log.get("description")).toUpperCase();

            if ("ACCOUNT_STATUS".equalsIgnoreCase(action)) {
                accountStatusLogs++;
            }

            if (description.contains("ACTIVE")) {
                activeLogs++;
            }

            if (description.contains("FROZEN")) {
                frozenLogs++;
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Audit Logs - DKS Bank</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/oldStyle.css?v=207">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>

<body>

<div class="admin-page audit-page">

    <div class="audit-header">

        <div class="audit-title-box">
            <h1>Audit Logs</h1>
            <p>Track admin activities, account status changes, and system actions.</p>
        </div>

        <div class="audit-header-actions">

            <div class="audit-admin-chip">
                <span><%= adminInitial %></span>
                <div>
                    <small>Logged in as</small>
                    <strong><%= fullName %></strong>
                </div>
            </div>

            <a class="audit-dashboard-btn" href="${pageContext.request.contextPath}/admin">
                <i class="bi bi-arrow-left"></i>
                Dashboard
            </a>

        </div>

    </div>

    <div class="audit-stats-grid">

        <div class="audit-stat-card">
            <div class="audit-stat-icon total">
                <i class="bi bi-list-check"></i>
            </div>
            <div>
                <h4>Total Logs</h4>
                <h2><%= totalLogs %></h2>
                <p>All recorded actions</p>
            </div>
        </div>

        <div class="audit-stat-card">
            <div class="audit-stat-icon status">
                <i class="bi bi-shield-check"></i>
            </div>
            <div>
                <h4>Status Actions</h4>
                <h2><%= accountStatusLogs %></h2>
                <p>Account status updates</p>
            </div>
        </div>

        <div class="audit-stat-card">
            <div class="audit-stat-icon active">
                <i class="bi bi-unlock"></i>
            </div>
            <div>
                <h4>Activated</h4>
                <h2><%= activeLogs %></h2>
                <p>Changed to active</p>
            </div>
        </div>

        <div class="audit-stat-card">
            <div class="audit-stat-icon frozen">
                <i class="bi bi-lock"></i>
            </div>
            <div>
                <h4>Frozen</h4>
                <h2><%= frozenLogs %></h2>
                <p>Changed to frozen</p>
            </div>
        </div>

    </div>

    <div class="audit-main-card">

        <div class="audit-section-head">

            <div>
                <h2>Activity Timeline</h2>
                <p>Recent admin activities are shown below.</p>
            </div>

            <div class="audit-search-box">
                <i class="bi bi-search"></i>
                <input type="text"
                       id="auditSearchInput"
                       placeholder="Search by ID, action, description, date..."
                       onkeyup="filterAuditTable()">
            </div>

        </div>

        <div class="audit-table-wrap">

            <table class="audit-table" id="auditLogTable">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Action</th>
                    <th>Description</th>
                    <th>Status</th>
                    <th>Date / Time</th>
                </tr>
                </thead>

                <tbody>
                <%
                    if (logs != null && !logs.isEmpty()) {
                        for (Map<String, Object> log : logs) {

                            String logId = getValue(log, "log_id", "id", null);
                            String action = getValue(log, "action", null, null);
                            String description = getValue(log, "description", null, null);
                            String dateTime = formatDate(log.get("created_at"));

                            if (dateTime == null || dateTime.trim().isEmpty()) {
                                dateTime = formatDate(log.get("createdAt"));
                            }

                            String upperDescription = description.toUpperCase();

                            String statusText = "INFO";
                            String statusClass = "audit-status-badge audit-status-info";

                            if (upperDescription.contains("FROZEN")) {
                                statusText = "FROZEN";
                                statusClass = "audit-status-badge audit-status-frozen";
                            } else if (upperDescription.contains("ACTIVE")) {
                                statusText = "ACTIVE";
                                statusClass = "audit-status-badge audit-status-active";
                            }

                            String actionIcon = "bi bi-activity";

                            if ("ACCOUNT_STATUS".equalsIgnoreCase(action)) {
                                actionIcon = "bi bi-shield-lock";
                            } else if (action.toUpperCase().contains("BALANCE")) {
                                actionIcon = "bi bi-cash-stack";
                            } else if (action.toUpperCase().contains("USER")) {
                                actionIcon = "bi bi-person-plus";
                            }
                %>

                <tr>
                    <td>
                        <span class="audit-id">#<%= logId %></span>
                    </td>

                    <td>
                        <span class="audit-action-badge">
                            <i class="<%= actionIcon %>"></i>
                            <%= action %>
                        </span>
                    </td>

                    <td>
                        <div class="audit-description">
                            <i class="bi bi-file-text"></i>
                            <span><%= description %></span>
                        </div>
                    </td>

                    <td>
                        <span class="<%= statusClass %>"><%= statusText %></span>
                    </td>

                    <td>
                        <div class="audit-date">
                            <i class="bi bi-calendar-event"></i>
                            <span><%= dateTime %></span>
                        </div>
                    </td>
                </tr>

                <%
                        }
                    } else {
                %>

                <tr>
                    <td colspan="5" class="audit-empty-row">
                        <i class="bi bi-journal-x"></i>
                        <span>No audit logs found.</span>
                    </td>
                </tr>

                <%
                    }
                %>
                </tbody>
            </table>

        </div>

    </div>

</div>

<script>
    function filterAuditTable() {
        const input = document.getElementById("auditSearchInput");
        const filter = input.value.toLowerCase();
        const table = document.getElementById("auditLogTable");
        const rows = table.getElementsByTagName("tr");

        for (let i = 1; i < rows.length; i++) {
            const rowText = rows[i].innerText.toLowerCase();

            if (rowText.indexOf("no audit logs found") !== -1) {
                continue;
            }

            rows[i].style.display = rowText.includes(filter) ? "" : "none";
        }
    }
</script>

</body>
</html>