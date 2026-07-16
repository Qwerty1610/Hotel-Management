package com.mycompany.hotelmanagement.controller.manager;

import com.mycompany.hotelmanagement.entity.StaffInfo;
import com.mycompany.hotelmanagement.service.RequestManagementService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * ManagerStaffController
 * Trang chi tiết nhân viên (render server-side): trạng thái, số liệu công việc,
 * việc đang làm và danh sách công việc đã nhận (phân trang 5/trang).
 *
 * GET /manager/staff?id=X&page=N
 *
 * Date: 05/6/2026
 * ver 1.0
 * @author Pham Quoc Quy
 */
@WebServlet(name = "ManagerStaffController", urlPatterns = {"/manager/staff"})
public class ManagerStaffController extends HttpServlet {

    private final RequestManagementService service = new RequestManagementService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/manager/requests");
            return;
        }

        StaffInfo staff = service.getStaffById(id);
        if (staff == null) {
            response.sendRedirect(request.getContextPath() + "/manager/requests");
            return;
        }

        final int pageSize = 5;
        int page = parseIntOr(request.getParameter("page"), 1);
        if (page < 1) page = 1;

        int totalItems = service.countRequestsByStaff(id);
        int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * pageSize;

        request.setAttribute("staff", staff);
        request.setAttribute("inProgress", service.getInProgressByStaff(id));
        request.setAttribute("assigned", service.getRequestsByStaff(id, offset, pageSize));
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);

        request.getRequestDispatcher("/WEB-INF/views/manager/staff-detail.jsp")
                .forward(request, response);
    }

    private int parseIntOr(String v, int fallback) {
        try { return Integer.parseInt(v.trim()); } catch (Exception e) { return fallback; }
    }
}
