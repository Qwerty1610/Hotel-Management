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

        // 3. Fallback to Mock Data if DB failed or has no room types
        if (!dbSuccess || allRoomTypes.isEmpty()) {
            allRoomTypes = getMockRoomTypes();
        }

        // 4. Perform in-memory filtering
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

        // 5. Set attributes for view rendering
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

    private List<RoomTypeInfo> getMockRoomTypes() {
        List<RoomTypeInfo> list = new ArrayList<>();

        // Standard Room
        RoomTypeInfo standard = new RoomTypeInfo();
        standard.setTypeId(1);
        standard.setTypeName("Phòng Standard");
        standard.setBasePrice(750000.0);
        standard.setPricePerHour(100000.0);
        standard.setDepositPercent(10.0);
        standard.setCapacity(2);
        standard.setDescription("Phòng tiêu chuẩn phù hợp cho khách đi công tác hoặc nghỉ ngắn ngày.");
        standard.setImageUrl("https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80");
        List<String> standardAm = new ArrayList<>();
        standardAm.add("Wifi miễn phí");
        standardAm.add("Điều hòa");
        standardAm.add("Tivi");
        standard.setAmenities(standardAm);
        list.add(standard);

        // Deluxe Room
        RoomTypeInfo deluxe = new RoomTypeInfo();
        deluxe.setTypeId(2);
        deluxe.setTypeName("Phòng Deluxe");
        deluxe.setBasePrice(1200000.0);
        deluxe.setPricePerHour(180000.0);
        deluxe.setDepositPercent(10.0);
        deluxe.setCapacity(2);
        deluxe.setDescription("Phòng rộng rãi, nội thất hiện đại, có view thành phố cực kỳ lung linh.");
        deluxe.setImageUrl("https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80");
        List<String> deluxeAm = new ArrayList<>();
        deluxeAm.add("Wifi miễn phí");
        deluxeAm.add("Điều hòa");
        deluxeAm.add("Tivi");
        deluxeAm.add("View thành phố");
        deluxeAm.add("Mini bar");
        deluxe.setAmenities(deluxeAm);
        list.add(deluxe);

        // Family Room
        RoomTypeInfo family = new RoomTypeInfo();
        family.setTypeId(3);
        family.setTypeName("Phòng Family");
        family.setBasePrice(1800000.0);
        family.setPricePerHour(250000.0);
        family.setDepositPercent(10.0);
        family.setCapacity(4);
        family.setDescription("Phòng gia đình với không gian lớn, phù hợp nhóm bạn hoặc gia đình nhỏ.");
        family.setImageUrl("https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80");
        List<String> familyAm = new ArrayList<>();
        familyAm.add("Wifi miễn phí");
        familyAm.add("Điều hòa");
        familyAm.add("Tivi");
        familyAm.add("Mini bar");
        family.setAmenities(familyAm);
        list.add(family);

        // Suite Room
        RoomTypeInfo suite = new RoomTypeInfo();
        suite.setTypeId(4);
        suite.setTypeName("Phòng Suite");
        suite.setBasePrice(2800000.0);
        suite.setPricePerHour(400000.0);
        suite.setDepositPercent(20.0);
        suite.setCapacity(3);
        suite.setDescription("Phòng cao cấp có khu tiếp khách riêng, bồn tắm và ban công.");
        suite.setImageUrl("https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80");
        List<String> suiteAm = new ArrayList<>();
        suiteAm.add("Wifi miễn phí");
        suiteAm.add("Điều hòa");
        suiteAm.add("Tivi");
        suiteAm.add("Bồn tắm");
        suiteAm.add("View thành phố");
        suiteAm.add("Mini bar");
        suiteAm.add("Ban công");
        suite.setAmenities(suiteAm);
        list.add(suite);

        // Deluxe City View
        RoomTypeInfo dcv = new RoomTypeInfo();
        dcv.setTypeId(6);
        dcv.setTypeName("Deluxe City View");
        dcv.setBasePrice(2950000.0);
        dcv.setPricePerHour(300000.0);
        dcv.setDepositPercent(10.0);
        dcv.setCapacity(2);
        dcv.setDescription("Không gian rộng rãi hướng toàn cảnh thành phố lung linh về đêm.");
        dcv.setImageUrl("https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600");
        List<String> dcvAm = new ArrayList<>();
        dcvAm.add("Wifi miễn phí");
        dcvAm.add("Điều hòa");
        dcvAm.add("Tivi");
        dcvAm.add("View thành phố");
        dcvAm.add("Mini bar");
        dcv.setAmenities(dcvAm);
        list.add(dcv);

        // Executive Suite
        RoomTypeInfo exec = new RoomTypeInfo();
        exec.setTypeId(7);
        exec.setTypeName("Executive Suite");
        exec.setBasePrice(5500000.0);
        exec.setPricePerHour(600000.0);
        exec.setDepositPercent(15.0);
        exec.setCapacity(3);
        exec.setDescription("Tích hợp phòng khách sang trọng và quầy bar nhỏ đẳng cấp cao.");
        exec.setImageUrl("https://images.unsplash.com/photo-1590490360182-c33d57733427?q=80&w=600");
        List<String> execAm = new ArrayList<>();
        execAm.add("Wifi miễn phí");
        execAm.add("Điều hòa");
        execAm.add("Tivi");
        execAm.add("Bồn tắm");
        execAm.add("View thành phố");
        execAm.add("Mini bar");
        execAm.add("Ban công");
        exec.setAmenities(execAm);
        list.add(exec);

        // Presidential Suite
        RoomTypeInfo pres = new RoomTypeInfo();
        pres.setTypeId(8);
        pres.setTypeName("Presidential Suite");
        pres.setBasePrice(12500000.0);
        pres.setPricePerHour(1500000.0);
        pres.setDepositPercent(20.0);
        pres.setCapacity(4);
        pres.setDescription("Căn hộ Tổng thống xa hoa bậc nhất với lối đi riêng và quản gia phục vụ.");
        pres.setImageUrl("https://images.unsplash.com/photo-1566665797739-1674de7a421a?q=80&w=600");
        List<String> presAm = new ArrayList<>();
        presAm.add("Wifi miễn phí");
        presAm.add("Điều hòa");
        presAm.add("Tivi");
        presAm.add("Bồn tắm");
        presAm.add("View thành phố");
        presAm.add("Mini bar");
        presAm.add("Ban công");
        pres.setAmenities(presAm);
        list.add(pres);

        return list;
    }
}
