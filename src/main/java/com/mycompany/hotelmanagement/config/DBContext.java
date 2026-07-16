package com.mycompany.hotelmanagement.config;

import java.sql.Connection;
import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * Lớp thiết lập kết nối cơ sở dữ liệu (Database Connection).
 * Sử dụng thư viện HikariCP Connection Pool để quản lý các kết nối SQL Server
 * tối ưu hiệu năng.
 * 
 * @author TùngNQ
 */
public class DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DBContext.class);
    private static final HikariDataSource dataSource;

    static {
        // Khởi tạo cấu hình Connection Pool với các tham số Driver, URL, tài khoản và
        // timeout
        try {
            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            config.setJdbcUrl(
                    "jdbc:sqlserver://localhost:1433;databaseName=HotelManagementDB;encrypt=true;trustServerCertificate=true;");
            config.setUsername("sa");
            config.setPassword("123");

            // Connection Pool configurations
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(5000); // 5 seconds connection timeout

            dataSource = new HikariDataSource(config);
            logger.info("HikariCP Connection Pool initialized successfully for database HotelManagementDB.");
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
     * 
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
