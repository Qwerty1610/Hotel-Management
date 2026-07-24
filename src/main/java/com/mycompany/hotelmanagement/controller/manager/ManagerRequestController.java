package com.mycompany.hotelmanagement.controller.manager;

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
 * Thay xử lý render trang từ FE xuống BE
 * 
 * Date: 11/6/2026
 * version 1.1
 * @author Pham Quoc Quy
 */
@WebServlet(name = "ManagerRequestController", urlPatterns = {"/manager/requests"})
public class ManagerRequestController extends HttpServlet {

    private final RequestManagementService service = new RequestManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Bộ lọc + phân trang server-side
        String roomKw = request.getParameter("q");
        String priority = request.getParameter("priority");
        String staffFilter = request.getParameter("staff");
        String status = request.getParameter("status");
        if (priority == null || priority.trim().isEmpty()) priority = "all";
        if (staffFilter == null || staffFilter.trim().isEmpty()) staffFilter = "all";
        if (status == null || status.trim().isEmpty()) status = "all";

        final int pageSize = 6;
        int page = parseIntOr(request.getParameter("page"), 1);
        if (page < 1) page = 1;

        int totalItems = service.countRequests(roomKw, priority, staffFilter, status);
        int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * pageSize;

        request.setAttribute("requests", service.getRequests(roomKw, priority, staffFilter, status, offset, pageSize));
        request.setAttribute("staffList", service.getHousekeepingStaff());
        request.setAttribute("pendingCount", service.countPending());
        request.setAttribute("inProgressCount", service.countInProgress());
        request.setAttribute("activeStaffCount", service.countActiveStaff());
        request.setAttribute("roomIssues", service.getAllRoomIssues());

        request.setAttribute("q", roomKw == null ? "" : roomKw);
        request.setAttribute("priorityFilter", priority);
        request.setAttribute("staffFilterVal", staffFilter);
        request.setAttribute("statusFilter", status);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);

        request.getRequestDispatcher("/WEB-INF/views/manager/requests.jsp").forward(request, response);
    }

    private int parseIntOr(String v, int fallback) {
        try { return Integer.parseInt(v.trim()); } catch (Exception e) { return fallback; }
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
            } else if ("priority".equalsIgnoreCase(action)) {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                String priority = request.getParameter("priority");
                if (isValidPriority(priority)) {
                    service.updatePriority(requestId, priority);
                }
            }
        } catch (NumberFormatException e) {
            // Tham số không hợp lệ -> bỏ qua, quay lại danh sách
        }

        response.sendRedirect(request.getContextPath() + "/manager/requests");
    }

    private boolean isValidStatus(String status) {
        return "Pending".equals(status) || "InProgress".equals(status)
                || "Resolved".equals(status) || "Unresolvable".equals(status)
                || "Cancelled".equals(status);
    }

    private boolean isValidPriority(String priority) {
        return "Low".equals(priority) || "Medium".equals(priority)
                || "High".equals(priority) || "Urgent".equals(priority);
    }
}
