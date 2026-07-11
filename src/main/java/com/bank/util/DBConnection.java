package com.bank.util;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * DBConnection
 *
 * Single Responsibility: open and hand back a JDBC connection to the
 * MySQL-compatible database (TiDB Cloud in production).
 *
 * This class does NOT create databases or tables, does NOT run
 * migrations, and does NOT seed an admin user. All of that lives in
 * {@link DatabaseSetup}, which is run once, separately, before the
 * application is started for the first time.
 *
 * Connection details are read purely from environment variables so
 * the exact same code can point at a local MySQL instance, TiDB
 * Cloud, or any other MySQL-compatible database without any code
 * changes:
 *
 *   DB_URL        - full JDBC URL, e.g.
 *                    jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/online_banking?sslMode=VERIFY_IDENTITY
 *   DB_USERNAME   - database username
 *   TIDB_PASSWORD - database password
 */
public class DBConnection {
	
//	private static final String DB_NAME = "online_banking";

	private static final String DB_URL =
	        System.getenv("DB_URL") != null
	        ? System.getenv("DB_URL")
	        : "jdbc:mysql://localhost:3306/dks_banking";

	private static final String USERNAME =
	        System.getenv("DB_USERNAME") != null
	        ? System.getenv("DB_USERNAME")
	        : "root";

	private static final String PASSWORD =
	        System.getenv("DB_PASSWORD") != null
	        ? System.getenv("DB_PASSWORD")
	        : "";

    // Utility class - no instances.
    private DBConnection() {
    }

    /**
     * Opens a new JDBC connection using the DB_URL / DB_USERNAME /
     * TIDB_PASSWORD environment variables.
     *
     * @return an open {@link Connection}, or {@code null} if the
     *         connection could not be established (the underlying
     *         exception is printed to stderr).
     */
    public static Connection getConnection() {
        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(DB_URL, USERNAME, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return con;
    }
}
