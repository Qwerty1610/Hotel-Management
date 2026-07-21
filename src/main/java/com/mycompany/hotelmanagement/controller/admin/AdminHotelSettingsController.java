package com.mycompany.hotelmanagement.controller.admin;

import com.mycompany.hotelmanagement.config.ConfigUtil;
import com.mycompany.hotelmanagement.dal.SystemConfigDAO;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller to manage hotel details and landing page details.
 * Only accessible to Admin users.
 * 
 * @author TungNQ
 * @version 1.0.1
 * Created: 24/06/2026
 * Modified: 16/07/2026
 */
@WebServlet(name = "AdminHotelSettingsController", urlPatterns = {"/admin/hotel-settings"})
public class AdminHotelSettingsController extends HttpServlet {

    private final SystemConfigDAO systemConfigDAO = new SystemConfigDAO();

    private static final String[] DEFAULT_HOTEL_KEYS = {
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

    /**
     * Xử lý yêu cầu GET: nạp danh sách cấu hình thông tin khách sạn và giao diện landing page.
     * 
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws ServletException nếu có lỗi Servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        systemConfigDAO.ensureConfigKeysExist(DEFAULT_HOTEL_KEYS);
        
        Map<String, String> configs = systemConfigDAO.getAllConfigs();
        request.setAttribute("configs", configs);
        request.getRequestDispatcher("/WEB-INF/views/admin/hotel-settings.jsp").forward(request, response);
    }

    /**
     * Xử lý yêu cầu POST: cập nhật thông tin chi tiết khách sạn và giao diện trang chủ vào CSDL.
     * 
     * @param request HttpServletRequest chứa dữ liệu cấu hình thông tin khách sạn
     * @param response HttpServletResponse
     * @throws ServletException nếu có lỗi Servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Map<String, String> newConfigs = new HashMap<>();
        newConfigs.put("hotel.name", request.getParameter("hotelName"));
        newConfigs.put("hotel.address", request.getParameter("hotelAddress"));
        newConfigs.put("hotel.phone", request.getParameter("hotelPhone"));
        newConfigs.put("hotel.email", request.getParameter("hotelEmail"));
        newConfigs.put("hotel.intro", request.getParameter("hotelIntro"));
        newConfigs.put("hotel.hero.title", request.getParameter("hotelHeroTitle"));
        newConfigs.put("hotel.hero.subtitle", request.getParameter("hotelHeroSubtitle"));
        newConfigs.put("hotel.about.tag", request.getParameter("hotelAboutTag"));
        newConfigs.put("hotel.about.title", request.getParameter("hotelAboutTitle"));
        newConfigs.put("hotel.about.desc", request.getParameter("hotelAboutDesc"));
        
        boolean success = systemConfigDAO.updateConfigs(newConfigs);
        if (success) {
            ConfigUtil.reload();
            request.setAttribute("success", "Cập nhật thông tin khách sạn thành công!");
        } else {
            request.setAttribute("error", "Lỗi lưu cấu hình thông tin khách sạn!");
        }
        
        doGet(request, response);
    }
}
