package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import com.mycompany.hotelmanagement.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller xử lý việc đặt lại mật khẩu mới.
 * Chỉ tiếp nhận dữ liệu đầu vào, ủy thác xác thực mã OTP, đặt lại mật khẩu mới cho AuthService,
 * sau đó chuyển hướng người dùng dựa trên kết quả trả về.
 * 
 * @author TùngNQ
 */
@WebServlet(name = "ResetPasswordController", urlPatterns = {"/home/reset-password"})
public class ResetPasswordController extends HttpServlet {

    private final AuthService authService = new AuthService();

    /**
     * Chuyển hướng người dùng đến giao diện nhập OTP và mật khẩu mới.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to the reset password page
        request.getRequestDispatcher("/WEB-INF/views/home/reset-password.jsp").forward(request, response);
    }

    /**
     * Xác thực thông tin đặt lại mật khẩu: chuyển xử lý cho AuthService và thực hiện redirect.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String otp = request.getParameter("otp");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        String result = authService.resetPassword(email, otp, newPassword, confirmPassword);
        String contextPath = request.getContextPath();
        String encodedEmail = encode(email);

        switch (result) {
            case "success":
                // Success, redirect to login page
                response.sendRedirect(contextPath + "/home/login?success=password_reset");
                break;
                
            case "invalid_input":
                response.sendRedirect(contextPath + "/home/reset-password?error=invalid_input&email=" + encodedEmail);
                break;
                
            case "invalid_password":
                response.sendRedirect(contextPath + "/home/reset-password?error=invalid_password&email=" + encodedEmail);
                break;
                
            case "passwords_dont_match":
                response.sendRedirect(contextPath + "/home/reset-password?error=passwords_dont_match&email=" + encodedEmail);
                break;
                
            case "invalid_otp":
                response.sendRedirect(contextPath + "/home/reset-password?error=invalid_otp&email=" + encodedEmail);
                break;
                
            case "server_error":
            default:
                response.sendRedirect(contextPath + "/home/reset-password?error=server_error&email=" + encodedEmail);
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
