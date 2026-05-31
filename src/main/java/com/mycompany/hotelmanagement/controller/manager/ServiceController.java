package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.mycompany.hotelmanagement.config.DBContext;

@WebServlet(name = "ServiceController", urlPatterns = {"/manager/services"})
public class ServiceController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Authorization check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"HOTEL_MANAGER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        int serviceId = -1;
        try {
            if (idParam != null) {
                serviceId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=services");
            return;
        }

        // 2. Perform DB operations based on GET action
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try {
                    conn.createStatement().execute("USE HotelManagementDB");
                } catch (SQLException e) {
                    // Ignore
                }

                if ("delete".equalsIgnoreCase(action) && serviceId != -1) {
                    String deleteSql = "DELETE FROM HotelService WHERE service_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                        ps.setInt(1, serviceId);
                        ps.executeUpdate();
                    }
                } else if ("toggle".equalsIgnoreCase(action) && serviceId != -1) {
                    String statusParam = request.getParameter("status");
                    boolean isActive = "true".equalsIgnoreCase(statusParam);
                    String toggleSql = "UPDATE HotelService SET is_active = ?, updated_at = SYSDATETIME() WHERE service_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(toggleSql)) {
                        ps.setBoolean(1, isActive);
                        ps.setInt(2, serviceId);
                        ps.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=services");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Authorization check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"HOTEL_MANAGER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        if ("save".equalsIgnoreCase(action)) {
            String serviceIdParam = request.getParameter("serviceId");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceParam = request.getParameter("price");
            String unit = request.getParameter("unit");

            if (name != null) name = name.trim();
            if (description != null) description = description.trim();
            if (unit != null) unit = unit.trim();

            double price = 0.0;
            try {
                if (priceParam != null) {
                    price = Double.parseDouble(priceParam.trim());
                }
            } catch (NumberFormatException e) {
                // keep 0.0
            }

            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    try {
                        conn.createStatement().execute("USE HotelManagementDB");
                    } catch (SQLException e) {
                        // Ignore
                    }

                    if (serviceIdParam == null || serviceIdParam.trim().isEmpty()) {
                        // Insert new service
                        String insertSql = "INSERT INTO HotelService (service_name, description, price, unit, is_active) VALUES (?, ?, ?, ?, 1)";
                        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                            ps.setString(1, name);
                            ps.setString(2, description);
                            ps.setDouble(3, price);
                            ps.setString(4, unit);
                            ps.executeUpdate();
                        }
                    } else {
                        // Update existing service
                        int serviceId = Integer.parseInt(serviceIdParam.trim());
                        String updateSql = "UPDATE HotelService SET service_name = ?, description = ?, price = ?, unit = ?, updated_at = SYSDATETIME() WHERE service_id = ?";
                        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                            ps.setString(1, name);
                            ps.setString(2, description);
                            ps.setDouble(3, price);
                            ps.setString(4, unit);
                            ps.setInt(5, serviceId);
                            ps.executeUpdate();
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=services");
    }
}
