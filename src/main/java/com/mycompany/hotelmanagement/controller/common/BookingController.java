package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.BookingService;
import com.mycompany.hotelmanagement.service.RoomTypeService;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "BookingController", urlPatterns = { "/booking/start" })
public class BookingController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(BookingController.class.getName());
    private final RoomTypeService roomTypeService = new RoomTypeService();
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

        String typeIdStr = request.getParameter("id");
        if (typeIdStr == null || typeIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        try {
            int typeId = Integer.parseInt(typeIdStr.trim());
            RoomTypeInfo roomType = roomTypeService.getRoomTypeDetail(typeId);
            if (roomType == null) {
                response.sendRedirect(request.getContextPath() + "/rooms");
                return;
            }

            request.setAttribute("roomType", roomType);
            request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid room type id format: " + typeIdStr, e);
            response.sendRedirect(request.getContextPath() + "/rooms");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in BookingController doGet", e);
            response.sendRedirect(request.getContextPath() + "/rooms?error=unknown");
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

        String typeIdStr = request.getParameter("roomTypeId");
        String checkInStr = request.getParameter("checkInDate");
        String checkOutStr = request.getParameter("checkOutDate");
        String qtyStr = request.getParameter("roomQuantity");
        String guestsStr = request.getParameter("guests");
        String customerName = request.getParameter("customerName");
        String note = request.getParameter("note");

        if (typeIdStr == null || typeIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        int typeId = Integer.parseInt(typeIdStr.trim());
        RoomTypeInfo roomType = roomTypeService.getRoomTypeDetail(typeId);
        if (roomType == null) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        // Restore values in case of validation failures
        request.setAttribute("roomType", roomType);
        request.setAttribute("checkInDate", checkInStr);
        request.setAttribute("checkOutDate", checkOutStr);
        request.setAttribute("roomQuantity", qtyStr);
        request.setAttribute("guests", guestsStr);
        request.setAttribute("customerName", customerName);
        request.setAttribute("note", note);

        try {
            // E1 - Required field check
            if (checkInStr == null || checkInStr.trim().isEmpty() ||
                checkOutStr == null || checkOutStr.trim().isEmpty() ||
                qtyStr == null || qtyStr.trim().isEmpty() ||
                guestsStr == null || guestsStr.trim().isEmpty() ||
                customerName == null || customerName.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập đầy đủ các trường thông tin bắt buộc.");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
                return;
            }

            Date checkIn = Date.valueOf(checkInStr.trim());
            Date checkOut = Date.valueOf(checkOutStr.trim());
            int quantity = Integer.parseInt(qtyStr.trim());
            int guests = Integer.parseInt(guestsStr.trim());
            customerName = customerName.trim();

            if (note == null) {
                note = "";
            }

            // E2 - Check-out date check
            Date today = Date.valueOf(LocalDate.now());
            if (checkIn.before(today)) {
                request.setAttribute("error", "Ngày nhận phòng không được ở quá khứ.");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
                return;
            }

            if (!checkIn.before(checkOut)) {
                request.setAttribute("error", "Ngày trả phòng phải sau ngày nhận phòng.");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
                return;
            }

            // Quantity range validation
            if (quantity <= 0 || quantity > 100) {
                request.setAttribute("error", "Số lượng phòng không hợp lệ (từ 1 đến 100).");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
                return;
            }

            // E4 - Guest number capacity check
            int totalCapacity = roomType.getCapacity() * quantity;
            if (guests <= 0 || guests > totalCapacity) {
                request.setAttribute("error", "Số khách vượt quá sức chứa tối đa của số lượng phòng đã chọn (" + totalCapacity + " khách).");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
                return;
            }

            // Special Request Note validation (max length 500 characters)
            if (note.trim().length() > 500) {
                request.setAttribute("error", "Ghi chú yêu cầu đặc biệt không được quá 500 ký tự.");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
                return;
            }

            // E3 - Room availability check
            int availableRooms = bookingService.checkRoomAvailability(typeId, checkIn, checkOut);
            if (availableRooms < quantity) {
                request.setAttribute("error", "Phòng loại này đã hết hoặc không đủ trong khoảng thời gian đã chọn (Còn lại: " + availableRooms + " phòng).");
                request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
                return;
            }

            // Calculations
            long diff = checkOut.getTime() - checkIn.getTime();
            long nights = diff / (24 * 60 * 60 * 1000);
            if (nights <= 0) {
                nights = 1; // Fallback
            }
            double totalAmount = roomType.getBasePrice() * quantity * nights;

            // Retrieve account ID of logged in user
            String email = (String) session.getAttribute("email");
            int accountId = accountRepo.getAccountIdByEmail(email);

            if (accountId == -1) {
                response.sendRedirect(request.getContextPath() + "/home/login?error=session_expired");
                return;
            }

            // Populate Draft Booking
            Booking draft = new Booking();
            draft.setAccountId(accountId);
            draft.setCustomerName(customerName);
            draft.setRoomTypeId(typeId);
            draft.setRoomTypeName(roomType.getTypeName());
            draft.setRoomQuantity(quantity);
            draft.setCheckInDate(checkIn);
            draft.setCheckOutDate(checkOut);
            draft.setTotalAmount(totalAmount);
            draft.setNote(note.trim());
            draft.setStatus("Pending");

            session.setAttribute("draftBooking", draft);
            session.setAttribute("draftNights", nights);
            session.setAttribute("draftBasePrice", roomType.getBasePrice());
            session.setAttribute("draftDepositPercent", roomType.getDepositPercent());

            response.sendRedirect(request.getContextPath() + "/booking/confirm");

        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Định dạng ngày không hợp lệ. Vui lòng nhập đúng định dạng YYYY-MM-DD.");
            request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in BookingController doPost", e);
            request.setAttribute("error", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/WEB-INF/views/customer/booking-form.jsp").forward(request, response);
        }
    }
}
