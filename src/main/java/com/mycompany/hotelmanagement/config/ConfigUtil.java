package com.mycompany.hotelmanagement.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Lớp tiện ích đọc các giá trị cấu hình hệ thống.
 * Hỗ trợ tìm kiếm khóa cấu hình linh hoạt từ file config.properties,
 * biến môi trường (Environment Variables) hoặc thuộc tính hệ thống (System Properties).
 * 
 * @author TùngNQ
 */
public class ConfigUtil {

    private static final Properties properties = new Properties();

    static {
        // Tự động tải file config.properties từ resources lúc khởi tạo class
        try (InputStream input = ConfigUtil.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (input != null) {
                properties.load(input);
            }
        } catch (IOException e) {
            // Ignore missing config file; fallback values will be used.
        }

        // Tải thêm cấu hình động từ database
        loadConfigFromDatabase();
    }

    private static void loadConfigFromDatabase() {
        String sql = "SELECT config_key, config_value FROM dbo.SystemConfig";
        try (java.sql.Connection conn = DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String key = rs.getString("config_key");
                String val = rs.getString("config_value");
                if (key != null && val != null) {
                    properties.setProperty(key, val);
                }
            }
            System.out.println("ConfigUtil: Loaded system configurations from database successfully.");
        } catch (Exception e) {
            System.err.println("ConfigUtil Warning: Failed to load configuration from database. Falling back to properties file. Error: " + e.getMessage());
        }
    }

    /**
     * Lấy giá trị cấu hình dựa trên khóa. Nếu không tìm thấy hoặc trống, trả về giá trị mặc định.
     *
     * @param key Khóa cấu hình (ví dụ: "smtp.host")
     * @param defaultValue Giá trị mặc định nếu không có cấu hình nào khớp
     * @return Giá trị cấu hình tìm được hoặc defaultValue
     */
    public static String get(String key, String defaultValue) {
        // 1. Try to find the exact key in config.properties
        String value = properties.getProperty(key);
        
        // 2. Try the uppercase/underscore variant in config.properties
        if (value == null || value.trim().isEmpty()) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = properties.getProperty(alternativeKey);
        }
        
        // 3. Try System.getenv for env vars
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(key);
        }
        if (value == null || value.trim().isEmpty()) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = System.getenv(alternativeKey);
        }
        
        // 4. Try System properties
        if (value == null || value.trim().isEmpty()) {
            value = System.getProperty(key);
        }
        if (value == null || value.trim().isEmpty()) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = System.getProperty(alternativeKey);
        }
        
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }

    /**
     * Lấy giá trị cấu hình dựa trên khóa, trả về null nếu không tìm thấy.
     *
     * @param key Khóa cấu hình
     * @return Giá trị cấu hình tìm được hoặc null
     */
    public static String get(String key) {
        return get(key, null);
    }

    /**
     * Nạp lại các cấu hình hệ thống từ cơ sở dữ liệu.
     */
    public static void reload() {
        loadConfigFromDatabase();
    }
}
