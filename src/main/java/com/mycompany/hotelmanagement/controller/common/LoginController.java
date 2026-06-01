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

@WebServlet(name = "LoginController", urlPatterns = {"/home/login"})
public class LoginController extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to standalone login page
        request.getRequestDispatcher("/WEB-INF/views/home/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String pass = request.getParameter("password");
        
        if (username != null) {
            username = username.trim();
        }
        if (pass != null) {
            pass = pass.trim();
        }
        
        Account account = authService.authenticate(username, pass);
        
        if (account != null) {
            String role = null;
            String redirectUrl = null;
            String dbRoleName = account.getRoleName();
            String fullName = account.getFullName();
            
            if ("Admin".equalsIgnoreCase(dbRoleName)) {
                role = "ADMIN";
                redirectUrl = "/admin/dashboard";
            } else if ("Customer".equalsIgnoreCase(dbRoleName)) {
                role = "CUSTOMER";
                redirectUrl = "/";
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
            
            String displayName = (fullName != null && !fullName.trim().isEmpty()) ? fullName : username;
            
            // Authentication successful, establish session
            HttpSession session = request.getSession();
            session.setAttribute("user", displayName);
            session.setAttribute("role", role);
            
            // Redirect to dashboard page
            response.sendRedirect(request.getContextPath() + redirectUrl);
        } else {
            // Authentication failed, redirect back to login page with error parameter
            response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
        }
    }
}
