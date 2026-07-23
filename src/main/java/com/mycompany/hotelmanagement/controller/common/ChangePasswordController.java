package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.service.AdminService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller xử lý yêu cầu đổi mật khẩu dùng chung cho tất cả các vai trò.
 * Ánh xạ tới các URL tương ứng với vai trò của người dùng.
 * 
 * @author TungNQ
 * @version 1.0.4
 * Created: 24/06/2026
 * Modified: 16/07/2026
 */
@WebServlet(name = "ChangePasswordController", urlPatterns = {
    "/admin/change-password",
    "/manager/change-password",
    "/receptionist/change-password",
    "/housekeeping/change-password",
    "/customer/change-password",
    "/profile/change-password"
})
public class ChangePasswordController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminService adminService = new AdminService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPut(request, response);
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra sự tồn tại của phiên làm việc
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Phiên làm việc đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.\"}");
            return;
        }

        // 2. Xác thực phân quyền chéo (Cross-role validation)
        String servletPath = request.getServletPath();
        String sessionRole = (String) session.getAttribute("role");
        
        boolean authorized = false;
        if (servletPath.startsWith("/admin") && "ADMIN".equals(sessionRole)) {
            authorized = true;
        } else if (servletPath.startsWith("/manager") && "HOTEL_MANAGER".equals(sessionRole)) {
            authorized = true;
        } else if (servletPath.startsWith("/receptionist") && "RECEPTIONIST".equals(sessionRole)) {
            authorized = true;
        } else if (servletPath.startsWith("/housekeeping") && "HOUSEKEEPING".equals(sessionRole)) {
            authorized = true;
        } else if (servletPath.startsWith("/customer") && "CUSTOMER".equals(sessionRole)) {
            authorized = true;
        } else if (servletPath.startsWith("/profile") && 
                   ("ADMIN".equals(sessionRole) || 
                    "HOTEL_MANAGER".equals(sessionRole) || 
                    "RECEPTIONIST".equals(sessionRole) || 
                    "HOUSEKEEPING".equals(sessionRole) || 
                    "CUSTOMER".equals(sessionRole))) {
            authorized = true;
        }

        if (!authorized) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Bạn không có quyền thực hiện chức năng này.\"}");
            return;
        }

        // 3. Lấy email của người dùng hiện tại từ session
        String email = (String) session.getAttribute("email");
        if (email == null || email.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Email không tồn tại trong phiên làm việc.\"}");
            return;
        }

        try {
            // 4. Đọc dữ liệu JSON payload
            String oldPassword = null;
            String newPassword = null;
            String confirmPassword = null;
            
            try {
                StringBuilder sb = new StringBuilder();
                String line;
                try (java.io.BufferedReader reader = request.getReader()) {
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                String body = sb.toString().trim();
                
                oldPassword = extractJsonField(body, "oldPassword");
                newPassword = extractJsonField(body, "newPassword");
                confirmPassword = extractJsonField(body, "confirmPassword");
            } catch (Exception ex) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu yêu cầu không đúng định dạng JSON.\"}");
                return;
            }

            if (oldPassword == null || newPassword == null || confirmPassword == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu yêu cầu trống hoặc không đầy đủ.\"}");
                return;
            }

            // 5. Gọi Service thực hiện đổi mật khẩu
            String result = adminService.changePassword(
                    email, 
                    oldPassword, 
                    newPassword, 
                    confirmPassword
            );

            // 6. Phản hồi dựa trên kết quả nghiệp vụ
            switch (result) {
                case "invalid_input":
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng điền đầy đủ các trường bắt buộc.\"}");
                    break;
                case "account_not_found":
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"success\":false,\"message\":\"Tài khoản không tồn tại trên hệ thống.\"}");
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
                case "password_same_as_current":
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu mới không được trùng với mật khẩu hiện tại!\"}");
                    break;
                case "passwords_dont_match":
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu xác nhận không trùng khớp!\"}");
                    break;
                case "update_failed":
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu mật khẩu mới. Lỗi cơ sở dữ liệu.\"}");
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
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống xảy ra khi đổi mật khẩu. Vui lòng thử lại sau.\"}");
        }
    }

    /**
     * Hàm helper trích xuất giá trị trường JSON đơn giản bằng biểu thức chính quy (Regex).
     */
    private String extractJsonField(String json, String field) {
        if (json == null || json.isEmpty()) return null;
        String patternStr = "\"" + field + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"";
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(patternStr);
        java.util.regex.Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return unescapeJsonString(matcher.group(1));
        }
        return null;
    }

    /**
     * Giải mã chuỗi ký tự JSON escape sang chuỗi Java thuần túy.
     */
    private String unescapeJsonString(String escaped) {
        if (escaped == null) return null;
        StringBuilder sb = new StringBuilder();
        int len = escaped.length();
        for (int i = 0; i < len; i++) {
            char c = escaped.charAt(i);
            if (c == '\\' && i + 1 < len) {
                char next = escaped.charAt(i + 1);
                switch (next) {
                    case '"': sb.append('"'); i++; break;
                    case '\\': sb.append('\\'); i++; break;
                    case '/': sb.append('/'); i++; break;
                    case 'b': sb.append('\b'); i++; break;
                    case 'f': sb.append('\f'); i++; break;
                    case 'n': sb.append('\n'); i++; break;
                    case 'r': sb.append('\r'); i++; break;
                    case 't': sb.append('\t'); i++; break;
                    case 'u':
                        if (i + 5 < len) {
                            try {
                                int code = Integer.parseInt(escaped.substring(i + 2, i + 6), 16);
                                sb.append((char) code);
                                i += 5;
                            } catch (NumberFormatException e) {
                                sb.append(c);
                            }
                        } else {
                            sb.append(c);
                        }
                        break;
                    default:
                        sb.append(next);
                        i++;
                        break;
                }
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }
}
