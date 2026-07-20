# 🏦 Banking Management System

![Java](https://img.shields.io/badge/Java-17_LTS-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![Jakarta EE](https://img.shields.io/badge/Jakarta_EE-Servlets_&_JSP-005C84?style=for-the-badge&logo=jakartaee&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Apache Tomcat](https://img.shields.io/badge/Apache_Tomcat-10.1-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black)
![Maven](https://img.shields.io/badge/Maven-Build_Tool-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Multi--Stage_Build-2496ED?style=for-the-badge&logo=docker&logoColor=white)

A full-stack, Java-based online banking web application — built with **Servlets, JSP, and JDBC**, backed by **MySQL/TiDB**, and deployed live on **Render**.

It digitizes the core retail-banking workflow end to end: OTP-verified digital account opening, online-banking activation, secure login, atomic fund transfers, transaction history, PDF mini-statements, and a full administrative back office for customer, account, and transaction management.

---

## 🚀 Live Deployment

> ### 🔗 **Live Website: [DKS_Online_Banking_System](https://dks-java-webapp-101.onrender.com)**

The application is fully deployed and publicly accessible — not just a local demo.

|**Sub** |**Links** |
|---|---|
| **Live URL** | [DKS_Online_Banking_System](https://dks-java-webapp-101.onrender.com) |
| **Application Hosting** | [Render](https://render.com) |
| **Database** | [TiDB Cloud](https://tidbcloud.com) (MySQL-compatible, serverless) |
| **Status** | 🟢 Live |

The app connects to the database purely through environment variables (see [Environment Variables](#-environment-variables) below) — there is no hardcoded host, username, or password anywhere in the source code, so the exact same codebase can be pointed at a local MySQL instance, TiDB Cloud, or any other MySQL-compatible database just by changing env vars. This is what makes the Render + TiDB deployment possible without modifying a single line of code.

---

## ✨ Key Features

- 🆔 **Digital Account Opening** — auto-generated Customer ID and Account Number
- 📧 **Email OTP Verification** — email is verified with a time-limited OTP (5-minute validity, 30s resend cooldown) before an account-opening request is accepted
- 💳 **Simulated UPI Payment Step** — the account-opening flow runs through a clearly-labeled demo payment page before the account is actually provisioned
- 🔐 **Two-Step Online Banking Activation** — physical account opening kept separate from digital activation
- 👥 **Role-Based Login** — a single login gateway routes customers and admins to their own dashboards
- 💸 **Atomic Fund Transfers** — debit, credit, and ledger entry execute inside one database transaction; a failure anywhere rolls the whole transfer back
- 🔎 **Real-Time Receiver Verification** — AJAX lookup confirms the receiver's identity before a transfer is submitted
- 📄 **Transaction History & PDF Mini Statements** — paginated Debit/Credit history, plus a downloadable statement (OpenPDF)
- 🔑 **Forgot / Reset Password** — SecureRandom token, hashed at rest, single-use, expiring, with rate-limiting and no account-existence leakage
- 🛠️ **Admin Console** — search/manage customers, accounts, and transactions from one place
- ❄️ **Freeze / Unfreeze Accounts** and **Manual Balance Addition**
- ➕ **Add User** — activate online banking for an existing customer (auto-generated temp password, emailed) or create a new admin account
- 📊 **Reports & CSV Export**, plus an **Audit Log** of sensitive admin/customer actions
- ☁️ **Live Cloud Deployment** on Render (Docker + Tomcat 10.1), with a TiDB-compatible MySQL database

---

## 🧰 Tech Stack

| Layer | Technology |
|------|------------|
| Language | ![Java](https://img.shields.io/badge/Java-17%20LTS-orange?style=flat-square&logo=openjdk&logoColor=white) |
| Web Layer | ![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-Servlets%206%20%26%20JSP%203.1-00599C?style=flat-square&logo=eclipseide&logoColor=white) |
| Data Access | ![JDBC](https://img.shields.io/badge/JDBC-PreparedStatement-4B8BBE?style=flat-square&logo=java&logoColor=white) |
| Database | ![MySQL](https://img.shields.io/badge/MySQL%208%20%2F%20TiDB%20Cloud-MySQL%20Compatible-4479A1?style=flat-square&logo=mysql&logoColor=white) |
| Local Development | ![XAMPP](https://img.shields.io/badge/XAMPP-Local%20MySQL%20Server-FB7A24?style=flat-square&logo=xampp&logoColor=white) |
| Build Tool | ![Maven](https://img.shields.io/badge/Maven-Build%20Tool-C71A36?style=flat-square&logo=apachemaven&logoColor=white) |
| Security | ![BCrypt](https://img.shields.io/badge/jBCrypt-Password%20Hashing-6E4C13?style=flat-square) |
| Email / OTP | ![Brevo](https://img.shields.io/badge/Brevo-Transactional%20Email%20API-0B996E?style=flat-square) (HTTPS API via `java.net.http.HttpClient`) |
| PDF Generation | ![OpenPDF](https://img.shields.io/badge/OpenPDF-PDF%20Generation-0A7B83?style=flat-square) |
| Front-End | ![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white) ![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=flat-square&logo=css3&logoColor=white) ![JavaScript](https://img.shields.io/badge/JavaScript-AJAX-F7DF1E?style=flat-square&logo=javascript&logoColor=black) |
| Containerization | ![Docker](https://img.shields.io/badge/Docker-Multi--Stage%20Build-2496ED?style=flat-square&logo=docker&logoColor=white) |
| Hosting | ![Render](https://img.shields.io/badge/Render-Hosting-46E3B7?style=flat-square&logo=render&logoColor=black) |

---

## 🏗️ Project Architecture (MVC)

The application follows a layered, MVC-inspired architecture:

```
Browser
   │
   ▼
JSP (View)  ───────────────►  Servlet (Controller)
                                     │
                                     ▼
                              DAO (Data Access / JDBC)
                                     │
                                     ▼
                            MySQL / TiDB Database
```

- **`controller/`** — Servlets, one per route/action, grouped by domain: `auth`, `account`, `transaction`, `admin`, `payment`, `verification`, `general` (e.g. `LoginServlet`, `TransferServlet`, `AdminServlet`, `ProcessUpiPaymentServlet`)
- **`dao/`** — every SQL statement in the app, using parameterized `PreparedStatement`s (`UserDAO`, `AccountDAO`, `TransactionDAO`, `AdminDAO`, `AdminReportDAO`, `OtpDAO`, `PasswordResetDAO`, `PaymentDAO`)
- **`model/`** — plain data classes (`User`, `Account`, `Transaction`, `Payment`, `OtpVerification`, `PasswordResetToken`, `RegistrationInfo`, `AccountOpenResult`, `ActivationResult`)
- **`util/`** — `DBConnection.java` (environment-variable-driven connection factory), `PasswordUtil.java` (BCrypt + token hashing), `AdminAuth.java` (admin session gating), `AuditLogger.java`, `EmailService.java`
- **`setup/`** — `DatabaseSetup.java` (one-time, idempotent schema creation + interactive first-admin seeding)

---

## 🔄 Workflow

**Customer flow:**

```
Open Account form  →  Verify Email (OTP)  →  Submit  →  Simulated UPI Payment  →  Account Created
     │
     ▼
Register for Online Banking (set password)  →  Login
     │
     ▼
Dashboard  →  Fund Transfer → Confirm Transfer → Success
     │
     ├──►  Transaction History  →  Mini Statement (PDF)
     ├──►  My Account / Profile Overview  /  Change Password
     ├──►  Forgot Password  →  Emailed Reset Link  →  Reset Password
     └──►  Logout
```

**Admin flow:**

```
Login as Admin  →  Admin Dashboard
     │
     ├──►  Customer / Account / Transaction Management (search & listing)
     ├──►  Add User (activate customer online banking, or create new admin)
     ├──►  Freeze / Unfreeze Account   │   Add Balance
     ├──►  Reports & Generate Report (CSV export)
     ├──►  Audit Logs
     ├──►  Admin Profile / Change Password
     └──►  Logout
```

---

## ⚙️ Installation & Setup Guide

Before building, make sure the following are installed:

- Java 17+
- Maven
- MySQL-compatible database (XAMPP MySQL / MySQL Server / TiDB or Aiven Cloud)
- Apache Tomcat 10.1

### 1. Clone Repository

```bash
git clone https://github.com/jeetsutradhar009/Banking_Management_System.git
cd Banking_Management_System
```

### 2. Build Project

Run:

```bash
mvn clean package
```

This will download dependencies, compile the project, and generate:

```
target/OnlineBankingSystem.war
```

### 3. Database Setup

Before initializing the database, configure the database connection according to your environment.

**Using default XAMPP MySQL?**

No environment variables are required. The application will automatically use the default local configuration:

```
URL: jdbc:mysql://localhost:3306/dks_banking
Username: root
Password: empty
```

**Using Custom MySQL / TiDB or Aiven Cloud?**

Set the following environment variables before running the database setup:

```powershell
$env:DB_URL="your_database_url"
$env:DB_USERNAME="your_username"
$env:DB_PASSWORD="your_password"
```

After configuring the database connection, initialize the database:

```bash
mvn exec:java
```

This runs `com.bank.setup.DatabaseSetup`, which will:

- Create the database schema
- Create required tables: `users`, `accounts`, `transactions`, `payments`, `otp_verifications`, `password_reset_tokens`, `audit_logs`
- Ask for initial admin details through the terminal
- Insert the first admin account

---

### Database Setup Fallback (Optional)

If `DatabaseSetup.java` fails for any reason (JDBC driver issue, incorrect environment variables, connection problem, etc.), manually initialize the database using `database_setup.sql`:

1. Open `database_setup.sql` in any MySQL-compatible SQL editor (TiDB Cloud SQL Editor / MySQL Workbench / phpMyAdmin).
2. Run the complete SQL file from top to bottom. It creates the schema, required tables, and schema migrations.

**Admin Account Note:** the SQL fallback file does **not** automatically create an admin account. If you use only the SQL setup, manually insert the admin record using the commented template at the bottom of `database_setup.sql`.

### 4. Configure Email (Brevo API / OTP)

Copy `src/main/resources/email.properties.example` to `email.properties` and fill in your real Brevo values, **or** set the equivalent environment variables (see below — environment variables always take priority over the properties file).

Emails (OTP, password reset, account/activation notifications) are sent via [Brevo's](https://brevo.com) transactional email HTTPS API — not SMTP. This is a deliberate choice: several free-tier hosts (including Render's free web services) block outbound SMTP ports (25/465/587), but plain HTTPS calls on port 443 are never blocked. Only a single verified sender email is required — no custom domain purchase/verification needed, and emails can be sent to any recipient.

1. Create a free account at [brevo.com](https://brevo.com).
2. Under **Senders, Domains & Dedicated IPs**, add and verify your sending email address (a verification link is emailed to it).
3. Under **SMTP & API → API Keys**, generate a new API key.
4. Set `BREVO_API_KEY` to that key, and `EMAIL_FROM_ADDRESS` to the verified sender email (see Environment Variables below).

After database and email are configured, run the application using **Apache Tomcat 10.1**, or build/run the included `Dockerfile`.

---

## 🔑 Environment Variables

| Variable | Purpose | Example |
|---|---|---|
| `DB_URL` | JDBC connection string | `jdbc:mysql://host:4000/dks_banking?sslMode=VERIFY_IDENTITY` |
| `DB_USERNAME` | Database username | `your_db_user` |
| `DB_PASSWORD` | Database password | `••••••••` |
| `BREVO_API_KEY` | Brevo transactional email API key | `xkeysib-••••••••••••••••` |
| `EMAIL_FROM_ADDRESS` | Verified Brevo sender email | `your_bank_email@gmail.com` |
| `EMAIL_FROM_NAME` | "From" display name (optional) | `DKS Bank` |
| `PASSWORD_RESET_TOKEN_VALIDITY_MINUTES` | Reset token validity window (optional) | `10` |

None of these have hardcoded fallbacks pointing at a real database or mailbox in production — local development only falls back to a plain `localhost` MySQL default (and to `email.properties`, if present) so the app can still boot without full configuration during early development.

---

## 📁 Project Structure

```
Banking_Management_System/
├── pom.xml
├── Dockerfile
├── database_setup.sql
├── src/main/java/com/bank/
│   ├── controller/
│   │   ├── auth/           → LoginServlet, RegisterServlet, LogoutServlet,
│   │   │                      ForgotPasswordServlet, ResetPasswordServlet
│   │   ├── account/        → DashboardServlet, MyAccountServlet, OpenAccountServlet,
│   │   │                      ChangePasswordServlet, ProfileOverviewServlet, CreateAccountServlet
│   │   ├── transaction/    → TransferServlet, ConfirmTransferServlet, TransactionHistoryServlet,
│   │   │                      MiniStatementServlet, CheckAccountServlet, CustomerLookupServlet
│   │   ├── admin/          → AdminServlet, AdminUsersServlet, AdminAccountsServlet,
│   │   │                      FreezeAccountServlet, AddBalanceServlet, AddUserServlet,
│   │   │                      GenerateReportServlet, AuditLogsServlet, and more
│   │   ├── payment/        → PaymentServlet, ProcessUpiPaymentServlet (demo simulation)
│   │   ├── verification/   → SendEmailVerificationServlet, VerifyEmailOtpServlet, ResendEmailOtpServlet
│   │   └── general/        → ServicesServlet
│   ├── dao/                 → UserDAO, AccountDAO, TransactionDAO, AdminDAO, AdminReportDAO,
│   │                           OtpDAO, PasswordResetDAO, PaymentDAO
│   ├── model/                → User, Account, Transaction, Payment, OtpVerification,
│   │                            PasswordResetToken, RegistrationInfo, AccountOpenResult, ActivationResult
│   ├── util/                  → DBConnection, PasswordUtil, AdminAuth, AuditLogger, EmailService
│   └── setup/                 → DatabaseSetup (database initialization & admin setup)
└── src/main/webapp/
    ├── *.jsp              → index.jsp
    ├── css/                → Stylesheets
    └── WEB-INF/             → web.xml, shared nav, views/ (auth, user, transaction, admin, payment, verification, common)
```

---

## 👨‍💻 Developer

**Dipankar Sutradhar**
[GitHub](https://github.com/jeetsutradhar009)

⭐ Star the repository if you found it useful.