<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bank.model.User" %>

<%
    User navUser = (User) session.getAttribute("user");
    String navName = navUser != null ? navUser.getFullName() : "User";
%>

<div class="app-layout">

    <aside class="sidebar">
        <div class="logo">🏦 Banking System</div>

        <a href="dashboard">🏠 Dashboard</a>
        <a href="myaccount">👤 My Account</a>
        <a href="transfer">💸 Fund Transfer</a>
        <a href="history">📄 Transaction History</a>
        <a href="changePassword.jsp">🔐 Change Password</a>
        <a href="logout">🚪 Logout</a>
    </aside>

    <main class="main-panel">
        <div class="topbar">
            <strong>Welcome, <%= navName %></strong>
            <a href="logout" class="btn btn-sm btn-danger">Logout</a>
        </div>