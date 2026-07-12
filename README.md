# 🏦 Banking Management System

![Java](https://img.shields.io/badge/Java-17_LTS-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![Jakarta EE](https://img.shields.io/badge/Jakarta_EE-Servlets_&_JSP-005C84?style=for-the-badge&logo=jakartaee&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Apache Tomcat](https://img.shields.io/badge/Apache_Tomcat-10.1-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black)
![Maven](https://img.shields.io/badge/Maven-Build_Tool-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white)

A full-stack, Java-based online banking web application — built with **Servlets, JSP, and JDBC**, backed by **MySQL/TiDB**, and deployed live on **Render**.

It digitizes the core retail-banking workflow end to end: digital account opening, online-banking activation, secure login, atomic fund transfers, transaction history, PDF mini-statements, and a full administrative back office for customer, account, and transaction management.

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
- 🔐 **Two-Step Online Banking Activation** — physical account opening kept separate from digital activation
- 👥 **Role-Based Login** — a single login gateway routes customers and admins to their own dashboards
- 💸 **Atomic Fund Transfers** — debit, credit, and ledger entry execute inside one database transaction; a failure anywhere rolls the whole transfer back
- 🔎 **Real-Time Receiver Verification** — AJAX lookup confirms the receiver's identity before a transfer is submitted
- 📄 **Transaction History & PDF Mini Statements** — paginated Debit/Credit history, plus a downloadable statement
- 🛠️ **Admin Console** — search/manage customers, accounts, and transactions from one place
- ❄️ **Freeze / Unfreeze Accounts** and **Manual Balance Addition**
- 📊 **Reports & CSV Export**, plus an **Audit Log** of sensitive admin actions
- ☁️ **Live Cloud Deployment** on Render, with a TiDB-compatible MySQL database

---

## 🧰 Tech Stack

| Layer | Technology |
|------|------------|
| Language | ![Java](https://img.shields.io/badge/Java-17%20LTS-orange?style=flat-square&logo=openjdk&logoColor=white) |
| Web Layer | ![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-Servlets%20%26%20JSP-00599C?style=flat-square&logo=eclipseide&logoColor=white) |
| Data Access | ![JDBC](https://img.shields.io/badge/JDBC-PreparedStatement-4B8BBE?style=flat-square&logo=java&logoColor=white) |
| Database | ![MySQL](https://img.shields.io/badge/MySQL%208%20%2F%20TiDB%20Cloud-MySQL%20Compatible-4479A1?style=flat-square&logo=mysql&logoColor=white) |
| Local Development | ![XAMPP](https://img.shields.io/badge/XAMPP-Local%20MySQL%20Server-FB7A24?style=flat-square&logo=xampp&logoColor=white) |
| Build Tool | ![Maven](https://img.shields.io/badge/Maven-Build%20Tool-C71A36?style=flat-square&logo=apachemaven&logoColor=white) |
| PDF Generation | ![OpenPDF](https://img.shields.io/badge/OpenPDF-PDF%20Generation-0A7B83?style=flat-square) |
| Front-End | ![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white) ![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=flat-square&logo=css3&logoColor=white) ![JavaScript](https://img.shields.io/badge/JavaScript-AJAX-F7DF1E?style=flat-square&logo=javascript&logoColor=black) |
| Hosting | ![Render](https://img.shields.io/badge/Render-Hosting-46E3B7?style=flat-square&logo=render&logoColor=black) |

---

## 🏗️ Project Architecture(MVC)

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

- **`controller/`** — Servlets, one per route/action (e.g. `LoginServlet`, `TransferServlet`, `AdminServlet`)
- **`dao/`** — every SQL statement in the app, using parameterized `PreparedStatement`s (`UserDAO`, `AccountDAO`, `TransactionDAO`, `AdminDAO`, `AdminReportDAO`)
- **`model/`** — plain data classes (`User`, `Account`, `Transaction`, `RegistrationInfo`, `AccountOpenResult`)
- **`util/`** — `DBConnection.java` (environment-variable-driven connection factory) and `AdminAuth.java`

---

## 🔄 Workflow

**Customer flow:**

```
Open Account  →  Register for Online Banking  →  Login
     │
     ▼
Dashboard  →  Fund Transfer → Confirm Transfer → Success
     │
     ├──►  Transaction History  →  Mini Statement (PDF)
     ├──►  My Account  /  Change Password
     └──►  Logout
```

**Admin flow:**

```
Login as Admin  →  Admin Dashboard
     │
     ├──►  Customer / Account / Transaction Management
     ├──►  Add User   │   Freeze / Unfreeze Account   │   Add Balance
     ├──►  Generate Reports (with CSV export)
     ├──►  Audit Logs
     └──►  Logout
```

---

## ⚙️ Installation & Setup Guide





Before building, make sure the required tools mentioned in **`requirements.txt`** are installed:



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


### Database Configuration


**Using default XAMPP MySQL?**

No environment variables are required.

The application will automatically use the default local configuration:

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


This runs:

```
com.bank.setup.DatabaseSetup
```


The setup program will:

- Create the database schema
- Create required tables:
  - users
  - accounts
  - transactions
  - audit_logs
- Ask for initial admin details through the terminal
- Insert the first admin account details


---

### Database Setup Fallback (Optional)

Normally, the database is initialized automatically using:

```bash
mvn exec:java
```
However, if `DatabaseSetup.java` fails due to any reason such as:

- JDBC driver issue
- Incorrect environment variable configuration
- Database connection problem
- Other setup errors

you can manually initialize the database using:

```text
database_setup.sql
```


### Manual SQL Setup Steps

1. Open:

```text
database_setup.sql
```

in any MySQL-compatible SQL editor:

- TiDB Cloud SQL Editor
- MySQL Workbench
- phpMyAdmin (XAMPP)


2. Run the complete SQL file from top to bottom.


It will create:

- Database schema
- Required tables
- Schema migrations


### Admin Account Note

The SQL fallback file does not automatically create an admin account.


If you use only the SQL setup, manually insert the admin record using the commented template provided at the bottom of:

```text
database_setup.sql
```


After successful database initialization, run the application using **Apache Tomcat 10.1**.

---



## 🔑 Environment Variables

| Variable | Purpose | Example |
|---|---|---|
| `DB_URL` | JDBC connection string | `jdbc:mysql://host:4000/banking_db?sslMode=VERIFY_IDENTITY` |
| `DB_USERNAME` | Database username | `your_db_user` |
| `DB_PASSWORD` | Database password | `••••••••` |


None of these have hardcoded fallbacks pointing at a real database in production — local development only falls back to a plain `localhost` MySQL default so the app can still boot without any configuration during early development.

---

## 📁 Project Structure

```
Banking_Management_System/
├── src/main/java/com/bank/
│   ├── controller/     → Servlets (routes/actions)
│   ├── dao/             → Data access (JDBC)
│   ├── model/            → Data classes
│   ├── util/              → DBConnection, AdminAuth
│   └── setup/             → DatabaseSetup (database initialization & admin setup)
└── src/main/webapp/
    ├── *.jsp             → Views
    ├── css/               → Stylesheets
    └── WEB-INF/            → web.xml, shared nav
```

---

## 👨‍💻 Developer

**Dipankar Sutradhar**
[GitHub](https://github.com/jeetsutradhar009)

⭐ Star the repository if you found it useful.
