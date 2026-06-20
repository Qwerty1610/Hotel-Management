package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.RoomTypeRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRoom;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import java.sql.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service xử lý các nghiệp vụ logic liên quan đến Đặt phòng (Booking).
 * Thực hiện kiểm tra ngày hợp lệ, sức chứa tối đa, tính tổng tiền, đặt cọc 30% và gọi DAO lưu thông tin.
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
     * Creates a new booking with validation.
     * Throws exception with message keys (MSG17, MSG19, MSG20, MSG03, MSG55) if validation fails.
     */
    public boolean createBooking(Booking booking, List<BookingRoom> rooms) throws Exception {
        try {
            // 1. Validate inputs
            if (booking == null || rooms == null || rooms.isEmpty()) {
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

            double totalAmount = 0;
            int totalRoomsCount = 0;
            StringBuilder guestNamesBuilder = new StringBuilder();

            // 4. Validate capacity and availability for each room selection
            for (BookingRoom br : rooms) {
                RoomTypeInfo rt = roomTypeRepository.getRoomTypeById(br.getRoomTypeId());
                if (rt == null) {
                    throw new Exception("MSG55");
                }

                // Attach room type name and price per night to the BookingRoom detail record
                br.setRoomTypeName(rt.getTypeName());
                br.setPrice(rt.getBasePrice());

                // Check capacity constraint (MSG20)
                // In single-room mode, the quantity is br.getQuantity() (which is 1 or more)
                // and guests count is compared.
                // In multi-room mode, each BookingRoom has quantity=1.
                // br.getQuantity() should be >= 1.
                int qty = br.getQuantity() > 0 ? br.getQuantity() : 1;
                totalRoomsCount += qty;

                // Validate capacity: if the room has guest name list or guest count
                // Since guestName is a string, let's check its length or content.
                // However, for direct capacity check, we will validate the number of guests
                // that the user passed for this room type.
                // If the user specifies guestName, we can split it by comma to count guests.
                int guestCount = 1;
                if (br.getGuestName() != null && !br.getGuestName().trim().isEmpty()) {
                    String[] names = br.getGuestName().split(",");
                    guestCount = names.length;
                }
                
                if (guestCount > rt.getCapacity() * qty) {
                    throw new Exception("MSG20"); // Guest count exceeds capacity
                }

                // Check date-based overlapping availability (MSG19)
                int totalRoomsInHotel = getRoomCountByTypeId(br.getRoomTypeId());
                int bookedRoomsCount = bookingDAO.getBookedRoomsCountForDates(br.getRoomTypeId(), checkIn, checkOut);
                int availableRooms = totalRoomsInHotel - bookedRoomsCount;

                if (qty > availableRooms) {
                    throw new Exception("MSG19"); // Rooms not available
                }

                // Accumulate total price
                totalAmount += rt.getBasePrice() * qty * nights;

                // Collect guest names
                if (br.getGuestName() != null && !br.getGuestName().trim().isEmpty()) {
                    if (guestNamesBuilder.length() > 0) {
                        guestNamesBuilder.append(", ");
                    }
                    guestNamesBuilder.append(br.getGuestName().trim());
                }
            }

            // Set calculated properties on booking
            booking.setTotalAmount(totalAmount);
            booking.setRoomQuantity(totalRoomsCount);
            booking.setStatus("Pending"); // Default initial status

            // Format note for receptionist dashboard compatibility (appending guest list to the note)
            String originalNote = booking.getNote() != null ? booking.getNote().trim() : "";
            String formattedNote = originalNote;
            if (guestNamesBuilder.length() > 0) {
                String guestListPart = "Khách đi cùng: " + guestNamesBuilder.toString();
                if (!originalNote.isEmpty()) {
                    formattedNote = guestListPart + ". Ghi chú đặc biệt: " + originalNote;
                } else {
                    formattedNote = guestListPart;
                }
            }
            if (formattedNote.length() > 500) {
                formattedNote = formattedNote.substring(0, 497) + "...";
            }
            booking.setNote(formattedNote);

            // 5. Call DAO to write Booking and BookingRooms in a single transaction
            boolean success = bookingDAO.insertBookingTransaction(booking, rooms);
            if (!success) {
                throw new Exception("MSG55");
            }
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
            if ("CheckedIn".equalsIgnoreCase(status) || "CheckedOut".equalsIgnoreCase(status) || "Rejected".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status)) {
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

    public List<BookingRoom> getBookingRooms(int bookingId) {
        return bookingDAO.getBookingRooms(bookingId);
    }

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
    public List<Room> getAllRooms() {
        return bookingDAO.getAllRooms();
    }

    /**
     * Returns rooms filtered by room type ID.
     */
    public List<Room> getRoomsByTypeId(int typeId) {
        return bookingDAO.getRoomsByTypeId(typeId);
    }

    /**
     * Returns rooms already assigned to a specific booking via Booking_Room.
     */
    public List<Room> getAssignedRoomsForBooking(int bookingId) {
        return bookingDAO.getAssignedRoomsForBooking(bookingId);
    }

    /**
     * Assigns (or replaces) rooms to a booking in the Booking_Room table.
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
}
