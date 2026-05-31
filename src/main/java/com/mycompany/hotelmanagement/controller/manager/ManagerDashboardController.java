package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.HotelService;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.RoomInfo;

@WebServlet(name = "ManagerDashboardController", urlPatterns = {"/manager/dashboard"})
public class ManagerDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"HOTEL_MANAGER".equals(session.getAttribute("role"))) {
            // Unauthorized or wrong role, redirect back to login page with unauthorized error
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String tab = request.getParameter("tab");
        if ("services".equalsIgnoreCase(tab)) {
            List<HotelService> servicesList = new ArrayList<>();
            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    try {
                        conn.createStatement().execute("USE HotelManagementDB");
                    } catch (SQLException e) {
                        // Ignore if USE database fails
                    }

                    String sql = "SELECT service_id, service_name, description, price, unit, is_active FROM HotelService ORDER BY service_id";
                    try (PreparedStatement ps = conn.prepareStatement(sql);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            HotelService hs = new HotelService();
                            hs.setServiceId(rs.getInt("service_id"));
                            hs.setServiceName(rs.getString("service_name"));
                            hs.setDescription(rs.getString("description"));
                            hs.setPrice(rs.getDouble("price"));
                            hs.setUnit(rs.getString("unit"));
                            hs.setIsActive(rs.getBoolean("is_active"));
                            servicesList.add(hs);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            request.setAttribute("servicesList", servicesList);
        } else if ("roomtypes".equalsIgnoreCase(tab)) {
            List<RoomTypeInfo> roomTypesList = new ArrayList<>();
            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    try {
                        conn.createStatement().execute("USE HotelManagementDB");
                    } catch (SQLException e) {
                        // Ignore
                    }

                    Map<Integer, List<String>> typeImages = new HashMap<>();
                    Map<Integer, List<String>> typeAmenities = new HashMap<>();

                    // Fetch images
                    String imgSql = "SELECT type_id, image_url FROM RoomImage";
                    try (PreparedStatement ps = conn.prepareStatement(imgSql);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int tId = rs.getInt("type_id");
                            String url = rs.getString("image_url");
                            typeImages.computeIfAbsent(tId, k -> new ArrayList<>()).add(url);
                        }
                    }

                    // Fetch amenities
                    String amenitySql = "SELECT ra.type_id, a.name FROM Amenity a JOIN RoomType_Amenity ra ON a.amenity_id = ra.amenity_id";
                    try (PreparedStatement ps = conn.prepareStatement(amenitySql);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int tId = rs.getInt("type_id");
                            String name = rs.getString("name");
                            typeAmenities.computeIfAbsent(tId, k -> new ArrayList<>()).add(name);
                        }
                    }

                    // Fetch room types
                    String rtSql = "SELECT type_id, type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type FROM RoomType ORDER BY type_id";
                    try (PreparedStatement ps = conn.prepareStatement(rtSql);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int tId = rs.getInt("type_id");
                            RoomTypeInfo info = new RoomTypeInfo();
                            info.setTypeId(tId);
                            info.setTypeName(rs.getString("type_name"));
                            info.setBasePrice(rs.getDouble("base_price"));
                            info.setPricePerHour(rs.getDouble("price_per_hour"));
                            info.setDepositPercent(rs.getDouble("deposit_percent"));
                            info.setCapacity(rs.getInt("capacity"));
                            info.setDescription(rs.getString("description"));
                            info.setArea(rs.getString("area"));
                            info.setBedType(rs.getString("bed_type"));

                            List<String> imgUrls = typeImages.get(tId);
                            if (imgUrls != null && !imgUrls.isEmpty()) {
                                info.setImageUrl(imgUrls.get(0));
                                info.setImageUrls(imgUrls);
                            } else {
                                info.setImageUrl("https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600");
                                info.setImageUrls(new ArrayList<>());
                            }

                            List<String> amList = typeAmenities.get(tId);
                            if (amList != null) {
                                info.setAmenities(amList);
                            } else {
                                info.setAmenities(new ArrayList<>());
                            }

                            roomTypesList.add(info);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (roomTypesList.isEmpty()) {
                roomTypesList = getMockRoomTypes();
            }
            request.setAttribute("roomTypesList", roomTypesList);
        } else if ("rooms".equalsIgnoreCase(tab)) {
            List<RoomInfo> roomsList = new ArrayList<>();
            List<RoomTypeInfo> roomTypesList = new ArrayList<>();
            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    try {
                        conn.createStatement().execute("USE HotelManagementDB");
                    } catch (SQLException e) {
                        // Ignore
                    }

                    // Fetch RoomTypes (needed for modal types dropdown)
                    String rtSql = "SELECT type_id, type_name, base_price, capacity, area, bed_type FROM RoomType ORDER BY type_id";
                    try (PreparedStatement ps = conn.prepareStatement(rtSql);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            RoomTypeInfo info = new RoomTypeInfo();
                            info.setTypeId(rs.getInt("type_id"));
                            info.setTypeName(rs.getString("type_name"));
                            info.setBasePrice(rs.getDouble("base_price"));
                            info.setCapacity(rs.getInt("capacity"));
                            info.setArea(rs.getString("area"));
                            info.setBedType(rs.getString("bed_type"));
                            roomTypesList.add(info);
                        }
                    }

