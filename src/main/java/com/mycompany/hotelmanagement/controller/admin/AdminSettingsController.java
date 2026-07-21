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
 * Controller to manage system configurations (Google Login API, SMTP Email Settings).
 * Only accessible to Admin users.
 * 
 * @author TungNQ
 * @version 1.0.1
 * Created: 24/06/2026
 * Modified: 16/07/2026
 */
@WebServlet(name = "AdminSettingsController", urlPatterns = {"/admin/settings"})
public class AdminSettingsController extends HttpServlet {

    private final SystemConfigDAO systemConfigDAO = new SystemConfigDAO();

    /**
     * Xử lý yêu cầu GET: nạp danh sách cấu hình hệ thống từ CSDL và chuyển hướng tới trang quản trị settings.jsp.
     * 
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws ServletException nếu có lỗi Servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Map<String, String> configs = systemConfigDAO.getAllConfigs();
        request.setAttribute("configs", configs);
        request.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(request, response);
    }

    /**
     * Xử lý yêu cầu POST: cập nhật các giá trị cấu hình hệ thống (Google OAuth, SMTP Email) vào CSDL.
     * 
     * @param request HttpServletRequest chứa các giá trị cấu hình mới từ form
     * @param response HttpServletResponse
     * @throws ServletException nếu có lỗi Servlet
     * @throws IOException nếu có lỗi I/O
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Map<String, String> newConfigs = new HashMap<>();
        newConfigs.put("google.client.id", request.getParameter("googleClientId"));
        newConfigs.put("google.client.secret", request.getParameter("googleClientSecret"));
        newConfigs.put("smtp.user", request.getParameter("smtpUser"));
        newConfigs.put("smtp.password", request.getParameter("smtpPassword"));
        newConfigs.put("smtp.host", request.getParameter("smtpHost"));
        newConfigs.put("smtp.port", request.getParameter("smtpPort"));
        
        boolean success = systemConfigDAO.updateConfigs(newConfigs);
        if (success) {
            ConfigUtil.reload();
            request.setAttribute("success", "Cập nhật cấu hình hệ thống thành công!");
        } else {
            request.setAttribute("error", "Lỗi lưu cấu hình hệ thống!");
        }
        
        doGet(request, response);
    }
}
