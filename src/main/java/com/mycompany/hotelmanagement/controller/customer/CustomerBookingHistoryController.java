package com.mycompany.hotelmanagement.controller.customer;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.service.BookingService;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerBookingHistoryController", urlPatterns = { "/customer/booking/history" })
public class CustomerBookingHistoryController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CustomerBookingHistoryController.class.getName());
    private final BookingService bookingService = new BookingService();
    private final AccountRepository accountRepo = new AccountRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Verify Session & Customer Role
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        try {
            String email = (String) session.getAttribute("email");
            int accountId = accountRepo.getAccountIdByEmail(email);

            if (accountId == -1) {
                response.sendRedirect(request.getContextPath() + "/home/login?error=session_expired");
                return;
            }

            List<Booking> bookings = bookingService.getCustomerBookings(accountId);

            request.setAttribute("bookings", bookings);
            
            String successParam = request.getParameter("success");
            if (successParam != null) {
                if ("created".equals(successParam)) {
                    request.setAttribute("successMessage", "Đặt phòng thành công! Yêu cầu của bạn đang chờ xác nhận.");
                } else if ("cancelled".equals(successParam)) {
                    request.setAttribute("successMessage", "Đã huỷ đặt phòng thành công.");
                }
            }

            String errorParam = request.getParameter("error");
            if (errorParam != null) {
                request.setAttribute("errorMessage", "Không thể xử lý yêu cầu huỷ phòng.");
            }

            request.getRequestDispatcher("/WEB-INF/views/customer/booking-history.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in CustomerBookingHistoryController doGet", e);
            response.sendRedirect(request.getContextPath() + "/home?error=unknown");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Verify Session & Customer Role
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String bookingIdStr = request.getParameter("bookingId");

        if (action == null || !"cancel".equals(action) || bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            String email = (String) session.getAttribute("email");
            int accountId = accountRepo.getAccountIdByEmail(email);

            if (accountId == -1) {
                response.sendRedirect(request.getContextPath() + "/home/login?error=session_expired");
                return;
            }

            Booking booking = bookingService.getBookingById(bookingId);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/customer/booking/history?error=invalid_booking");
                return;
            }

            // Security check: Verify that this booking belongs to the current logged in customer
            if (booking.getAccountId() == null || booking.getAccountId() != accountId) {
                response.sendRedirect(request.getContextPath() + "/customer/booking/history?error=unauthorized");
                return;
            }

            // Check if status is Pending or Confirmed (cancelable)
            String status = booking.getStatus();
            if ("CheckedIn".equals(status) || "CheckedOut".equals(status) || "Cancelled".equals(status) || "Rejected".equals(status)) {
                response.sendRedirect(request.getContextPath() + "/customer/booking/history?error=cannot_cancel");
                return;
            }

            boolean cancelled = bookingService.cancelBooking(bookingId, "Huỷ bởi khách hàng");
            if (cancelled) {
                response.sendRedirect(request.getContextPath() + "/customer/booking/history?success=cancelled");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/booking/history?error=fail");
            }

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid booking id format for cancel: " + bookingIdStr, e);
            response.sendRedirect(request.getContextPath() + "/customer/booking/history?error=invalid_id");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in CustomerBookingHistoryController doPost", e);
            response.sendRedirect(request.getContextPath() + "/customer/booking/history?error=unknown");
        }
    }
}
