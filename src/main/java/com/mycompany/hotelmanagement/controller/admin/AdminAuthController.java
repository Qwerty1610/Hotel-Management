package com.mycompany.hotelmanagement.controller.admin;

import com.mycompany.hotelmanagement.service.AdminService;
import jakarta.json.bind.Jsonb;
import jakarta.json.bind.JsonbBuilder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller xử lý yêu cầu đổi mật khẩu cho tài khoản Admin.
 * Được bảo vệ tự động bởi AuthFilter (vì nằm dưới path /admin/*).
 * 
 * @author TùngNQ
 */
@WebServlet(name = "AdminAuthController", urlPatterns = {"/admin/change-password"})
public class AdminAuthController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminService adminService = new AdminService();

    /**
     * Xử lý yêu cầu đổi mật khẩu qua phương thức HTTP PUT dưới dạng JSON.
     */
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // 1. Phân quyền: Kiểm tra sự tồn tại của Session và vai trò ADMIN
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Bạn không có quyền thực hiện chức năng này.\"}");
            return;
        }

        // 2. Lấy Email Admin từ phiên đăng nhập
        String email = (String) session.getAttribute("email");
        if (email == null || email.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Phiên làm việc hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.\"}");
            return;
        }

        try {
            // 3. Deserialize JSON payload từ request body sang request DTO
            Jsonb jsonb = JsonbBuilder.create();
            AdminChangePasswordRequest req;
            try {
                req = jsonb.fromJson(request.getReader(), AdminChangePasswordRequest.class);
            } catch (Exception ex) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu yêu cầu không đúng định dạng JSON.\"}");
                return;
            }

            if (req == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu yêu cầu trống.\"}");
                return;
            }

            // 4. Gọi service xử lý logic đổi mật khẩu
            String result = adminService.changePassword(
                    email, 
                    req.getOldPassword(), 
                    req.getNewPassword(), 
                    req.getConfirmPassword()
            );

            // 5. Trả về mã trạng thái HTTP và thông báo JSON tương ứng với kết quả xử lý
            switch (result) {
                case "invalid_input":
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng điền đầy đủ tất cả các trường!\"}");
                    break;
                case "account_not_found":
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"success\":false,\"message\":\"Tài khoản quản trị không tồn tại trong hệ thống.\"}");
                    break;
                case "incorrect_old_password":
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu hiện tại không chính xác.\"}");
                    break;
                case "password_too_short":
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu mới phải tối thiểu từ 8 ký tự trở lên!\"}");
                    break;
                case "password_too_weak":
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu mới phải bao gồm cả chữ, số và ký tự đặc biệt!\"}");
                    break;
                case "passwords_dont_match":
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu xác nhận không trùng khớp!\"}");
                    break;
                case "update_failed":
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"success\":false,\"message\":\"Không thể cập nhật mật khẩu mới vào cơ sở dữ liệu.\"}");
                    break;
                case "success":
                default:
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("{\"success\":true,\"message\":\"Đổi mật khẩu thành công!\"}");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống nghiêm trọng xảy ra. Vui lòng thử lại sau.\"}");
        }
    }
}
