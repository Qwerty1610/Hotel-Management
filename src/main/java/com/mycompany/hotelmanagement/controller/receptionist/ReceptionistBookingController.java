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
import java.time.LocalDate;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReceptionistBookingController
 * URL: /receptionist/booking
 *
 * Xử lý 4 hành động (action param):
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

    private static final Logger LOGGER = Logger.getLogger(ReceptionistBookingController.class.getName());

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

        try {
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
                case "confirm": {
                    Booking existing = dao.getBookingById(bookingId);
                    if (existing == null || !"Pending".equals(existing.getStatus())) {
                        LOGGER.log(Level.WARNING, "Confirm attempted on invalid booking or state. ID: " + bookingId);
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                        return;
                    }
                    String confirmNote = request.getParameter("note");
                    success = dao.updateBookingStatus(bookingId, "Confirmed",
                            confirmNote != null ? confirmNote.trim() : "Đã xác nhận bởi lễ tân");
                    break;
                }

                /* ---------- Từ chối ---------- */
                case "reject": {
                    Booking existing = dao.getBookingById(bookingId);
                    if (existing == null || !"Pending".equals(existing.getStatus())) {
                        LOGGER.log(Level.WARNING, "Reject attempted on invalid booking or state. ID: " + bookingId);
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                        return;
                    }
                    String rejectReason = request.getParameter("reason");
                    if (rejectReason == null || rejectReason.trim().isEmpty()) {
                        LOGGER.log(Level.WARNING, "Reject attempted without providing a reason. ID: " + bookingId);
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }
                    success = dao.updateBookingStatus(bookingId, "Rejected", rejectReason.trim());
                    break;
                }

                /* ---------- Huỷ booking ---------- */
                case "cancel": {
                    Booking existing = dao.getBookingById(bookingId);
                    if (existing == null || "CheckedIn".equals(existing.getStatus()) || "CheckedOut".equals(existing.getStatus())) {
                        LOGGER.log(Level.WARNING, "Cancel attempted on checked-in/out or non-existing booking. ID: " + bookingId);
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                        return;
                    }
                    String cancelReason = request.getParameter("reason");
                    success = dao.cancelBooking(bookingId,
                            cancelReason != null ? cancelReason.trim() : "Huỷ theo yêu cầu khách");
                    break;
                }

                /* ---------- Cập nhật thông tin ---------- */
                case "update": {
                    Booking existing = dao.getBookingById(bookingId);
                    if (existing == null || !"Pending".equals(existing.getStatus())) {
                        LOGGER.log(Level.WARNING, "Update attempted on invalid booking or state. ID: " + bookingId);
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                        return;
                    }

                    // Đọc form fields
                    String customerName = request.getParameter("customerName");
                    String checkInStr   = request.getParameter("checkInDate");
                    String checkOutStr  = request.getParameter("checkOutDate");
                    String roomTypeStr  = request.getParameter("roomTypeId");
                    String qtyStr       = request.getParameter("roomQuantity");
                    String amountStr    = request.getParameter("totalAmount");
                    String note         = request.getParameter("note");

                    // 1. Validate customerName
                    if (customerName == null || customerName.trim().isEmpty() || customerName.trim().length() > 100) {
                        LOGGER.log(Level.WARNING, "Update failed validation: customerName is empty or too long");
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }

                    // 2. Validate dates
                    if (checkInStr == null || checkInStr.isEmpty() || checkOutStr == null || checkOutStr.isEmpty()) {
                        LOGGER.log(Level.WARNING, "Update failed validation: missing check-in/out date");
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }

                    Date checkInDate;
                    Date checkOutDate;
                    try {
                        checkInDate = Date.valueOf(checkInStr);
                        checkOutDate = Date.valueOf(checkOutStr);
                    } catch (IllegalArgumentException e) {
                        LOGGER.log(Level.WARNING, "Update failed validation: date format parse error", e);
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=parse");
                        return;
                    }

                    if (!checkInDate.before(checkOutDate)) {
                        LOGGER.log(Level.WARNING, "Update failed validation: check-in date is not before check-out date");
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }

                    Date today = Date.valueOf(LocalDate.now());
                    if (checkInDate.before(today)) {
                        LOGGER.log(Level.WARNING, "Update failed validation: check-in date cannot be in the past");
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }

                    // 3. Validate roomQuantity
                    if (qtyStr == null || qtyStr.trim().isEmpty()) {
                        LOGGER.log(Level.WARNING, "Update failed validation: missing roomQuantity");
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }

                    int qty;
                    try {
                        qty = Integer.parseInt(qtyStr.trim());
                    } catch (NumberFormatException e) {
                        LOGGER.log(Level.WARNING, "Update failed validation: roomQuantity parse error", e);
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=parse");
                        return;
                    }

                    if (qty <= 0 || qty > 100) {
                        LOGGER.log(Level.WARNING, "Update failed validation: roomQuantity is out of range 1-100");
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }

                    // 4. Validate totalAmount
                    if (amountStr == null || amountStr.trim().isEmpty()) {
                        LOGGER.log(Level.WARNING, "Update failed validation: missing totalAmount");
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }

                    double amount;
                    try {
                        amount = Double.parseDouble(amountStr.trim());
                    } catch (NumberFormatException e) {
                        LOGGER.log(Level.WARNING, "Update failed validation: totalAmount parse error", e);
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=parse");
                        return;
                    }

                    if (amount < 0) {
                        LOGGER.log(Level.WARNING, "Update failed validation: totalAmount cannot be negative");
                        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=validation");
                        return;
                    }

                    // Populate fields
                    existing.setCustomerName(customerName.trim());
                    existing.setCheckInDate(checkInDate);
                    existing.setCheckOutDate(checkOutDate);
                    if (roomTypeStr != null && !roomTypeStr.trim().isEmpty()) {
                        try {
                            existing.setRoomTypeId(Integer.parseInt(roomTypeStr.trim()));
                        } catch (NumberFormatException e) {
                            LOGGER.log(Level.WARNING, "Update failed validation: roomTypeId parse error", e);
                            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=parse");
                            return;
                        }
                    } else {
                        existing.setRoomTypeId(null);
                    }
                    existing.setRoomQuantity(qty);
                    existing.setTotalAmount(amount);
                    existing.setNote(note != null ? note.trim() : "");

                    success = dao.updateBookingDetails(existing);
                    break;
                }

                default:
                    LOGGER.log(Level.WARNING, "Unknown action received in ReceptionistBookingController: " + action);
                    response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=unknown");
                    return;
            }

            // Redirect kèm thông báo kết quả
            String result = success ? "success" : "fail";
            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=bookings&result=" + result
                    + "&action=" + action);

        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Unexpected server error in ReceptionistBookingController", ex);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=unknown");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings");
    }
}
