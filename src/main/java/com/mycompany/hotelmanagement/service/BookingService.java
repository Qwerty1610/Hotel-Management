package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.RoomTypeRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
import java.sql.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service xử lý các nghiệp vụ logic liên quan đến Đặt phòng (Booking). Thực
 * hiện kiểm tra ngày hợp lệ, sức chứa tối đa, tính tổng tiền, đặt cọc 30% và
 * gọi DAO lưu thông tin.
 *
 * @author BinhHD
 * @date 20/06/2026
 * @version 1.0
 */
public class BookingService {

    private static final Logger LOGGER = Logger.getLogger(BookingService.class.getName());
    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomTypeRepository roomTypeRepository = new RoomTypeRepository();

    /**
     * Creates a new booking with validation. Throws exception with message keys
     * (MSG17, MSG19, MSG20, MSG03, MSG55) if validation fails.
     */
    public boolean createBooking(Booking booking) throws Exception {
        try {
            // 1. Validate inputs
            if (booking == null) {
                throw new Exception("MSG55"); // Unexpected error
            }

            // 2. Validate dates (MSG17)
            Date checkIn = booking.getCheckInDate();
            Date checkOut = booking.getCheckOutDate();
            if (checkIn == null || checkOut == null || !checkIn.before(checkOut)) {
                throw new Exception("MSG17"); // Checkout must be after checkin
            }

            // 3. Validate Special Request length (MSG03)
            if (booking.getNote() != null && booking.getNote().length() > 500) {
                throw new Exception("MSG03"); // Special request too long (max 500)
            }

            long nights = booking.getNights();
            if (nights <= 0) {
                throw new Exception("MSG17");
            }

            // 4. Validate capacity and availability
            RoomTypeInfo rt = roomTypeRepository.getRoomTypeById(booking.getRoomTypeId());
            if (rt == null) {
                throw new Exception("MSG55");
            }

            // Attach room type name
            booking.setRoomTypeName(rt.getTypeName());

            int qty = booking.getRoomQuantity() > 0 ? booking.getRoomQuantity() : 1;

            // Check date-based overlapping availability (MSG19)
            int totalRoomsInHotel = getRoomCountByTypeId(booking.getRoomTypeId());
            int bookedRoomsCount = bookingDAO.getBookedRoomsCountForDates(booking.getRoomTypeId(), checkIn, checkOut);
            int availableRooms = totalRoomsInHotel - bookedRoomsCount;

            if (qty > availableRooms) {
                throw new Exception("MSG19"); // Rooms not available
            }

            // Calculate total price
            double totalAmount = rt.getBasePrice() * qty * nights;
            booking.setTotalAmount(totalAmount);
            booking.setStatus("Pending"); // Default initial status

            // 5. Call DAO to write Booking
            int bookingId = bookingDAO.createBooking(booking);
            if (bookingId <= 0) {
                throw new Exception("MSG55");
            }
            booking.setBookingId(bookingId);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in createBooking service call", e);
            if (e.getMessage() != null && e.getMessage().startsWith("MSG")) {
                throw e;
            }
            throw new Exception("MSG55", e);
        }
    }

