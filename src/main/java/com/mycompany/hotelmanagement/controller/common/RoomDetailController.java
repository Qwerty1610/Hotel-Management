package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.AmenityInfo;

@WebServlet(name = "RoomDetailController", urlPatterns = {"/rooms/detail"})
public class RoomDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        int typeId = -1;
        try {
            typeId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        RoomTypeInfo roomDetail = null;
        boolean dbSuccess = false;

        // 1. Fetch details from database
        try (Connection conn = DBContext.getConnection()) {
            dbSuccess = true;
            try {
                conn.createStatement().execute("USE HotelManagementDB");
            } catch (SQLException e) {
                // Ignore
            }

            // Query RoomType
            String rtSql = "SELECT type_id, type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type FROM RoomType WHERE type_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(rtSql)) {
                ps.setInt(1, typeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        roomDetail = new RoomTypeInfo();
                        roomDetail.setTypeId(rs.getInt("type_id"));
                        roomDetail.setTypeName(rs.getString("type_name"));
                        roomDetail.setBasePrice(rs.getDouble("base_price"));
                        roomDetail.setPricePerHour(rs.getDouble("price_per_hour"));
                        roomDetail.setDepositPercent(rs.getDouble("deposit_percent"));
                        roomDetail.setCapacity(rs.getInt("capacity"));
                        roomDetail.setDescription(rs.getString("description"));
                        roomDetail.setArea(rs.getString("area"));
                        roomDetail.setBedType(rs.getString("bed_type"));
                    }
                }
            }

            if (roomDetail != null) {
                // Fetch images for this type
                List<String> imageUrls = new ArrayList<>();
                String imgSql = "SELECT image_url FROM RoomImage WHERE type_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(imgSql)) {
                    ps.setInt(1, typeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            imageUrls.add(rs.getString("image_url"));
                        }
                    }
                }
                
                // Add default unsplash image URLs
                if (imageUrls.isEmpty()) {
                    if (typeId == 1) {
                        imageUrls.add("https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80");
                    } else if (typeId == 2 || typeId == 6) {
                        imageUrls.add("https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600");
                    } else if (typeId == 3) {
                        imageUrls.add("https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80");
                    } else {
                        imageUrls.add("https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80");
                    }
                }
                roomDetail.setImageUrls(imageUrls);
                roomDetail.setImageUrl(imageUrls.get(0));

                // Fetch amenities
                List<String> amenityNames = new ArrayList<>();
                List<AmenityInfo> amenityDetails = new ArrayList<>();
                String amenitySql = "SELECT a.name, a.icon_url FROM Amenity a JOIN RoomType_Amenity ra ON a.amenity_id = ra.amenity_id WHERE ra.type_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(amenitySql)) {
                    ps.setInt(1, typeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String name = rs.getString("name");
                            String icon = rs.getString("icon_url");
                            amenityNames.add(name);
                            amenityDetails.add(new AmenityInfo(name, icon));
                        }
                    }
                }
                roomDetail.setAmenities(amenityNames);
                roomDetail.setAmenityDetails(amenityDetails);

                // Fetch live available room count
                int availableCount = 0;
                String countSql = "SELECT COUNT(*) FROM Room WHERE type_id = ? AND status = 'Available'";
                try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                    ps.setInt(1, typeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            availableCount = rs.getInt(1);
                        }
                    }
                }
                roomDetail.setAvailableCount(availableCount);
            }

        } catch (SQLException e) {
            dbSuccess = false;
            e.printStackTrace();
        }

        if (roomDetail == null) {
            // Room type ID does not exist in database or database query failed
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        // Set attribute and forward
        request.setAttribute("room", roomDetail);
        request.getRequestDispatcher("/WEB-INF/views/home/room_detail.jsp").forward(request, response);
    }
}
