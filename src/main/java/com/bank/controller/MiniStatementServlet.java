package com.bank.controller;

import com.bank.model.User;
import com.bank.util.DBConnection;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

import java.awt.Color;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/mini-statement", "/miniStatement", "/download-statement", "/downloadStatement"})
public class MiniStatementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Color DARK_GREEN = new Color(16, 122, 99);
    private static final Color ORANGE = new Color(247, 112, 24);
    private static final Color LIGHT_GREEN = new Color(232, 248, 243);
    private static final Color HEADER_GRAY = new Color(238, 238, 238);
    private static final Color BORDER = new Color(40, 40, 40);
    private static final Color WHITE = Color.WHITE;
    private static final Color BLACK = Color.BLACK;

    private static final DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MMM-yy");
    private static final SimpleDateFormat statementDateFormat = new SimpleDateFormat("yyyy-MM-dd");
    private static final SimpleDateFormat fileDateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        AccountInfo accountInfo = getAccountInfo(user.getUserId());

        if (accountInfo == null) {
            response.setContentType("text/html");
            response.getWriter().println("<h2>Account not found.</h2>");
            return;
        }

        List<TxnInfo> transactions = getTransactions(accountInfo.accountNumber);

        String safeAccount = accountInfo.accountNumber.replaceAll("[^a-zA-Z0-9]", "");
        String fileName = "MiniStatement_" + safeAccount + ".pdf";

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try {
            Document document = new Document(PageSize.A4, 24, 24, 25, 25);
            PdfWriter.getInstance(document, response.getOutputStream());

            document.open();

            addTopBanner(document);
            addStatementInfo(document, accountInfo);
            addTransactionTable(document, accountInfo.accountNumber, transactions);
            addFooter(document);

            document.close();

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("PDF generation failed: " + e.getMessage());
        }
    }

    private AccountInfo getAccountInfo(int userId) {
        AccountInfo accountInfo = null;

        String sql = "SELECT u.full_name, u.email, u.phone, " +
                     "a.account_number, a.account_type, a.balance " +
                     "FROM users u " +
                     "JOIN accounts a ON u.user_id = a.user_id " +
                     "WHERE u.user_id = ? " +
                     "LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                accountInfo = new AccountInfo();

                accountInfo.fullName = rs.getString("full_name");
                accountInfo.email = rs.getString("email");
                accountInfo.phone = rs.getString("phone");
                accountInfo.accountNumber = rs.getString("account_number");
                accountInfo.accountType = rs.getString("account_type");
                accountInfo.balance = rs.getDouble("balance");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return accountInfo;
    }

    private List<TxnInfo> getTransactions(String accountNumber) {
        List<TxnInfo> transactions = new ArrayList<>();

        String sql =
                "SELECT t.transaction_id, t.sender_account, t.receiver_account, t.amount, " +
                "t.status, t.transaction_date, " +
                "su.full_name AS sender_name, " +
                "ru.full_name AS receiver_name " +
                "FROM transactions t " +
                "LEFT JOIN accounts sa ON t.sender_account = sa.account_number " +
                "LEFT JOIN users su ON sa.user_id = su.user_id " +
                "LEFT JOIN accounts ra ON t.receiver_account = ra.account_number " +
                "LEFT JOIN users ru ON ra.user_id = ru.user_id " +
                "WHERE t.sender_account = ? OR t.receiver_account = ? " +
                "ORDER BY t.transaction_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, accountNumber);
            ps.setString(2, accountNumber);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                TxnInfo tx = new TxnInfo();

                tx.transactionId = rs.getInt("transaction_id");
                tx.senderAccount = rs.getString("sender_account");
                tx.receiverAccount = rs.getString("receiver_account");
                tx.amount = rs.getDouble("amount");
                tx.status = rs.getString("status");
                tx.transactionDate = rs.getTimestamp("transaction_date");
                tx.senderName = rs.getString("sender_name");
                tx.receiverName = rs.getString("receiver_name");

                if (accountNumber.equals(tx.senderAccount)) {
                    tx.type = "Dr";
                    tx.description = "TRANSFER/" + tx.transactionId + "/" + value(tx.receiverName, tx.receiverAccount);
                } else {
                    tx.type = "Cr";
                    tx.description = "TRANSFER/" + tx.transactionId + "/" + value(tx.senderName, tx.senderAccount);
                }

                transactions.add(tx);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return transactions;
    }

    private void addTopBanner(Document document) throws Exception {
        PdfPTable bannerWrapper = new PdfPTable(1);
        bannerWrapper.setWidthPercentage(58);
        bannerWrapper.setHorizontalAlignment(Element.ALIGN_CENTER);
        bannerWrapper.setSpacingAfter(8);

        PdfPCell bannerCell = new PdfPCell();
        bannerCell.setBorder(Rectangle.NO_BORDER);
        bannerCell.setBackgroundColor(DARK_GREEN);
        bannerCell.setPadding(12);

        PdfPTable banner = new PdfPTable(2);
        banner.setWidthPercentage(100);
        banner.setWidths(new float[]{1.1f, 4.4f});

        PdfPCell logoCell = new PdfPCell();
        logoCell.setBorder(Rectangle.NO_BORDER);
        logoCell.setBackgroundColor(DARK_GREEN);
        logoCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        logoCell.setVerticalAlignment(Element.ALIGN_MIDDLE);

        Font circleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 26, ORANGE);
        Paragraph circle = new Paragraph("●", circleFont);
        circle.setAlignment(Element.ALIGN_CENTER);
        logoCell.addElement(circle);

        PdfPCell textCell = new PdfPCell();
        textCell.setBorder(Rectangle.NO_BORDER);
        textCell.setBackgroundColor(DARK_GREEN);
        textCell.setVerticalAlignment(Element.ALIGN_MIDDLE);

        Font bankFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 27, WHITE);
        Font passbookFont = FontFactory.getFont(FontFactory.HELVETICA_BOLDOBLIQUE, 16, new Color(230, 255, 248));

        Paragraph bankName = new Paragraph("DKS BANK", bankFont);
        bankName.setLeading(26);

        Paragraph passbook = new Paragraph("mPassbook", passbookFont);
        passbook.setLeading(18);

        textCell.addElement(bankName);
        textCell.addElement(passbook);

        banner.addCell(logoCell);
        banner.addCell(textCell);

        bannerCell.addElement(banner);
        bannerWrapper.addCell(bannerCell);

        document.add(bannerWrapper);

        Font titleFont = FontFactory.getFont(FontFactory.HELVETICA, 13, BLACK);
        Paragraph title = new Paragraph("Transaction Statement", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(6);
        document.add(title);
    }

    private void addStatementInfo(Document document, AccountInfo accountInfo) throws Exception {
        Font labelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, BLACK);

        Paragraph account = new Paragraph("Account Number : " + value(accountInfo.accountNumber, "-"), labelFont);
        account.setSpacingAfter(3);
        document.add(account);

        Paragraph date = new Paragraph("Date : " + statementDateFormat.format(new Date()), labelFont);
        date.setSpacingAfter(3);
        document.add(date);

        Paragraph currency = new Paragraph("Currency : INR", labelFont);
        currency.setSpacingAfter(8);
        document.add(currency);
    }

    private void addTransactionTable(Document document, String accountNumber, List<TxnInfo> transactions) throws Exception {
        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{0.7f, 1.6f, 6.0f, 1.3f, 0.8f});
        table.setHeaderRows(1);

        addHeaderCell(table, "Sr");
        addHeaderCell(table, "Date");
        addHeaderCell(table, "Description");
        addHeaderCell(table, "Amount");
        addHeaderCell(table, "Type");

        Font cellFont = FontFactory.getFont(FontFactory.HELVETICA, 8.2f, BLACK);
        Font debitFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8.2f, new Color(180, 35, 35));
        Font creditFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8.2f, new Color(0, 130, 65));

        if (transactions == null || transactions.isEmpty()) {
            PdfPCell empty = new PdfPCell(new Phrase("No transactions found.", cellFont));
            empty.setColspan(5);
            empty.setPadding(8);
            empty.setHorizontalAlignment(Element.ALIGN_CENTER);
            empty.setBorderColor(BORDER);
            table.addCell(empty);
        } else {
            int sr = 1;

            for (TxnInfo tx : transactions) {
                String dateText = tx.transactionDate != null ? dateFormat.format(tx.transactionDate).toUpperCase() : "-";
                String amountText = moneyFormat.format(tx.amount);

                Font amountFont = "Cr".equalsIgnoreCase(tx.type) ? creditFont : debitFont;

                addBodyCell(table, sr + ".", cellFont, Element.ALIGN_CENTER);
                addBodyCell(table, dateText, cellFont, Element.ALIGN_CENTER);
                addBodyCell(table, value(tx.description, "-"), cellFont, Element.ALIGN_LEFT);
                addBodyCell(table, amountText, amountFont, Element.ALIGN_RIGHT);
                addBodyCell(table, tx.type, amountFont, Element.ALIGN_CENTER);

                sr++;
            }
        }

        document.add(table);
    }

    private void addFooter(Document document) throws Exception {
        Font footerFont = FontFactory.getFont(FontFactory.HELVETICA, 10, BLACK);

        Paragraph footer = new Paragraph("This is a computer-generated mini statement.", footerFont);
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setSpacingBefore(18);

        document.add(footer);
    }

    private void addHeaderCell(PdfPTable table, String text) {
        Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, BLACK);

        PdfPCell cell = new PdfPCell(new Phrase(text, headerFont));
        cell.setBackgroundColor(HEADER_GRAY);
        cell.setPadding(5);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setBorderColor(BORDER);

        table.addCell(cell);
    }

    private void addBodyCell(PdfPTable table, String text, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(4);
        cell.setHorizontalAlignment(align);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setBorderColor(BORDER);

        table.addCell(cell);
    }

    private String value(String text, String fallback) {
        if (text == null || text.trim().isEmpty()) {
            return fallback;
        }

        return text;
    }

    private static class AccountInfo {
        private String fullName;
        private String email;
        private String phone;
        private String accountNumber;
        private String accountType;
        private double balance;
    }

    private static class TxnInfo {
        private int transactionId;
        private String senderAccount;
        private String receiverAccount;
        private String senderName;
        private String receiverName;
        private String description;
        private String type;
        private double amount;
        private String status;
        private Timestamp transactionDate;
    }
}