package com.ams.util;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.net.URLDecoder;
ClassNotFoundException: com.mysql.cj.jdbc.Driver.

/**
 * Central JDBC connection helper for the Asset Management System.
 *
 * Reads connection settings in order of priority:
 * 1. Environment variables (DB_DRIVER, DB_URL, DB_USER, DB_PASSWORD)
 * 2. Parsed DATABASE_URL (from Render PostgreSQL service)
 * 3. db.properties file (/WEB-INF/classes/db.properties)
 *
 * Example db.properties (PostgreSQL):
 *   db.driver=org.postgresql.Driver
 *   db.url=jdbc:postgresql://localhost:5432/ams_db
 *   db.user=postgres
 *   db.password=password
 *
 * Example Render DATABASE_URL:
 *   postgresql://user:password@host.render.com:5432/database
 */
public class DBConnection {

    private static final Properties props = new Properties();
    private static boolean driverLoaded = false;
    private static boolean databaseInitialized = false;

    private static synchronized void loadConfig() {
        if (!props.isEmpty()) return;

        // Try to load from environment variables first
        String dbDriver = System.getenv("DB_DRIVER");
        String dbUrl = System.getenv("DB_URL");
        String dbUser = System.getenv("DB_USER");
        String dbPassword = System.getenv("DB_PASSWORD");

        // If DATABASE_URL is set (Render PostgreSQL), parse it
        String databaseUrl = System.getenv("DATABASE_URL");
        if (databaseUrl != null && !databaseUrl.isEmpty() && dbUrl == null) {
            try {
                String[] parsed = parseDatabaseUrl(databaseUrl);
                dbDriver = parsed[0];
                dbUrl = parsed[1];
                dbUser = parsed[2];
                dbPassword = parsed[3];
            } catch (Exception e) {
                System.err.println("Warning: Could not parse DATABASE_URL, falling back to db.properties");
            }
        }

        // If env vars are set, use them
        if (dbDriver != null) props.setProperty("db.driver", dbDriver);
        if (dbUrl != null) props.setProperty("db.url", dbUrl);
        if (dbUser != null) props.setProperty("db.user", dbUser);
        if (dbPassword != null) props.setProperty("db.password", dbPassword);

        // If not all properties are set, load from file
        if (props.size() < 4) {
            try (InputStream in = DBConnection.class.getClassLoader()
                    .getResourceAsStream("db.properties")) {
                if (in == null) {
                    throw new RuntimeException(
                        "db.properties not found on classpath (expected at WEB-INF/classes/db.properties)");
                }
                Properties fileProps = new Properties();
                fileProps.load(in);

                // Merge with priority to env vars
                if (!props.containsKey("db.driver"))
                    props.setProperty("db.driver", fileProps.getProperty("db.driver", "org.postgresql.Driver"));
                if (!props.containsKey("db.url"))
                    props.setProperty("db.url", fileProps.getProperty("db.url", "jdbc:postgresql://localhost:5432/ams_db"));
                if (!props.containsKey("db.user"))
                    props.setProperty("db.user", fileProps.getProperty("db.user", "postgres"));
                if (!props.containsKey("db.password"))
                    props.setProperty("db.password", fileProps.getProperty("db.password", ""));

            } catch (Exception e) {
                throw new RuntimeException("Unable to load db.properties", e);
            }
        }
    }

    /**
     * Parse Render's DATABASE_URL format: postgresql://user:password@host:port/database
     * Returns array: [driver, jdbcUrl, user, password]
     */
    private static String[] parseDatabaseUrl(String databaseUrl) throws Exception {
        // Example: postgresql://user:password@host.render.com:5432/database

        String driver = "org.postgresql.Driver";
        String url, user, password;

        // Remove protocol
        if (databaseUrl.startsWith("postgresql://")) {
            databaseUrl = databaseUrl.substring("postgresql://".length());

            // Parse user:password
            int atIndex = databaseUrl.lastIndexOf("@");
            String credentials = databaseUrl.substring(0, atIndex);
            String hostPart = databaseUrl.substring(atIndex + 1);

            int colonIndex = credentials.indexOf(":");
            user = URLDecoder.decode(credentials.substring(0, colonIndex), StandardCharsets.UTF_8);
            password = URLDecoder.decode(credentials.substring(colonIndex + 1), StandardCharsets.UTF_8);

            // Build JDBC URL
            url = "jdbc:postgresql://" + hostPart;

            return new String[] { driver, url, user, password };
        } else {
            throw new RuntimeException("Unknown database URL format: " + databaseUrl);
        }
    }

    /**
     * Returns a new JDBC connection using the settings from environment variables,
     * DATABASE_URL (Render), or db.properties file (in that order of priority).
     * Callers are responsible for closing the connection (use try-with-resources).
     */
    public static Connection getConnection() throws Exception {
        loadConfig();
        if (!driverLoaded) {
            Class.forName(props.getProperty("db.driver"));
            driverLoaded = true;
        }

        String url = props.getProperty("db.url");
        String user = props.getProperty("db.user");
        String password = props.getProperty("db.password");

        System.out.println("Connecting to: " + url.replaceAll("password=.*", "password=***"));

        Connection con = DriverManager.getConnection(url, user, password);
        initializeDatabaseIfNeeded(con);
        return con;
    }

    private static synchronized void initializeDatabaseIfNeeded(Connection con) throws Exception {
        if (databaseInitialized) return;

        String init = System.getenv("DB_INIT");
        String driver = props.getProperty("db.driver", "");
        if ("false".equalsIgnoreCase(init) || !driver.toLowerCase().contains("postgresql")) {
            databaseInitialized = true;
            return;
        }

        try (InputStream in = DBConnection.class.getClassLoader()
                .getResourceAsStream("ams_schema_postgresql.sql")) {
            if (in == null) {
                throw new RuntimeException("ams_schema_postgresql.sql not found on classpath");
            }

            String schema = new String(in.readAllBytes(), StandardCharsets.UTF_8);
            for (String statement : splitSqlStatements(schema)) {
                if (!statement.trim().isEmpty()) {
                    try (Statement st = con.createStatement()) {
                        st.execute(statement);
                    }
                }
            }
        }

        databaseInitialized = true;
    }

    private static List<String> splitSqlStatements(String sql) {
        List<String> statements = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean inSingleQuote = false;

        for (int i = 0; i < sql.length(); i++) {
            char c = sql.charAt(i);
            if (c == '\'' && (i == 0 || sql.charAt(i - 1) != '\\')) {
                inSingleQuote = !inSingleQuote;
            }
            if (c == ';' && !inSingleQuote) {
                statements.add(current.toString());
                current.setLength(0);
            } else {
                current.append(c);
            }
        }
        statements.add(current.toString());
        return statements;
    }
}
