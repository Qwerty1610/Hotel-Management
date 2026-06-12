package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
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
 * URL: controller/manager
 *
 * Xử lý các hành động (action param):
 * - view : Hiển thị danh sách phòng và loại phòng (Manage Room)
 * - save : Thêm mới hoặc cập nhật thông tin phòng (Manage Room)
 * - delete : Xóa thông tin phòng (Manage Room)
 * - updateStatus : Cập nhật trạng thái của phòng (Manage Room)
 * 
 * Date: 01/6/2026
 * 
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

            roomService.saveRoom(room);
        }

        response.sendRedirect(request.getContextPath() + "/manager/rooms?success=saved");
    }
}
