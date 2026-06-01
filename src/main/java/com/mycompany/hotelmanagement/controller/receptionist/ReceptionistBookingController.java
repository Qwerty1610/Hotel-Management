package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;

/**
 * ReceptionistBookingController
 * URL: /receptionist/booking
 *
 * Xử lý 3 hành động (action param):
 *   - confirm  : Xác nhận booking (Pending → Confirmed)
 *   - reject   : Từ chối booking  (Pending → Rejected)
 *   - update   : Cập nhật thông tin booking (chỉ khi Pending)
 *   - cancel   : Huỷ booking
 * 
 * Standardized imports utilizing dal instead of dao.
 * Date: 01/6/2026
 * @author DUC BINH
 */
@WebServlet(name = "ReceptionistBookingController", urlPatterns = {"/receptionist/booking"})
public class ReceptionistBookingController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra quyền
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action      = request.getParameter("action");
        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr == null || action == null) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
            return;
        }

        BookingDAO dao = new BookingDAO();
        boolean success = false;

        switch (action.toLowerCase()) {

            /* ---------- Xác nhận ---------- */
            case "confirm":
                String confirmNote = request.getParameter("note");
                success = dao.updateBookingStatus(bookingId, "Confirmed",
                        confirmNote != null ? confirmNote : "Đã xác nhận bởi lễ tân");
                break;

            /* ---------- Từ chối ---------- */
            case "reject":
                String rejectReason = request.getParameter("reason");
                if (rejectReason == null || rejectReason.trim().isEmpty()) {
                    rejectReason = "Không đáp ứng yêu cầu";
                }
                success = dao.updateBookingStatus(bookingId, "Rejected", rejectReason);
                break;

            /* ---------- Huỷ booking ---------- */
            case "cancel":
                String cancelReason = request.getParameter("reason");
                success = dao.cancelBooking(bookingId,
                        cancelReason != null ? cancelReason : "Huỷ theo yêu cầu khách");
                break;

            /* ---------- Cập nhật thông tin ---------- */
            case "update":
                Booking existing = dao.getBookingById(bookingId);
                if (existing != null && "Pending".equals(existing.getStatus())) {
                    // Đọc form fields
                    String customerName = request.getParameter("customerName");
                    String checkInStr   = request.getParameter("checkInDate");
                    String checkOutStr  = request.getParameter("checkOutDate");
                    String roomTypeStr  = request.getParameter("roomTypeId");
                    String qtyStr       = request.getParameter("roomQuantity");
                    String amountStr    = request.getParameter("totalAmount");
                    String note         = request.getParameter("note");

                    // Validate & parse
                    try {
                        if (customerName != null && !customerName.trim().isEmpty())
                            existing.setCustomerName(customerName.trim());

                        if (checkInStr != null && !checkInStr.isEmpty())
                            existing.setCheckInDate(Date.valueOf(checkInStr));
                        if (checkOutStr != null && !checkOutStr.isEmpty())
                            existing.setCheckOutDate(Date.valueOf(checkOutStr));

                        if (roomTypeStr != null && !roomTypeStr.trim().isEmpty())
                            existing.setRoomTypeId(Integer.parseInt(roomTypeStr.trim()));

                        if (qtyStr != null && !qtyStr.trim().isEmpty())
                            existing.setRoomQuantity(Integer.parseInt(qtyStr.trim()));

                        if (amountStr != null && !amountStr.trim().isEmpty())
                            existing.setTotalAmount(Double.parseDouble(amountStr.trim()));

                        existing.setNote(note);
                        success = dao.updateBookingDetails(existing);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        // Redirect với thông báo lỗi
                        response.sendRedirect(request.getContextPath()
                                + "/receptionist/dashboard?tab=bookings&error=parse");
                        return;
                    }
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=unknown");
                return;
        }

        // Redirect kèm thông báo kết quả
        String result = success ? "success" : "fail";
        response.sendRedirect(request.getContextPath()
                + "/receptionist/dashboard?tab=bookings&result=" + result
                + "&action=" + action);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET không hỗ trợ – redirect về dashboard
        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings");
    }
}
