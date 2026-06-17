package com.mycompany.hotelmanagement.controller.manager;

import com.mycompany.hotelmanagement.entity.CustomerRequest;
import com.mycompany.hotelmanagement.entity.StaffInfo;
import com.mycompany.hotelmanagement.service.RequestManagementService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * ManagerRequestController
 * Quản lý yêu cầu khách hàng và theo dõi công việc nhân viên Housekeeping.
 *
 * GET  /manager/requests                -> hiển thị trang
 * POST /manager/requests?action=assign  -> gán việc cho nhân viên (requestId, staffId)
 * POST /manager/requests?action=status  -> cập nhật trạng thái yêu cầu (requestId, status)
 *
 * Date: 02/6/2026
 * version 1.0
 * @author Pham Quoc Quy
 */
@WebServlet(name = "ManagerRequestController", urlPatterns = {"/manager/requests"})
public class ManagerRequestController extends HttpServlet {

    private final RequestManagementService service = new RequestManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<CustomerRequest> requests = service.getAllRequests();
        List<StaffInfo> staffList = service.getHousekeepingStaff();

        request.setAttribute("requests", requests);
        request.setAttribute("staffList", staffList);
        request.setAttribute("pendingCount", service.countPending());
        request.setAttribute("inProgressCount", service.countInProgress());
        request.setAttribute("activeStaffCount", service.countActiveStaff());

        request.getRequestDispatcher("/WEB-INF/views/manager/requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        try {
            if ("assign".equalsIgnoreCase(action)) {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                int staffId = Integer.parseInt(request.getParameter("staffId"));
                service.assignRequest(requestId, staffId);
            } else if ("status".equalsIgnoreCase(action)) {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                String status = request.getParameter("status");
                if (isValidStatus(status)) {
                    service.updateStatus(requestId, status);
                }
            }
        } catch (NumberFormatException e) {
            // Tham số không hợp lệ -> bỏ qua, quay lại danh sách
        }

        response.sendRedirect(request.getContextPath() + "/manager/requests");
    }

    private boolean isValidStatus(String status) {
        return "Pending".equals(status) || "InProgress".equals(status)
                || "Completed".equals(status) || "Cancelled".equals(status);
    }
}
