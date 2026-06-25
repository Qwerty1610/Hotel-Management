package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
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
 * Controller xử lý đăng nhập dành riêng cho nhân viên và quản trị viên.
 * Chỉ cho phép các vai trò ADMIN, HOTEL_MANAGER, RECEPTIONIST, HOUSEKEEPING.
 * 
 * @author TungNQ
 */
@WebServlet(name = "StaffLoginController", urlPatterns = { "/staff/login" })
public class StaffLoginController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to staff login page
        request.getRequestDispatcher("/WEB-INF/views/staff/login.jsp").forward(request, response);
    }

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

        // 2. Fallback to Mock Admin authentication check
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
                // Reject customers on the staff portal
                response.sendRedirect(request.getContextPath() + "/staff/login?error=not_staff");
                return;
            }
        }
        
        // If they authenticated but turned out to have CUSTOMER role, reject them
        if (account != null && "Customer".equalsIgnoreCase(account.getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=not_staff");
            return;
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
            response.sendRedirect(request.getContextPath() + redirectUrl);
        } else {
            // Authentication failed, redirect back to login page with error parameter
            response.sendRedirect(request.getContextPath() + "/staff/login?error=invalid_credentials");
        }
    }
}
