package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginController", urlPatterns = {"/home/login"})
public class LoginController extends HttpServlet {

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
        
        String role = null;
        String redirectUrl = null;
        
        // Mock authentication credentials check
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
            redirectUrl = "/customer/dashboard";
        }
        
        if (role != null) {
            // Authentication successful, establish session
            HttpSession session = request.getSession();
            session.setAttribute("user", username);
            session.setAttribute("role", role);
            
            // Redirect to dashboard page
            response.sendRedirect(request.getContextPath() + redirectUrl);
        } else {
            // Authentication failed, redirect back to login page with error parameter
            response.sendRedirect(request.getContextPath() + "/home/login?error=invalid_credentials");
        }
    }
}
