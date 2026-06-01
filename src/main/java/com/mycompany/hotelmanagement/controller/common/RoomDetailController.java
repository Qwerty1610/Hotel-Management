package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.mycompany.hotelmanagement.service.RoomTypeService;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;

@WebServlet(name = "RoomDetailController", urlPatterns = {"/rooms/detail"})
public class RoomDetailController extends HttpServlet {

    private final RoomTypeService roomTypeService = new RoomTypeService();

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

        // Fetch detail using Service
        RoomTypeInfo roomDetail = roomTypeService.getRoomTypeDetail(typeId);

        if (roomDetail == null) {
            // Room type ID does not exist in database or database query failed
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        // Set attribute and forward
        request.setAttribute("room", roomDetail);
        request.getRequestDispatcher("/WEB-INF/views/home/room_detail.jsp").forward(request, response);
    }
}
