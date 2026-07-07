package com.mycompany.hotelmanagement.controller.admin;

import com.mycompany.hotelmanagement.config.ConfigUtil;
import com.mycompany.hotelmanagement.config.DBContext;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller to manage system configurations (Google Login API, SMTP Email Settings).
 * Only accessible to Admin users.
 * 
 * @author Antigravity
 */
@WebServlet(name = "AdminSettingsController", urlPatterns = {"/admin/settings"})
public class AdminSettingsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
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
            request.setAttribute("error", "Không thể nạp cấu hình từ database: " + e.getMessage());
        }
        
        request.setAttribute("configs", configs);
        request.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String googleClientId = request.getParameter("googleClientId");
        String googleClientSecret = request.getParameter("googleClientSecret");
        String smtpUser = request.getParameter("smtpUser");
        String smtpPassword = request.getParameter("smtpPassword");
        String smtpHost = request.getParameter("smtpHost");
        String smtpPort = request.getParameter("smtpPort");
        String webLanguage = request.getParameter("webLanguage");
        
        String sql = "UPDATE dbo.SystemConfig SET config_value = ?, updated_at = SYSDATETIME() WHERE config_key = ?";
        
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                // 1. Google Client ID
                ps.setString(1, googleClientId != null ? googleClientId.trim() : "");
                ps.setString(2, "google.client.id");
                ps.addBatch();
                
                // 2. Google Client Secret
                ps.setString(1, googleClientSecret != null ? googleClientSecret.trim() : "");
                ps.setString(2, "google.client.secret");
                ps.addBatch();
                
                // 3. SMTP User
                ps.setString(1, smtpUser != null ? smtpUser.trim() : "");
                ps.setString(2, "smtp.user");
                ps.addBatch();
                
                // 4. SMTP Password
                ps.setString(1, smtpPassword != null ? smtpPassword.trim() : "");
                ps.setString(2, "smtp.password");
                ps.addBatch();
                
                // 5. SMTP Host
                ps.setString(1, smtpHost != null ? smtpHost.trim() : "");
                ps.setString(2, "smtp.host");
                ps.addBatch();
                
                // 6. SMTP Port
                ps.setString(1, smtpPort != null ? smtpPort.trim() : "");
                ps.setString(2, "smtp.port");
                ps.addBatch();
                
                // 7. Web Language
                ps.setString(1, webLanguage != null ? webLanguage.trim() : "vi");
                ps.setString(2, "web.language");
                ps.addBatch();
                
                ps.executeBatch();
                conn.commit();
                
                // Refresh memory cache in ConfigUtil
                ConfigUtil.reload();
                
                request.setAttribute("success", "Cập nhật cấu hình hệ thống thành công!");
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi lưu cấu hình: " + e.getMessage());
        }
        
        doGet(request, response);
    }
}
