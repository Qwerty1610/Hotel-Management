package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.RoomRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ReceptionistCheckInController", urlPatterns = {"/receptionist/checkin"})
public class ReceptionistCheckInController extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        BookingDAO dao = new BookingDAO();

        String keyword = request.getParameter("keyword");

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception e) {
            page = 1;
        }

        if (page < 1) {
            page = 1;
        }

        int totalItems = dao.countCheckInBookings(keyword);
        int totalPages = (int) Math.ceil(totalItems / (double) PAGE_SIZE);

        if (totalPages < 1) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
        }

        int offset = (page - 1) * PAGE_SIZE;

        List<Booking> list = dao.getCheckInBookings(keyword, offset, PAGE_SIZE);

        request.setAttribute("bookingList", list);
        request.setAttribute("keyword", keyword != null ? keyword : "");
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/WEB-INF/views/dashboard/receptionist.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));

        BookingDAO dao = new BookingDAO();
        RoomRepository roomRepo = new RoomRepository();

        // 1. update booking status
        boolean updated = dao.updateStatus(bookingId, "CheckedIn");

        // 2. update room status theo booking
        if (updated) {
            roomRepo.updateRoomStatusByBooking(bookingId, "CheckedIn");
        }

        response.sendRedirect(
                request.getContextPath() + "/receptionist/dashboard?tab=checkin"
        );
    }
}
