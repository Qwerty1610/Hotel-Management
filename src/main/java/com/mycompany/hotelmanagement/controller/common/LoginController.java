package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import com.mycompany.hotelmanagement.config.ConfigUtil;
import com.mycompany.hotelmanagement.service.AuthService;
import com.mycompany.hotelmanagement.service.LoginResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;

/**
 * Controller xử lý đăng nhập hệ thống.
 * Chỉ nhận yêu cầu HTTP, ủy quyền xử lý đăng nhập cho AuthService,
 * sau đó thiết lập Session, Cookie và điều hướng trang.
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
        
        // Save referer as redirect target if it is a valid page within authority and not homepage/auth
        HttpSession session = request.getSession(true);
        if (session.getAttribute("redirectAfterLogin") == null) {
            String referer = request.getHeader("Referer");
            if (referer != null && referer.contains(request.getServerName()) && !isHomepageOrAuth(referer, request)) {
                session.setAttribute("redirectAfterLogin", referer);
            }
        }

        // Pass Google Client ID from config.properties or system properties to JSP
        String googleClientId = ConfigUtil.get("google.client.id",
                System.getProperty("google.client.id", "your-google-client-id"));
        request.setAttribute("googleClientId", googleClientId);
        
        // Forward to standalone login page
        request.getRequestDispatcher("/WEB-INF/views/home/login.jsp").forward(request, response);
    }

    private boolean isHomepageOrAuth(String referer, HttpServletRequest request) {
        if (referer == null) return true;
        String contextPath = request.getContextPath();
        try {
            java.net.URI uri = new java.net.URI(referer);
            String path = uri.getPath();
            if (path == null) return true;
            
            String relativePath = path;
            if (contextPath != null && !contextPath.isEmpty() && path.startsWith(contextPath)) {
                relativePath = path.substring(contextPath.length());
            }
            
            if (relativePath.startsWith("/")) {
                relativePath = relativePath.substring(1);
            }
            if (relativePath.endsWith("/")) {
                relativePath = relativePath.substring(0, relativePath.length() - 1);
            }
            
            return relativePath.isEmpty() 
                || "home".equals(relativePath) 
                || "home/login".equals(relativePath) 
                || "home/register".equals(relativePath);
        } catch (Exception e) {
            return true;
        }
    }

    /**
     * Thực hiện kiểm tra thông tin tài khoản, mật khẩu nhập vào qua AuthService:
     * - Nếu thành công: Tạo Session, lưu thông tin định danh và vai trò, thiết lập Cookie Remember Me, redirect.
     * - Nếu thất bại: Redirect báo lỗi.
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

        String role = null;
        String redirectUrl = null;
        String displayName = null;

        String emailVal = null;
        int accountIdVal = -1;

        // 1. Authenticate using database via AuthService
        Account account = authService.authenticate(username, pass);
        if (account != null) {
            String dbRoleName = account.getRoleName();
            String fullName = account.getFullName();
            emailVal = account.getEmail();
            accountIdVal = account.getAccountId();

            if ("Admin".equalsIgnoreCase(dbRoleName)) {
                role = "ADMIN";
                redirectUrl = "/admin/dashboard";
            } else if ("Customer".equalsIgnoreCase(dbRoleName)) {
                role = "CUSTOMER";
                redirectUrl = "/home";
            } else if ("Manager".equalsIgnoreCase(dbRoleName)) {
                role = "HOTEL_MANAGER";
                redirectUrl = "/manager/dashboard";
            } else if ("Receptionist".equalsIgnoreCase(dbRoleName)) {
                role = "RECEPTIONIST";
                redirectUrl = "/receptionist/dashboard";
            } else if ("Housekeeping".equalsIgnoreCase(dbRoleName) || "Housekeeper".equalsIgnoreCase(dbRoleName)) {
                role = "HOUSEKEEPING";
                redirectUrl = "/housekeeping/dashboard";
            } else if ("Staff".equalsIgnoreCase(dbRoleName)) {
                if (username != null && username.toLowerCase().contains("manager")) {
                    role = "HOTEL_MANAGER";
                    redirectUrl = "/manager/dashboard";
                } else if (username != null && username.toLowerCase().contains("housekeeping")) {
                    role = "HOUSEKEEPING";
                    redirectUrl = "/housekeeping/dashboard";
                } else {
                    role = "RECEPTIONIST";
                    redirectUrl = "/receptionist/dashboard";
                }
            }
            displayName = (fullName != null && !fullName.trim().isEmpty()) ? fullName : username;
        }

        // 2. Fallback to Mock authentication credentials check if database check didn't match
        if (role == null) {
            if ("admin".equalsIgnoreCase(username) && "admin123".equals(pass)) {
                role = "ADMIN";
                redirectUrl = "/admin/dashboard";
                displayName = "Admin User";
                com.mycompany.hotelmanagement.dal.AccountRepository ar = new com.mycompany.hotelmanagement.dal.AccountRepository();
                Account mockAcc = ar.getAccountByEmail("admin@hotel.com");
                if (mockAcc != null) {
                    emailVal = mockAcc.getEmail();
                    accountIdVal = mockAcc.getAccountId();
                } else {
                    emailVal = "admin@hotel.com";
                    accountIdVal = 1;
                }
            } else if ("customer".equalsIgnoreCase(username) && "customer123".equals(pass)) {
                role = "CUSTOMER";
                redirectUrl = "/home";
                displayName = "Customer User";
                com.mycompany.hotelmanagement.dal.AccountRepository ar = new com.mycompany.hotelmanagement.dal.AccountRepository();
                Account mockAcc = ar.getAccountByEmail("customer@hotel.com");
                if (mockAcc != null) {
                    emailVal = mockAcc.getEmail();
                    accountIdVal = mockAcc.getAccountId();
                } else {
                    emailVal = "customer@hotel.com";
                    accountIdVal = 5;
                }
            }
        }
        
        if (role != null) {
            // Authentication successful, establish session
            HttpSession session = request.getSession();
            session.setAttribute("user", displayName);
            session.setAttribute("role", role);
            session.setAttribute("email", emailVal);
            session.setAttribute("accountId", accountIdVal);

            // Remember Me Cookies configuration
            if ("on".equals(remember) || "true".equals(remember)) {
                String cleanUsername = username != null ? username.trim() : "";
                String cleanPass = pass != null ? pass.trim() : "";
                String encodedUsername = java.net.URLEncoder.encode(cleanUsername, java.nio.charset.StandardCharsets.UTF_8).replace("+", "%20");
                String encodedPass = java.net.URLEncoder.encode(cleanPass, java.nio.charset.StandardCharsets.UTF_8).replace("+", "%20");
                
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

            // Redirect to dashboard page or previous page if customer
            String redirectUrl = null;
            if ("CUSTOMER".equals(result.getRole())) {
                redirectUrl = (String) session.getAttribute("redirectAfterLogin");
                session.removeAttribute("redirectAfterLogin");
            } else {
                session.removeAttribute("redirectAfterLogin");
            }

            if (redirectUrl != null && !redirectUrl.isEmpty()) {
                response.sendRedirect(redirectUrl);
            } else {
                response.sendRedirect(request.getContextPath() + result.getRedirectUrl());
            }
        } else {
            // Authentication failed, redirect back to login page with error parameter
            response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
        }
    }
}
