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
 * @version 1.0.2
 * Created: 25/06/2026
 * Modified: 25/06/2026
 */
@WebServlet(name = "StaffLoginController", urlPatterns = { "/staff/login" })
public class StaffLoginController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            String role = (String) session.getAttribute("role");
            if ("CUSTOMER".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/home/login");
                return;
            } else if (role != null) {
                String redirectUrl = "/home";
                if ("ADMIN".equals(role)) {
                    redirectUrl = "/admin/dashboard";
                } else if ("HOTEL_MANAGER".equals(role)) {
                    redirectUrl = "/manager/dashboard";
                } else if ("RECEPTIONIST".equals(role)) {
                    redirectUrl = "/receptionist/dashboard";
                } else if ("HOUSEKEEPING".equals(role)) {
                    redirectUrl = "/housekeeping/dashboard";
                }
                response.sendRedirect(request.getContextPath() + redirectUrl);
                return;
            }
        }

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

        if (username == null || username.isEmpty() || pass == null || pass.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=invalid_input");
            return;
        }

        // Call Service layer to process login
        com.mycompany.hotelmanagement.service.LoginResult result = authService.login(username, pass);

        if (result.isSuccess()) {
            String role = result.getRole();
            
            // Reject customers on the staff portal
            if ("CUSTOMER".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/staff/login?error=not_staff");
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
            String err = "invalid_credentials";
            if ("account_locked".equals(result.getErrorCode())) {
                err = "account_locked";
            }
            response.sendRedirect(request.getContextPath() + "/staff/login?error=" + err);
        }
    }
}
