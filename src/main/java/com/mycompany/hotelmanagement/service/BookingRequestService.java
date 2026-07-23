package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.BookingRequestDAO;
import com.mycompany.hotelmanagement.dal.RoomTypeDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRequest;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Business logic for the two customer self-service booking requests:
 * <ul>
 *   <li>UC 2.3.9  Request Booking Change</li>
 *   <li>UC 2.3.14 Request Stay Extension</li>
 * </ul>
 * Each method validates per the use case and creates a Pending request that
 * Reception/Manager can later review. Validation returns short result codes
 * (MSGxx / NOT_ELIGIBLE) that the controller maps to user-facing messages.
 *
 * @author QuyPQ
 * date: 12/07/2026
 * version: 1.1
 */
public class BookingRequestService {

    private static final Logger LOGGER = Logger.getLogger(BookingRequestService.class.getName());

    private final BookingRequestDAO requestDAO = new BookingRequestDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomTypeDAO roomTypeRepository = new RoomTypeDAO();

    /** Outcome of a request operation: a result code plus any computed charge. */
    public static class Result {
        public final String code;
        public final double additionalCharge;

        public Result(String code) { this(code, 0); }
        public Result(String code, double additionalCharge) {
            this.code = code;
            this.additionalCharge = additionalCharge;
        }
        public boolean isSuccess() { return code != null && code.startsWith("MSG2"); }
    }

    public List<BookingRequest> getRequestsByAccount(int accountId) {
        return requestDAO.getRequestsByAccount(accountId);
    }

    // =====================================================================
    // UC 2.4.5 Process Booking Change (Receptionist)
    // =====================================================================

    public List<BookingRequest> getRequestsForStaff(String statusFilter, String keyword, int offset, int limit) {
        return requestDAO.getRequestsForStaff(statusFilter, keyword, offset, limit);
    }

    public int countRequestsForStaff(String statusFilter, String keyword) {
        return requestDAO.countRequestsForStaff(statusFilter, keyword);
    }

    /**
     * Approves a pending request and applies it to the booking:
     * <ul>
     *   <li>Change    — new dates / room type / quantity; room assignments are
     *                   cleared so reception can re-assign; amount recalculated.</li>
     *   <li>Extension — later check-out on the current stay; amount recalculated.</li>
     * </ul>
     *
     * @return null on success, or an error code:
     *         notfound | not_pending | not_eligible | no_room | unknown
     */
    public String approveRequest(int requestId) {
        try {
            BookingRequest req = requestDAO.getRequestById(requestId);
            if (req == null) {
                return "notfound";
            }
            if (!"Pending".equalsIgnoreCase(req.getStatus())) {
                return "not_pending";
            }
            Booking booking = bookingDAO.getBookingById(req.getBookingId());
            if (booking == null) {
                return "notfound";
            }

            BookingService bookingService = new BookingService();

            if (req.isChange()) {
                // Booking must still be changeable (not checked-in / cancelled)
                String status = booking.getStatus();
                boolean eligible = "Pending".equalsIgnoreCase(status) || "Confirmed".equalsIgnoreCase(status);
                if (!eligible || req.getNewCheckIn() == null || req.getNewCheckOut() == null
                        || req.getNewRoomTypeId() == null || req.getNewRoomQuantity() == null) {
                    return "not_eligible";
                }
                // Yêu cầu đã quá hạn: ngày nhận phòng mới nằm trong quá khứ
                if (req.getNewCheckIn().toLocalDate().isBefore(LocalDate.now())) {
                    return "not_eligible";
                }

                // Re-check availability at approval time; chính booking này được
                // loại khỏi phép đếm trong SQL (không cộng trả thủ công để tránh
                // thổi phồng số trống khi khoảng ngày mới không giao khoảng cũ).
                int available = bookingDAO.checkRoomAvailability(
                        req.getNewRoomTypeId(), req.getNewCheckIn(), req.getNewCheckOut(),
                        booking.getBookingId());
                if (req.getNewRoomQuantity() > available) {
                    return "no_room";
                }

                booking.setCheckInDate(req.getNewCheckIn());
                booking.setCheckOutDate(req.getNewCheckOut());
                booking.setRoomTypeId(req.getNewRoomTypeId());
                booking.setRoomQuantity(req.getNewRoomQuantity());
                booking.setTotalAmount(bookingService.calculateBookingAmount(booking));
                // updateBookingDetails chỉ nhận đơn Pending nên dùng applyBookingChange
                // để cập nhật được cả đơn Confirmed
                if (!bookingDAO.applyBookingChange(booking)) {
                    return "unknown";
                }
                // Old room assignments may no longer fit the new dates/type
                bookingService.assignRoomsToBooking(booking.getBookingId(), new java.util.ArrayList<>());

            } else if (req.isExtension()) {
                if (!"CheckedIn".equalsIgnoreCase(booking.getStatus())
                        || req.getNewCheckOut() == null || booking.getCheckOutDate() == null
                        || !booking.getCheckOutDate().before(req.getNewCheckOut())) {
                    return "not_eligible";
                }

                // Re-check availability of the same type for the extra nights
                if (booking.getRoomTypeId() == null) {
                    return "unknown";
                }
                int qty = booking.getRoomQuantity() > 0 ? booking.getRoomQuantity() : 1;
                int available = bookingDAO.checkRoomAvailability(
                        booking.getRoomTypeId(), booking.getCheckOutDate(), req.getNewCheckOut(),
                        booking.getBookingId());
                if (qty > available) {
                    return "no_room";
                }
                // BR-41 — phòng vật lý đang ở đã bị đơn khác đặt cho các đêm gia hạn
                if (hasRoomConflictForExtension(booking.getBookingId(),
                        booking.getCheckOutDate(), req.getNewCheckOut())) {
                    return "no_room";
                }

                booking.setCheckOutDate(req.getNewCheckOut());
                booking.setTotalAmount(bookingService.calculateBookingAmount(booking));
                // Đơn gia hạn đang CheckedIn nên phải dùng applyBookingChange
                if (!bookingDAO.applyBookingChange(booking)) {
                    return "unknown";
                }
            } else {
                return "unknown";
            }

            if (!requestDAO.updateStatus(requestId, "Approved")) {
                return "unknown";
            }
            return null;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error approving request " + requestId, e);
            return "unknown";
        }
    }