    /**
     * Cancels a booking by customer request.
     */
    public boolean cancelBookingByCustomer(int bookingId, int accountId) throws Exception {
        try {
            Booking b = bookingDAO.getBookingById(bookingId);
            if (b == null) {
                throw new Exception("MSG55");
            }

            // Validate data ownership
            if (b.getAccountId() == null || b.getAccountId() != accountId) {
                throw new Exception("MSG55");
            }

            // Validate status allows cancellation
            String status = b.getStatus();
            if ("CheckedIn".equalsIgnoreCase(status) || "CheckedOut".equalsIgnoreCase(status)
                    || "Rejected".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status)) {
                throw new Exception("MSG55");
            }

            boolean success = bookingDAO.cancelBooking(bookingId, "Huỷ bởi khách hàng");
            if (!success) {
                throw new Exception("MSG55");
            }
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in cancelBookingByCustomer: id=" + bookingId, e);
            if (e.getMessage() != null && e.getMessage().startsWith("MSG")) {
                throw e;
            }
            throw new Exception("MSG55", e);
        }
    }

    public List<Booking> getBookingsByAccount(int accountId, String statusFilter, String keyword) {
        return bookingDAO.getBookingsByAccount(accountId, statusFilter, keyword);
    }

    public Booking getBookingById(int bookingId) {
        return bookingDAO.getBookingById(bookingId);
    }

    public List<Booking> getChildBookings(int parentBookingId) {
        return bookingDAO.getChildBookings(parentBookingId);
    }

    // getBookingRooms removed in simplification
    /**
     * Delegates updateBookingDetails to DAO.
     */
    public boolean updateBookingDetails(Booking booking) {
        return bookingDAO.updateBookingDetails(booking);
    }

    /**
     * Delegates updateBookingStatus to DAO.
     */
    public boolean updateBookingStatus(int bookingId, String newStatus, String note) {
        return bookingDAO.updateBookingStatus(bookingId, newStatus, note);
    }

    /**
     * Delegates cancelBooking to DAO.
     */
    public boolean cancelBooking(int bookingId, String reason) {
        return bookingDAO.cancelBooking(bookingId, reason);
    }

    /**
     * Returns all rooms in the hotel with their type name and current status.
     */
    public List<Room> getAllRooms(Date checkIn, Date checkOut) {
        return bookingDAO.getAllRooms(checkIn, checkOut);
    }

    /**
     * Returns rooms filtered by room type ID.
     */
    public List<Room> getRoomsByTypeId(int typeId, Date checkIn, Date checkOut) {
        return bookingDAO.getRoomsByTypeId(typeId, checkIn, checkOut);
    }

    /**
     * Returns rooms already assigned to a specific booking via RoomAssignment.
     */
    public List<Room> getAssignedRoomsForBooking(int bookingId, Date checkIn, Date checkOut) {
        return bookingDAO.getAssignedRoomsForBooking(bookingId, checkIn, checkOut);
    }

    /**
     * Assigns (or replaces) rooms to a booking in the RoomAssignment table.
     */
    public boolean assignRoomsToBooking(int bookingId, List<Integer> roomIds) {
        return bookingDAO.assignRoomsToBooking(bookingId, roomIds);
    }

    /**
     * Returns customer account details (full name, email, phone) by accountId.
     */
    public CustomerDetails getCustomerDetailsByAccountId(int accountId) {
        return bookingDAO.getCustomerDetailsByAccountId(accountId);
    }

    /**
     * Checks available rooms of a specific type for a date range.
     */
    public int checkRoomAvailability(int roomTypeId, Date checkIn, Date checkOut) {
        return bookingDAO.checkRoomAvailability(roomTypeId, checkIn, checkOut);
    }

    /**
     * Checks if specific rooms conflict with other overlapping assignments.
     */
    public List<Integer> getConflictingRooms(List<Integer> roomIds, Date checkIn, Date checkOut, int excludeBookingId) {
        return bookingDAO.getConflictingRooms(roomIds, checkIn, checkOut, excludeBookingId);
    }

    /**
     * Gets the total count of rooms of a specific type in the database.
     */
    private int getRoomCountByTypeId(int typeId) {
        String sql = "SELECT COUNT(*) FROM Room WHERE type_id = ?";
        try (java.sql.Connection conn = com.mycompany.hotelmanagement.config.DBContext.getConnection()) {
            try (java.sql.Statement stmt = conn.createStatement()) {
                stmt.execute("USE HotelManagementDB");
            } catch (Exception se) {
                // Ignore USE DB error
            }
            try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, typeId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getRoomCountByTypeId: typeId=" + typeId, e);
        }
        return 0;
    }

    public double calculateGroupTotalAmount(int parentBookingId) {
        Booking parent = bookingDAO.getBookingById(parentBookingId);
        if (parent == null) {
            return 0;
        }
        long nights = parent.getNights();
        double total = 0;

        RoomTypeInfo parentType
                = roomTypeRepository.getRoomTypeById(parent.getRoomTypeId());
        if (parentType != null) {
            total += parentType.getBasePrice() * parent.getRoomQuantity();
        }

        List<Booking> children = bookingDAO.getChildBookings(parentBookingId);
        for (Booking child : children) {
            RoomTypeInfo type
                    = roomTypeRepository.getRoomTypeById(child.getRoomTypeId());
            if (type != null) {
                total += type.getBasePrice() * child.getRoomQuantity();
            }
        }
        return total * nights;
    }

    public double calculateBookingAmount(Booking booking) {
        if (booking == null || booking.getRoomTypeId() == null) {
            return 0;
        }
        RoomTypeInfo roomType = roomTypeRepository.getRoomTypeById(booking.getRoomTypeId());
        if (roomType == null) {
            return 0;
        }
        return roomType.getBasePrice()
                * booking.getRoomQuantity()
                * booking.getNights();
    }
}
