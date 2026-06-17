package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.service.BookingService;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
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
 * ReceptionistBookingDetailController
 * URL: /receptionist/booking/detail
 *
 * Hiển thị chi tiết (read-only) của một yêu cầu đặt phòng.
 *
 * @author DUC BINH
 */
@WebServlet(name = "ReceptionistBookingDetailController", urlPatterns = {"/receptionist/booking/detail"})
public class ReceptionistBookingDetailController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistBookingDetailController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authorization check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            BookingService bookingService = new BookingService();
            Booking booking = bookingService.getBookingById(bookingId);

            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                return;
            }

            // Load Customer details if accountId is present
            CustomerDetails customer = null;
            if (booking.getAccountId() != null) {
                customer = bookingService.getCustomerDetailsByAccountId(booking.getAccountId());
            }

            // Load assigned rooms if any
            List<Room> assignedRooms = bookingService.getAssignedRoomsForBooking(bookingId);

            request.setAttribute("booking", booking);
            request.setAttribute("customer", customer);
            request.setAttribute("assignedRooms", assignedRooms);

            request.getRequestDispatcher("/WEB-INF/views/receptionist/booking-detail.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId format: " + bookingIdStr, e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=parse");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in ReceptionistBookingDetailController doGet", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=unknown");
        }
    }
}