                    // Fetch Rooms
                    String rSql = "SELECT r.room_id, r.room_number, r.type_id, r.status, r.floor, " +
                                  "rt.type_name, rt.base_price, rt.bed_type, rt.area " +
                                  "FROM Room r " +
                                  "JOIN RoomType rt ON r.type_id = rt.type_id " +
                                  "ORDER BY r.room_number";
                    try (PreparedStatement ps = conn.prepareStatement(rSql);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            RoomInfo room = new RoomInfo();
                            room.setRoomId(rs.getInt("room_id"));
                            room.setRoomNumber(rs.getString("room_number"));
                            room.setTypeId(rs.getInt("type_id"));
                            room.setStatus(rs.getString("status"));
                            room.setFloor(rs.getString("floor"));
                            room.setTypeName(rs.getString("type_name"));
                            room.setBasePrice(rs.getDouble("base_price"));
                            room.setBedType(rs.getString("bed_type"));
                            room.setArea(rs.getString("area"));
                            roomsList.add(room);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (roomsList.isEmpty()) {
                if (roomTypesList.isEmpty()) {
                    roomTypesList = getMockRoomTypes();
                }
                roomsList = getMockRooms(roomTypesList);
            }
            
            request.setAttribute("roomsList", roomsList);
            request.setAttribute("roomTypesList", roomTypesList);
        }
        
        // Authorized, forward to Hotel Manager Dashboard view
        request.getRequestDispatcher("/WEB-INF/views/dashboard/manager.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private List<RoomTypeInfo> getMockRoomTypes() {
        List<RoomTypeInfo> list = new ArrayList<>();

        RoomTypeInfo standard = new RoomTypeInfo();
        standard.setTypeId(1);
        standard.setTypeName("Phòng Standard");
        standard.setBasePrice(750000.0);
        standard.setCapacity(2);
        standard.setArea("25 m²");
        standard.setBedType("1 Giường Queen");
        standard.setImageUrl("https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80");
        List<String> standardAm = new ArrayList<>();
        standardAm.add("Wifi miễn phí");
        standardAm.add("Điều hòa");
        standardAm.add("Tivi");
        standard.setAmenities(standardAm);
        list.add(standard);

        RoomTypeInfo deluxe = new RoomTypeInfo();
        deluxe.setTypeId(2);
        deluxe.setTypeName("Phòng Deluxe");
        deluxe.setBasePrice(1200000.0);
        deluxe.setCapacity(2);
        deluxe.setArea("45 m²");
        deluxe.setBedType("1 Giường đôi lớn");
        deluxe.setImageUrl("https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80");
        List<String> deluxeAm = new ArrayList<>();
        deluxeAm.add("Wifi miễn phí");
        deluxeAm.add("Điều hòa");
        deluxeAm.add("Tivi");
        deluxeAm.add("View thành phố");
        deluxeAm.add("Mini bar");
        deluxe.setAmenities(deluxeAm);
        list.add(deluxe);

        RoomTypeInfo family = new RoomTypeInfo();
        family.setTypeId(3);
        family.setTypeName("Phòng Family");
        family.setBasePrice(1800000.0);
        family.setCapacity(4);
        family.setArea("60 m²");
        family.setBedType("2 Giường đôi");
        family.setImageUrl("https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80");
        List<String> familyAm = new ArrayList<>();
        familyAm.add("Wifi miễn phí");
        familyAm.add("Điều hòa");
        familyAm.add("Tivi");
        familyAm.add("Mini bar");
        family.setAmenities(familyAm);
        list.add(family);

        RoomTypeInfo suite = new RoomTypeInfo();
        suite.setTypeId(4);
        suite.setTypeName("Phòng Suite");
        suite.setBasePrice(2800000.0);
        suite.setCapacity(3);
        suite.setArea("75 m²");
        suite.setBedType("1 Giường King");
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

        return list;
    }

