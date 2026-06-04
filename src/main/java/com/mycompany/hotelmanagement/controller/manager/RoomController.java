package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.RoomInfo;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.RoomService;
import com.mycompany.hotelmanagement.service.RoomTypeService;

/**
 * RoomController
 * URL: /manager/rooms
 *
 * Xử lý các hành động (action param):
 *   - view         : Hiển thị danh sách phòng và loại phòng (Manage Room)
 *   - save         : Thêm mới hoặc cập nhật thông tin phòng (Manage Room)
 *   - delete       : Xóa thông tin phòng (Manage Room)
 *   - updateStatus : Cập nhật trạng thái của phòng (Manage Room)
 * 
 * Date: 01/6/2026
 * @author DINH KHANH
 */
@WebServlet(name = "RoomController", urlPatterns = { "/manager/rooms" })
public class RoomController extends HttpServlet {

    private final RoomService roomService = new RoomService();
    private final RoomTypeService roomTypeService = new RoomTypeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        int roomId = -1;
        try {
            if (idParam != null) {
                roomId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/rooms");
            return;
        }

        if ("delete".equalsIgnoreCase(action) && roomId != -1) {
            boolean deleted = roomService.deleteRoom(roomId);
            if (!deleted) {
                response.sendRedirect(request.getContextPath() + "/manager/rooms?error=deleteError");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/manager/rooms?success=deleted");
            return;
        } else if ("updateStatus".equalsIgnoreCase(action) && roomId != -1) {
            String status = request.getParameter("status");
            if (status != null && !status.trim().isEmpty()) {
                roomService.updateRoomStatus(roomId, status.trim());
            }
            response.sendRedirect(request.getContextPath() + "/manager/rooms?success=saved");
            return;
        }

        List<RoomInfo> roomsList = roomService.getAllRooms();
        List<RoomTypeInfo> roomTypesList = roomTypeService.getAllRoomTypes();

        if (roomsList.isEmpty()) {
            if (roomTypesList.isEmpty()) {
                roomTypesList = getMockRoomTypes();
            }
            roomsList = getMockRooms(roomTypesList);
        }

        request.setAttribute("roomsList", roomsList);
        request.setAttribute("roomTypesList", roomTypesList);
        request.getRequestDispatcher("/WEB-INF/views/manager/rooms/list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("save".equalsIgnoreCase(action)) {
            String roomIdParam = request.getParameter("roomId");
            String roomNumber = request.getParameter("roomNumber");
            String floor = request.getParameter("floor");
            String typeIdParam = request.getParameter("typeId");
            String status = request.getParameter("status");

            if (roomNumber != null)
                roomNumber = roomNumber.trim();
            if (floor != null)
                floor = floor.trim();
            if (status != null)
                status = status.trim();

            int typeId = -1;
            try {
                if (typeIdParam != null) {
                    typeId = Integer.parseInt(typeIdParam.trim());
                }
            } catch (NumberFormatException e) {
                // keep -1
            }

            RoomInfo room = new RoomInfo();
            room.setRoomNumber(roomNumber);
            room.setFloor(floor);
            room.setTypeId(typeId);
            room.setStatus(status);

            if (roomIdParam != null && !roomIdParam.trim().isEmpty()) {
                try {
                    int roomId = Integer.parseInt(roomIdParam.trim());
                    room.setRoomId(roomId);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }

            // Duplicate Room Number validation
            if (roomNumber != null && !roomNumber.isEmpty()) {
                List<RoomInfo> existingRooms = roomService.getAllRooms();
                boolean isDuplicate = false;
                for (RoomInfo existing : existingRooms) {
                    if (existing.getRoomNumber().trim().equalsIgnoreCase(roomNumber.trim())) {
                        if (room.getRoomId() <= 0) {
                            isDuplicate = true;
                            break;
                        } else if (existing.getRoomId() != room.getRoomId()) {
                            isDuplicate = true;
                            break;
                        }
                    }
                }
                if (isDuplicate) {
                    response.sendRedirect(request.getContextPath() + "/manager/rooms?error=duplicateNumber");
                    return;
                }
            }

            roomService.saveRoom(room);
        }

        response.sendRedirect(request.getContextPath() + "/manager/rooms?success=saved");
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

        RoomTypeInfo standard = types.stream().filter(t -> t.getTypeName().contains("Standard")).findFirst()
                .orElse(null);
        RoomTypeInfo deluxe = types.stream().filter(t -> t.getTypeName().contains("Deluxe")).findFirst().orElse(null);
        RoomTypeInfo family = types.stream().filter(t -> t.getTypeName().contains("Family")).findFirst().orElse(null);
        RoomTypeInfo suite = types.stream().filter(t -> t.getTypeName().contains("Suite")).findFirst().orElse(null);

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

        RoomInfo r4 = new RoomInfo();
        r4.setRoomId(4);
        r4.setRoomNumber("401");
        r4.setTypeId(suite != null ? suite.getTypeId() : 4);
        r4.setFloor("Tầng 4");
        r4.setStatus("Maintenance");
        r4.setTypeName(suite != null ? suite.getTypeName() : "Phòng Suite");
        r4.setBasePrice(suite != null ? suite.getBasePrice() : 2800000.0);
        r4.setBedType(suite != null ? suite.getBedType() : "1 Giường King");
        r4.setArea(suite != null ? suite.getArea() : "75 m²");
        list.add(r4);

        return list;
    }
}
