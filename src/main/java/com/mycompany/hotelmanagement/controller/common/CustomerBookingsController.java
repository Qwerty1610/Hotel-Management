package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRoom;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.BookingService;
import com.mycompany.hotelmanagement.service.RoomTypeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller xử lý luồng tạo đặt phòng và quản lý lịch sử đặt phòng của khách hàng (Customer).
 * Hỗ trợ các chức năng hiển thị danh sách, chi tiết hóa đơn đặt phòng, tạo đặt phòng đơn/nhiều phòng.
 *
 * @author BinhHD
 * @date 20/06/2026
 * @version 1.0
 */
@WebServlet(name = "CustomerBookingsController", urlPatterns = {"/customer/bookings", "/customer/booking/*"})
public class CustomerBookingsController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CustomerBookingsController.class.getName());
    private final BookingService bookingService = new BookingService();
    private final RoomTypeService roomTypeService = new RoomTypeService();

    private static final Map<String, String> ERROR_MESSAGES = new HashMap<>();
    static {
        ERROR_MESSAGES.put("MSG17", "Ngày trả phòng phải sau ngày nhận phòng.");
        ERROR_MESSAGES.put("MSG19", "Xin lỗi, loại phòng bạn chọn không còn đủ phòng trống trong thời gian này.");
        ERROR_MESSAGES.put("MSG20", "Số lượng khách vượt quá sức chứa tối đa của phòng.");
        ERROR_MESSAGES.put("MSG03", "Yêu cầu đặc biệt không được vượt quá 500 ký tự.");
        ERROR_MESSAGES.put("MSG55", "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Authorize Customer
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int accountId = (int) session.getAttribute("accountId");
        String pathInfo = request.getPathInfo();
        String action = request.getParameter("action");

        try {
            if ("/create".equals(pathInfo)) {
                showCreateForm(request, response);
            } else if ("/detail".equals(pathInfo) || "detail".equalsIgnoreCase(action)) {
                showBookingDetail(request, response, accountId);
            } else {
                showBookingHistory(request, response, accountId);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in CustomerBookingsController doGet", e);
            request.setAttribute("errorCode", "MSG55");
            request.setAttribute("errorMessage", ERROR_MESSAGES.get("MSG55"));
            request.getRequestDispatcher("/WEB-INF/views/customer/booking-history.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Authorize Customer
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int accountId = (int) session.getAttribute("accountId");
        String pathInfo = request.getPathInfo();

        try {
            if ("/create".equals(pathInfo)) {
                handleCreateBooking(request, response, accountId);
            } else if ("/cancel".equals(pathInfo)) {
                handleCancelBooking(request, response, accountId);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in CustomerBookingsController doPost", e);
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=MSG55");
        }
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<RoomTypeInfo> roomTypes = roomTypeService.getAllRoomTypes();
        request.setAttribute("roomTypes", roomTypes);
        
        AccountRepository accountRepo = new AccountRepository();
        List<String> customerNames = accountRepo.getAllCustomerNames();
        request.setAttribute("customerNames", customerNames);
        
        request.getRequestDispatcher("/WEB-INF/views/customer/booking-create.jsp").forward(request, response);
    }

    private void showBookingHistory(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        String statusFilter = request.getParameter("status");
        String keyword = request.getParameter("keyword");

        if (statusFilter == null) {
            statusFilter = "All";
        }

        List<Booking> bookings = bookingService.getBookingsByAccount(accountId, statusFilter, keyword);
        request.setAttribute("bookings", bookings);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("keyword", keyword);

        // Display success or error toast/alert if redirected
        String success = request.getParameter("success");
        if (success != null) {
            request.setAttribute("successMessage", "Thao tác thực hiện thành công!");
        }
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorCode", error);
            request.setAttribute("errorMessage", ERROR_MESSAGES.getOrDefault(error, ERROR_MESSAGES.get("MSG55")));
        }

        request.getRequestDispatcher("/WEB-INF/views/customer/booking-history.jsp").forward(request, response);
    }

    private void showBookingDetail(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }

        try {
            int bookingId = Integer.parseInt(idStr);
            Booking booking = bookingService.getBookingById(bookingId);
            
            // Check authorization: must belong to logged-in user
            if (booking == null || booking.getAccountId() == null || booking.getAccountId() != accountId) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?error=MSG55");
                return;
            }

            List<BookingRoom> rooms = bookingService.getBookingRooms(bookingId);
            request.setAttribute("booking", booking);
            request.setAttribute("rooms", rooms);
            request.getRequestDispatcher("/WEB-INF/views/customer/booking-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=MSG55");
        }
    }

    private void handleCreateBooking(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        
        String customerName = request.getParameter("customerName");
        String checkInStr = request.getParameter("checkInDate");
        String checkOutStr = request.getParameter("checkOutDate");
        String note = request.getParameter("note");
        String bookingType = request.getParameter("bookingType"); // "single" or "multi"

        List<BookingRoom> roomsList = new ArrayList<>();
        Booking booking = new Booking();

        try {
            booking.setAccountId(accountId);
            booking.setCustomerName(customerName);
            booking.setNote(note);

            if (checkInStr != null && !checkInStr.trim().isEmpty()) {
                booking.setCheckInDate(Date.valueOf(checkInStr));
            }
            if (checkOutStr != null && !checkOutStr.trim().isEmpty()) {
                booking.setCheckOutDate(Date.valueOf(checkOutStr));
            }

            if ("single".equalsIgnoreCase(bookingType)) {
                String roomTypeIdStr = request.getParameter("roomTypeId");
                String quantityStr = request.getParameter("roomQuantity");
                String guestCountStr = request.getParameter("guestCount");

                if (roomTypeIdStr == null || roomTypeIdStr.trim().isEmpty()) {
                    throw new Exception("MSG55");
                }

                int roomTypeId = Integer.parseInt(roomTypeIdStr);
                int quantity = 1;
                if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                    quantity = Integer.parseInt(quantityStr);
                }

                int guestCount = 1;
                if (guestCountStr != null && !guestCountStr.trim().isEmpty()) {
                    guestCount = Integer.parseInt(guestCountStr);
                }

                booking.setRoomTypeId(roomTypeId);
                booking.setRoomQuantity(quantity);

                // Construct guestName based on customerName and guestCount
                StringBuilder guestNameBuilder = new StringBuilder(customerName);
                for (int i = 1; i < guestCount; i++) {
                    guestNameBuilder.append(", Khách đi cùng ").append(i);
                }
                String guestName = guestNameBuilder.toString();

                // Add detail row
                BookingRoom br = new BookingRoom();
                br.setRoomTypeId(roomTypeId);
                br.setQuantity(quantity);
                br.setGuestName(guestName);
                roomsList.add(br);
            } else {
                // Multi-room selection
                String[] roomTypeIds = request.getParameterValues("roomTypeId[]");
                String[] roomQuantities = request.getParameterValues("roomQuantity[]");
                String[] guestCounts = request.getParameterValues("guestCount[]");
                String[] guestNames = request.getParameterValues("guestName[]");

                if (roomTypeIds == null || roomTypeIds.length == 0) {
                    throw new Exception("MSG55");
                }

                // In multi-room mode, booking roomTypeId is null
                booking.setRoomTypeId(null);

                for (int i = 0; i < roomTypeIds.length; i++) {
                    int rtId = Integer.parseInt(roomTypeIds[i]);
                    
                    int qty = 1;
                    if (roomQuantities != null && roomQuantities.length > i && !roomQuantities[i].trim().isEmpty()) {
                        qty = Integer.parseInt(roomQuantities[i]);
                    }
                    
                    int guestCount = 1;
                    if (guestCounts != null && guestCounts.length > i && !guestCounts[i].trim().isEmpty()) {
                        guestCount = Integer.parseInt(guestCounts[i]);
                    }
                    
                    String rawGuestName = (guestNames != null && guestNames.length > i) ? guestNames[i] : "";

                    // Construct guestName list based on rawGuestName and guestCount.
                    StringBuilder guestNameBuilder = new StringBuilder();
                    if (!rawGuestName.trim().isEmpty()) {
                        guestNameBuilder.append(rawGuestName.trim());
                        String[] typedNames = rawGuestName.split(",");
                        int typedCount = typedNames.length;
                        for (int j = typedCount; j < guestCount; j++) {
                            guestNameBuilder.append(", Khách đi cùng ").append(j);
                        }
                    } else {
                        guestNameBuilder.append("Thành viên");
                        for (int j = 1; j < guestCount; j++) {
                            guestNameBuilder.append(", Khách đi cùng ").append(j);
                        }
                    }

                    BookingRoom br = new BookingRoom();
                    br.setRoomTypeId(rtId);
                    br.setQuantity(qty);
                    br.setGuestName(guestNameBuilder.toString());
                    roomsList.add(br);
                }
            }

            // Create booking inside service layer
            bookingService.createBooking(booking, roomsList);

            // Redirect to history on success
            response.sendRedirect(request.getContextPath() + "/customer/bookings?success=created");

        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Validation failed during booking creation: " + e.getMessage(), e);
            String errCode = "MSG55";
            if (ERROR_MESSAGES.containsKey(e.getMessage())) {
                errCode = e.getMessage();
            }

            // Keep form data and forward to create form with error message
            request.setAttribute("errorCode", errCode);
            request.setAttribute("errorMessage", ERROR_MESSAGES.get(errCode));
            
            // Retain inputs
            request.setAttribute("customerName", customerName);
            request.setAttribute("checkInDate", checkInStr);
            request.setAttribute("checkOutDate", checkOutStr);
            request.setAttribute("note", note);
            request.setAttribute("bookingType", bookingType);
            
            // Reload room types list
            List<RoomTypeInfo> roomTypes = roomTypeService.getAllRoomTypes();
            request.setAttribute("roomTypes", roomTypes);
            
            // Reload customer names for lookup dropdown
            AccountRepository accountRepo = new AccountRepository();
            request.setAttribute("customerNames", accountRepo.getAllCustomerNames());

            request.getRequestDispatcher("/WEB-INF/views/customer/booking-create.jsp").forward(request, response);
        }
    }

    private void handleCancelBooking(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=MSG55");
            return;
        }

        try {
            int bookingId = Integer.parseInt(idStr);
            bookingService.cancelBookingByCustomer(bookingId, accountId);
            response.sendRedirect(request.getContextPath() + "/customer/bookings?success=cancelled");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error cancelling booking: " + idStr, e);
            String errCode = "MSG55";
            if (ERROR_MESSAGES.containsKey(e.getMessage())) {
                errCode = e.getMessage();
            }
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=" + errCode);
        }
    }
}
