package com.mycompany.hotelmanagement.utils;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.Connection;
import java.sql.SQLException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DBContext.class);
    private static final HikariDataSource dataSource;

    static {
        try {
            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            config.setJdbcUrl("jdbc:sqlserver://localhost:1433;databaseName=HotelDB;encrypt=true;trustServerCertificate=true;");
            config.setUsername("sa");
            config.setPassword("123");

            // Connection Pool configurations
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(5000); // 5 seconds connection timeout

            dataSource = new HikariDataSource(config);
            logger.info("HikariCP Connection Pool initialized successfully for database HotelDB.");
        } catch (Exception e) {
            logger.error("Failed to initialize HikariCP Connection Pool", e);
            throw new RuntimeException("Error initializing database connection pool", e);
        }
    }

    private DBContext() {
        // Prevent instantiation
    }

    /**
     * Gets a connection from the pool.
     * @return a database Connection object
     * @throws SQLException if a connection cannot be obtained
     */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    /**
     * Closes the connection pool.
     */
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            logger.info("HikariCP Connection Pool shut down successfully.");
        }
    }
}
