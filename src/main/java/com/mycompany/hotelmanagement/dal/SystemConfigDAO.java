package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * Data Access Object (DAO) cho bảng dbo.SystemConfig.
 * Chịu trách nhiệm cho tất cả các thao tác truy vấn và cập nhật CSDL liên quan đến cấu hình hệ thống.
 * 
 * @author TungNQ
 * @version 1.0.1
 * Created: 24/06/2026
 * Modified: 16/07/2026
 */
public class SystemConfigDAO {

    /**
     * Nạp tất cả các cặp cấu hình (config_key, config_value) từ CSDL.
     * 
     * @return Map chứa các cặp khóa - giá trị cấu hình
     */
    public Map<String, String> getAllConfigs() {
        Map<String, String> configs = new HashMap<>();
        String sql = "SELECT config_key, config_value FROM dbo.SystemConfig";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                configs.put(rs.getString("config_key"), rs.getString("config_value"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return configs;
    }

    /**
     * Cập nhật hàng loạt danh sách các cặp cấu hình vào CSDL trong một transaction.
     * 
     * @param configs Map chứa các khóa và giá trị cấu hình mới
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    public boolean updateConfigs(Map<String, String> configs) {
        if (configs == null || configs.isEmpty()) {
            return true;
        }
        
        String sql = "UPDATE dbo.SystemConfig SET config_value = ?, updated_at = SYSDATETIME() WHERE config_key = ?";
        
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (Map.Entry<String, String> entry : configs.entrySet()) {
                    ps.setString(1, entry.getValue() != null ? entry.getValue().trim() : "");
                    ps.setString(2, entry.getKey());
                    ps.addBatch();
                }
                ps.executeBatch();
                conn.commit();
                return true;
            } catch (Exception e) {
                if (conn != null) {
                    conn.rollback();
                }
                e.printStackTrace();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Đảm bảo các khóa cấu hình mặc định tồn tại trong bảng SystemConfig.
     * 
     * @param defaultKeys Mảng 1 chiều có cấu trúc [key1, value1, desc1, key2, value2, desc2, ...]
     */
    public void ensureConfigKeysExist(String[] defaultKeys) {
        if (defaultKeys == null || defaultKeys.length < 3) {
            return;
        }
        
        String checkSql = "SELECT COUNT(*) FROM dbo.SystemConfig WHERE config_key = ?";
        String insertSql = "INSERT INTO dbo.SystemConfig (config_key, config_value, description) VALUES (?, ?, ?)";
        
        try (Connection conn = DBContext.getConnection()) {
            for (int i = 0; i < defaultKeys.length; i += 3) {
                String key = defaultKeys[i];
                String val = defaultKeys[i + 1];
                String desc = defaultKeys[i + 2];
                
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setString(1, key);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next() && rs.getInt(1) == 0) {
                            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                                psInsert.setString(1, key);
                                psInsert.setString(2, val);
                                psInsert.setString(3, desc);
                                psInsert.executeUpdate();
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
