package com.mycompany.hotelmanagement.controller.customer;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.BookingService;
import com.mycompany.hotelmanagement.service.RoomTypeService;

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

@WebServlet(name = "CustomerBookingDetailController", urlPatterns = { "/customer/booking/detail" })
public class CustomerBookingDetailController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CustomerBookingDetailController.class.getName());
    private final BookingService bookingService = new BookingService();
    private final RoomTypeService roomTypeService = new RoomTypeService();
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

        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
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

            // Load Customer profile if accountId is set
            CustomerDetails customer = bookingService.getCustomerDetailsByAccountId(accountId);

            // Load assigned rooms if any
            List<Room> assignedRooms = bookingService.getAssignedRoomsForBooking(bookingId);

            // Load room type details for this booking
            RoomTypeInfo roomType = null;
            if (booking.getRoomTypeId() != null) {
                roomType = roomTypeService.getRoomTypeDetail(booking.getRoomTypeId());
            }

            request.setAttribute("booking", booking);
            request.setAttribute("customer", customer);
            request.setAttribute("assignedRooms", assignedRooms);
            request.setAttribute("roomType", roomType);

            request.getRequestDispatcher("/WEB-INF/views/customer/booking-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId format: " + bookingIdStr, e);
            response.sendRedirect(request.getContextPath() + "/customer/booking/history?error=parse");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in CustomerBookingDetailController doGet", e);
            response.sendRedirect(request.getContextPath() + "/customer/booking/history?error=unknown");
        }
    }
}
