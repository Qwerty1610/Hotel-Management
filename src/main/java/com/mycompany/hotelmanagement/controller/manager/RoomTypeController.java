package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.mycompany.hotelmanagement.config.DBContext;

@WebServlet(name = "RoomTypeController", urlPatterns = {"/manager/roomtypes"})
public class RoomTypeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Authorization check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"HOTEL_MANAGER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        // We only support Redirect back to Dashboard
        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=roomtypes");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Authorization check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"HOTEL_MANAGER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        if ("save".equalsIgnoreCase(action)) {
            String roomTypeIdParam = request.getParameter("roomTypeId");
            String name = request.getParameter("name");
            String priceParam = request.getParameter("price");
            String capacityParam = request.getParameter("capacity");
            String bedType = request.getParameter("bedType");
            String area = request.getParameter("area");
            String imageUrl = request.getParameter("imageUrl");
            String description = request.getParameter("description");
            String[] amenities = request.getParameterValues("amenity");

            if (name != null) name = name.trim();
            if (bedType != null) bedType = bedType.trim();
            if (area != null) area = area.trim();
            if (imageUrl != null) imageUrl = imageUrl.trim();
            if (description != null) description = description.trim();

            double price = 0.0;
            try {
                if (priceParam != null) {
                    price = Double.parseDouble(priceParam.trim());
                }
            } catch (NumberFormatException e) {
                // Keep 0.0
            }

            int capacity = 2;
            try {
                if (capacityParam != null) {
                    capacity = Integer.parseInt(capacityParam.trim());
                }
            } catch (NumberFormatException e) {
                // Keep 2
            }

            // Defaults for helper pricing columns in RoomType table
            double pricePerHour = price * 0.15;
            double depositPercent = 10.0;

            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    try {
                        conn.createStatement().execute("USE HotelManagementDB");
                    } catch (SQLException e) {
                        // Ignore
                    }

                    // Disable AutoCommit for transaction
                    conn.setAutoCommit(false);
                    try {
                        int typeId = -1;

                        if (roomTypeIdParam == null || roomTypeIdParam.trim().isEmpty()) {
                            // Insert RoomType
                            String insertRt = "INSERT INTO RoomType (type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                            try (PreparedStatement ps = conn.prepareStatement(insertRt, Statement.RETURN_GENERATED_KEYS)) {
                                ps.setString(1, name);
                                ps.setDouble(2, price);
                                ps.setDouble(3, pricePerHour);
                                ps.setDouble(4, depositPercent);
                                ps.setInt(5, capacity);
                                ps.setString(6, description);
                                ps.setString(7, area);
                                ps.setString(8, bedType);
                                ps.executeUpdate();

                                try (ResultSet rs = ps.getGeneratedKeys()) {
                                    if (rs.next()) {
                                        typeId = rs.getInt(1);
                                    }
                                }
                            }
                        } else {
                            // Update RoomType
                            typeId = Integer.parseInt(roomTypeIdParam.trim());
                            String updateRt = "UPDATE RoomType SET type_name = ?, base_price = ?, price_per_hour = ?, deposit_percent = ?, capacity = ?, description = ?, area = ?, bed_type = ? WHERE type_id = ?";
                            try (PreparedStatement ps = conn.prepareStatement(updateRt)) {
                                ps.setString(1, name);
                                ps.setDouble(2, price);
                                ps.setDouble(3, pricePerHour);
                                ps.setDouble(4, depositPercent);
                                ps.setInt(5, capacity);
                                ps.setString(6, description);
                                ps.setString(7, area);
                                ps.setString(8, bedType);
                                ps.setInt(9, typeId);
                                ps.executeUpdate();
                            }
                        }

                        if (typeId != -1) {
                            // Save Image: Delete old images and insert new image URL
                            String deleteImg = "DELETE FROM RoomImage WHERE type_id = ?";
                            try (PreparedStatement ps = conn.prepareStatement(deleteImg)) {
                                ps.setInt(1, typeId);
                                ps.executeUpdate();
                            }

                            if (imageUrl != null && !imageUrl.isEmpty()) {
                                String insertImg = "INSERT INTO RoomImage (type_id, image_url) VALUES (?, ?)";
                                try (PreparedStatement ps = conn.prepareStatement(insertImg)) {
                                    ps.setInt(1, typeId);
                                    ps.setString(2, imageUrl);
                                    ps.executeUpdate();
                                }
                            }

                            // Save Amenities: Delete old mappings and insert checked ones
                            String deleteAm = "DELETE FROM RoomType_Amenity WHERE type_id = ?";
                            try (PreparedStatement ps = conn.prepareStatement(deleteAm)) {
                                ps.setInt(1, typeId);
                                ps.executeUpdate();
                            }

                            if (amenities != null && amenities.length > 0) {
                                for (String amName : amenities) {
                                    int amenityId = -1;
                                    
                                    // Try to select amenity_id
                                    String selectAm = "SELECT amenity_id FROM Amenity WHERE name = ?";
                                    try (PreparedStatement ps = conn.prepareStatement(selectAm)) {
                                        ps.setString(1, amName);
                                        try (ResultSet rs = ps.executeQuery()) {
                                            if (rs.next()) {
                                                amenityId = rs.getInt("amenity_id");
                                            }
                                        }
                                    }

                                    // If not exists, insert it
                                    if (amenityId == -1) {
                                        String insertAm = "INSERT INTO Amenity (name, icon_url) VALUES (?, ?)";
                                        String iconUrl = "fa-wifi"; // Default icon mapping
                                        if (amName.contains("Điều hòa")) iconUrl = "fa-snowflake";
                                        else if (amName.contains("Tivi")) iconUrl = "fa-tv";
                                        else if (amName.contains("View")) iconUrl = "fa-city";
                                        else if (amName.contains("bar")) iconUrl = "fa-glass";
                                        else if (amName.contains("tắm")) iconUrl = "fa-bath";
                                        else if (amName.contains("công")) iconUrl = "fa-door-open";
                                        else if (amName.contains("cà phê")) iconUrl = "fa-mug-hot";

                                        try (PreparedStatement ps = conn.prepareStatement(insertAm, Statement.RETURN_GENERATED_KEYS)) {
                                            ps.setString(1, amName);
                                            ps.setString(2, iconUrl);
                                            ps.executeUpdate();
                                            try (ResultSet rs = ps.getGeneratedKeys()) {
                                                if (rs.next()) {
                                                    amenityId = rs.getInt(1);
                                                }
                                            }
                                        }
                                    }

                                    // Link RoomType and Amenity
                                    if (amenityId != -1) {
                                        String insertMapping = "INSERT INTO RoomType_Amenity (type_id, amenity_id) VALUES (?, ?)";
                                        try (PreparedStatement ps = conn.prepareStatement(insertMapping)) {
                                            ps.setInt(1, typeId);
                                            ps.setInt(2, amenityId);
                                            ps.executeUpdate();
                                        }
                                    }
                                }
                            }
                        }

                        // Commit changes
                        conn.commit();
                    } catch (Exception e) {
                        conn.rollback();
                        throw e;
                    } finally {
                        conn.setAutoCommit(true);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=roomtypes");
    }
}
