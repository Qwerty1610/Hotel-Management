package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRoom;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * BookingDAO
 * Package harmonized to dal for HMS Hotel-Management structure.
 * Standardized database selection utilizing useDatabase helper.
 * Date: 01/6/2026
 * 
 * @author DUC BINH
 */
public class BookingDAO {

    private static final Logger LOGGER = Logger.getLogger(BookingDAO.class.getName());
    
    private static final Set<String> STATUS_WHITELIST = Set.of("Pending", "Confirmed", "Rejected", "Cancelled");
    private static final Set<String> FILTER_STATUS_WHITELIST = Set.of("All", "Pending", "Confirmed", "Rejected", "Cancelled", "CheckedIn", "CheckedOut");

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    private static final String BASE_SELECT = "SELECT b.booking_id, b.account_id, b.customer_name, " +
            "       b.room_type_id, COALESCE(rt.type_name, (SELECT STRING_AGG(rt2.type_name, ', ') FROM dbo.BookingRoom br JOIN dbo.RoomType rt2 ON br.room_type_id = rt2.type_id WHERE br.booking_id = b.booking_id)) AS room_type_name, " +
            "       b.room_quantity, b.check_in_date, b.check_out_date, " +
            "       b.total_amount, b.status, b.note, CAST(b.created_at AS DATE) AS created_at, " +
            "       (SELECT STRING_AGG(r.room_number, ', ') " +
            "        FROM dbo.Booking_Room br " +
            "        JOIN dbo.Room r ON br.room_id = r.room_id " +
            "        WHERE br.booking_id = b.booking_id) AS assigned_rooms " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.RoomType rt ON b.room_type_id = rt.type_id ";

    private String sanitizeLikeKeyword(String keyword) {
        if (keyword == null) return "";
        return keyword.replace("[", "[[]")
                      .replace("%", "[%]")
                      .replace("_", "[_]");
    }

    public List<Booking> getBookings(String statusFilter, String keyword) {
        List<Booking> list = new ArrayList<>();

        // Validate statusFilter
        if (statusFilter == null || !FILTER_STATUS_WHITELIST.contains(statusFilter)) {
            statusFilter = "All";
        }

        StringBuilder sql = new StringBuilder(BASE_SELECT);
        List<Object> params = new ArrayList<>();
        boolean hasWhere = false;

        // Filter by status
        if (!statusFilter.equalsIgnoreCase("All")) {
            sql.append("WHERE b.status = ? ");
            params.add(statusFilter);
            hasWhere = true;
        }

        // Filter by keyword (tên khách hoặc mã)
        if (keyword != null && !keyword.trim().isEmpty()) {
            String sanitizedKw = sanitizeLikeKeyword(keyword.trim());
            String kw = "%" + sanitizedKw + "%";
            if (hasWhere) {
                sql.append("AND (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ?) ");
            } else {
                sql.append("WHERE (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ?) ");
            }
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY b.created_at DESC, b.booking_id DESC");

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getBookings: " + statusFilter + ", " + keyword, e);
        }
        return list;
    }

    public Booking getBookingById(int bookingId) {
        if (bookingId <= 0) {
            return null;
        }
        String sql = BASE_SELECT + "WHERE b.booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next())
                        return mapRow(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getBookingById: " + bookingId, e);
        }
        return null;
    }

    public boolean updateBookingStatus(int bookingId, String newStatus, String note) {
        if (bookingId <= 0) {
            return false;
        }
        if (newStatus == null || !STATUS_WHITELIST.contains(newStatus)) {
            LOGGER.log(Level.WARNING, "Invalid new status for booking update: " + newStatus);
            return false;
        }
        String sql = "UPDATE dbo.Booking " +
                "SET status = ?, note = ?, updated_at = SYSDATETIME() " +
                "WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setString(2, note != null ? note.trim() : "");
                ps.setInt(3, bookingId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in updateBookingStatus: id=" + bookingId + ", status=" + newStatus, e);
        }
        return false;
    }

