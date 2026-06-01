package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.RoomTypeService;

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
            response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=roomtypes");
            return;
        }

        if ("delete".equalsIgnoreCase(action) && roomTypeId != -1) {
            roomTypeService.deleteRoomType(roomTypeId);
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=roomtypes");
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

            roomTypeService.saveRoomType(rt, imageUrl, amenities);
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=roomtypes");
    }
}
