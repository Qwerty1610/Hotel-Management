package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import com.mycompany.hotelmanagement.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller xử lý yêu cầu quên mật khẩu.
 * Tiếp nhận email của người dùng, ủy quyền kiểm tra tài khoản, sinh OTP và gửi thư cho AuthService,
 * sau đó chuyển hướng người dùng dựa trên kết quả.
 * 
 * @author TùngNQ
 */
@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/home/forgot-password"})
public class ForgotPasswordController extends HttpServlet {

    private final AuthService authService = new AuthService();

    /**
     * Chuyển hướng người dùng đến giao diện trang quên mật khẩu.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to forgot password page
        request.getRequestDispatcher("/WEB-INF/views/home/forgot-password.jsp").forward(request, response);
    }

    /**
     * Tiếp nhận email yêu cầu khôi phục mật khẩu, ủy thác xử lý cho AuthService và thực hiện redirect.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        if (email != null) {
            email = email.trim();
        }

        String result = authService.requestPasswordReset(email);
        String contextPath = request.getContextPath();
        String encodedEmail = encode(email);

        switch (result) {
            case "invalid_input":
                response.sendRedirect(contextPath + "/home/forgot-password?error=invalid_input");
                break;
                
            case "email_not_found":
                response.sendRedirect(contextPath + "/home/forgot-password?error=email_not_found&email=" + encodedEmail);
                break;
                
            case "server_error":
                response.sendRedirect(contextPath + "/home/forgot-password?error=server_error&email=" + encodedEmail);
                break;
                
            case "success":
            default:
                // Redirect to Reset Password input form
                response.sendRedirect(contextPath + "/home/reset-password?email=" + encodedEmail + "&success=otp_sent");
                break;
        }
    }

    private String encode(String val) {
        if (val == null) {
            return "";
        }
        return java.net.URLEncoder.encode(val.trim(), java.nio.charset.StandardCharsets.UTF_8).replace("+", "%20");
    }
}
