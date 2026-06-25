package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.BookingRequestDAO;
import com.mycompany.hotelmanagement.dal.RoomTypeRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRequest;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import java.sql.Date;
import java.time.LocalDate;
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
 */
public class BookingRequestService {

    private static final Logger LOGGER = Logger.getLogger(BookingRequestService.class.getName());

    private final BookingRequestDAO requestDAO = new BookingRequestDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomTypeRepository roomTypeRepository = new RoomTypeRepository();

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

            // AF-2 — availability for the new selection. The current booking already
            // reserves rooms of its own type, so add its quantity back when the type
            // is unchanged to avoid a false "no room" on a same-type date tweak.
            int available = bookingDAO.checkRoomAvailability(newRoomTypeId, newCheckIn, newCheckOut);
            boolean sameType = booking.getRoomTypeId() != null && booking.getRoomTypeId() == newRoomTypeId;
            int effectiveAvailable = available + (sameType ? booking.getRoomQuantity() : 0);
            if (newRoomQuantity > effectiveAvailable) {
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
            int available = bookingDAO.checkRoomAvailability(booking.getRoomTypeId(), currentCheckOut, newCheckOut);
            if (qty > available) {
                return new Result("MSG16");
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
