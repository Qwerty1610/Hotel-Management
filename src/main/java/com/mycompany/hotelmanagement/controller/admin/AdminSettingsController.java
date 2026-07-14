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

    private void ensureConfigKeysExist() {
        String[] keys = {
            "hotel.name", "HotelOps Pro", "Tên khách sạn",
            "hotel.address", "123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh", "Địa chỉ khách sạn",
            "hotel.phone", "1900 6789", "Số điện thoại liên hệ",
            "hotel.email", "contact@hotelopspro.com", "Email liên hệ",
            "hotel.intro", "Hệ thống quản lý và nghỉ dưỡng đẳng cấp quốc tế, đem lại trải nghiệm sang trọng vượt thời gian.", "Giới thiệu ngắn khách sạn (Footer)",
            "hotel.hero.title", "Trải nghiệm kỳ nghỉ tuyệt vời tại HotelOps", "Tiêu đề biểu ngữ (Hero Title)",
            "hotel.hero.subtitle", "Nơi sang trọng gặp gỡ sự tinh tế, mang đến cho bạn trải nghiệm nghỉ dưỡng đích thực tại trung tâm thành phố.", "Phụ đề biểu ngữ (Hero Subtitle)",
            "hotel.about.tag", "VỀ HOTELOPS", "Thẻ tiêu đề Giới thiệu (About Tagline)",
            "hotel.about.title", "Định nghĩa lại lòng hiếu khách", "Tiêu đề phần Giới thiệu (About Title)",
            "hotel.about.desc", "HotelOps cung cấp không gian lưu trú sạch sẽ, tiện nghi và thoải mái dành cho cá nhân, gia đình và khách du lịch. Chúng tôi luôn cố gắng mang đến trải nghiệm nghỉ ngơi thuận tiện với mức giá phù hợp cho mọi khách hàng.", "Nội dung phần Giới thiệu (About Description)"
        };
        
        String checkSql = "SELECT COUNT(*) FROM dbo.SystemConfig WHERE config_key = ?";
        String insertSql = "INSERT INTO dbo.SystemConfig (config_key, config_value, description) VALUES (?, ?, ?)";
        
        try (Connection conn = DBContext.getConnection()) {
            for (int i = 0; i < keys.length; i += 3) {
                String key = keys[i];
                String val = keys[i+1];
                String desc = keys[i+2];
                
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        ensureConfigKeysExist();
        
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
        
        // Hotel & Website Information
        String hotelName = request.getParameter("hotelName");
        String hotelAddress = request.getParameter("hotelAddress");
        String hotelPhone = request.getParameter("hotelPhone");
        String hotelEmail = request.getParameter("hotelEmail");
        String hotelIntro = request.getParameter("hotelIntro");
        String hotelHeroTitle = request.getParameter("hotelHeroTitle");
        String hotelHeroSubtitle = request.getParameter("hotelHeroSubtitle");
        String hotelAboutTag = request.getParameter("hotelAboutTag");
        String hotelAboutTitle = request.getParameter("hotelAboutTitle");
        String hotelAboutDesc = request.getParameter("hotelAboutDesc");
        
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
                
                // 7. Hotel Name
                ps.setString(1, hotelName != null ? hotelName.trim() : "");
                ps.setString(2, "hotel.name");
                ps.addBatch();
                
                // 8. Hotel Address
                ps.setString(1, hotelAddress != null ? hotelAddress.trim() : "");
                ps.setString(2, "hotel.address");
                ps.addBatch();
                
                // 9. Hotel Phone
                ps.setString(1, hotelPhone != null ? hotelPhone.trim() : "");
                ps.setString(2, "hotel.phone");
                ps.addBatch();
                
                // 10. Hotel Email
                ps.setString(1, hotelEmail != null ? hotelEmail.trim() : "");
                ps.setString(2, "hotel.email");
                ps.addBatch();
                
                // 11. Hotel Intro
                ps.setString(1, hotelIntro != null ? hotelIntro.trim() : "");
                ps.setString(2, "hotel.intro");
                ps.addBatch();
                
                // 12. Hero Title
                ps.setString(1, hotelHeroTitle != null ? hotelHeroTitle.trim() : "");
                ps.setString(2, "hotel.hero.title");
                ps.addBatch();
                
                // 13. Hero Subtitle
                ps.setString(1, hotelHeroSubtitle != null ? hotelHeroSubtitle.trim() : "");
                ps.setString(2, "hotel.hero.subtitle");
                ps.addBatch();
                
                // 14. About Tag
                ps.setString(1, hotelAboutTag != null ? hotelAboutTag.trim() : "");
                ps.setString(2, "hotel.about.tag");
                ps.addBatch();
                
                // 15. About Title
                ps.setString(1, hotelAboutTitle != null ? hotelAboutTitle.trim() : "");
                ps.setString(2, "hotel.about.title");
                ps.addBatch();
                
                // 16. About Description
                ps.setString(1, hotelAboutDesc != null ? hotelAboutDesc.trim() : "");
                ps.setString(2, "hotel.about.desc");
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