    public boolean updateBookingDetails(Booking b) {
        if (b == null || !b.isValid()) {
            LOGGER.log(Level.WARNING, "Invalid Booking entity provided for update: " + b);
            return false;
        }
        String sql = "UPDATE dbo.Booking " +
                "SET customer_name = ?, room_type_id = ?, room_quantity = ?, " +
                "    check_in_date = ?, check_out_date = ?, total_amount = ?, " +
                "    note = ?, updated_at = SYSDATETIME() " +
                "WHERE booking_id = ? AND status = N'Pending'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, b.getCustomerName());
                if (b.getRoomTypeId() != null)
                    ps.setInt(2, b.getRoomTypeId());
                else
                    ps.setNull(2, Types.INTEGER);
                ps.setInt(3, b.getRoomQuantity());
                ps.setDate(4, b.getCheckInDate());
                ps.setDate(5, b.getCheckOutDate());
                ps.setDouble(6, b.getTotalAmount());
                ps.setString(7, b.getNote());
                ps.setInt(8, b.getBookingId());

                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in updateBookingDetails for id: " + b.getBookingId(), e);
        }
        return false;
    }

    public boolean cancelBooking(int bookingId, String reason) {
        if (bookingId <= 0) {
            return false;
        }
        String sql = "UPDATE dbo.Booking " +
                "SET status = N'Cancelled', note = ?, updated_at = SYSDATETIME() " +
                "WHERE booking_id = ? AND status NOT IN (N'CheckedIn', N'CheckedOut')";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, reason != null ? reason.trim() : "Huỷ theo yêu cầu");
                ps.setInt(2, bookingId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in cancelBooking: id=" + bookingId, e);
        }
        return false;
    }

    public int countByStatus(String status) {
        if (status == null || !FILTER_STATUS_WHITELIST.contains(status)) {
            return 0;
        }
        String sql = "SELECT COUNT(*) FROM dbo.Booking WHERE status = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next())
                        return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in countByStatus: " + status, e);
        }
        return 0;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM dbo.Booking";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in countAll", e);
        }
        return 0;
    }

    private Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getInt("booking_id"));
        int accountId = rs.getInt("account_id");
        if (!rs.wasNull())
            b.setAccountId(accountId);
        b.setCustomerName(rs.getString("customer_name"));
        int typeId = rs.getInt("room_type_id");
        if (!rs.wasNull())
            b.setRoomTypeId(typeId);
        b.setRoomTypeName(rs.getString("room_type_name"));
        b.setRoomQuantity(rs.getInt("room_quantity"));
        b.setCheckInDate(rs.getDate("check_in_date"));
        b.setCheckOutDate(rs.getDate("check_out_date"));
        b.setTotalAmount(rs.getDouble("total_amount"));
        b.setStatus(rs.getString("status"));
        b.setNote(rs.getString("note"));
        b.setCreatedAt(rs.getDate("created_at"));
        try {
            b.setAssignedRoomsStr(rs.getString("assigned_rooms"));
        } catch (SQLException e) {
            // Safe fallback
        }
        return b;
    }

    public int getBookedRoomsCountForDates(int typeId, Date checkIn, Date checkOut) {
        String sql = "SELECT COALESCE(SUM(quantity), 0) FROM (" +
                     "    SELECT SUM(br.quantity) AS quantity " +
                     "    FROM dbo.BookingRoom br " +
                     "    JOIN dbo.Booking b ON br.booking_id = b.booking_id " +
                     "    WHERE br.room_type_id = ? " +
                     "      AND b.status IN ('Pending', 'Confirmed', 'CheckedIn') " +
                     "      AND b.check_in_date < ? " +
                     "      AND b.check_out_date > ? " +
                     "    UNION ALL " +
                     "    SELECT SUM(b.room_quantity) AS quantity " +
                     "    FROM dbo.Booking b " +
                     "    WHERE b.room_type_id = ? " +
                     "      AND b.status IN ('Pending', 'Confirmed', 'CheckedIn') " +
                     "      AND b.check_in_date < ? " +
                     "      AND b.check_out_date > ? " +
                     "      AND b.booking_id NOT IN (SELECT booking_id FROM dbo.BookingRoom)" +
                     ") AS combined";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, typeId);
                ps.setDate(2, checkOut);
                ps.setDate(3, checkIn);
                ps.setInt(4, typeId);
                ps.setDate(5, checkOut);
                ps.setDate(6, checkIn);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getBookedRoomsCountForDates: typeId=" + typeId + ", in=" + checkIn + ", out=" + checkOut, e);
        }
        return 0;
    }

    public boolean insertBookingTransaction(Booking booking, List<BookingRoom> rooms) {
        if (booking == null || rooms == null || rooms.isEmpty()) {
            return false;
        }
        String insertBookingSql = "INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, " +
                "check_in_date, check_out_date, total_amount, status, note, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        String insertRoomSql = "INSERT INTO dbo.BookingRoom (booking_id, room_type_id, quantity, price, guest_name) " +
                "VALUES (?, ?, ?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            useDatabase(conn);
            conn.setAutoCommit(false);
            
            try (PreparedStatement psB = conn.prepareStatement(insertBookingSql, Statement.RETURN_GENERATED_KEYS)) {
                if (booking.getAccountId() != null) {
                    psB.setInt(1, booking.getAccountId());
                } else {
                    psB.setNull(1, Types.INTEGER);
                }
                psB.setString(2, booking.getCustomerName());
                if (booking.getRoomTypeId() != null) {
                    psB.setInt(3, booking.getRoomTypeId());
                } else {
                    psB.setNull(3, Types.INTEGER);
                }
                psB.setInt(4, booking.getRoomQuantity());
                psB.setDate(5, booking.getCheckInDate());
                psB.setDate(6, booking.getCheckOutDate());
                psB.setDouble(7, booking.getTotalAmount());
                psB.setString(8, booking.getStatus());
                psB.setString(9, booking.getNote());
                
                psB.executeUpdate();
                int bookingId = -1;
                try (ResultSet rs = psB.getGeneratedKeys()) {
                    if (rs.next()) {
                        bookingId = rs.getInt(1);
                    }
                }
                
                if (bookingId <= 0) {
                    throw new SQLException("Inserting booking failed, no ID obtained.");
                }
                
                booking.setBookingId(bookingId);
                
                try (PreparedStatement psR = conn.prepareStatement(insertRoomSql)) {
                    for (BookingRoom r : rooms) {
                        psR.setInt(1, bookingId);
                        psR.setInt(2, r.getRoomTypeId());
                        psR.setInt(3, r.getQuantity() > 0 ? r.getQuantity() : 1);
                        psR.setDouble(4, r.getPrice());
                        psR.setString(5, r.getGuestName());
                        psR.addBatch();
                    }
                    psR.executeBatch();
                }
                
                conn.commit();
                return true;
            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException ex) {
                        LOGGER.log(Level.SEVERE, "Rollback failed", ex);
                    }
                }
                throw e;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in insertBookingTransaction", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Closing connection failed", ex);
                }
            }
        }
        return false;
    }

    public List<BookingRoom> getBookingRooms(int bookingId) {
        List<BookingRoom> rooms = new ArrayList<>();
        String sql = "SELECT br.booking_room_id, br.booking_id, br.room_type_id, rt.type_name, br.quantity, br.price, br.guest_name " +
                     "FROM dbo.BookingRoom br " +
                     "JOIN dbo.RoomType rt ON br.room_type_id = rt.type_id " +
                     "WHERE br.booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        BookingRoom r = new BookingRoom();
                        r.setBookingRoomId(rs.getInt("booking_room_id"));
                        r.setBookingId(rs.getInt("booking_id"));
                        r.setRoomTypeId(rs.getInt("room_type_id"));
                        r.setRoomTypeName(rs.getString("type_name"));
                        r.setQuantity(rs.getInt("quantity"));
                        r.setPrice(rs.getDouble("price"));
                        r.setGuestName(rs.getString("guest_name"));
                        rooms.add(r);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getBookingRooms for bookingId=" + bookingId, e);
        }
        return rooms;
    }

    public List<Booking> getBookingsByAccount(int accountId, String statusFilter, String keyword) {
        List<Booking> list = new ArrayList<>();

        if (statusFilter == null || !FILTER_STATUS_WHITELIST.contains(statusFilter)) {
            statusFilter = "All";
        }

        StringBuilder sql = new StringBuilder(BASE_SELECT);
        List<Object> params = new ArrayList<>();
        
        sql.append("WHERE b.account_id = ? ");
        params.add(accountId);

        // Filter by status
        if (!statusFilter.equalsIgnoreCase("All")) {
            sql.append("AND b.status = ? ");
            params.add(statusFilter);
        }

        // Filter by keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            String sanitizedKw = sanitizeLikeKeyword(keyword.trim());
            String kw = "%" + sanitizedKw + "%";
            sql.append("AND (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ? OR b.note LIKE ?) ");
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY b.created_at DESC, b.booking_id DESC");

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getBookingsByAccount: accountId=" + accountId + ", status=" + statusFilter + ", keyword=" + keyword, e);
        }
        return list;
    }

    public BookingDAO() {
        ensureBookingRoomTableExists();
    }

    private void ensureBookingRoomTableExists() {
        String sql = "IF OBJECT_ID(N'dbo.Booking_Room', N'U') IS NULL " +
                     "BEGIN " +
                     "    CREATE TABLE dbo.Booking_Room ( " +
                     "        booking_id INT NOT NULL, " +
                     "        room_id INT NOT NULL, " +
                     "        PRIMARY KEY (booking_id, room_id), " +
                     "        CONSTRAINT FK_BookingRoom_Booking FOREIGN KEY (booking_id) REFERENCES dbo.Booking(booking_id) ON DELETE CASCADE, " +
                     "        CONSTRAINT FK_BookingRoom_Room FOREIGN KEY (room_id) REFERENCES dbo.Room(room_id) ON DELETE CASCADE " +
                     "    ); " +
                     "END";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(sql);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error ensuring Booking_Room table exists", e);
        }
    }

    public List<Room> getRoomsByTypeId(int typeId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.room_id, r.room_number, r.status, r.floor, rt.type_name " +
                     "FROM dbo.Room r " +
                     "JOIN dbo.RoomType rt ON r.type_id = rt.type_id " +
                     "WHERE r.type_id = ? " +
                     "ORDER BY r.floor, r.room_number";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, typeId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Room r = new Room();
                        r.setRoomId(rs.getInt("room_id"));
                        r.setRoomNumber(rs.getString("room_number"));
                        r.setStatus(rs.getString("status"));
                        r.setFloor(rs.getString("floor"));
                        r.setTypeName(rs.getString("type_name"));
                        list.add(r);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getRoomsByTypeId: " + typeId, e);
        }
        return list;
    }

    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.room_id, r.room_number, r.status, r.floor, rt.type_name " +
                     "FROM dbo.Room r " +
                     "JOIN dbo.RoomType rt ON r.type_id = rt.type_id " +
                     "ORDER BY r.floor, r.room_number";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Room r = new Room();
                        r.setRoomId(rs.getInt("room_id"));
                        r.setRoomNumber(rs.getString("room_number"));
                        r.setStatus(rs.getString("status"));
                        r.setFloor(rs.getString("floor"));
                        r.setTypeName(rs.getString("type_name"));
                        list.add(r);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getAllRooms", e);
        }
        return list;
    }

    public CustomerDetails getCustomerDetailsByAccountId(int accountId) {
        String sql = "SELECT a.full_name, a.email, a.phone " +
                     "FROM dbo.Account a " +
                     "WHERE a.account_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        CustomerDetails cd = new CustomerDetails();
                        cd.setFullName(rs.getString("full_name"));
                        cd.setEmail(rs.getString("email"));
                        cd.setPhone(rs.getString("phone"));
                        return cd;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getCustomerDetailsByAccountId: " + accountId, e);
        }
        return null;
    }

    public boolean assignRoomsToBooking(int bookingId, List<Integer> roomIds) {
        if (bookingId <= 0 || roomIds == null) {
            return false;
        }
        
        String deleteSql = "DELETE FROM dbo.Booking_Room WHERE booking_id = ?";
        String insertSql = "INSERT INTO dbo.Booking_Room (booking_id, room_id) VALUES (?, ?)";
        
        Connection conn = null;
        PreparedStatement deletePs = null;
        PreparedStatement insertPs = null;
        
        try {
            conn = DBContext.getConnection();
            useDatabase(conn);
            conn.setAutoCommit(false);
            
            // Delete old assignments
            deletePs = conn.prepareStatement(deleteSql);
            deletePs.setInt(1, bookingId);
            deletePs.executeUpdate();
            
            // Insert new assignments
            if (!roomIds.isEmpty()) {
                insertPs = conn.prepareStatement(insertSql);
                for (int roomId : roomIds) {
                    insertPs.setInt(1, bookingId);
                    insertPs.setInt(2, roomId);
                    insertPs.addBatch();
                }
                insertPs.executeBatch();
            }
            
            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in assignRoomsToBooking: bookingId=" + bookingId, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Error rolling back transaction", ex);
                }
            }
        } finally {
            if (deletePs != null) try { deletePs.close(); } catch (Exception e) {}
            if (insertPs != null) try { insertPs.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return false;
    }

    public List<Room> getAssignedRoomsForBooking(int bookingId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.room_id, r.room_number, r.status, r.floor, rt.type_name " +
                     "FROM dbo.Booking_Room br " +
                     "JOIN dbo.Room r ON br.room_id = r.room_id " +
                     "JOIN dbo.RoomType rt ON r.type_id = rt.type_id " +
                     "WHERE br.booking_id = ? " +
                     "ORDER BY r.room_number";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Room r = new Room();
                        r.setRoomId(rs.getInt("room_id"));
                        r.setRoomNumber(rs.getString("room_number"));
                        r.setStatus(rs.getString("status"));
                        r.setFloor(rs.getString("floor"));
                        r.setTypeName(rs.getString("type_name"));
                        list.add(r);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getAssignedRoomsForBooking: " + bookingId, e);
        }
        return list;
    }

    public int createBooking(Booking b) {
        if (b == null) return -1;
        String sql = "INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                if (b.getAccountId() != null) {
                    ps.setInt(1, b.getAccountId());
                } else {
                    ps.setNull(1, Types.INTEGER);
                }
                ps.setString(2, b.getCustomerName());
                if (b.getRoomTypeId() != null) {
                    ps.setInt(3, b.getRoomTypeId());
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setInt(4, b.getRoomQuantity());
                ps.setDate(5, b.getCheckInDate());
                ps.setDate(6, b.getCheckOutDate());
                ps.setDouble(7, b.getTotalAmount());
                ps.setString(8, b.getStatus() != null ? b.getStatus() : "Pending");
                ps.setString(9, b.getNote() != null ? b.getNote().trim() : "");

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            return rs.getInt(1);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in createBooking: " + b, e);
        }
        return -1;
    }

    private static class BookingOverlap {
        Date checkIn;
        Date checkOut;
        int qty;
        BookingOverlap(Date checkIn, Date checkOut, int qty) {
            this.checkIn = checkIn;
            this.checkOut = checkOut;
            this.qty = qty;
        }
    }

    public int checkRoomAvailability(int roomTypeId, Date checkIn, Date checkOut) {
        int totalRooms = 0;
        String countSql = "SELECT COUNT(*) FROM dbo.Room WHERE type_id = ? AND status <> N'Maintenance'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setInt(1, roomTypeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalRooms = rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting total rooms for type: " + roomTypeId, e);
            return 0;
        }

        String overlapSql = "SELECT check_in_date, check_out_date, room_quantity FROM dbo.Booking " +
                            "WHERE room_type_id = ? AND status IN (N'Pending', N'Confirmed', N'CheckedIn') " +
                            "AND check_in_date < ? AND check_out_date > ?";
        
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(overlapSql)) {
                ps.setInt(1, roomTypeId);
                ps.setDate(2, checkOut);
                ps.setDate(3, checkIn);
                
                List<BookingOverlap> overlaps = new ArrayList<>();
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        overlaps.add(new BookingOverlap(
                            rs.getDate("check_in_date"),
                            rs.getDate("check_out_date"),
                            rs.getInt("room_quantity")
                        ));
                    }
                }
                
                long startEpoch = checkIn.getTime();
                long endEpoch = checkOut.getTime();
                int maxBooked = 0;
                
                for (long time = startEpoch; time < endEpoch; time += 24 * 60 * 60 * 1000L) {
                    Date day = new Date(time);
                    int bookedOnDay = 0;
                    for (BookingOverlap overlap : overlaps) {
                        if (!day.before(overlap.checkIn) && day.before(overlap.checkOut)) {
                            bookedOnDay += overlap.qty;
                        }
                    }
                    if (bookedOnDay > maxBooked) {
                        maxBooked = bookedOnDay;
                    }
                }
                
                return Math.max(0, totalRooms - maxBooked);
                
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error checking room availability for type: " + roomTypeId, e);
        }
        return 0;
    }
}
