package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.dal.AccountDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRequest;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.BookingRequestService;
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
 * Project: Hotel Management System
 * Class: CustomerBookingsController
 *
 * Description:
 * Controller xử lý vòng đời đặt phòng của khách hàng: tạo đơn đặt phòng đơn
 * và nhiều loại phòng, xem lịch sử đặt phòng với bộ lọc trạng thái và áp dụng
 * mã khuyến mãi lúc thanh toán. Ủy quyền xác thực nghiệp vụ cho BookingService
 * và tra cứu khuyến mãi cho PromotionService.
 *
 * Related Use Cases:
 * - UC-11 Create Booking (Customer Online)
 * - UC-38 View Booking History
 * - UC-48 Apply Promotion Code
 * 
 * Date: 21-06-2026
 * 
 * @author BinhHD, QuyPQ
 * @version 1.2
 */

@WebServlet(name = "CustomerBookingsController", urlPatterns = { "/customer/bookings", "/customer/booking/*" })
public class CustomerBookingsController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CustomerBookingsController.class.getName());
    private final BookingService bookingService = new BookingService();
    private final RoomTypeService roomTypeService = new RoomTypeService();
    private final BookingRequestService bookingRequestService = new BookingRequestService();
    private final com.mycompany.hotelmanagement.service.PromotionService promotionService = new com.mycompany.hotelmanagement.service.PromotionService();

    private static final Map<String, String> ERROR_MESSAGES = new HashMap<>();
    static {
        ERROR_MESSAGES.put("MSG02", "Vui lòng điền đầy đủ các trường bắt buộc.");
        ERROR_MESSAGES.put("MSG03", "Yêu cầu đặc biệt / lý do không được vượt quá 500 ký tự.");
        ERROR_MESSAGES.put("MSG16",
                "Không còn phòng trống phù hợp cho lựa chọn / khoảng ngày mới. Vui lòng thử phương án khác.");
        ERROR_MESSAGES.put("MSG17", "Ngày trả phòng phải sau ngày nhận phòng.");
        ERROR_MESSAGES.put("MSG19", "Xin lỗi, loại phòng bạn chọn không còn đủ phòng trống trong thời gian này.");
        ERROR_MESSAGES.put("MSG20", "Số lượng khách vượt quá sức chứa tối đa của phòng.");
        ERROR_MESSAGES.put("NOT_ELIGIBLE", "Đơn đặt phòng này không đủ điều kiện để thực hiện yêu cầu.");
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
            } else if ("/change".equals(pathInfo)) {
                showBookingChangePage(request, response, accountId);
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
            } else if ("/change-request".equals(pathInfo)) {
                handleBookingChangeRequest(request, response, accountId);
            } else if ("/extension-request".equals(pathInfo)) {
                handleStayExtensionRequest(request, response, accountId);
            } else if ("/check-promotion".equals(pathInfo)) {
                handleCheckPromotion(request, response);
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

        AccountDAO accountRepo = new AccountDAO();
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

        // Customer's change/extension requests, for status tracking (POST-3)
        request.setAttribute("myRequests", bookingRequestService.getRequestsByAccount(accountId));

        // Display success or error toast/alert if redirected
        String success = request.getParameter("success");
        if (success != null) {
            request.setAttribute("successMessage", buildSuccessMessage(success, request.getParameter("charge")));
        }
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorCode", error);
            request.setAttribute("errorMessage", ERROR_MESSAGES.getOrDefault(error, ERROR_MESSAGES.get("MSG55")));
        }

        request.getRequestDispatcher("/WEB-INF/views/customer/booking-history.jsp").forward(request, response);
    }

    /**
     * Maps a success code (and optional charge) to a friendly Vietnamese message.
     */
    private String buildSuccessMessage(String success, String charge) {
        switch (success) {
            case "change_requested":
                return "Đã gửi yêu cầu thay đổi đặt phòng. Vui lòng chờ lễ tân/quản lý duyệt.";
            case "ext_requested":
                String base = "Đã gửi yêu cầu gia hạn lưu trú. Vui lòng chờ duyệt.";
                if (charge != null && !charge.isBlank()) {
                    try {
                        double c = Double.parseDouble(charge);
                        java.text.NumberFormat nf = java.text.NumberFormat
                                .getInstance(new java.util.Locale("vi", "VN"));
                        base += " Phụ phí dự kiến: " + nf.format(c) + " VND.";
                    } catch (NumberFormatException ignored) {
                    }
                }
                return base;
            case "created":
                return "Đặt phòng thành công!";
            case "cancelled":
                return "Đã hủy đơn đặt phòng.";
            default:
                return "Thao tác thực hiện thành công!";
        }
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

            // Redirect child booking to parent booking details
            if (booking.getGroupBookingId() != null) {
                booking = bookingService.getBookingById(booking.getGroupBookingId());
                if (booking == null || booking.getAccountId() == null || booking.getAccountId() != accountId) {
                    response.sendRedirect(request.getContextPath() + "/customer/bookings?error=MSG55");
                    return;
                }
            }

            List<Booking> children = bookingService.getChildBookings(booking.getBookingId());
            List<Map<String, Object>> roomsList = new ArrayList<>();

            // Add parent room details
            Map<String, Object> parentMap = new HashMap<>();
            parentMap.put("roomTypeName", booking.getRoomTypeName());
            parentMap.put("quantity", booking.getRoomQuantity());
            parentMap.put("price", booking.getTotalAmount() / booking.getRoomQuantity() / booking.getNights());
            parentMap.put("guestName", booking.getCustomerName() + " (Theo đơn đặt)");
            roomsList.add(parentMap);

            double overallTotal = booking.getTotalAmount();

            // Add child room details
            for (Booking child : children) {
                Map<String, Object> childMap = new HashMap<>();
                childMap.put("roomTypeName", child.getRoomTypeName());
                childMap.put("quantity", child.getRoomQuantity());
                childMap.put("price", child.getTotalAmount() / child.getRoomQuantity() / child.getNights());
                childMap.put("guestName", child.getCustomerName() + " (Theo đơn đặt)");
                roomsList.add(childMap);

                overallTotal += child.getTotalAmount();
            }

            // Temporarily update totalAmount on parent booking object for JSP presentation
            booking.setTotalAmount(overallTotal);

            request.setAttribute("booking", booking);
            request.setAttribute("rooms", roomsList);
            request.getRequestDispatcher("/WEB-INF/views/customer/booking-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=MSG55");
        }
    }

    private void showBookingChangePage(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                int bookingId = Integer.parseInt(idStr);
                Booking booking = bookingService.getBookingById(bookingId);
                if (booking != null && booking.getAccountId() != null && booking.getAccountId() == accountId) {
                    request.setAttribute("booking", booking);
                }
            } catch (NumberFormatException ignored) {
            }
        }

        // Propagate error/success messages if redirected back here
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorCode", error);
            request.setAttribute("errorMessage", ERROR_MESSAGES.getOrDefault(error, ERROR_MESSAGES.get("MSG55")));
        }

        List<RoomTypeInfo> roomTypes = roomTypeService.getAllRoomTypes();
        request.setAttribute("roomTypes", roomTypes);

        request.getRequestDispatcher("/WEB-INF/views/customer/booking-change.jsp").forward(request, response);
    }

    private void handleCreateBooking(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {

        String customerName = request.getParameter("customerName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String checkInStr = request.getParameter("checkInDate");
        String checkOutStr = request.getParameter("checkOutDate");
        String note = request.getParameter("note");
        String bookingType = request.getParameter("bookingType"); // "single" or "multi"

        System.out.println("DEBUG handleCreateBooking:");
        System.out.println("  bookingType: " + bookingType);
        System.out.println("  roomTypeId: " + request.getParameter("roomTypeId"));
        System.out.println("  roomQuantity: " + request.getParameter("roomQuantity"));
        String[] rtIds = request.getParameterValues("roomTypeId[]");
        System.out.println("  roomTypeId[]: " + (rtIds == null ? "null" : java.util.Arrays.toString(rtIds)));
        String[] rtQs = request.getParameterValues("roomQuantity[]");
        System.out.println("  roomQuantity[]: " + (rtQs == null ? "null" : java.util.Arrays.toString(rtQs)));

        Booking booking = new Booking();

        try {
            booking.setAccountId(accountId);
            booking.setCustomerName(customerName);
            booking.setPhone(phone);
            booking.setEmail(email);
            booking.setNote(note);

            if (checkInStr != null && !checkInStr.trim().isEmpty()) {
                booking.setCheckInDate(Date.valueOf(checkInStr));
            }
            if (checkOutStr != null && !checkOutStr.trim().isEmpty()) {
                booking.setCheckOutDate(Date.valueOf(checkOutStr));
            }

            if ("multi".equalsIgnoreCase(bookingType)) {
                String[] roomTypeIds = request.getParameterValues("roomTypeId[]");
                String[] roomQuantities = request.getParameterValues("roomQuantity[]");

                if (roomTypeIds == null || roomQuantities == null || roomTypeIds.length == 0
                        || roomTypeIds.length != roomQuantities.length) {
                    throw new Exception("MSG55");
                }

                // 1. Pre-validate availability for all selected room types
                for (int i = 0; i < roomTypeIds.length; i++) {
                    int rtId = Integer.parseInt(roomTypeIds[i].trim());
                    int qty = Integer.parseInt(roomQuantities[i].trim());
                    int available = bookingService.checkRoomAvailability(rtId, booking.getCheckInDate(),
                            booking.getCheckOutDate());
                    if (qty > available) {
                        throw new Exception("MSG19"); // Rooms not available
                    }
                }

                // 2. Insert main (parent) booking
                int parentRoomTypeId = Integer.parseInt(roomTypeIds[0].trim());
                int parentQty = Integer.parseInt(roomQuantities[0].trim());
                booking.setRoomTypeId(parentRoomTypeId);
                booking.setRoomQuantity(parentQty);
                booking.setGroupBookingId(null); // Parent is root

                bookingService.createBooking(booking);
                int parentBookingId = booking.getBookingId();

                // 3. Insert subsequent bookings as child bookings
                for (int i = 1; i < roomTypeIds.length; i++) {
                    Booking childBooking = new Booking();
                    childBooking.setAccountId(accountId);
                    childBooking.setCustomerName(customerName);

                    childBooking.setPhone(phone);
                    childBooking.setEmail(email);
                    childBooking.setCheckInDate(booking.getCheckInDate());
                    childBooking.setCheckOutDate(booking.getCheckOutDate());
                    childBooking.setNote(note);
                    childBooking.setGroupBookingId(parentBookingId);

                    int childRoomTypeId = Integer.parseInt(roomTypeIds[i].trim());
                    int childQty = Integer.parseInt(roomQuantities[i].trim());
                    childBooking.setRoomTypeId(childRoomTypeId);
                    childBooking.setRoomQuantity(childQty);

                    bookingService.createBooking(childBooking);
                }
            } else {
                // Single booking creation flow
                String roomTypeIdStr = request.getParameter("roomTypeId");
                String quantityStr = request.getParameter("roomQuantity");

                if (roomTypeIdStr == null || roomTypeIdStr.trim().isEmpty()) {
                    throw new Exception("MSG55");
                }

                int roomTypeId = Integer.parseInt(roomTypeIdStr);
                int quantity = 1;
                if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                    quantity = Integer.parseInt(quantityStr);
                }

                booking.setRoomTypeId(roomTypeId);
                booking.setRoomQuantity(quantity);
                booking.setGroupBookingId(null);

                bookingService.createBooking(booking);
            }

            // ===== BINHHD START - Apply Promotion =====
            String promotionCode = request.getParameter("promotionCode");
            if (promotionCode != null && !promotionCode.trim().isEmpty()) {
                double totalGroupAmount = bookingService.calculateGroupTotalAmount(booking.getBookingId());
                if (totalGroupAmount == 0) {
                    totalGroupAmount = bookingService.calculateBookingAmount(booking);
                }

                com.mycompany.hotelmanagement.service.PromotionService.PromotionResult promoRes = promotionService
                        .validateAndCalculateDiscount(promotionCode, totalGroupAmount);
                if (promoRes.success && promoRes.discountAmount > 0) {
                    bookingService.applyDiscountToGroup(booking.getBookingId(), promoRes.discountAmount,
                            promoRes.promotion.getPromotionCode());
                    promotionService.incrementUsedCount(promoRes.promotion.getPromotionId());
                }
            }
            // ===== BINHHD END - Apply Promotion =====

            // Redirect to payment on success
            response.sendRedirect(
                    request.getContextPath() + "/customer/payments/pay?bookingId=" + booking.getBookingId());

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
            request.setAttribute("phone", phone);
            request.setAttribute("email", email);
            request.setAttribute("checkInDate", checkInStr);
            request.setAttribute("checkOutDate", checkOutStr);
            request.setAttribute("note", note);
            request.setAttribute("bookingType", bookingType);

            // Reload room types list
            List<RoomTypeInfo> roomTypes = roomTypeService.getAllRoomTypes();
            request.setAttribute("roomTypes", roomTypes);

            // Reload customer names for lookup dropdown
            AccountDAO accountRepo = new AccountDAO();
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

    private void handleBookingChangeRequest(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws IOException {
        String ctx = request.getContextPath();
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            BookingRequestService.Result res = bookingRequestService.requestBookingChange(
                    accountId,
                    bookingId,
                    request.getParameter("newCheckInDate"),
                    request.getParameter("newCheckOutDate"),
                    request.getParameter("roomTypeId"),
                    request.getParameter("roomQuantity"),
                    request.getParameter("reason"));
            if (res.isSuccess()) {
                response.sendRedirect(ctx + "/customer/bookings?success=change_requested");
            } else {
                response.sendRedirect(ctx + "/customer/booking/change?error=" + res.code);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/customer/booking/change?error=MSG02");
        }
    }

    private void handleStayExtensionRequest(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws IOException {
        String ctx = request.getContextPath();
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            BookingRequestService.Result res = bookingRequestService.requestStayExtension(
                    accountId,
                    bookingId,
                    request.getParameter("newCheckOutDate"),
                    request.getParameter("reason"));
            if (res.isSuccess()) {
                response.sendRedirect(ctx + "/customer/bookings?success=ext_requested&charge="
                        + (long) res.additionalCharge);
            } else {
                response.sendRedirect(ctx + "/customer/booking/change?error=" + res.code);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/customer/booking/change?error=MSG02");
        }
    }

    private void handleCheckPromotion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String code = request.getParameter("promoCode");
        String totalAmountStr = request.getParameter("totalAmount");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            double totalAmount = Double.parseDouble(totalAmountStr);
            com.mycompany.hotelmanagement.service.PromotionService.PromotionResult res = promotionService
                    .validateAndCalculateDiscount(code, totalAmount);

            String json = String.format("{\"success\": %b, \"message\": \"%s\", \"discountAmount\": %.0f}",
                    res.success, res.message.replace("\"", "\\\""), res.discountAmount);
            response.getWriter().write(json);
        } catch (Exception e) {
            response.getWriter()
                    .write("{\"success\": false, \"message\": \"Dữ liệu không hợp lệ.\", \"discountAmount\": 0}");
        }
    }
}
