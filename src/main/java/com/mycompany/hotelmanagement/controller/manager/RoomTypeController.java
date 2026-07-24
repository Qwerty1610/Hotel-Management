package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.CloudinaryService;
import com.mycompany.hotelmanagement.service.RoomTypeService;

/**
 * Project: Hotel Management System
 * Class: RoomTypeController
 *
 * Description:
 * Controller quản lý loại phòng cho Hotel Manager, xử lý hiển thị danh sách,
 * thêm mới, chỉnh sửa và xóa loại phòng. Class kiểm tra dữ liệu đầu vào,
 * kiểm tra tên loại phòng trùng lặp, điều hướng kết quả về trang quản lý
 * và ủy quyền thao tác lưu trữ cho RoomTypeService.
 *
 * Related Use Cases:
 * - UC-53 View Room Type Records
 * - UC-54 Add Room Type
 * - UC-55 Edit Room Type
 *
 * Date: 31-05-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
@WebServlet(name = "RoomTypeController", urlPatterns = { "/manager/roomtypes" })
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB – buffer before writing to disk
    maxFileSize       = 10 * 1024 * 1024, // 10 MB max per file
    maxRequestSize    = 15 * 1024 * 1024  // 15 MB max per request
)
public class RoomTypeController extends HttpServlet {

    private final RoomTypeService roomTypeService = new RoomTypeService();
    private final CloudinaryService cloudinaryService = new CloudinaryService();

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
                if (roomTypeService.hasOccupiedGuests(roomTypeId)) {
                    response.sendRedirect(request.getContextPath() + "/manager/roomtypes?error=hasOccupiedGuests");
                    return;
                }
                if (roomTypeService.hasRooms(roomTypeId)) {
                    response.sendRedirect(request.getContextPath() + "/manager/roomtypes?error=hasRooms");
                    return;
                }
                boolean success = roomTypeService.deleteRoomType(roomTypeId);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/manager/roomtypes?success=deleted");
                } else {
                    response.sendRedirect(request.getContextPath() + "/manager/roomtypes?error=deleteError");
                }
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/manager/roomtypes?error=deleteError");
            }
            return;
        }

        List<RoomTypeInfo> roomTypesList = roomTypeService.getAllRoomTypes();
        request.setAttribute("roomTypesList", roomTypesList);
        request.getRequestDispatcher("/WEB-INF/views/manager/room-types-list.jsp").forward(request, response);
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

            // --- Handle file upload via Cloudinary (overrides the URL field if provided) ---
            try {
                Part filePart = request.getPart("imageFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String cloudinaryUrl = cloudinaryService.uploadImage(filePart);
                    if (cloudinaryUrl != null) {
                        imageUrl = cloudinaryUrl;
                        System.out.println("[RoomTypeController] Image uploaded to Cloudinary: " + imageUrl);
                    }
                }
            } catch (Exception ex) {
                System.out.println("[RoomTypeController] Cloudinary upload skipped/error: " + ex.getMessage());
            }

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

            boolean saved = roomTypeService.saveRoomType(rt, imageUrl);
            if (saved) {
                response.sendRedirect(request.getContextPath() + "/manager/roomtypes?success=saved");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/roomtypes?error=saveError");
            }
            return;
        }
    }
}
