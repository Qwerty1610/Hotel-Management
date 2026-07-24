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
 * Project: Hotel Management System
 * Class: ServiceController
 *
 * Description:
 * Controller quản lý dịch vụ khách sạn cho Hotel Manager, xử lý hiển thị
 * danh sách, thêm mới, chỉnh sửa, bật/tắt trạng thái và xóa dịch vụ.
 * Class kiểm tra dữ liệu đầu vào, xử lý trùng tên dịch vụ, điều hướng
 * kết quả về trang quản lý và ủy quyền nghiệp vụ cho HotelServiceService.
 *
 * Related Use Cases:
 * - UC-59 View Service Records
 * - UC-60 Add Service
 * - UC-61 Edit Service
 *
 * Date: 31-05-2026
 *
 * @author KhanhTD
 * @version 1.0
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
            boolean success = hotelServiceService.deleteService(serviceId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/manager/services?success=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/services?error=hasUsage");
            }
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
        request.getRequestDispatcher("/WEB-INF/views/manager/services-list.jsp").forward(request, response);
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

            boolean saved = hotelServiceService.saveService(service);
            if (saved) {
                response.sendRedirect(request.getContextPath() + "/manager/services?success=saved");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/services?error=saveError");
            }
            return;
        }

        response.sendRedirect(request.getContextPath() + "/manager/services");
    }
}
