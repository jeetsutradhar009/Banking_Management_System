package com.bank.util;

import com.bank.model.User;

import jakarta.servlet.http.HttpSession;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Types;

/**
 * Central place to write audit_logs rows for BOTH customer (USER) and
 * ADMIN actions, including who performed the action.
 *
 * Usage from any servlet, right after a successful state-changing action:
 *
 *     AuditLogger.log(request.getSession(false), "FUND_TRANSFER",
 *             "Transferred Rs." + amount + " to " + receiverAccount);
 *
 * If there is no logged-in user yet (e.g. Open Account, before login exists),
 * use the overload that takes a plain identifier string instead of a session.
 */
public class AuditLogger {

    /**
     * Log an action performed by whoever is logged into this session
     * (works for both USER and ADMIN sessions).
     */
    public static void log(HttpSession session, String action, String description) {
        User user = null;

        if (session != null) {
            Object obj = session.getAttribute("user");
            if (obj instanceof User) {
                user = (User) obj;
            }
        }

        log(user, action, description);
    }

    /**
     * Log an action performed by a specific, already-fetched User object.
     */
    public static void log(User user, String action, String description) {
        String actorType = "USER";
        Integer actorUserId = null;
        String actorIdentifier = null;
        String actorName = "UNKNOWN";

        if (user != null) {
            actorType = "ADMIN".equalsIgnoreCase(user.getRole()) ? "ADMIN" : "USER";
            actorUserId = user.getUserId();
            actorIdentifier = user.getCustomerId();
            actorName = user.getFullName();
        }

        insert(actorType, actorUserId, actorIdentifier, actorName, action, description);
    }

    /**
     * Log an action where there is no session yet (e.g. Open Account,
     * which happens before the customer has ever logged in).
     */
    public static void logByIdentifier(String actorIdentifier, String actorName, String action, String description) {
        insert("USER", null, actorIdentifier, actorName, action, description);
    }

    private static void insert(String actorType,
                                Integer actorUserId,
                                String actorIdentifier,
                                String actorName,
                                String action,
                                String description) {

        String sql = "INSERT INTO audit_logs(actor_type, actor_user_id, actor_identifier, actor_name, action, description) " +
                     "VALUES (?,?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, actorType);

            if (actorUserId != null) {
                ps.setInt(2, actorUserId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setString(3, actorIdentifier);
            ps.setString(4, actorName);
            ps.setString(5, action);
            ps.setString(6, description);

            ps.executeUpdate();

        } catch (Exception e) {
            // Logging must never break the actual user-facing action.
            e.printStackTrace();
        }
    }
}
