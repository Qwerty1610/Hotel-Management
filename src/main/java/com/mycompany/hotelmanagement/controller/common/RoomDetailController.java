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
                
                // If database has no images, add default unsplash image URLs
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

                // Fetch amenities (including icons)
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

        // 2. Fallback to Mock Data if DB fails or room type is not found
        if (!dbSuccess || roomDetail == null) {
            roomDetail = getMockRoomDetail(typeId);
        }

        if (roomDetail == null) {
            // Room type ID does not exist in mocks either
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        // 3. Set attribute and forward
        request.setAttribute("room", roomDetail);
        request.getRequestDispatcher("/WEB-INF/views/home/room_detail.jsp").forward(request, response);
    }

    private RoomTypeInfo getMockRoomDetail(int typeId) {
        RoomTypeInfo room = new RoomTypeInfo();
        room.setTypeId(typeId);

        List<String> images = new ArrayList<>();
        List<String> amNames = new ArrayList<>();
        List<AmenityInfo> amDetails = new ArrayList<>();

        if (typeId == 1) {
            room.setTypeName("Phòng Standard");
            room.setBasePrice(750000.0);
            room.setPricePerHour(100000.0);
            room.setDepositPercent(10.0);
            room.setCapacity(2);
            room.setDescription("Phòng Standard tại HotelOps được thiết kế để tối ưu hóa sự thoải mái cho khách đi công tác hoặc nghỉ dưỡng ngắn ngày. Với không gian 25m², căn phòng mang đến sự cân bằng hoàn hảo giữa tính năng hiện đại và phong cách tối giản sang trọng. Mỗi chi tiết từ ánh sáng đến nội thất đều được chăm chút để mang lại trải nghiệm \"effortless control\" cho khách hàng.");
            room.setArea("25 m²");
            room.setBedType("1 Giường Queen");
            
            // Standard Room Images (4 images)
            images.add("https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80");
            
            // Amenities
            amDetails.add(new AmenityInfo("Điều hòa", "fa-snowflake"));
            amDetails.add(new AmenityInfo("Tivi HD", "fa-tv"));
            amDetails.add(new AmenityInfo("Wifi miễn phí", "fa-wifi"));
            amDetails.add(new AmenityInfo("Máy pha cà phê", "fa-glass"));
            
            room.setAvailableCount(3);
        } else if (typeId == 2 || typeId == 6) {
            // Deluxe / Deluxe City View
            room.setTypeName(typeId == 2 ? "Phòng Deluxe" : "Deluxe City View");
            room.setBasePrice(typeId == 2 ? 1200000.0 : 2950000.0);
            room.setPricePerHour(typeId == 2 ? 180000.0 : 300000.0);
            room.setDepositPercent(10.0);
            room.setCapacity(2);
            room.setDescription("Phòng Deluxe mang lại không gian lưu trú rộng rãi với hướng nhìn toàn cảnh thành phố rực rỡ sắc màu về đêm. Nội thất được thiết kế hiện đại, sang trọng, mang lại cảm giác thoải mái và thư thái tối đa cho quý khách trong suốt thời gian lưu trú.");
            room.setArea("45 m²");
            room.setBedType("1 Giường đôi lớn");
            
            // Deluxe Images
            images.add("https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=600");
            images.add("https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&q=80");
            
            // Amenities
            amDetails.add(new AmenityInfo("Wifi miễn phí", "fa-wifi"));
            amDetails.add(new AmenityInfo("Điều hòa", "fa-snowflake"));
            amDetails.add(new AmenityInfo("Tivi", "fa-tv"));
            amDetails.add(new AmenityInfo("View thành phố", "fa-city"));
            amDetails.add(new AmenityInfo("Mini bar", "fa-glass"));
            
            room.setAvailableCount(2);
        } else if (typeId == 3) {
            room.setTypeName("Phòng Family");
            room.setBasePrice(1800000.0);
            room.setPricePerHour(250000.0);
            room.setDepositPercent(10.0);
            room.setCapacity(4);
            room.setDescription("Không gian gia đình ấm cúng với hai giường ngủ lớn, đáp ứng trọn vẹn nhu cầu nghỉ dưỡng của nhóm bạn hoặc gia đình nhỏ từ 3 đến 4 thành viên. Trang thiết bị hiện đại cùng thiết kế trang nhã đảm bảo sự riêng tư và thoải mái tốt nhất.");
            room.setArea("60 m²");
            room.setBedType("2 Giường đôi");
            
            images.add("https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80");
            
            amDetails.add(new AmenityInfo("Wifi miễn phí", "fa-wifi"));
            amDetails.add(new AmenityInfo("Điều hòa", "fa-snowflake"));
            amDetails.add(new AmenityInfo("Tivi", "fa-tv"));
            amDetails.add(new AmenityInfo("Mini bar", "fa-glass"));
            
            room.setAvailableCount(2);
        } else if (typeId == 4 || typeId == 7) {
            // Suite / Executive Suite
            room.setTypeName(typeId == 4 ? "Phòng Suite" : "Executive Suite");
            room.setBasePrice(typeId == 4 ? 2800000.0 : 5500000.0);
            room.setPricePerHour(typeId == 4 ? 400000.0 : 600000.0);
            room.setDepositPercent(15.0);
            room.setCapacity(3);
            room.setDescription("Executive Suite mang đẳng cấp thượng lưu với thiết kế tích hợp phòng khách sang trọng và quầy bar nhỏ cao cấp ngay trong phòng. Tầm nhìn đắt giá cùng lối bày trí nội thất tinh tế hứa hẹn mang lại những giây phút nghỉ dưỡng đỉnh cao.");
            room.setArea("75 m²");
            room.setBedType("1 Giường King");
            
            images.add("https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&q=80");
            
            amDetails.add(new AmenityInfo("Wifi miễn phí", "fa-wifi"));
            amDetails.add(new AmenityInfo("Điều hòa", "fa-snowflake"));
            amDetails.add(new AmenityInfo("Tivi", "fa-tv"));
            amDetails.add(new AmenityInfo("Bồn tắm", "fa-bath"));
            amDetails.add(new AmenityInfo("View thành phố", "fa-city"));
            amDetails.add(new AmenityInfo("Mini bar", "fa-glass"));
            amDetails.add(new AmenityInfo("Ban công", "fa-door-open"));
            
            room.setAvailableCount(2);
        } else if (typeId == 8) {
            // Presidential Suite
            room.setTypeName("Presidential Suite");
            room.setBasePrice(12500000.0);
            room.setPricePerHour(1500000.0);
            room.setDepositPercent(20.0);
            room.setCapacity(4);
            room.setDescription("Căn hộ Tổng thống Presidential Suite là biểu tượng của sự xa hoa và quyền quý bậc nhất tại HotelOps. Lối đi riêng biệt, phòng họp biệt lập và quản gia túc trực phục vụ 24/7. Từng món đồ nội thất đều được chế tác thủ công cao cấp để đem lại trải nghiệm lưu trú thượng hạng và xứng tầm vị thế.");
            room.setArea("180 m²");
            room.setBedType("2 Giường King");
            
            images.add("https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80");
            images.add("https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80");
            
            amDetails.add(new AmenityInfo("Wifi miễn phí", "fa-wifi"));
            amDetails.add(new AmenityInfo("Điều hòa", "fa-snowflake"));
            amDetails.add(new AmenityInfo("Tivi", "fa-tv"));
            amDetails.add(new AmenityInfo("Bồn tắm", "fa-bath"));
            amDetails.add(new AmenityInfo("View thành phố", "fa-city"));
            amDetails.add(new AmenityInfo("Mini bar", "fa-glass"));
            amDetails.add(new AmenityInfo("Ban công", "fa-door-open"));
            
            room.setAvailableCount(1);
        } else {
            return null;
        }

        room.setImageUrls(images);
        room.setImageUrl(images.get(0));
        
        for (AmenityInfo am : amDetails) {
            amNames.add(am.getName());
        }
        room.setAmenities(amNames);
        room.setAmenityDetails(amDetails);

        return room;
    }
}
