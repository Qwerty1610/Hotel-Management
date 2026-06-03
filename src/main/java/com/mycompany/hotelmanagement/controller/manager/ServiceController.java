package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.HotelService;
import com.mycompany.hotelmanagement.service.HotelServiceService;

@WebServlet(name = "ServiceController", urlPatterns = {"/manager/services"})
public class ServiceController extends HttpServlet {

    private final HotelServiceService hotelServiceService = new HotelServiceService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        int serviceId = -1;
        try {
            if (idParam != null) {
                serviceId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=services");
            return;
        }

        if ("delete".equalsIgnoreCase(action) && serviceId != -1) {
            hotelServiceService.deleteService(serviceId);
        } else if ("toggle".equalsIgnoreCase(action) && serviceId != -1) {
            String statusParam = request.getParameter("status");
            boolean isActive = "true".equalsIgnoreCase(statusParam);
            hotelServiceService.toggleServiceStatus(serviceId, isActive);
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=services");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("save".equalsIgnoreCase(action)) {
            String serviceIdParam = request.getParameter("serviceId");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceParam = request.getParameter("price");
            String unit = request.getParameter("unit");

            if (name != null) name = name.trim();
            if (description != null) description = description.trim();
            if (unit != null) unit = unit.trim();

            double price = 0.0;
            try {
                if (priceParam != null) {
                    price = Double.parseDouble(priceParam.trim());
                }
            } catch (NumberFormatException e) {
                // keep 0.0
            }

            if (name == null || name.isEmpty() ||
                price <= 0 ||
                unit == null || unit.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=services&error=invalidData");
                return;
            }

            HotelService service = new HotelService();
            service.setServiceName(name);
            service.setDescription(description);
            service.setPrice(price);
            service.setUnit(unit);

            if (serviceIdParam != null && !serviceIdParam.trim().isEmpty()) {
                try {
                    int serviceId = Integer.parseInt(serviceIdParam.trim());
                    service.setServiceId(serviceId);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }

            hotelServiceService.saveService(service);
        }

        response.sendRedirect(request.getContextPath() + "/manager/dashboard?tab=services");
    }
}
