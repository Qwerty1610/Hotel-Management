package com.mycompany.hotelmanagement.controller.customer;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerDashboardController", urlPatterns = {"/customer/dashboard"})
public class CustomerDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"CUSTOMER".equals(session.getAttribute("role"))) {
            // Unauthorized or wrong role, redirect back to login page with unauthorized error
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }
        
        // Authorized, forward to Customer Dashboard view
        request.getRequestDispatcher("/WEB-INF/views/dashboard/customer.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
