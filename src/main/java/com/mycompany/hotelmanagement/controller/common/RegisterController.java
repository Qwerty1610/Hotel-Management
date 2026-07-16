package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import com.mycompany.hotelmanagement.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller xử lý đăng ký tài khoản khách hàng mới.
 * Chỉ tiếp nhận yêu cầu từ Form đăng ký, ủy thác xử lý logic đăng ký cho AuthService
 * và thực hiện chuyển hướng kèm tham số phù hợp với kết quả nhận được.
 * 
 * @author TùngNQ
 */
@WebServlet(name = "RegisterController", urlPatterns = {"/home/register"})
public class RegisterController extends HttpServlet {

    private final AuthService authService = new AuthService();

    /**
     * Chuyển hướng người dùng đến giao diện trang đăng ký tài khoản.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to the registration page
        request.getRequestDispatcher("/WEB-INF/views/home/register.jsp").forward(request, response);
    }

    /**
     * Tiếp nhận dữ liệu đăng ký từ Form, gọi AuthService thực hiện kiểm tra và lưu tài khoản,
     * sau đó chuyển hướng người dùng dựa trên kết quả trả về.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        String result = authService.register(fullName, email, phone, password, confirmPassword);

        String contextPath = request.getContextPath();
        
        switch (result) {
            case "success":
                response.sendRedirect(contextPath + "/home/login?success=registered");
                break;
                
            case "invalid_input":
                response.sendRedirect(contextPath + "/home/register?error=invalid_input");
                break;
                
            case "invalid_email":
                response.sendRedirect(contextPath + "/home/register?error=invalid_email"
                    + "&fullName=" + encode(fullName)
                    + "&phone=" + encode(phone));
                break;
                
            case "invalid_phone":
                response.sendRedirect(contextPath + "/home/register?error=invalid_phone"
                    + "&fullName=" + encode(fullName)
                    + "&email=" + encode(email));
                break;
                
            case "invalid_password":
                response.sendRedirect(contextPath + "/home/register?error=invalid_password"
                    + "&fullName=" + encode(fullName)
                    + "&email=" + encode(email)
                    + "&phone=" + encode(phone));
                break;
                
            case "password_too_short":
                response.sendRedirect(contextPath + "/home/register?error=password_too_short"
                    + "&fullName=" + encode(fullName)
                    + "&email=" + encode(email)
                    + "&phone=" + encode(phone));
                break;
                
            case "passwords_dont_match":
                response.sendRedirect(contextPath + "/home/register?error=passwords_dont_match"
                    + "&fullName=" + encode(fullName)
                    + "&email=" + encode(email)
                    + "&phone=" + encode(phone));
                break;
                
            case "email_exists":
                response.sendRedirect(contextPath + "/home/register?error=email_exists"
                    + "&fullName=" + encode(fullName)
                    + "&email=" + encode(email)
                    + "&phone=" + encode(phone));
                break;
                
            case "phone_exists":
                response.sendRedirect(contextPath + "/home/register?error=phone_exists"
                    + "&fullName=" + encode(fullName)
                    + "&email=" + encode(email)
                    + "&phone=" + encode(phone));
                break;
                
            case "server_error":
            default:
                response.sendRedirect(contextPath + "/home/register?error=server_error");
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
