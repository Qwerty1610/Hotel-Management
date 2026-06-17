package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.service.BookingService;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "BookingConfirmController", urlPatterns = { "/booking/confirm" })
public class BookingConfirmController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(BookingConfirmController.class.getName());
    private final BookingService bookingService = new BookingService();

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

        Booking draft = (Booking) session.getAttribute("draftBooking");
        if (draft == null) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        request.setAttribute("booking", draft);
        request.getRequestDispatcher("/WEB-INF/views/customer/booking-confirm.jsp").forward(request, response);
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

        Booking draft = (Booking) session.getAttribute("draftBooking");
        if (draft == null) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        try {
            // Check availability one more time to prevent conflicts just before saving
            int availableRooms = bookingService.checkRoomAvailability(draft.getRoomTypeId(), draft.getCheckInDate(), draft.getCheckOutDate());
            if (availableRooms < draft.getRoomQuantity()) {
                request.setAttribute("error", "Phòng loại này đã hết hoặc không đủ trong khoảng thời gian đã chọn (Còn lại: " + availableRooms + " phòng). Vui lòng đặt lại.");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-confirm.jsp").forward(request, response);
                return;
            }

            int bookingId = bookingService.createBooking(draft);
            if (bookingId > 0) {
                // Clear session attributes
                session.removeAttribute("draftBooking");
                session.removeAttribute("draftNights");
                session.removeAttribute("draftBasePrice");
                session.removeAttribute("draftDepositPercent");

                response.sendRedirect(request.getContextPath() + "/rooms?success=created");
            } else {
                request.setAttribute("error", "Không thể tạo mã đặt phòng. Vui lòng liên hệ hỗ trợ hoặc thử lại sau.");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-confirm.jsp").forward(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in BookingConfirmController doPost", e);
            request.setAttribute("error", "Đã xảy ra lỗi hệ thống khi lưu đặt phòng. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/WEB-INF/views/customer/booking-confirm.jsp").forward(request, response);
        }
    }
}
