package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
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
 * Project: Hotel Management System
 * Class: RoomController
 *
 * Description:
 * Controller quản lý danh sách phòng cho Hotel Manager, xử lý hiển thị danh
 * sách phòng kèm loại phòng, thêm mới, chỉnh sửa, xóa và cập nhật trạng thái
 * phòng. Class kiểm tra dữ liệu đầu vào, xử lý kết quả trùng số phòng,
 * tính trạng thái phòng theo ngày chọn (selectedDate), ngăn chặn sửa trạng thái
 * khi phòng đang có khách thực sự và điều hướng về trang quản lý.
 *
 * Related Use Cases:
 * - UC-56 View Room List
 * - UC-57 Add Room
 * - UC-58 Edit Room
 *
 * Date: 31-05-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
@WebServlet(name = "RoomController", urlPatterns = { "/manager/rooms" })
public class RoomController extends HttpServlet {

    private final RoomService roomService = new RoomService();
    private final RoomTypeService roomTypeService = new RoomTypeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String selectedDateParam = request.getParameter("selectedDate");
        LocalDate selectedDate;
        try {
            if (selectedDateParam != null && !selectedDateParam.trim().isEmpty()) {
                selectedDate = LocalDate.parse(selectedDateParam.trim());
            } else {
                selectedDate = LocalDate.now();
            }
        } catch (DateTimeParseException e) {
            selectedDate = LocalDate.now();
        }

        String selectedDateStr = selectedDate.format(DateTimeFormatter.ISO_LOCAL_DATE);
        String selectedDateFormatted = selectedDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        int roomId = -1;
        try {
            if (idParam != null) {
                roomId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/rooms?selectedDate=" + selectedDateStr);
            return;
        }

        if ("delete".equalsIgnoreCase(action) && roomId != -1) {
            boolean deleted = roomService.deleteRoom(roomId);
            if (!deleted) {
                response.sendRedirect(request.getContextPath() + "/manager/rooms?selectedDate=" + selectedDateStr + "&error=deleteError");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/manager/rooms?selectedDate=" + selectedDateStr + "&success=deleted");
            return;
        } else if ("updateStatus".equalsIgnoreCase(action) && roomId != -1) {
            String status = request.getParameter("status");
            if (status != null && !status.trim().isEmpty()) {
                String result = roomService.updateRoomStatus(roomId, status.trim());
                if ("roomCurrentlyOccupied".equals(result)) {
                    response.sendRedirect(request.getContextPath() + "/manager/rooms?selectedDate=" + selectedDateStr + "&error=roomCurrentlyOccupied");
                    return;
                } else if ("invalidStatus".equals(result)) {
                    response.sendRedirect(request.getContextPath() + "/manager/rooms?selectedDate=" + selectedDateStr + "&error=invalidStatus");
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/manager/rooms?selectedDate=" + selectedDateStr + "&success=saved");
            return;
        }

        List<RoomInfo> roomsList = roomService.getRoomsByDate(selectedDate);
        List<RoomTypeInfo> roomTypesList = roomTypeService.getAllRoomTypes();

        request.setAttribute("selectedDate", selectedDateStr);
        request.setAttribute("selectedDateFormatted", selectedDateFormatted);
        request.setAttribute("roomsList", roomsList);
        request.setAttribute("roomTypesList", roomTypesList);
        request.getRequestDispatcher("/WEB-INF/views/manager/rooms-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String selectedDateParam = request.getParameter("selectedDate");
        String dateQuery = (selectedDateParam != null && !selectedDateParam.trim().isEmpty())
                ? "?selectedDate=" + selectedDateParam.trim()
                : "?selectedDate=" + LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);

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
            room.setOperationalStatus(status);

            if (roomIdParam != null && !roomIdParam.trim().isEmpty()) {
                try {
                    int roomId = Integer.parseInt(roomIdParam.trim());
                    room.setRoomId(roomId);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }

            String result = roomService.saveRoom(room);
            if ("duplicateNumber".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/manager/rooms" + dateQuery + "&error=duplicateNumber");
                return;
            } else if ("roomCurrentlyOccupied".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/manager/rooms" + dateQuery + "&error=roomCurrentlyOccupied");
                return;
            } else if ("invalidStatus".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/manager/rooms" + dateQuery + "&error=invalidStatus");
                return;
            } else if ("error".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/manager/rooms" + dateQuery + "&error=saveError");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/manager/rooms" + dateQuery + "&success=saved");
    }
}
