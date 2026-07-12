package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.mycompany.hotelmanagement.entity.AmenityInfo;
import com.mycompany.hotelmanagement.service.AmenityService;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.RoomTypeService;
import com.google.gson.Gson;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;

/**
 * AmenityController
 * URL: controller/manager
 *
 * Xử lý các hành động (action param):
 * - view : Hiển thị danh sách tiện nghi
 * - save : Thêm mới hoặc cập nhật thông tin tiện nghi
 * - delete : Xóa tiện nghi
 * - toggle : Bật tắt trạng thái
 * - assign : Áp dụng cho loại phòng
 * 
 * Date: 10/7/2026
 * 
 * @author DUC BINH
 * @version 1.1
 */

@WebServlet(name = "AmenityController", urlPatterns = { "/manager/amenities" })
public class AmenityController extends HttpServlet {

    private final AmenityService amenityService = new AmenityService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        int amenityId = -1;
        try {
            if (idParam != null && !idParam.trim().isEmpty()) {
                amenityId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/amenities");
            return;
        }

        if ("toggle".equalsIgnoreCase(action) && amenityId != -1) {
            String statusParam = request.getParameter("status");
            boolean isActive = "true".equalsIgnoreCase(statusParam);
            amenityService.toggleAmenityStatus(amenityId, isActive);
            response.sendRedirect(request.getContextPath() + "/manager/amenities");
            return;
        }

        if ("delete".equalsIgnoreCase(action) && amenityId != -1) {
            amenityService.deleteAmenity(amenityId);
            response.sendRedirect(request.getContextPath() + "/manager/amenities?success=deleted");
            return;
        }

        List<AmenityInfo> amenitiesList = amenityService.getAllAmenities();
        List<RoomTypeInfo> roomTypesList = new RoomTypeService().getAllRoomTypes();

        Map<Integer, List<Integer>> assignedRoomTypesMap = new HashMap<>();
        for (AmenityInfo a : amenitiesList) {
            assignedRoomTypesMap.put(a.getAmenityId(), amenityService.getAssignedRoomTypeIds(a.getAmenityId()));
        }

        request.setAttribute("amenitiesList", amenitiesList);
        request.setAttribute("roomTypesList", roomTypesList);
        request.setAttribute("assignedRoomTypesMapJson", new Gson().toJson(assignedRoomTypesMap));
        request.getRequestDispatcher("/WEB-INF/views/manager/amenities-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("assign".equalsIgnoreCase(action)) {
            String amenityIdParam = request.getParameter("amenityId");
            String[] roomTypeIdsParam = request.getParameterValues("roomTypeIds");

            try {
                int amenityId = Integer.parseInt(amenityIdParam.trim());
                List<Integer> roomTypeIds = new ArrayList<>();
                if (roomTypeIdsParam != null) {
                    for (String rtId : roomTypeIdsParam) {
                        roomTypeIds.add(Integer.parseInt(rtId.trim()));
                    }
                }
                amenityService.assignToRoomTypes(amenityId, roomTypeIds);
            } catch (Exception e) {
                // Ignore parsing errors
            }
            response.sendRedirect(request.getContextPath() + "/manager/amenities?success=assigned");
            return;
        }

        if ("save".equalsIgnoreCase(action)) {
            String amenityIdParam = request.getParameter("amenityId");
            String name = request.getParameter("name");
            String icon = request.getParameter("icon");

            if (name != null)
                name = name.trim();
            if (icon != null)
                icon = icon.trim();

            if (name == null || name.isEmpty() || icon == null || icon.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/manager/amenities?error=invalidData");
                return;
            }

            AmenityInfo amenity = new AmenityInfo();
            amenity.setName(name);
            amenity.setIcon(icon);

            if (amenityIdParam != null && !amenityIdParam.trim().isEmpty()) {
                try {
                    int amenityId = Integer.parseInt(amenityIdParam.trim());
                    amenity.setAmenityId(amenityId);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }

            // Duplicate Name validation
            List<AmenityInfo> existingAmenities = amenityService.getAllAmenities();
            boolean isDuplicate = false;
            for (AmenityInfo existing : existingAmenities) {
                if (existing.getName().trim().equalsIgnoreCase(name.trim())) {
                    if (amenity.getAmenityId() <= 0) {
                        isDuplicate = true;
                        break;
                    } else if (existing.getAmenityId() != amenity.getAmenityId()) {
                        isDuplicate = true;
                        break;
                    }
                }
            }

            if (isDuplicate) {
                response.sendRedirect(request.getContextPath() + "/manager/amenities?error=duplicateName");
                return;
            }

            if (amenity.getAmenityId() > 0) {
                amenityService.updateAmenity(amenity);
            } else {
                amenityService.addAmenity(amenity);
            }
        }

        response.sendRedirect(request.getContextPath() + "/manager/amenities?success=saved");
    }
}
