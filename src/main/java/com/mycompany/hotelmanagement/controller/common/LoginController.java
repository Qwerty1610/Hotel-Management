package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.mycompany.hotelmanagement.utils.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;

@WebServlet(name = "LoginController", urlPatterns = { "/home/login" })
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Pass Google Client ID from system properties to JSP
        String googleClientId = System.getProperty("google.client.id", "your-google-client-id");
        request.setAttribute("googleClientId", googleClientId);
        
        // Forward to standalone login page
        request.getRequestDispatcher("/WEB-INF/views/home/login.jsp").forward(request, response);
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

        // 1. Authenticate using database first
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT a.email, a.password, a.full_name, r.role_name " +
                                "FROM Account a JOIN Role r ON a.role_id = r.role_id " +
                                "WHERE a.email = ? AND a.is_active = 1")) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String dbPasswordHash = rs.getString("password");
                    String fullName = rs.getString("full_name");
                    String dbRoleName = rs.getString("role_name");

                    // Verify the password using BCrypt
                    if (org.mindrot.jbcrypt.BCrypt.checkpw(pass, dbPasswordHash)) {
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
                        } else if ("Housekeeping".equalsIgnoreCase(dbRoleName)
                                || "Housekeeper".equalsIgnoreCase(dbRoleName)) {
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
                        username = (fullName != null && !fullName.trim().isEmpty()) ? fullName : username;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2. Fallback to Mock authentication credentials check if database check didn't
        // match
        if (role == null) {
            if ("admin".equalsIgnoreCase(username) && "admin123".equals(pass)) {
                role = "ADMIN";
                redirectUrl = "/admin/dashboard";
            } else if ("manager".equalsIgnoreCase(username) && "manager123".equals(pass)) {
                role = "HOTEL_MANAGER";
                redirectUrl = "/manager/dashboard";
            } else if ("housekeeping".equalsIgnoreCase(username) && "housekeeping123".equals(pass)) {
                role = "HOUSEKEEPING";
                redirectUrl = "/housekeeping/dashboard";
            } else if ("receptionist".equalsIgnoreCase(username) && "receptionist123".equals(pass)) {
                role = "RECEPTIONIST";
                redirectUrl = "/receptionist/dashboard";
            } else if ("customer".equalsIgnoreCase(username) && "customer123".equals(pass)) {
                role = "CUSTOMER";
                redirectUrl = "/home";
            }
        }

        if (role != null) {
            // Authentication successful, establish session
            HttpSession session = request.getSession();
            session.setAttribute("user", username);
            session.setAttribute("role", role);

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
            response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
        }
    }
}
