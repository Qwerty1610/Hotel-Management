package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import java.sql.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.mycompany.hotelmanagement.dal.AccountDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRequestItem;
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
import java.util.ArrayList;
import java.util.List;

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
        ERROR_MESSAGES.put("ROOM_TAKEN",
                "Phòng bạn đang ở đã có khách khác đặt ngay sau ngày trả phòng hiện tại nên không thể gia hạn.");
        ERROR_MESSAGES.put("PENDING_EXISTS",
                "Đơn này đang có một yêu cầu chờ duyệt. Vui lòng đợi lễ tân xử lý xong rồi gửi yêu cầu mới.");
        ERROR_MESSAGES.put("EMPTY_GROUP",
                "Bạn không thể bỏ hết phòng khỏi đơn. Nếu không còn nhu cầu, vui lòng huỷ đơn đặt phòng.");
        ERROR_MESSAGES.put("STALE",
                "Đơn đặt phòng vừa được cập nhật. Vui lòng tải lại trang và chọn lại thông tin mới.");
        ERROR_MESSAGES.put("NO_CHANGE", "Bạn chưa thay đổi thông tin nào so với đơn hiện tại.");
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
            } else if ("/availability".equals(pathInfo)) {
                handleCheckAvailability(request, response, accountId);
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

        String roomTypeIdStr = request.getParameter("roomTypeId");
        if (roomTypeIdStr != null && !roomTypeIdStr.trim().isEmpty()) {
            request.setAttribute("selectedRoomTypeId", roomTypeIdStr.trim());
        }

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
            case "change_requested": {
                String base = "Đã gửi yêu cầu thay đổi đặt phòng. Vui lòng chờ lễ tân/quản lý duyệt.";
                Double delta = parseCharge(charge);
                if (delta != null && Math.abs(delta) >= 1) {
                    base += delta > 0
                            ? " Bạn sẽ cần thanh toán thêm " + formatVnd(delta) + " VND."
                            : " Bạn sẽ được hoàn lại " + formatVnd(-delta) + " VND.";
                }
                return base;
            }
            case "ext_requested": {
                String base = "Đã gửi yêu cầu gia hạn lưu trú. Vui lòng chờ duyệt.";
                Double c = parseCharge(charge);
                if (c != null) {
                    base += " Phụ phí dự kiến: " + formatVnd(c) + " VND.";
                }
                return base;
            }
            case "created":
                return "Đặt phòng thành công!";
            case "cancelled":
                return "Đã hủy đơn đặt phòng.";
            default:
                return "Thao tác thực hiện thành công!";
        }
    }

    private Double parseCharge(String charge) {
        if (charge == null || charge.isBlank()) {
            return null;
        }
        try {
            return Double.parseDouble(charge);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String formatVnd(double amount) {
        return java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN")).format(amount);
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
            parentMap.put("price", booking.getTotalAmount() / booking.getNights());
            parentMap.put("assignedRooms", bookingService.getAssignedRoomsForBookingSelf(booking.getBookingId()));
            parentMap.put("guestName", booking.getCustomerName() + " (Theo đơn đặt)");
            roomsList.add(parentMap);

            double overallTotal = booking.getTotalAmount();

            // Add child room details
            for (Booking child : children) {
                Map<String, Object> childMap = new HashMap<>();
                childMap.put("roomTypeName", child.getRoomTypeName());
                childMap.put("quantity", child.getRoomQuantity());
                childMap.put("price", child.getTotalAmount() / child.getNights());
                childMap.put("assignedRooms", child.getAssignedRoomsStr());
                childMap.put("guestName", child.getCustomerName() + " (Theo đơn đặt)");
                roomsList.add(childMap);

                overallTotal += child.getTotalAmount();
            }

            // Temporarily update totalAmount on parent booking object for JSP presentation
            booking.setTotalAmount(overallTotal);

            // Nút "Thay đổi đặt phòng" chỉ hiện khi đơn thực sự gửi được yêu
            // cầu — cùng điều kiện requestBookingChange sẽ kiểm. Tính ở đây vì
            // so sánh ngày trong JSTL rất vướng.
            String st = booking.getStatus();
            boolean canRequestChange = ("Pending".equalsIgnoreCase(st) || "Confirmed".equalsIgnoreCase(st))
                    && booking.getCheckInDate() != null
                    && java.time.LocalDate.now().isBefore(booking.getCheckInDate().toLocalDate());
            request.setAttribute("canRequestChange", canRequestChange);

            request.setAttribute("booking", booking);
            request.setAttribute("rooms", roomsList);
            request.getRequestDispatcher("/WEB-INF/views/customer/booking-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=MSG55");
        }
    }

    private void showBookingChangePage(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        // ?id= đến từ nút "Thay đổi đặt phòng" ở trang chi tiết. Attribute này
        // được JSP dùng để tự chọn sẵn đơn trong dropdown và mở form, nên chỉ
        // set khi đơn là dòng cha, đúng chủ sở hữu và đủ điều kiện thay đổi —
        // đúng tập mà dropdown liệt kê.
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                int bookingId = Integer.parseInt(idStr);
                Booking booking = bookingService.getBookingById(bookingId);
                if (booking != null && booking.getGroupBookingId() != null) {
                    booking = bookingService.getBookingById(booking.getGroupBookingId());
                }
                if (booking != null && booking.getAccountId() != null && booking.getAccountId() == accountId
                        && ("Pending".equalsIgnoreCase(booking.getStatus())
                                || "Confirmed".equalsIgnoreCase(booking.getStatus()))) {
                    request.setAttribute("booking", booking);
                }
            } catch (NumberFormatException ignored) {
            }
        }

        // Propagate error/success messages if redirected back here
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorCode", error);
            request.setAttribute("errorMessage",
                    ERROR_MESSAGES.getOrDefault(error, ERROR_MESSAGES.get("MSG55")));

            // Thiếu phòng: nói rõ loại phòng nào và còn bao nhiêu, để khách biết
            // phải sửa dòng nào thay vì đoán.
            if ("MSG16".equals(error)) {
                String detailed = buildOutOfRoomsMessage(request);
                if (detailed != null) {
                    request.setAttribute("errorMessage", detailed);
                }
            }
        }

        List<RoomTypeInfo> roomTypes = roomTypeService.getAllRoomTypes();
        request.setAttribute("roomTypes", roomTypes);

        // Load the customer's bookings so the change/extension dropdowns can be
        // populated. Without this, the JSP's <c:forEach items="${bookings}"> has
        // nothing to iterate and both selects stay empty (no eligible booking).
        List<Booking> bookings = bookingService.getBookingsByAccount(accountId, "All", null);
        request.setAttribute("bookings", bookings);

        // Chi tiết từng dòng phòng của mỗi đơn: form thay đổi phải cho khách sửa
        // được từng loại phòng của đơn nhiều phòng, chứ không chỉ một cặp
        // (loại phòng, số lượng) của dòng cha.
        request.setAttribute("bookingRowsJson", buildBookingRowsJson(bookings));

        // Customer's change/extension requests, for the status-tracking table.
        request.setAttribute("myRequests", bookingRequestService.getRequestsByAccount(accountId));

        request.getRequestDispatcher("/WEB-INF/views/customer/booking-change.jsp").forward(request, response);
    }

    /**
     * Dựng JSON mô tả từng đơn kèm danh sách dòng phòng của nó, cho form thay
     * đổi đặt phòng dựng bảng dòng phía client. Chỉ lấy chi tiết của các đơn đủ
     * điều kiện gửi yêu cầu để không truy vấn thừa.
     */
    private String buildBookingRowsJson(List<Booking> bookings) {
        Map<String, Object> byBooking = new LinkedHashMap<>();
        for (Booking b : bookings) {
            String status = b.getStatus();
            boolean eligible = "Pending".equalsIgnoreCase(status)
                    || "Confirmed".equalsIgnoreCase(status)
                    || "CheckedIn".equalsIgnoreCase(status);
            if (!eligible) {
                continue;
            }

            List<Map<String, Object>> rows = new ArrayList<>();
            rows.add(describeRow(b));
            for (Booking child : bookingService.getChildBookings(b.getBookingId())) {
                rows.add(describeRow(child));
            }

            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("checkIn", b.getCheckInDate() != null ? b.getCheckInDate().toString() : null);
            entry.put("checkOut", b.getCheckOutDate() != null ? b.getCheckOutDate().toString() : null);
            entry.put("status", status);
            entry.put("totalAmount", b.getOverallTotalAmount());
            entry.put("rows", rows);
            byBooking.put(String.valueOf(b.getBookingId()), entry);
        }
        return new com.google.gson.Gson().toJson(byBooking);
    }

    /**
     * Dựng thông báo thiếu phòng cụ thể từ ba tham số số nguyên trên URL
     * (rt / need / have). Tên loại phòng được tra từ CSDL chứ không lấy từ URL,
     * nên không có nội dung nào do người dùng kiểm soát lọt vào trang.
     *
     * @return null nếu tham số không hợp lệ (khi đó dùng thông báo chung)
     */
    private String buildOutOfRoomsMessage(HttpServletRequest request) {
        try {
            int typeId = Integer.parseInt(request.getParameter("rt").trim());
            int need = Integer.parseInt(request.getParameter("need").trim());
            int have = Integer.parseInt(request.getParameter("have").trim());

            String name = "#" + typeId;
            for (RoomTypeInfo rt : roomTypeService.getAllRoomTypes()) {
                if (rt.getTypeId() == typeId) {
                    name = rt.getTypeName();
                    break;
                }
            }

            if (have <= 0) {
                return "Loại phòng \"" + name + "\" đã hết phòng trong khoảng ngày bạn chọn. "
                        + "Vui lòng đổi ngày hoặc chọn loại phòng khác.";
            }
            return "Loại phòng \"" + name + "\" chỉ còn " + have + " phòng trống trong khoảng ngày bạn chọn, "
                    + "trong khi yêu cầu của bạn cần " + need + " phòng. "
                    + "Vui lòng giảm số phòng hoặc đổi ngày.";
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Trả về số phòng còn trống của từng loại phòng cho khoảng ngày khách đang
     * chọn, đã loại chính nhóm đặt phòng này khỏi phép đếm (đơn của khách không
     * tự chặn mình).
     * <p>
     * Có endpoint này thì form thay đổi mới chặn được ngay tại chỗ: khách thấy
     * "còn mấy phòng" trước khi bấm gửi, thay vì điền xong mới bị trả về với
     * một thông báo chung chung. Server vẫn kiểm tra lại khi nhận yêu cầu —
     * đây chỉ là lớp hiển thị, không phải lớp bảo vệ.
     */
    private void handleCheckAvailability(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> payload = new LinkedHashMap<>();
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId").trim());
            Date checkIn = Date.valueOf(request.getParameter("checkIn").trim());
            Date checkOut = Date.valueOf(request.getParameter("checkOut").trim());
            if (!checkIn.before(checkOut)) {
                throw new IllegalArgumentException("checkOut must be after checkIn");
            }

            Booking root = bookingService.getBookingById(bookingId);
            if (root != null && root.getGroupBookingId() != null) {
                root = bookingService.getBookingById(root.getGroupBookingId());
            }
            if (root == null || root.getAccountId() == null || root.getAccountId() != accountId) {
                payload.put("success", false);
                response.getWriter().write(new com.google.gson.Gson().toJson(payload));
                return;
            }

            List<Integer> exclude = new ArrayList<>();
            exclude.add(root.getBookingId());
            for (Booking child : bookingService.getChildBookings(root.getBookingId())) {
                exclude.add(child.getBookingId());
            }

            Map<String, Integer> available = new LinkedHashMap<>();
            for (RoomTypeInfo rt : roomTypeService.getAllRoomTypes()) {
                available.put(String.valueOf(rt.getTypeId()),
                        bookingService.checkRoomAvailability(rt.getTypeId(), checkIn, checkOut, exclude));
            }

            payload.put("success", true);
            payload.put("available", available);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Invalid availability lookup", e);
            payload.clear();
            payload.put("success", false);
        }
        response.getWriter().write(new com.google.gson.Gson().toJson(payload));
    }

    private Map<String, Object> describeRow(Booking b) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("bookingId", b.getBookingId());
        row.put("roomTypeId", b.getRoomTypeId());
        row.put("roomTypeName", b.getRoomTypeName());
        row.put("quantity", b.getRoomQuantity());
        return row;
    }

    private void handleCreateBooking(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {

        String customerName = request.getParameter("customerName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String checkInStr = request.getParameter("checkInDate");
        String checkOutStr = request.getParameter("checkOutDate");
        String note = request.getParameter("note");

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

            String[] roomTypeIds = request.getParameterValues("roomTypeId[]");
            String[] roomQuantities = request.getParameterValues("roomQuantity[]");

            if (roomTypeIds == null || roomQuantities == null || roomTypeIds.length == 0
                    || roomTypeIds.length != roomQuantities.length) {
                throw new Exception("MSG55");
            }

            // Group duplicate room types
            Map<Integer, Integer> groupedRooms = new LinkedHashMap<>();
            for (int i = 0; i < roomTypeIds.length; i++) {
                int rtId = Integer.parseInt(roomTypeIds[i].trim());
                int qty = Integer.parseInt(roomQuantities[i].trim());
                groupedRooms.put(rtId, groupedRooms.getOrDefault(rtId, 0) + qty);
            }
            
            List<Integer> finalRtIds = new java.util.ArrayList<>(groupedRooms.keySet());

            // 1. Pre-validate availability for all selected room types
            for (int rtId : finalRtIds) {
                int qty = groupedRooms.get(rtId);
                int available = bookingService.checkRoomAvailability(rtId, booking.getCheckInDate(),
                        booking.getCheckOutDate());
                if (qty > available) {
                    throw new Exception("MSG19"); // Rooms not available
                }
            }

            if (finalRtIds.size() == 1) {
                // Single booking creation flow
                int roomTypeId = finalRtIds.get(0);
                int quantity = groupedRooms.get(roomTypeId);

                booking.setRoomTypeId(roomTypeId);
                booking.setRoomQuantity(quantity);
                booking.setGroupBookingId(null);

                bookingService.createBooking(booking);
            } else {
                // 2. Insert main (parent) booking
                int parentRoomTypeId = finalRtIds.get(0);
                int parentQty = groupedRooms.get(parentRoomTypeId);
                booking.setRoomTypeId(parentRoomTypeId);
                booking.setRoomQuantity(parentQty);
                booking.setGroupBookingId(null); // Parent is root

                bookingService.createBooking(booking);
                int parentBookingId = booking.getBookingId();

                // 3. Insert subsequent bookings as child bookings
                for (int i = 1; i < finalRtIds.size(); i++) {
                    Booking childBooking = new Booking();
                    childBooking.setAccountId(accountId);
                    childBooking.setCustomerName(customerName);

                    childBooking.setPhone(phone);
                    childBooking.setEmail(email);
                    childBooking.setCheckInDate(booking.getCheckInDate());
                    childBooking.setCheckOutDate(booking.getCheckOutDate());
                    childBooking.setNote(note);
                    childBooking.setGroupBookingId(parentBookingId);

                    int childRoomTypeId = finalRtIds.get(i);
                    int childQty = groupedRooms.get(childRoomTypeId);
                    childBooking.setRoomTypeId(childRoomTypeId);
                    childBooking.setRoomQuantity(childQty);

                    bookingService.createBooking(childBooking);
                }
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
                            promoRes.promotion.getPromotionId(), promoRes.promotion.getPromotionCode());
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
                    parseItemChanges(request),
                    request.getParameter("reason"));
            if (res.isSuccess()) {
                response.sendRedirect(ctx + "/customer/bookings?success=change_requested&charge="
                        + Math.round(res.additionalCharge));
            } else if (res.shortRoomTypeId != null) {
                // Chỉ đẩy số nguyên qua URL; tên loại phòng được tra lại ở
                // server khi dựng thông báo, nên không có chữ nào của người
                // dùng bị phản chiếu ngược ra trang.
                response.sendRedirect(ctx + "/customer/booking/change?error=" + res.code
                        + "&rt=" + res.shortRoomTypeId
                        + "&need=" + res.requestedRooms
                        + "&have=" + res.availableRooms);
            } else {
                response.sendRedirect(ctx + "/customer/booking/change?error=" + res.code);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/customer/booking/change?error=MSG02");
        }
    }

    /**
     * Đọc bảng dòng phòng mà khách gửi lên. Mỗi dòng gồm ba tham số song song:
     * {@code itemBookingId[]} (rỗng = dòng phòng mới thêm), {@code itemRoomTypeId[]}
     * và {@code itemRoomQuantity[]} (0 = bỏ dòng đó khỏi đơn).
     * <p>
     * Form cũ chỉ có một cặp loại phòng / số lượng; nếu gặp dạng đó thì coi như
     * một thao tác Update lên chính dòng khách đang chọn.
     */
    private List<BookingService.ItemChange> parseItemChanges(HttpServletRequest request) {
        List<BookingService.ItemChange> items = new ArrayList<>();

        String[] rowBookingIds = request.getParameterValues("itemBookingId[]");
        String[] rowTypeIds = request.getParameterValues("itemRoomTypeId[]");
        String[] rowQuantities = request.getParameterValues("itemRoomQuantity[]");

        if (rowTypeIds == null || rowQuantities == null || rowTypeIds.length != rowQuantities.length) {
            String typeId = request.getParameter("roomTypeId");
            String qty = request.getParameter("roomQuantity");
            String bookingId = request.getParameter("bookingId");
            if (typeId != null && !typeId.isBlank() && qty != null && !qty.isBlank()) {
                items.add(BookingService.ItemChange.of(BookingRequestItem.ACTION_UPDATE,
                        Integer.parseInt(bookingId.trim()),
                        Integer.parseInt(typeId.trim()), Integer.parseInt(qty.trim())));
            }
            return items;
        }

        for (int i = 0; i < rowTypeIds.length; i++) {
            if (rowTypeIds[i] == null || rowTypeIds[i].isBlank()) {
                continue;
            }
            int typeId = Integer.parseInt(rowTypeIds[i].trim());
            int quantity = Integer.parseInt(rowQuantities[i].trim());

            Integer targetBookingId = null;
            if (rowBookingIds != null && i < rowBookingIds.length
                    && rowBookingIds[i] != null && !rowBookingIds[i].isBlank()) {
                targetBookingId = Integer.parseInt(rowBookingIds[i].trim());
            }

            if (targetBookingId == null) {
                if (quantity > 0) {
                    items.add(BookingService.ItemChange.of(BookingRequestItem.ACTION_ADD, null, typeId, quantity));
                }
            } else if (quantity <= 0) {
                items.add(BookingService.ItemChange.of(BookingRequestItem.ACTION_REMOVE, targetBookingId, null, null));
            } else {
                items.add(BookingService.ItemChange.of(BookingRequestItem.ACTION_UPDATE, targetBookingId,
                        typeId, quantity));
            }
        }
        return items;
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
