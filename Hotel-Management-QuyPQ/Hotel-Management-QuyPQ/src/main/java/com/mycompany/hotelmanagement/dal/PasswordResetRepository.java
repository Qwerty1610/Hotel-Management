package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class PasswordResetRepository {

    public boolean insertResetToken(String email, String token, Timestamp expiryTime) {
        String sql = "INSERT INTO PasswordReset (email, token, expiry_time, is_used, created_at) VALUES (?, ?, ?, 0, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, token);
            ps.setTimestamp(3, expiryTime);
            ps.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getValidResetId(String email, String token) {
        String sql = "SELECT TOP 1 id FROM PasswordReset " +
                     "WHERE email = ? AND token = ? AND is_used = 0 AND expiry_time > GETDATE() " +
                     "ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean performPasswordReset(String email, String hashedPassword, int resetId) {
        String updatePassSql = "UPDATE Account SET password = ? WHERE email = ? AND is_active = 1";
        String updateOtpSql = "UPDATE PasswordReset SET is_used = 1 WHERE id = ?";
        
        Connection conn = null;
        PreparedStatement updatePassPs = null;
        PreparedStatement updateOtpPs = null;
        
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            
            updatePassPs = conn.prepareStatement(updatePassSql);
            updatePassPs.setString(1, hashedPassword);
            updatePassPs.setString(2, email);
            updatePassPs.executeUpdate();
            
            updateOtpPs = conn.prepareStatement(updateOtpSql);
            updateOtpPs.setInt(1, resetId);
            updateOtpPs.executeUpdate();
            
            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (updatePassPs != null) updatePassPs.close();
                if (updateOtpPs != null) updateOtpPs.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