    /**
     * Rejects a pending request. The booking itself is left untouched.
     *
     * @return null on success, or an error code: notfound | not_pending | unknown
     */
    public String rejectRequest(int requestId) {
        try {
            BookingRequest req = requestDAO.getRequestById(requestId);
            if (req == null) {
                return "notfound";
            }
            if (!"Pending".equalsIgnoreCase(req.getStatus())) {
                return "not_pending";
            }
            return requestDAO.updateStatus(requestId, "Rejected") ? null : "unknown";
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error rejecting request " + requestId, e);
            return "unknown";
        }
    }

    /**
     * UC 2.3.9 — create a booking-change request (new dates / type / quantity).
     * Eligible only for the customer's own Pending/Confirmed booking before check-in.
     */
    public Result requestBookingChange(int accountId, int bookingId, String newCheckInStr,
            String newCheckOutStr, String roomTypeIdStr, String roomQuantityStr, String reason) {
        try {
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null || booking.getAccountId() == null || booking.getAccountId() != accountId) {
                return new Result("MSG55");
            }

            // E1 — eligible status only (not CheckedIn / CheckedOut / Cancelled / Rejected)
            String status = booking.getStatus();
            boolean eligible = "Pending".equalsIgnoreCase(status) || "Confirmed".equalsIgnoreCase(status);
            if (!eligible) {
                return new Result("NOT_ELIGIBLE");
            }
            // PRE-3 — change window still open (before the original check-in date)
            if (booking.getCheckInDate() != null
                    && !LocalDate.now().isBefore(booking.getCheckInDate().toLocalDate())) {
                return new Result("NOT_ELIGIBLE");
            }

            // AF-1 — required fields
            if (isBlank(newCheckInStr) || isBlank(newCheckOutStr)
                    || isBlank(roomTypeIdStr) || isBlank(roomQuantityStr)) {
                return new Result("MSG02");
            }
            if (reason != null && reason.length() > 500) {
                return new Result("MSG03");
            }

            Date newCheckIn = parseDate(newCheckInStr);
            Date newCheckOut = parseDate(newCheckOutStr);
            int newRoomTypeId = Integer.parseInt(roomTypeIdStr.trim());
            int newRoomQuantity = Integer.parseInt(roomQuantityStr.trim());
            if (newCheckIn == null || newCheckOut == null || newRoomQuantity <= 0) {
                return new Result("MSG02");
            }

            // E2 — checkout must be after checkin; new check-in must not be in the past
            if (!newCheckIn.before(newCheckOut) || newCheckIn.toLocalDate().isBefore(LocalDate.now())) {
                return new Result("MSG17");
            }

            RoomTypeInfo rt = roomTypeRepository.getRoomTypeById(newRoomTypeId);
            if (rt == null) {
                return new Result("MSG55");
            }

            // AF-2 — availability for the new selection. Chính booking này (và các
            // booking con trong nhóm) được loại khỏi phép đếm ngay trong SQL, để
            // đơn của khách không tự chặn mình trên những ngày hai khoảng giao nhau
            // nhưng cũng không thổi phồng số trống khi khoảng mới không giao khoảng cũ.
            int available = bookingDAO.checkRoomAvailability(newRoomTypeId, newCheckIn, newCheckOut, bookingId);
            if (newRoomQuantity > available) {
                return new Result("MSG16");
            }

            BookingRequest r = new BookingRequest();
            r.setBookingId(bookingId);
            r.setAccountId(accountId);
            r.setRequestType(BookingRequest.TYPE_CHANGE);
            r.setOldCheckIn(booking.getCheckInDate());
            r.setOldCheckOut(booking.getCheckOutDate());
            r.setNewCheckIn(newCheckIn);
            r.setNewCheckOut(newCheckOut);
            r.setNewRoomTypeId(newRoomTypeId);
            r.setNewRoomQuantity(newRoomQuantity);
            r.setReason(reason);
            r.setStatus("Pending");

            int id = requestDAO.create(r);
            if (id <= 0) {
                return new Result("MSG55");
            }
            return new Result("MSG22");
        } catch (NumberFormatException e) {
            return new Result("MSG02");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in requestBookingChange", e);
            return new Result("MSG55");
        }
    }

    /**
     * UC 2.3.14 — create a stay-extension request (later check-out, same room).
     * Eligible only for the customer's own CheckedIn booking.
     */
    public Result requestStayExtension(int accountId, int bookingId, String newCheckOutStr, String reason) {
        try {
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null || booking.getAccountId() == null || booking.getAccountId() != accountId) {
                return new Result("MSG55");
            }

            // E1 — only an active (CheckedIn) stay can be extended
            if (!"CheckedIn".equalsIgnoreCase(booking.getStatus())) {
                return new Result("NOT_ELIGIBLE");
            }

            // AF-2 — new date required
            if (isBlank(newCheckOutStr)) {
                return new Result("MSG02");
            }
            if (reason != null && reason.length() > 500) {
                return new Result("MSG03");
            }

            Date newCheckOut = parseDate(newCheckOutStr);
            Date currentCheckOut = booking.getCheckOutDate();
            if (newCheckOut == null || currentCheckOut == null) {
                return new Result("MSG02");
            }

            // E2 — new check-out must be strictly later than the current check-out
            if (!currentCheckOut.before(newCheckOut)) {
                return new Result("MSG17");
            }

            // AF-1 — availability of the same room type for the extra nights
            int qty = booking.getRoomQuantity() > 0 ? booking.getRoomQuantity() : 1;
            if (booking.getRoomTypeId() == null) {
                return new Result("MSG55");
            }
            int available = bookingDAO.checkRoomAvailability(
                    booking.getRoomTypeId(), currentCheckOut, newCheckOut, bookingId);
            if (qty > available) {
                return new Result("MSG16");
            }

            // E2 / BR-41 — phòng cụ thể khách đang ở đã bị đơn khác đặt cho các
            // đêm gia hạn (dù loại phòng vẫn còn phòng trống khác) -> chặn gửi.
            if (hasRoomConflictForExtension(bookingId, currentCheckOut, newCheckOut)) {
                return new Result("ROOM_TAKEN");
            }

            RoomTypeInfo rt = roomTypeRepository.getRoomTypeById(booking.getRoomTypeId());
            if (rt == null) {
                return new Result("MSG55");
            }
            long extraNights = (newCheckOut.getTime() - currentCheckOut.getTime()) / (1000L * 60 * 60 * 24);
            double additionalCharge = rt.getBasePrice() * qty * extraNights;

            BookingRequest r = new BookingRequest();
            r.setBookingId(bookingId);
            r.setAccountId(accountId);
            r.setRequestType(BookingRequest.TYPE_EXTENSION);
            r.setOldCheckIn(booking.getCheckInDate());
            r.setOldCheckOut(currentCheckOut);
            r.setNewCheckOut(newCheckOut);
            r.setAdditionalCharge(additionalCharge);
            r.setReason(reason);
            r.setStatus("Pending");

            int id = requestDAO.create(r);
            if (id <= 0) {
                return new Result("MSG55");
            }
            return new Result("MSG23", additionalCharge);
        } catch (NumberFormatException e) {
            return new Result("MSG02");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in requestStayExtension", e);
            return new Result("MSG55");
        }
    }

    /**
     * BR-41 — kiểm tra xung đột PHÒNG VẬT LÝ khi gia hạn: một trong các phòng
     * đã gán (RoomAssignment) cho booking này có bị booking khác (Pending /
     * Confirmed / CheckedIn) đặt trong khoảng [from, to) hay không. Kiểm tra
     * theo loại phòng không phát hiện được trường hợp lễ tân đã gán đúng căn
     * phòng khách đang ở cho một đơn khác ngay sau ngày trả hiện tại.
     */
    private boolean hasRoomConflictForExtension(int bookingId, Date from, Date to) {
        List<Room> assigned = bookingDAO.getAssignedRoomsForBooking(bookingId, from, to);
        if (assigned == null || assigned.isEmpty()) {
            return false;
        }
        List<Integer> roomIds = new ArrayList<>();
        for (Room r : assigned) {
            roomIds.add(r.getRoomId());
        }
        return !bookingDAO.getConflictingRooms(roomIds, from, to, bookingId).isEmpty();
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private Date parseDate(String s) {
        try {
            return Date.valueOf(s.trim());
        } catch (Exception e) {
            return null;
        }
    }
}
