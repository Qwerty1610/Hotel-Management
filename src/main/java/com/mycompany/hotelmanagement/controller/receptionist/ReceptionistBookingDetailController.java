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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Project: Hotel Management System
 * Class: ReceptionistBookingDetailController
 *
 * Description:
 * Controller chỉ đọc dùng để tải và hiển thị toàn bộ chi tiết của một đơn
 * đặt phòng cho lễ tân. Truy xuất dữ liệu đặt phòng, các phòng đã xếp, chi
 * tiết tài khoản khách hàng, sau đó chuyển tiếp đến trang JSP chi tiết.
 *
 * Related Use Cases:
 * - UC-12 Process Booking Request
 * 
 * Date: 01-06-2026
 * 
 * @author BinhHD, MinhTDP
 * @version 1.2
 */
@WebServlet(name = "ReceptionistBookingDetailController", urlPatterns = { "/receptionist/booking/detail" })
public class ReceptionistBookingDetailController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistBookingDetailController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authorization check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
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

            // Load assigned rooms for parent booking
            java.util.List<Room> assignedRooms = bookingService.getAssignedRoomsForBooking(bookingId,
                    booking.getCheckInDate(),
                    booking.getCheckOutDate());

            // Load child bookings (for group booking support)
            java.util.List<Booking> childBookings = bookingService.getChildBookings(bookingId);

            // Load assigned rooms for each child booking
            Map<Integer, java.util.List<Room>> childAssignedRoomsMap = new HashMap<>();
            for (Booking child : childBookings) {
                java.util.List<Room> childRooms = bookingService.getAssignedRoomsForBooking(child.getBookingId(),
                        booking.getCheckInDate(),
                        booking.getCheckOutDate());
                childAssignedRoomsMap.put(child.getBookingId(), childRooms);
            }

            request.setAttribute("booking", booking);
            request.setAttribute("customer", customer);
            request.setAttribute("assignedRooms", assignedRooms);
            request.setAttribute("childBookings", childBookings);
            request.setAttribute("childAssignedRoomsMap", childAssignedRoomsMap);

            request.setAttribute("currentTab", "bookings");
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
