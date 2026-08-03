package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.RoomDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomInfo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Trang chi tiết phòng ở sơ đồ phòng của lễ tân — nhấn vào 1 phòng để xem
 * thông tin phòng và toàn bộ lịch sử đặt phòng của phòng đó. Status hiển thị
 * dùng đúng công thức tính display_status của sơ đồ phòng (theo khoảng ngày
 * đang lọc ở tab Sơ đồ phòng), để luôn khớp với trạng thái hiện ra trên đó.
 */
@WebServlet(name = "ReceptionistRoomDetailController", urlPatterns = {"/receptionist/roomDetail"})
public class ReceptionistRoomDetailController extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int roomId;
        try {
            roomId = Integer.parseInt(request.getParameter("roomId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=roommap");
            return;
        }

        HttpSession session = request.getSession();
        LocalDate fromDate;
        LocalDate toDate;
        try {
            String fromStr = (String) session.getAttribute("roommapFilterFromDate");
            fromDate = fromStr != null ? LocalDate.parse(fromStr) : LocalDate.now();
        } catch (Exception e) {
            fromDate = LocalDate.now();
        }
        try {
            String toStr = (String) session.getAttribute("roommapFilterToDate");
            toDate = toStr != null ? LocalDate.parse(toStr) : fromDate.plusDays(1);
        } catch (Exception e) {
            toDate = fromDate.plusDays(1);
        }
        if (!toDate.isAfter(fromDate)) {
            toDate = fromDate.plusDays(1);
        }

        RoomInfo room = roomDAO.getRoomByIdForDateRange(roomId,
                java.sql.Date.valueOf(fromDate), java.sql.Date.valueOf(toDate));
        if (room == null) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=roommap");
            return;
        }

        List<Booking> bookings = bookingDAO.getBookingHistoryByRoomId(roomId);

        request.setAttribute("room", room);
        request.setAttribute("bookings", bookings);

        request.getRequestDispatcher("/WEB-INF/views/receptionist/roomDetail.jsp")
                .forward(request, response);
    }
}
