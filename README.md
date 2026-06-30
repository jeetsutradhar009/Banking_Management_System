# 🏦 Enterprise Online Banking System

![Java](https://img.shields.io/badge/Java-17_LTS-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![Jakarta EE](https://img.shields.io/badge/Jakarta_EE-Servlets_&_JSP-005C84?style=for-the-badge&logo=jakartaee&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Apache Tomcat](https://img.shields.io/badge/Apache_Tomcat-10.1-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black)
![Maven](https://img.shields.io/badge/Maven-Build_Tool-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white)

An enterprise-grade, framework-free web application replicating core operations of modern retail banking platforms. Built using a strict **Model-View-Controller (MVC)** design pattern, this system ensures high transaction availability, complete data isolation, and robust security logging without relying on heavy third-party backend frameworks.

Developed as a part of the **L&T Technical Training Program** at **Lamrin Tech Skills University (LTSU)**.

---

## ✨ Key Features

### 👤 Customer Workspace Portal
* **Digital Onboarding:** Open a new bank account with a minimum initial deposit (₹500 constraint).
* **Auto-Generation:** System automatically generates a secure 10-digit Customer ID, Account Number (`ACC...`), and IFSC Code.
* **Smart Fund Transfers:** Execute secure peer-to-peer transfers. Features **AJAX-based asynchronous receiver verification** to prevent sending money to incorrect accounts.
* **Real-time Passbook:** View dynamic transaction history (debits/credits) and download mini-statements.
* **Profile Security:** Secure dual-layer authentication and profile management settings.

### 🛡️ Master Admin Infrastructure Center
* **Analytics Dashboard:** Graphical distribution of banking metrics (users, account types, transaction success rates) using Chart.js.
* **Account Lifecycle Management:** Admins can instantly toggle account statuses between `ACTIVE` and `FROZEN` to mitigate fraudulent activities.
* **System Auditing:** An immutable Audit Logs panel tracking all administrative overrides and database modifications in real-time.
* **Financial Overrides:** Add balance securely directly from the admin panel.
* **Export Reports:** Generate and download raw CSV reports of system metrics.

---

## 🛠️ Technology Stack

* **Backend:** Java SE 17 LTS, Jakarta Servlets 6.0, JDBC (Java Database Connectivity)  
* **Frontend:** JavaServer Pages (JSP), HTML5, CSS3 (Custom Fluid Layouts), Vanilla JavaScript, Bootstrap Icons  
* **Database:** MySQL 8.0 (Normalized to 3NF)  
* **Server:** Apache Tomcat 10.1  
* **Build Tool & Dependency Management:** Apache Maven (`pom.xml`)  
* **Libraries:** `librepdf:openpdf` (for dynamic PDF generation), `mysql-connector-j`

---

# 🏗 Project Architecture



OnlineBankingSystem
│
├── src
│ ├── main
│ │ ├── java
│ │ │ └── com.bank
│ │ │ ├── controller
│ │ │ ├── dao
│ │ │ ├── model
│ │ │ ├── util
│ │ │ └── filter
│ │ │
│ │ ├── resources
│ │ │
│ │ └── webapp
│ │ ├── css
│ │ ├── js
│ │ ├── images
│ │ ├── admin
│ │ ├── customer
│ │ └── WEB-INF
│ │
│ └── test
│
├── database.sql
├── pom.xml
└── README.md


---

## 📂 Project Architecture (MVC)

The project adheres to a strict MVC separation, ensuring clean, scalable, and maintainable code:

* **Controllers (`com.bank.controller`):** 27 specific Servlet routers intercepting HTTP requests, parsing data, and enforcing role-based access.  
* **DAO Layer (`com.bank.dao`):** Core database execution blocks with strict ACID compliance. Utilizes manual transaction management (`con.setAutoCommit(false)`) and Row-Level Exclusive Locks (`SELECT ... FOR UPDATE`) to prevent concurrency anomalies.  
* **Model Layer (`com.bank.model`):** Encapsulated Data Transfer Objects (POJOs) mapping directly to database tables.  
* **View Layer (`src/main/webapp`):** 20+ secure `.jsp` templates hidden behind server-side data sanitization to prevent XSS.

---

## ⚙️ Installation & Setup Guide

1. **Clone the Repository**
   ```bash
   git clone https://github.com/jeetsutradhar009/Banking_Management_System.git
   cd Banking_Management_System

2. **Database Setup**
* Open XAMPP and start the **MySQL** module.
* Open phpMyAdmin (`http://localhost/phpmyadmin`).
* Create a new database named `online_banking`.
* Import the `database.sql` file provided in the root folder of the project.

3. **Configure Database Credentials**
* Navigate to `src/main/java/com/bank/util/DBConnection.java`.
* Update the `DB_USER` and `DB_PASSWORD` variables to match your local MySQL configuration.

4. **Build the Project with Maven**
* Open your terminal in the project root directory and run:
  ```bash
  mvn install

* Alternatively, in Eclipse: Right-click the project -> **Run As** -> **Maven Install**.

5. **Deploy on Tomcat**
* Add the project to your Apache Tomcat 10.1 server in Eclipse.
* Right-click the server and click **Start**.

6. **Access the Application**
* Open your web browser and go to: [http://localhost:8080/OnlineBankingSystem](http://localhost:8080/OnlineBankingSystem)

---

## 🧪 Security & Boundary Testing Implemented

* **SQL Injection Prevention:** All database queries utilize Java `PreparedStatement` to parameterize inputs and block injection vectors.
* **Concurrency Handling:** Implemented database-level `try-with-resources` and mutex locking to prevent race conditions during simultaneous fund transfers.
* **XSS Filtering:** A custom `safe()` script function on JSP views dynamically escapes special characters (e.g., `<`, `>`, `&`) before rendering user inputs.

---

## 👥 Contributors

* **DIPANKAR SUTRADHAR** - B.Tech CSE, LTSU
* **ANKUSH** - B.Tech CSE, LTSU
* **ARUN SINGH TOMAR** - B.Tech CSE, LTSU
* **MITHLESH KUMAR** - B.Tech CSE, LTSU

**Under the Guidance of:** Prof. Digvijay Puri (L&T Technical Trainer),
                           Prof. Kanchan Sharma (Cordinator,LTSU), and
                           Prof. Gagandeep Kaur (Subject Teacher, LTSU)

---
*Made with ❤️ using Java, JSP, Servlets, JDBC, Maven & MySQL.*
