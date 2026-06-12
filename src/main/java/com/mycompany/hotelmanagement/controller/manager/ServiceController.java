package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.HotelService;
import com.mycompany.hotelmanagement.service.HotelServiceService;

/**
 * ServiceController
 * URL: controller/manager
 *
 * Xử lý các hành động (action param):
 * - view : Hiển thị danh sách các dịch vụ khách sạn (Manage Service)
 * - save : Thêm mới hoặc cập nhật thông tin dịch vụ (Manage Service)
 * - delete : Xóa dịch vụ khỏi hệ thống (Manage Service)
 * - toggle : Kích hoạt hoặc vô hiệu hóa trạng thái của dịch vụ (Manage Service)
 * 
 * Date: 01/6/2026
 * 
 * @author DINH KHANH
 */
@WebServlet(name = "ServiceController", urlPatterns = { "/manager/services" })
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
            response.sendRedirect(request.getContextPath() + "/manager/services");
            return;
        }

        if ("delete".equalsIgnoreCase(action) && serviceId != -1) {
            hotelServiceService.deleteService(serviceId);
            response.sendRedirect(request.getContextPath() + "/manager/services?success=deleted");
            return;
        } else if ("toggle".equalsIgnoreCase(action) && serviceId != -1) {
            String statusParam = request.getParameter("status");
            boolean isActive = "true".equalsIgnoreCase(statusParam);
            hotelServiceService.toggleServiceStatus(serviceId, isActive);
            // Since toggle is called via AJAX fetch, we can just return a redirect or 200
            // OK.
            // Redirecting to list path works fine and is consistent.
            response.sendRedirect(request.getContextPath() + "/manager/services");
            return;
        }

        List<HotelService> servicesList = hotelServiceService.getAllServices();
        request.setAttribute("servicesList", servicesList);
        request.getRequestDispatcher("/WEB-INF/views/manager/services/list.jsp").forward(request, response);
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

            if (name != null)
                name = name.trim();
            if (description != null)
                description = description.trim();
            if (unit != null)
                unit = unit.trim();

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
                response.sendRedirect(request.getContextPath() + "/manager/services?error=invalidData");
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

            // Duplicate Service Name validation
            if (name != null && !name.isEmpty()) {
                List<HotelService> existingServices = hotelServiceService.getAllServices();
                boolean isDuplicate = false;
                for (HotelService existing : existingServices) {
                    if (existing.getServiceName().trim().equalsIgnoreCase(name.trim())) {
                        if (service.getServiceId() <= 0) {
                            isDuplicate = true;
                            break;
                        } else if (existing.getServiceId() != service.getServiceId()) {
                            isDuplicate = true;
                            break;
                        }
                    }
                }
                if (isDuplicate) {
                    response.sendRedirect(request.getContextPath() + "/manager/services?error=duplicateName");
                    return;
                }
            }

            hotelServiceService.saveService(service);
        }

        response.sendRedirect(request.getContextPath() + "/manager/services?success=saved");
    }
}
