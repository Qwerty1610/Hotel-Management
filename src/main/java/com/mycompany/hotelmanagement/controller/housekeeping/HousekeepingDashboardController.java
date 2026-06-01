package com.mycompany.hotelmanagement.controller.housekeeping;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "HousekeepingDashboardController", urlPatterns = {"/housekeeping/dashboard"})
public class HousekeepingDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Authorized (by AuthFilter), forward to Housekeeping Dashboard view
        request.getRequestDispatcher("/WEB-INF/views/dashboard/housekeeping.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
