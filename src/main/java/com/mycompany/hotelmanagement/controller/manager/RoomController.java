package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.RoomInfo;
import com.mycompany.hotelmanagement.service.RoomService;

@WebServlet(name = "RoomController", urlPatterns = {"/manager/rooms"})
public class RoomController extends HttpServlet {

    private final RoomService roomService = new RoomService();

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
            response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=rooms");
            return;
        }

        if ("delete".equalsIgnoreCase(action) && roomId != -1) {
            roomService.deleteRoom(roomId);
        } else if ("updateStatus".equalsIgnoreCase(action) && roomId != -1) {
            String status = request.getParameter("status");
            if (status != null && !status.trim().isEmpty()) {
                roomService.updateRoomStatus(roomId, status.trim());
            }
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=rooms");
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

            if (roomNumber != null) roomNumber = roomNumber.trim();
            if (floor != null) floor = floor.trim();
            if (status != null) status = status.trim();

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

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=rooms");
    }
}
