package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.mycompany.hotelmanagement.service.RoomTypeService;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;

@WebServlet(name = "RoomsController", urlPatterns = {"/rooms"})
public class RoomsController extends HttpServlet {

    private final RoomTypeService roomTypeService = new RoomTypeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get search filter parameters
        String typeIdParam = request.getParameter("typeId");
        String minPriceParam = request.getParameter("minPrice");
        String maxPriceParam = request.getParameter("maxPrice");
        String guestsParam = request.getParameter("guests");

        int typeIdFilter = -1;
        double minPriceFilter = 0.0;
        double maxPriceFilter = Double.MAX_VALUE;
        int guestsFilter = -1;

        try {
            if (typeIdParam != null && !typeIdParam.trim().isEmpty() && !"all".equalsIgnoreCase(typeIdParam)) {
                typeIdFilter = Integer.parseInt(typeIdParam);
            }
        } catch (NumberFormatException e) {
            // keep -1
        }

        try {
            if (minPriceParam != null && !minPriceParam.trim().isEmpty()) {
                minPriceFilter = Double.parseDouble(minPriceParam.replaceAll("[^0-9.]", ""));
            }
        } catch (NumberFormatException e) {
            // keep 0.0
        }

        try {
            if (maxPriceParam != null && !maxPriceParam.trim().isEmpty() && !"Không giới hạn".equalsIgnoreCase(maxPriceParam)) {
                maxPriceFilter = Double.parseDouble(maxPriceParam.replaceAll("[^0-9.]", ""));
            }
        } catch (NumberFormatException e) {
            // keep Double.MAX_VALUE
        }

        try {
            if (guestsParam != null && !guestsParam.trim().isEmpty() && !"all".equalsIgnoreCase(guestsParam)) {
                guestsFilter = Integer.parseInt(guestsParam);
            }
        } catch (NumberFormatException e) {
            // keep -1
        }

        // 2. Fetch data from Service
        List<RoomTypeInfo> allRoomTypes = roomTypeService.getAllRoomTypes();
        List<RoomTypeInfo> filteredRoomTypes = roomTypeService.getFilteredRoomTypes(typeIdFilter, guestsFilter, minPriceFilter, maxPriceFilter);

        // Set attributes for view rendering
        request.setAttribute("roomTypes", filteredRoomTypes);
        request.setAttribute("allRoomTypesList", allRoomTypes); // For selection dropdown
        request.setAttribute("selectedTypeId", typeIdParam != null ? typeIdParam : "all");
        request.setAttribute("selectedMinPrice", minPriceParam != null ? minPriceParam : "");
        request.setAttribute("selectedMaxPrice", maxPriceParam != null ? maxPriceParam : "");
        request.setAttribute("selectedGuests", guestsParam != null ? guestsParam : "all");
        request.setAttribute("resultsCount", filteredRoomTypes.size());

        // Forward to rooms.jsp
        request.getRequestDispatcher("/WEB-INF/views/home/rooms.jsp").forward(request, response);
    }
}
