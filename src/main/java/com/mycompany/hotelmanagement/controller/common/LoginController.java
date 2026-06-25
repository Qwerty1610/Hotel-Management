package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import com.mycompany.hotelmanagement.config.ConfigUtil;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;

/**
 * Controller xử lý đăng nhập hệ thống.
 * Thực hiện xác thực thông tin đăng nhập của tài khoản qua Database thông qua AuthService,
 * phân vai trò người dùng để điều hướng phù hợp, đồng thời quản lý Cookie Remember Me.
 * 
 * @author TùngNQ
 */
@WebServlet(name = "LoginController", urlPatterns = { "/home/login" })
public class LoginController extends HttpServlet {

    private final AuthService authService = new AuthService();

    /**
     * Chuyển hướng người dùng đến trang đăng nhập độc lập và cấu hình ID đăng nhập Google.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Pass Google Client ID from config.properties or system properties to JSP
        String googleClientId = ConfigUtil.get("google.client.id",
                System.getProperty("google.client.id", "your-google-client-id"));
        request.setAttribute("googleClientId", googleClientId);
        
        // Forward to standalone login page
        request.getRequestDispatcher("/WEB-INF/views/home/login.jsp").forward(request, response);
    }

    /**
     * Thực hiện kiểm tra thông tin tài khoản, mật khẩu nhập vào:
     * - Nếu khớp trong DB: Tạo Session, lưu thông tin định danh và vai trò, thiết lập Cookie nếu có check "Remember Me".
     * - Nếu không khớp: Cho phép fallback thử tài khoản Mock (Admin/Customer), hoặc redirect báo lỗi.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String pass = request.getParameter("password");
        String remember = request.getParameter("remember");

        if (username != null) {
            username = username.trim();
        }
        if (pass != null) {
            pass = pass.trim();
        }

        // Call Service layer to process login
        com.mycompany.hotelmanagement.service.LoginResult result = authService.login(username, pass);

        if (result.isSuccess()) {
            String role = result.getRole();
            
            // Only allow CUSTOMER role to log in via this customer-facing portal
            if (!"CUSTOMER".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/home/login?error=not_customer");
                return;
            }

            // Authentication successful, establish session
            HttpSession session = request.getSession();
            session.setAttribute("user", result.getDisplayName());
            session.setAttribute("role", role);
            session.setAttribute("email", result.getEmail());
            session.setAttribute("accountId", result.getAccountId());

            // Remember Me Cookies configuration
            if ("on".equals(remember) || "true".equals(remember)) {
                String encodedUsername = java.net.URLEncoder.encode(username, java.nio.charset.StandardCharsets.UTF_8).replace("+", "%20");
                String encodedPass = java.net.URLEncoder.encode(pass, java.nio.charset.StandardCharsets.UTF_8).replace("+", "%20");
                
                Cookie userCookie = new Cookie("rememberUser", encodedUsername);
                userCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
                userCookie.setPath("/");

                Cookie passCookie = new Cookie("rememberPass", encodedPass);
                passCookie.setMaxAge(30 * 24 * 60 * 60);
                passCookie.setPath("/");

                Cookie rememberMeCookie = new Cookie("rememberMe", "true");
                rememberMeCookie.setMaxAge(30 * 24 * 60 * 60);
                rememberMeCookie.setPath("/");

                response.addCookie(userCookie);
                response.addCookie(passCookie);
                response.addCookie(rememberMeCookie);
            } else {
                Cookie userCookie = new Cookie("rememberUser", "");
                userCookie.setMaxAge(0);
                userCookie.setPath("/");

                Cookie passCookie = new Cookie("rememberPass", "");
                passCookie.setMaxAge(0);
                passCookie.setPath("/");

                Cookie rememberMeCookie = new Cookie("rememberMe", "");
                rememberMeCookie.setMaxAge(0);
                rememberMeCookie.setPath("/");

                response.addCookie(userCookie);
                response.addCookie(passCookie);
                response.addCookie(rememberMeCookie);
            }

            // Redirect to dashboard page
            response.sendRedirect(request.getContextPath() + result.getRedirectUrl());
        } else {
            // Authentication failed, redirect back to login page with error parameter
            response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
        }
    }

}