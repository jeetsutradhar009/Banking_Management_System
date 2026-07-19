package com.bank.controller.admin;

import com.bank.model.User;
import com.bank.util.AdminAuth;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * "My Profile" page - shows the logged-in admin's own profile details.
 * Kept separate from AdminProfileOverviewServlet (Profile Overview) and
 * AdminChangePasswordServlet (Change Password) so each dropdown item
 * has its own dedicated URL and JSP, as requested.
 *
 * NO DATABASE SCHEMA CHANGES: every "real" attribute below comes from
 * columns that already exist on the users table (via the session
 * User object). Everything else (Joined Date, Department, Employee
 * ID, Security Information, Recent Login Activity) is UI-only dummy
 * data - clearly named with a "dummy"/"DUMMY_" prefix here, and
 * clearly disclaimed on the page itself.
 *
 * The Recent Login Activity rows are pre-built here as a plain HTML
 * string (loginActivityHtml) instead of a List looped with JSTL
 * <c:forEach> - this environment's Tomcat/Eclipse deployment doesn't
 * resolve the JSTL TLD (see JasperException: "Unable to get JAR
 * resource [...jakarta.tags.core] containing TLD"), so the JSP now
 * has zero JSTL dependency - pure EL only.
 */
@WebServlet("/admin/profile")
public class AdminProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String DUMMY_JOINED_DATE = "01 January 2026";
    private static final String DUMMY_DEPARTMENT = "IT Administration";
    private static final String DUMMY_EMPLOYEE_ID = "DKS-ADMIN-0001";

    private static final String DUMMY_LAST_LOGIN = "18 July 2026, 10:30 AM";
    private static final String DUMMY_PASSWORD_CHANGED = "15 July 2026";
    private static final String DUMMY_TWO_FACTOR_STATUS = "Enabled";
    private static final String DUMMY_LOGIN_STATUS = "Active";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AdminAuth.requireAdmin(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);
        User admin = session != null ? (User) session.getAttribute("user") : null;

        // Real data - existing users table columns, via the session User.
        request.setAttribute("adminFullName", admin != null ? admin.getFullName() : null);
        request.setAttribute("adminEmail", admin != null ? admin.getEmail() : null);
        request.setAttribute("adminPhone", admin != null ? admin.getPhone() : null);
        request.setAttribute("adminAddress", admin != null ? admin.getAddress() : null);
        request.setAttribute("adminRole", admin != null ? admin.getRole() : null);
        request.setAttribute("adminId", admin != null ? admin.getCustomerId() : null);
        request.setAttribute("adminDob", (admin != null && admin.getDob() != null) ? admin.getDob().toString() : null);

        String fullName = (admin != null && admin.getFullName() != null && !admin.getFullName().trim().isEmpty())
                ? admin.getFullName().trim()
                : "Admin";

        request.setAttribute("adminInitial", fullName.substring(0, 1).toUpperCase());

        // Dummy/UI-only data.
        request.setAttribute("dummyJoinedDate", DUMMY_JOINED_DATE);
        request.setAttribute("dummyDepartment", DUMMY_DEPARTMENT);
        request.setAttribute("dummyEmployeeId", DUMMY_EMPLOYEE_ID);

        request.setAttribute("dummyLastLogin", DUMMY_LAST_LOGIN);
        request.setAttribute("dummyPasswordChanged", DUMMY_PASSWORD_CHANGED);
        request.setAttribute("dummyTwoFactorStatus", DUMMY_TWO_FACTOR_STATUS);
        request.setAttribute("dummyLoginStatus", DUMMY_LOGIN_STATUS);

        request.setAttribute("loginActivityHtml", buildDummyLoginActivityHtml());

        request.getRequestDispatcher("/WEB-INF/views/admin/admin-profile.jsp").forward(request, response);
    }

    /**
     * Pre-builds the 3 demo "Recent Login Activity" rows as plain
     * HTML (no JSTL needed). EL's ${...} does not HTML-escape by
     * default in a plain JSP, so this renders exactly like the
     * previous JSTL <c:forEach> version did.
     */
    private String buildDummyLoginActivityHtml() {
        String[][] rows = {
                {"18 Jul 2026, 10:30 AM", "192.168.1.10 \u2022 Kolkata, India", "Current", "current"},
                {"17 Jul 2026, 08:30 PM", "192.168.1.25 \u2022 Kolkata, India", "Success", "success"},
                {"17 Jul 2026, 02:15 PM", "192.168.1.32 \u2022 Kolkata, India", "Success", "success"}
        };

        StringBuilder html = new StringBuilder();

        for (String[] row : rows) {
            html.append("<div class=\"ap-activity-item\">")
                    .append("<span class=\"ap-activity-icon\"><i class=\"bi bi-check-circle-fill\"></i></span>")
                    .append("<div class=\"ap-activity-main\">")
                    .append("<div class=\"ap-activity-top\">")
                    .append("<b>").append(row[0]).append("</b>")
                    .append("<span class=\"ap-status-pill ").append(row[3]).append("\">").append(row[2]).append("</span>")
                    .append("</div>")
                    .append("<small>").append(row[1]).append("</small>")
                    .append("</div>")
                    .append("</div>");
        }

        return html.toString();
    }
}