package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.entity.BookingRequest;
import com.mycompany.hotelmanagement.service.BookingRequestService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReceptionistBookingChangeController URL: /receptionist/bookingchange
 *
 * UC 2.4.5 Process Booking Change: lễ tân duyệt hoặc từ chối các yêu cầu thay
 * đổi đặt phòng / gia hạn lưu trú do khách hàng gửi (UC 2.3.9 Booking Change).
 * - approve POST: kiểm tra lại điều kiện và tình trạng phòng trống, áp dụng
 * thay đổi vào đơn đặt phòng (ngày, loại phòng, số phòng hoặc ngày trả phòng
 * mới), tính lại tổng tiền rồi chuyển yêu cầu sang Approved. - reject POST:
 * chuyển yêu cầu sang Rejected, đơn đặt phòng giữ nguyên.
 *
 * @author QuyPQ date: 12/07/2026 version 1.0
 */
@WebServlet(name = "ReceptionistBookingChangeController", urlPatterns = {"/receptionist/bookingchange"})
public class ReceptionistBookingChangeController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistBookingChangeController.class.getName());

    private final BookingRequestService bookingRequestService = new BookingRequestService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra xác thực & quyền hạn
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
            return;
        }

        String base = request.getContextPath() + "/receptionist/bookingchange";
        String action = request.getParameter("action");
        String requestIdStr = request.getParameter("requestId");

        if (action == null || requestIdStr == null || requestIdStr.trim().isEmpty()) {
            response.sendRedirect(base + "&error=invalid");
            return;
        }

        int requestId;
        try {
            requestId = Integer.parseInt(requestIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(base + "&error=invalid");
            return;
        }

        try {
            String error;
            switch (action.toLowerCase()) {
                case "approve":
                    error = bookingRequestService.approveRequest(requestId);
                    break;
                case "reject":
                    error = bookingRequestService.rejectRequest(requestId);
                    break;
                default:
                    response.sendRedirect(base + "&error=invalid");
                    return;
            }

            if (error == null) {
                response.sendRedirect(base + "&result=success&action=" + action);
            } else {
                response.sendRedirect(base + "&error=" + error);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in ReceptionistBookingChangeController doPost", e);
            response.sendRedirect(base + "&error=unknown");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.getRequestDispatcher(
                    "/WEB-INF/views/receptionist/booking-change-requests.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Load booking change requests failed", e);
            throw new ServletException(e);
        }
    }
}
