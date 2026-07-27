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
 * @version 1.0.1
 * Created: 24/06/2026
 * Modified: 16/07/2026
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

    /**
     * Kiểm tra một giá trị cấu hình có phải là placeholder/mặc định hay không.
     */
    public static boolean isPlaceholder(String val) {
        if (val == null || val.trim().isEmpty()) {
            return true;
        }
        String v = val.trim();
        return v.equalsIgnoreCase("YOUR_SMTP_EMAIL") ||
               v.equalsIgnoreCase("YOUR_SMTP_PASSWORD") ||
               v.equalsIgnoreCase("YOUR_GOOGLE_CLIENT_ID") ||
               v.equalsIgnoreCase("YOUR_GOOGLE_CLIENT_SECRET") ||
               v.equalsIgnoreCase("your-email@gmail.com") ||
               v.equalsIgnoreCase("your-app-password") ||
               v.equalsIgnoreCase("your-google-client-id") ||
               v.equalsIgnoreCase("your-google-client-secret");
    }

    private static void loadConfigFromDatabase() {
        String sql = "SELECT config_key, config_value FROM dbo.SystemConfig";
        try (java.sql.Connection conn = DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String key = rs.getString("config_key");
                String val = rs.getString("config_value");
                if (key != null && val != null && !val.trim().isEmpty() && !isPlaceholder(val)) {
                    properties.setProperty(key, val.trim());
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
        // 1. Try to find the exact key in config.properties / database
        String value = properties.getProperty(key);
        
        // 2. Try the uppercase/underscore variant in properties
        if (isPlaceholder(value)) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = properties.getProperty(alternativeKey);
        }
        
        // 3. Try System.getenv for env vars
        if (isPlaceholder(value)) {
            value = System.getenv(key);
        }
        if (isPlaceholder(value)) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = System.getenv(alternativeKey);
        }
        
        // 4. Try System properties
        if (isPlaceholder(value)) {
            value = System.getProperty(key);
        }
        if (isPlaceholder(value)) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = System.getProperty(alternativeKey);
        }
        
        if (isPlaceholder(value)) {
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