    private List<RoomInfo> getMockRooms(List<RoomTypeInfo> types) {
        List<RoomInfo> list = new ArrayList<>();
        
        RoomTypeInfo standard = types.stream().filter(t -> t.getTypeName().contains("Standard")).findFirst().orElse(null);
        RoomTypeInfo deluxe = types.stream().filter(t -> t.getTypeName().contains("Deluxe")).findFirst().orElse(null);
        RoomTypeInfo family = types.stream().filter(t -> t.getTypeName().contains("Family")).findFirst().orElse(null);
        RoomTypeInfo suite = types.stream().filter(t -> t.getTypeName().contains("Suite")).findFirst().orElse(null);

        // Room 101
        RoomInfo r1 = new RoomInfo();
        r1.setRoomId(1);
        r1.setRoomNumber("101");
        r1.setTypeId(standard != null ? standard.getTypeId() : 1);
        r1.setFloor("Tầng 1");
        r1.setStatus("Available");
        r1.setTypeName(standard != null ? standard.getTypeName() : "Phòng Standard");
        r1.setBasePrice(standard != null ? standard.getBasePrice() : 750000.0);
        r1.setBedType(standard != null ? standard.getBedType() : "1 Giường Queen");
        r1.setArea(standard != null ? standard.getArea() : "25 m²");
        list.add(r1);

        // Room 204
        RoomInfo r2 = new RoomInfo();
        r2.setRoomId(2);
        r2.setRoomNumber("204");
        r2.setTypeId(deluxe != null ? deluxe.getTypeId() : 2);
        r2.setFloor("Tầng 2");
        r2.setStatus("Occupied");
        r2.setTypeName(deluxe != null ? deluxe.getTypeName() : "Phòng Deluxe");
        r2.setBasePrice(deluxe != null ? deluxe.getBasePrice() : 1200000.0);
        r2.setBedType(deluxe != null ? deluxe.getBedType() : "1 Giường đôi lớn");
        r2.setArea(deluxe != null ? deluxe.getArea() : "45 m²");
        list.add(r2);

        // Room 305
        RoomInfo r3 = new RoomInfo();
        r3.setRoomId(3);
        r3.setRoomNumber("305");
        r3.setTypeId(family != null ? family.getTypeId() : 3);
        r3.setFloor("Tầng 3");
        r3.setStatus("Cleaning");
        r3.setTypeName(family != null ? family.getTypeName() : "Phòng Family");
        r3.setBasePrice(family != null ? family.getBasePrice() : 1800000.0);
        r3.setBedType(family != null ? family.getBedType() : "2 Giường đôi");
        r3.setArea(family != null ? family.getArea() : "60 m²");
        list.add(r3);

        // Room 401
        RoomInfo r4 = new RoomInfo();
        r4.setRoomId(4);
        r4.setRoomNumber("401");
        r4.setTypeId(suite != null ? suite.getTypeId() : 4);
        r4.setFloor("Tầng VIP");
        r4.setStatus("Maintenance");
        r4.setTypeName(suite != null ? suite.getTypeName() : "Phòng Suite");
        r4.setBasePrice(suite != null ? suite.getBasePrice() : 2800000.0);
        r4.setBedType(suite != null ? suite.getBedType() : "1 Giường King");
        r4.setArea(suite != null ? suite.getArea() : "75 m²");
        list.add(r4);

        return list;
    }
}
