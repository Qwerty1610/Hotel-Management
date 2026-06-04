package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.RoomTypeService;

/**
 * RoomTypeController
 * URL: /manager/roomtypes
 *
 * Xử lý các hành động (action param):
 *   - view   : Hiển thị danh sách loại phòng (Manage Room Type)
 *   - save   : Thêm mới hoặc cập nhật thông tin loại phòng (Manage Room Type)
 *   - delete : Xóa loại phòng (Manage Room Type)
 * 
 * Date: 01/6/2026
 * @author DINH KHANH
 */
@WebServlet(name = "RoomTypeController", urlPatterns = { "/manager/roomtypes" })
public class RoomTypeController extends HttpServlet {

    private final RoomTypeService roomTypeService = new RoomTypeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        int roomTypeId = -1;
        try {
            if (idParam != null) {
                roomTypeId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/roomtypes");
            return;
        }

        if ("delete".equalsIgnoreCase(action) && roomTypeId != -1) {
            try {
                roomTypeService.deleteRoomType(roomTypeId);
                response.sendRedirect(request.getContextPath() + "/manager/roomtypes?success=deleted");
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/manager/roomtypes?error=deleteError");
            }
            return;
        }

        List<RoomTypeInfo> roomTypesList = roomTypeService.getAllRoomTypes();
        if (roomTypesList.isEmpty()) {
            roomTypesList = getMockRoomTypes();
        }
        request.setAttribute("roomTypesList", roomTypesList);
        request.getRequestDispatcher("/WEB-INF/views/manager/room-types/list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        System.out.println("[RoomTypeController] doPost called with action: " + action);

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

            System.out.println("[RoomTypeController] Form values: name=" + name +
                    ", price=" + priceParam +
                    ", capacity=" + capacityParam +
                    ", bedType=" + bedType +
                    ", area=" + area +
                    ", image=" + imageUrl +
                    ", roomTypeId=" + roomTypeIdParam);

            if (name != null)
                name = name.trim();
            if (bedType != null)
                bedType = bedType.trim();
            if (area != null)
                area = area.trim();
            if (imageUrl != null)
                imageUrl = imageUrl.trim();
            if (description != null)
                description = description.trim();

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

            RoomTypeInfo rt = new RoomTypeInfo();
            rt.setTypeName(name);
            rt.setBasePrice(price);
            rt.setPricePerHour(pricePerHour);
            rt.setDepositPercent(depositPercent);
            rt.setCapacity(capacity);
            rt.setDescription(description);
            rt.setArea(area);
            rt.setBedType(bedType);

            if (roomTypeIdParam != null && !roomTypeIdParam.trim().isEmpty()) {
                try {
                    int typeId = Integer.parseInt(roomTypeIdParam.trim());
                    rt.setTypeId(typeId);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }

            // Duplicate Room Type Name validation
            if (name != null && !name.isEmpty()) {
                List<RoomTypeInfo> existingTypes = roomTypeService.getAllRoomTypes();
                boolean isDuplicate = false;
                for (RoomTypeInfo existing : existingTypes) {
                    boolean sameName = existing.getTypeName().trim().equalsIgnoreCase(name.trim());
                    if (sameName) {
                        if (rt.getTypeId() <= 0) {
                            isDuplicate = true;
                            break;
                        } else if (existing.getTypeId() != rt.getTypeId()) {
                            isDuplicate = true;
                            break;
                        }
                    }
                }
                if (isDuplicate) {
                    response.sendRedirect(request.getContextPath() + "/manager/roomtypes?error=duplicateName");
                    return;
                }
            }

            roomTypeService.saveRoomType(rt, imageUrl, amenities);
        }

        response.sendRedirect(request.getContextPath() + "/manager/roomtypes?success=saved");
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
}
