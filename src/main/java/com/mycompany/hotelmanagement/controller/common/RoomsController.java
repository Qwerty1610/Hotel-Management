package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;

@WebServlet(name = "RoomsController", urlPatterns = {"/rooms"})
public class RoomsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get search filter parameters
        String typeIdParam = request.getParameter("typeId");
        String minPriceParam = request.getParameter("minPrice");
        String maxPriceParam = request.getParameter("maxPrice");
        String guestsParam = request.getParameter("guests");

        int typeIdFilter = -1;
        double minPriceFilter = 0.0;
        double maxPriceFilter = Double.MAX_VALUE;
        int guestsFilter = -1;

        try {
            if (typeIdParam != null && !typeIdParam.trim().isEmpty() && !"all".equalsIgnoreCase(typeIdParam)) {
                typeIdFilter = Integer.parseInt(typeIdParam);
            }
        } catch (NumberFormatException e) {
            // keep -1
        }

        try {
            if (minPriceParam != null && !minPriceParam.trim().isEmpty()) {
                minPriceFilter = Double.parseDouble(minPriceParam.replaceAll("[^0-9.]", ""));
            }
        } catch (NumberFormatException e) {
            // keep 0.0
        }

        try {
            if (maxPriceParam != null && !maxPriceParam.trim().isEmpty() && !"Không giới hạn".equalsIgnoreCase(maxPriceParam)) {
                maxPriceFilter = Double.parseDouble(maxPriceParam.replaceAll("[^0-9.]", ""));
            }
        } catch (NumberFormatException e) {
            // keep Double.MAX_VALUE
        }

        try {
            if (guestsParam != null && !guestsParam.trim().isEmpty() && !"all".equalsIgnoreCase(guestsParam)) {
                guestsFilter = Integer.parseInt(guestsParam);
            }
        } catch (NumberFormatException e) {
            // keep -1
        }

        List<RoomTypeInfo> allRoomTypes = new ArrayList<>();
        boolean dbSuccess = false;

        // 2. Fetch data from DB
        try (Connection conn = DBContext.getConnection()) {
            dbSuccess = true;
            try {
                conn.createStatement().execute("USE HotelManagementDB");
            } catch (SQLException e) {
                // Ignore if USE fails
            }

            // Maps to collect details
            Map<Integer, List<String>> typeImages = new HashMap<>();
            Map<Integer, List<String>> typeAmenities = new HashMap<>();

            // Fetch RoomImages
            String imgSql = "SELECT type_id, image_url FROM RoomImage";
            try (PreparedStatement ps = conn.prepareStatement(imgSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int tId = rs.getInt("type_id");
                    String url = rs.getString("image_url");
                    typeImages.computeIfAbsent(tId, k -> new ArrayList<>()).add(url);
                }
            }

            // Fetch Amenities
            String amenitySql = "SELECT ra.type_id, a.name FROM Amenity a JOIN RoomType_Amenity ra ON a.amenity_id = ra.amenity_id";
            try (PreparedStatement ps = conn.prepareStatement(amenitySql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int tId = rs.getInt("type_id");
                    String name = rs.getString("name");
                    typeAmenities.computeIfAbsent(tId, k -> new ArrayList<>()).add(name);
                }
            }

            // Fetch RoomTypes
            String rtSql = "SELECT type_id, type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type FROM RoomType";
            try (PreparedStatement ps = conn.prepareStatement(rtSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int tId = rs.getInt("type_id");
                    String name = rs.getString("type_name");
                    double basePrice = rs.getDouble("base_price");
                    double pricePerHour = rs.getDouble("price_per_hour");
                    double deposit = rs.getDouble("deposit_percent");
                    int cap = rs.getInt("capacity");
                    String desc = rs.getString("description");
                    String area = rs.getString("area");
                    String bedType = rs.getString("bed_type");

                    RoomTypeInfo info = new RoomTypeInfo();
                    info.setTypeId(tId);
                    info.setTypeName(name);
                    info.setBasePrice(basePrice);
                    info.setPricePerHour(pricePerHour);
                    info.setDepositPercent(deposit);
                    info.setCapacity(cap);
                    info.setDescription(desc);
                    info.setArea(area);
                    info.setBedType(bedType);

                    // Attach images
                    List<String> images = typeImages.get(tId);
                    if (images != null && !images.isEmpty()) {
                        info.setImageUrl(images.get(0)); // Primary image
                    } else {
                        info.setImageUrl("https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600");
                    }

                    // Attach amenities
                    List<String> amenities = typeAmenities.get(tId);
                    if (amenities != null) {
                        info.setAmenities(amenities);
                    } else {
                        info.setAmenities(new ArrayList<>());
                    }

                    allRoomTypes.add(info);
                }
            }

        } catch (SQLException e) {
            dbSuccess = false;
            e.printStackTrace();
        }

        // Perform in-memory filtering
        List<RoomTypeInfo> filteredRoomTypes = new ArrayList<>();
        for (RoomTypeInfo room : allRoomTypes) {
            // Filter by Room Type ID
            if (typeIdFilter != -1 && room.getTypeId() != typeIdFilter) {
                continue;
            }

            // Filter by Capacity (Guests)
            if (guestsFilter != -1 && room.getCapacity() < guestsFilter) {
                continue;
            }

            // Filter by Price range
            double finalPrice = room.getBasePrice();
            if (finalPrice < minPriceFilter || finalPrice > maxPriceFilter) {
                continue;
            }

            filteredRoomTypes.add(room);
        }

        // Set attributes for view rendering
        request.setAttribute("roomTypes", filteredRoomTypes);
        request.setAttribute("allRoomTypesList", allRoomTypes); // For selection dropdown
        request.setAttribute("selectedTypeId", typeIdParam != null ? typeIdParam : "all");
        request.setAttribute("selectedMinPrice", minPriceParam != null ? minPriceParam : "");
        request.setAttribute("selectedMaxPrice", maxPriceParam != null ? maxPriceParam : "");
        request.setAttribute("selectedGuests", guestsParam != null ? guestsParam : "all");
        request.setAttribute("resultsCount", filteredRoomTypes.size());

        // Forward to rooms.jsp
        request.getRequestDispatcher("/WEB-INF/views/home/rooms.jsp").forward(request, response);
    }
}
