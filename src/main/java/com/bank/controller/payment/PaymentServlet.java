package com.bank.controller.payment;

import com.bank.dao.PaymentDAO;
import com.bank.model.Payment;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * PaymentServlet
 *
 * Customer self-service "Open Account" flow ONLY. Shows the demo UPI
 * payment page for a given request_id (created by
 * OpenAccountServlet). The actual "Pay" simulation is a separate AJAX
 * POST handled by ProcessUpiPaymentServlet.
 *
 * The Admin "Create Account" flow never reaches this servlet.
 */
@WebServlet("/payment/demo")
public class PaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VIEW = "/WEB-INF/views/payment/payment.jsp";

    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String requestId = request.getParameter("id");

        if (requestId == null || requestId.trim().isEmpty()) {
            request.setAttribute("error", "Invalid payment link.");
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        try {
            Payment payment = paymentDAO.findByRequestId(requestId.trim());

            if (payment == null) {
                request.setAttribute("error", "Invalid or expired payment link.");
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            if ("SUCCESS".equalsIgnoreCase(payment.getStatus())) {
                request.setAttribute("alreadyCompleted", true);
            }

            String qrUrl = buildAbsoluteUrl(request, requestId.trim());

            request.setAttribute("payment", payment);
            request.setAttribute("requestId", requestId.trim());
            request.setAttribute("qrUrl", qrUrl);

            request.getRequestDispatcher(VIEW).forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Something went wrong while loading the payment page.");
            request.getRequestDispatcher(VIEW).forward(request, response);
        }
    }

    /**
     * Builds the full absolute URL to this same page, e.g.
     * "http://192.168.1.5:8080/OnlineBankingSystem/payment/demo?id=...".
     * This is what the demo QR code encodes, so scanning it with a
     * phone camera on the same network opens this exact page there -
     * same pattern already used by ForgotPasswordServlet for its
     * reset-password email link.
     */
    private String buildAbsoluteUrl(HttpServletRequest request, String requestId) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        boolean isDefaultPort =
                ("http".equalsIgnoreCase(scheme) && serverPort == 80)
                || ("https".equalsIgnoreCase(scheme) && serverPort == 443);

        String portPart = isDefaultPort ? "" : ":" + serverPort;

        return scheme + "://" + serverName + portPart + contextPath + "/payment/demo?id=" + requestId;
    }
}