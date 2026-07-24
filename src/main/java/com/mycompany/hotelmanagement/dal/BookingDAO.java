package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Project: Hotel Management System Class: BookingDAO
 *
 * Description: Đối tượng truy cập dữ liệu (DAO) cho tất cả các thao tác CSDL
 * liên quan đến đặt phòng. Cung cấp các phương thức để tạo, truy xuất, cập nhật
 * và phân trang đặt phòng, quản lý xếp phòng, và hỗ trợ chuyển đổi trạng thái
 * nhận/trả phòng. Sử dụng JDBC thuần thông qua DBContext.
 *
 * Related Use Cases: - UC-11 Create Booking (Customer Online) - UC-12 Process
 * Booking Request - UC-13 Create Walk-in Booking - UC-14 Check-In Customer -
 * UC-16 Check-Out Customer - UC-38 View Booking History
 *
 * Date: 01-06-2026
 *
 * @author BinhHD, QuyPQ
 * @version 1.5
 */
public class BookingDAO {

    private static final Logger LOGGER = Logger.getLogger(BookingDAO.class.getName());

    private static final Set<String> STATUS_WHITELIST = Set.of(
            "Pending",
            "Confirmed",
            "Rejected",
            "Cancelled",
            "CheckedIn",
            "CheckedOut");
    private static final Set<String> FILTER_STATUS_WHITELIST = Set.of("All", "Pending", "Confirmed", "Rejected",
            "Cancelled", "CheckedIn", "CheckedOut");

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    private static final String BASE_SELECT = "SELECT b.booking_id, b.account_id, b.customer_name, b.phone, b.email, "
            + "       b.room_type_id, rt.type_name AS room_type_name, "
            + "       b.room_quantity, b.check_in_date, b.check_out_date, "
            + "       b.total_amount, b.status, b.note, b.group_booking_id, CAST(b.created_at AS DATE) AS created_at, "
            + "       (SELECT STRING_AGG(r.room_number, ', ') "
            + "        FROM dbo.RoomAssignment br "
            + "        JOIN dbo.Room r ON br.room_id = r.room_id "
            + "        WHERE br.booking_id = b.booking_id) AS assigned_rooms, "
            + "       (SELECT SUM(sb.room_quantity) "
            + "        FROM dbo.Booking sb "
            + "        WHERE sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id) AS total_room_quantity, "
            + "       (SELECT STRING_AGG(type_name, ', ') "
            + "        FROM ( "
            + "            SELECT DISTINCT srt.type_name "
            + "            FROM dbo.Booking sb "
            + "            JOIN dbo.RoomType srt ON sb.room_type_id = srt.type_id "
            + "            WHERE sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id "
            + "        ) AS dt) AS group_room_type_names, "
            + "       (SELECT COUNT(DISTINCT sb.room_type_id) "
            + "        FROM dbo.Booking sb "
            + "        WHERE sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id) AS total_room_types, "
            + "       (SELECT SUM(sb.total_amount) "
            + "        FROM dbo.Booking sb "
            + "        WHERE sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id) AS overall_total_amount "
            + "FROM dbo.Booking b "
            + "LEFT JOIN dbo.RoomType rt ON b.room_type_id = rt.type_id ";

    private String sanitizeLikeKeyword(String keyword) {
        if (keyword == null) {
            return "";
        }
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

        sql.append("WHERE b.group_booking_id IS NULL ");

        // Filter by status
        if (!statusFilter.equalsIgnoreCase("All")) {
            sql.append("AND b.status = ? ");
            params.add(statusFilter);
        }

        // Filter by keyword (tên khách hoặc mã)
        if (keyword != null && !keyword.trim().isEmpty()) {
            String sanitizedKw = sanitizeLikeKeyword(keyword.trim());
            String kw = "%" + sanitizedKw + "%";
            sql.append("AND (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ?) ");
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
                    if (rs.next()) {
                        return mapRow(rs);
                    }
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
        String sql = "UPDATE dbo.Booking "
                + "SET status = ?, note = ?, updated_at = SYSDATETIME() "
                + "WHERE booking_id = ? OR group_booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setString(2, note != null ? note.trim() : "");
                ps.setInt(3, bookingId);
                ps.setInt(4, bookingId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    return true;
                }
                return false;
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
        String sql = "UPDATE dbo.Booking "
                + "SET customer_name = ?, phone = ?, email = ?, room_type_id = ?, room_quantity = ?, "
                + "    check_in_date = ?, check_out_date = ?, total_amount = ?, "
                + "    note = ?, updated_at = SYSDATETIME() "
                + "WHERE booking_id = ? AND status = N'Pending'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, b.getCustomerName());
                ps.setString(2, b.getPhone());
                ps.setString(3, b.getEmail());
                if (b.getRoomTypeId() != null) {
                    ps.setInt(4, b.getRoomTypeId());
                } else {
                    ps.setNull(4, Types.INTEGER);
                }
                ps.setInt(5, b.getRoomQuantity());
                ps.setDate(6, b.getCheckInDate());
                ps.setDate(7, b.getCheckOutDate());
                ps.setDouble(8, b.getTotalAmount());
                ps.setString(9, b.getNote());
                ps.setInt(10, b.getBookingId());

                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in updateBookingDetails for id: " + b.getBookingId(), e);
        }
        return false;
    }

    /**
     * UC 2.4.5 Process Booking Change: áp thay đổi đã duyệt vào đơn đặt phòng
     * (ngày, loại phòng, số phòng, tổng tiền). Khác updateBookingDetails,
     * method này không giới hạn status = Pending vì đơn Confirmed (thay đổi)
     * hoặc CheckedIn (gia hạn) cũng được cập nhật — điều kiện hợp lệ đã được
     * BookingRequestService kiểm tra trước khi gọi.
     */
    public boolean applyBookingChange(Booking b) {
        if (b == null || b.getBookingId() <= 0 || b.getCheckInDate() == null
                || b.getCheckOutDate() == null || !b.getCheckInDate().before(b.getCheckOutDate())) {
            LOGGER.log(Level.WARNING, "Invalid booking data for applyBookingChange: " + b);
            return false;
        }
        String sql = "UPDATE dbo.Booking "
                + "SET room_type_id = ?, room_quantity = ?, check_in_date = ?, check_out_date = ?, "
                + "    total_amount = ?, updated_at = SYSDATETIME() "
                + "WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (b.getRoomTypeId() != null) {
                    ps.setInt(1, b.getRoomTypeId());
                } else {
                    ps.setNull(1, Types.INTEGER);
                }
                ps.setInt(2, b.getRoomQuantity());
                ps.setDate(3, b.getCheckInDate());
                ps.setDate(4, b.getCheckOutDate());
                ps.setDouble(5, b.getTotalAmount());
                ps.setInt(6, b.getBookingId());
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in applyBookingChange for id: " + b.getBookingId(), e);
        }
        return false;
    }

    public boolean updateBookingTotalAmountAndNote(int bookingId, double newAmount, String noteAppend) {
        if (bookingId <= 0) {
            return false;
        }
        String sql = "UPDATE dbo.Booking "
                + "SET total_amount = ?, note = ISNULL(note, '') + CHAR(13) + CHAR(10) + ?, updated_at = SYSDATETIME() "
                + "WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDouble(1, newAmount);
                ps.setString(2, noteAppend);
                ps.setInt(3, bookingId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in updateBookingTotalAmountAndNote for id: " + bookingId, e);
        }
        return false;
    }

    public boolean cancelBooking(int bookingId, String reason) {
        if (bookingId <= 0) {
            return false;
        }
        String sql = "UPDATE dbo.Booking "
                + "SET status = N'Cancelled', note = ?, updated_at = SYSDATETIME() "
                + "WHERE (booking_id = ? OR group_booking_id = ?) AND status NOT IN (N'CheckedIn', N'CheckedOut')";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, reason != null ? reason.trim() : "Huỷ theo yêu cầu");
                ps.setInt(2, bookingId);
                ps.setInt(3, bookingId);
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
        String sql = "SELECT COUNT(*) FROM dbo.Booking WHERE status = ? AND group_booking_id IS NULL";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in countByStatus: " + status, e);
        }
        return 0;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM dbo.Booking WHERE group_booking_id IS NULL";
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
        if (!rs.wasNull()) {
            b.setAccountId(accountId);
        }
        b.setCustomerName(rs.getString("customer_name"));
        b.setPhone(rs.getString("phone"));
        b.setEmail(rs.getString("email"));
        int typeId = rs.getInt("room_type_id");
        if (!rs.wasNull()) {
            b.setRoomTypeId(typeId);
        }
        b.setRoomTypeName(rs.getString("room_type_name"));
        b.setRoomQuantity(rs.getInt("room_quantity"));
        b.setCheckInDate(rs.getDate("check_in_date"));
        b.setCheckOutDate(rs.getDate("check_out_date"));
        b.setTotalAmount(rs.getDouble("total_amount"));
        b.setStatus(rs.getString("status"));
        b.setNote(rs.getString("note"));
        int groupBookingId = rs.getInt("group_booking_id");
        if (!rs.wasNull()) {
            b.setGroupBookingId(groupBookingId);
        }
        b.setCreatedAt(rs.getDate("created_at"));
        try {
            b.setAssignedRoomsStr(rs.getString("assigned_rooms"));
        } catch (SQLException e) {
            // Safe fallback
        }
        try {
            b.setTotalRoomQuantity(rs.getInt("total_room_quantity"));
        } catch (SQLException e) {
            // Safe fallback
        }
        try {
            b.setGroupRoomTypeNames(rs.getString("group_room_type_names"));
        } catch (SQLException e) {
            // Safe fallback
        }
        try {
            b.setTotalRoomTypes(rs.getInt("total_room_types"));
        } catch (SQLException e) {
            // Safe fallback
        }
        try {
            b.setOverallTotalAmount(rs.getDouble("overall_total_amount"));
        } catch (SQLException e) {
            // Safe fallback
        }
        return b;
    }

    public int getBookedRoomsCountForDates(int typeId, Date checkIn, Date checkOut) {
        String sql = "SELECT COALESCE(SUM(room_quantity), 0) "
                + "FROM dbo.Booking "
                + "WHERE room_type_id = ? "
                + "  AND status IN ('Pending', 'Confirmed', 'CheckedIn') "
                + "  AND check_in_date < ? "
                + "  AND check_out_date > ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, typeId);
                ps.setDate(2, checkOut);
                ps.setDate(3, checkIn);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE,
                    "Error in getBookedRoomsCountForDates: typeId=" + typeId + ", in=" + checkIn + ", out=" + checkOut,
                    e);
        }
        return 0;
    }

    public List<Booking> getBookingsByAccount(int accountId, String statusFilter, String keyword) {
        List<Booking> list = new ArrayList<>();

        if (statusFilter == null || !FILTER_STATUS_WHITELIST.contains(statusFilter)) {
            statusFilter = "All";
        }

        StringBuilder sql = new StringBuilder(BASE_SELECT);
        List<Object> params = new ArrayList<>();

        sql.append("WHERE b.account_id = ? AND b.group_booking_id IS NULL ");
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
            LOGGER.log(Level.SEVERE, "Error in getBookingsByAccount: accountId=" + accountId + ", status="
                    + statusFilter + ", keyword=" + keyword, e);
        }
        return list;
    }

    public List<Booking> getChildBookings(int parentBookingId) {
        List<Booking> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE b.group_booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, parentBookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getChildBookings: " + parentBookingId, e);
        }
        return list;
    }

    public BookingDAO() {
        ensureRoomAssignmentTableExists();
    }

    private void ensureRoomAssignmentTableExists() {
        String sql = "IF OBJECT_ID(N'dbo.RoomAssignment', N'U') IS NULL "
                + "BEGIN "
                + "    CREATE TABLE dbo.RoomAssignment ( "
                + "        booking_id INT NOT NULL, "
                + "        room_id INT NOT NULL, "
                + "        assigned_by INT NULL, "
                + "        assigned_at DATETIME2 NULL, "
                + "        note NVARCHAR(500) NULL, "
                + "        PRIMARY KEY (booking_id, room_id), "
                + "        CONSTRAINT FK_RoomAssignment_Booking FOREIGN KEY (booking_id) REFERENCES dbo.Booking(booking_id) ON DELETE CASCADE, "
                + "        CONSTRAINT FK_RoomAssignment_Room FOREIGN KEY (room_id) REFERENCES dbo.Room(room_id) ON DELETE CASCADE, "
                + "        CONSTRAINT FK_RoomAssignment_Account FOREIGN KEY (assigned_by) REFERENCES dbo.Account(account_id) "
                + "    ); "
                + "END";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(sql);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error ensuring RoomAssignment table exists", e);
        }
    }

    public List<Room> getRoomsByTypeId(
            int typeId,
            Date checkIn,
            Date checkOut) {
        List<Room> list = new ArrayList<>();
        String sql = """
                SELECT
                    r.room_id,
                    r.room_number,

                    CASE

                        WHEN EXISTS (

                            SELECT 1
                            FROM RoomAssignment ra
                            JOIN Booking b
                                ON ra.booking_id = b.booking_id

                            WHERE ra.room_id = r.room_id
                              AND b.status IN ('Confirmed','CheckedIn')
                              AND b.check_in_date < ?
                              AND b.check_out_date > ?

                        )

                        THEN 'Occupied'

                        WHEN r.status='Maintenance'
                            THEN 'Maintenance'

                        WHEN r.status='OutOfService'
                            THEN 'OutOfService'

                        ELSE 'Available'

                    END AS display_status,

                    r.floor,

                    rt.type_name

                FROM Room r

                JOIN RoomType rt
                ON rt.type_id=r.type_id

                 WHERE r.type_id=? AND r.is_deleted = 0

                ORDER BY
                r.floor,
                r.room_number
                """;
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, checkOut);
                ps.setDate(2, checkIn);
                ps.setInt(3, typeId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Room r = new Room();
                        r.setRoomId(rs.getInt("room_id"));
                        r.setRoomNumber(rs.getString("room_number"));
                        r.setStatus(rs.getString("display_status"));
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

    public List<Room> getAllRooms(Date checkIn, Date checkOut) {
        List<Room> list = new ArrayList<>();

        String sql = """
                SELECT
                    r.room_id,
                    r.room_number,

                    CASE
                        WHEN EXISTS (
                            SELECT 1
                            FROM RoomAssignment ra
                            JOIN Booking b ON ra.booking_id = b.booking_id
                            WHERE ra.room_id = r.room_id
                              AND b.status IN ('Confirmed','CheckedIn')
                              AND b.check_in_date < ?
                              AND b.check_out_date > ?
                        )
                        THEN 'Occupied'

                        WHEN r.status='Maintenance'
                            THEN 'Maintenance'

                        WHEN r.status='OutOfService'
                            THEN 'OutOfService'

                        ELSE 'Available'
                    END AS display_status,

                    r.floor,
                    rt.type_name

                FROM Room r
                JOIN RoomType rt ON rt.type_id=r.type_id
                WHERE r.is_deleted = 0

                ORDER BY r.floor, r.room_number
                """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, checkOut);
            ps.setDate(2, checkIn);
            useDatabase(conn);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Room room = new Room();

                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setFloor(rs.getString("floor"));
                room.setTypeName(rs.getString("type_name"));

                room.setStatus(rs.getString("display_status"));

                list.add(room);

            }

        } catch (Exception e) {

            LOGGER.log(Level.SEVERE,
                    "Error getAllRooms", e);

        }
        return list;
    }

    public CustomerDetails getCustomerDetailsByAccountId(int accountId) {
        String sql = "SELECT a.full_name, a.email, a.phone "
                + "FROM dbo.Account a "
                + "WHERE a.account_id = ?";
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

        String deleteSql = "DELETE FROM dbo.RoomAssignment WHERE booking_id = ?";
        String insertSql = "INSERT INTO dbo.RoomAssignment (booking_id, room_id, assigned_at) VALUES (?, ?, SYSDATETIME())";

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
            if (deletePs != null)
                try {
                deletePs.close();
            } catch (Exception e) {
            }
            if (insertPs != null)
                try {
                insertPs.close();
            } catch (Exception e) {
            }
            if (conn != null)
                try {
                conn.close();
            } catch (Exception e) {
            }
        }
        return false;
    }

    public List<Room> getAssignedRoomsForBooking(int bookingId, Date checkIn, Date checkOut) {
        List<Room> list = new ArrayList<>();
        String sql = """
                SELECT

                    r.room_id,
                    r.room_number,

                    CASE
                        WHEN b.status IN ('Confirmed','CheckedIn')
                             AND b.check_in_date < ?
                             AND b.check_out_date > ?
                        THEN 'Occupied'

                        WHEN r.status='Maintenance'
                            THEN 'Maintenance'

                        WHEN r.status='OutOfService'
                            THEN 'OutOfService'

                        ELSE 'Available'
                    END AS display_status,

                    r.floor,

                    rt.type_name

                FROM RoomAssignment ra

                JOIN Room r

                ON ra.room_id=r.room_id

                JOIN RoomType rt

                ON rt.type_id=r.type_id

                JOIN Booking b

                ON b.booking_id=ra.booking_id

                WHERE ra.booking_id=?

                ORDER BY r.room_number
                """;
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, checkOut);
                ps.setDate(2, checkIn);
                ps.setInt(3, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Room r = new Room();
                        r.setRoomId(rs.getInt("room_id"));
                        r.setRoomNumber(rs.getString("room_number"));
                        r.setStatus(rs.getString("display_status"));
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
        if (b == null) {
            return -1;
        }
        String sql = "INSERT INTO dbo.Booking (account_id, customer_name, phone, email, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note, group_booking_id, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                if (b.getAccountId() != null) {
                    ps.setInt(1, b.getAccountId());
                } else {
                    ps.setNull(1, Types.INTEGER);
                }
                ps.setString(2, b.getCustomerName());
                ps.setString(3, b.getPhone());
                ps.setString(4, b.getEmail());
                if (b.getRoomTypeId() != null) {
                    ps.setInt(5, b.getRoomTypeId());
                } else {
                    ps.setNull(5, Types.INTEGER);
                }
                ps.setInt(6, b.getRoomQuantity());
                ps.setDate(7, b.getCheckInDate());
                ps.setDate(8, b.getCheckOutDate());
                ps.setDouble(9, b.getTotalAmount());
                ps.setString(10, b.getStatus() != null ? b.getStatus() : "Pending");
                ps.setString(11, b.getNote() != null ? b.getNote().trim() : "");
                if (b.getGroupBookingId() != null) {
                    ps.setInt(12, b.getGroupBookingId());
                } else {
                    ps.setNull(12, Types.INTEGER);
                }

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
        return checkRoomAvailability(roomTypeId, checkIn, checkOut, null);
    }

    /**
     * Số phòng trống của một loại phòng trong khoảng [checkIn, checkOut), tính
     * theo ngày cao điểm. {@code excludeBookingId} (nullable) loại chính booking
     * đó và các booking con trong nhóm của nó khỏi phép đếm — dùng khi kiểm tra
     * yêu cầu thay đổi ngày của một booking hiện hữu, để đơn của chính khách
     * không tự chặn mình trên những ngày hai khoảng giao nhau.
     */
    public int checkRoomAvailability(int roomTypeId, Date checkIn, Date checkOut, Integer excludeBookingId) {
        int totalRooms = 0;
        String countSql = "SELECT COUNT(*) FROM dbo.Room WHERE type_id = ? AND status <> N'Maintenance' AND is_deleted = 0";
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

        String overlapSql = "SELECT check_in_date, check_out_date, room_quantity FROM dbo.Booking "
                + "WHERE room_type_id = ? AND status IN (N'Pending', N'Confirmed', N'CheckedIn') "
                + "AND check_in_date < ? AND check_out_date > ?"
                + (excludeBookingId != null
                        ? " AND booking_id <> ? AND (group_booking_id IS NULL OR group_booking_id <> ?)"
                        : "");

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(overlapSql)) {
                ps.setInt(1, roomTypeId);
                ps.setDate(2, checkOut);
                ps.setDate(3, checkIn);
                if (excludeBookingId != null) {
                    ps.setInt(4, excludeBookingId);
                    ps.setInt(5, excludeBookingId);
                }

                List<BookingOverlap> overlaps = new ArrayList<>();
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        overlaps.add(new BookingOverlap(
                                rs.getDate("check_in_date"),
                                rs.getDate("check_out_date"),
                                rs.getInt("room_quantity")));
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

    public List<Integer> getConflictingRooms(List<Integer> roomIds, Date checkIn, Date checkOut,
            int excludeParentBookingId) {
        List<Integer> conflictingRooms = new ArrayList<>();
        if (roomIds == null || roomIds.isEmpty() || checkIn == null || checkOut == null) {
            return conflictingRooms;
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < roomIds.size(); i++) {
            placeholders.append("?");
            if (i < roomIds.size() - 1) {
                placeholders.append(",");
            }
        }

        String sql = "SELECT DISTINCT ra.room_id "
                + "FROM dbo.RoomAssignment ra "
                + "JOIN dbo.Booking b ON ra.booking_id = b.booking_id "
                + "WHERE ra.room_id IN (" + placeholders.toString() + ") "
                + "AND b.booking_id != ? AND (b.group_booking_id IS NULL OR b.group_booking_id != ?) "
                + "AND b.status IN (N'Pending', N'Confirmed', N'CheckedIn') "
                + "AND b.check_in_date < ? AND b.check_out_date > ?";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int index = 1;
                for (Integer roomId : roomIds) {
                    ps.setInt(index++, roomId);
                }
                ps.setInt(index++, excludeParentBookingId);
                ps.setInt(index++, excludeParentBookingId);
                ps.setDate(index++, checkOut);
                ps.setDate(index++, checkIn);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        conflictingRooms.add(rs.getInt("room_id"));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getConflictingRooms: " + e.getMessage(), e);
        }
        return conflictingRooms;
    }

    public List<Booking> getCheckInBookings(
            String status,
            String keyword,
            int offset,
            int pageSize) {

        List<Booking> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(BASE_SELECT);

        sql.append("""
            WHERE b.group_booking_id IS NULL
        """);

        List<Object> params = new ArrayList<>();

        // Filter status
        if ("Confirmed".equals(status)
                || "CheckedIn".equals(status)
                || "CheckedOut".equals(status)) {

            sql.append(" AND b.status = ? ");
            params.add(status);

        } else {

            sql.append("""
                AND b.status IN ('Confirmed','CheckedIn','CheckedOut')
            """);
        }

        // Search
        if (keyword != null && !keyword.trim().isEmpty()) {

            sql.append("""
                AND (
                    b.customer_name LIKE ?
                    OR CAST(b.booking_id AS NVARCHAR) LIKE ?
                )
            """);

            String kw = "%" + sanitizeLikeKeyword(keyword.trim()) + "%";

            params.add(kw);
            params.add(kw);
        }

        sql.append("""
            ORDER BY
                CASE
                    WHEN b.status='Confirmed' THEN 1
                    WHEN b.status='CheckedIn' THEN 2
                    WHEN b.status='CheckedOut' THEN 3
                END,
                b.booking_id DESC
            OFFSET ? ROWS
            FETCH NEXT ? ROWS ONLY
        """);

        params.add(offset);
        params.add(pageSize);

        try (Connection conn = DBContext.getConnection()) {

            useDatabase(conn);

            PreparedStatement ps = conn.prepareStatement(sql.toString());

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getCheckInBookings", e);
        }

        return list;
    }

    public int countCheckInBookings(
            String status,
            String keyword) {

        StringBuilder sql = new StringBuilder("""
        SELECT COUNT(*)
        FROM dbo.Booking b
        WHERE b.group_booking_id IS NULL
    """);

        List<Object> params = new ArrayList<>();

        if ("Confirmed".equals(status)
                || "CheckedIn".equals(status)
                || "CheckedOut".equals(status)) {

            sql.append(" AND b.status = ? ");
            params.add(status);

        } else {

            sql.append("""
            AND b.status IN ('Confirmed','CheckedIn','CheckedOut')
        """);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {

            sql.append("""
            AND (
                b.customer_name LIKE ?
                OR CAST(b.booking_id AS NVARCHAR) LIKE ?
            )
        """);

            String kw = "%" + sanitizeLikeKeyword(keyword.trim()) + "%";

            params.add(kw);
            params.add(kw);
        }

        try (Connection conn = DBContext.getConnection()) {

            useDatabase(conn);

            PreparedStatement ps = conn.prepareStatement(sql.toString());

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error countCheckInBookings", e);
        }

        return 0;
    }

    public boolean updateStatus(int bookingId, String status) {

        String sql = "UPDATE dbo.Booking SET status = ? WHERE booking_id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, bookingId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<Room> getAllAssignedRoomsForGroup(int bookingId) {

        List<Room> list = new ArrayList<>();

        String sql = """
                    SELECT
                        r.room_id,
                        r.room_number,
                        r.status,
                        r.floor,
                        rt.type_name
                    FROM RoomAssignment ra
                    JOIN Room r
                        ON ra.room_id = r.room_id
                    JOIN RoomType rt
                        ON r.type_id = rt.type_id
                    WHERE ra.booking_id = ?
                       OR ra.booking_id IN (
                            SELECT booking_id
                            FROM Booking
                            WHERE group_booking_id = ?
                       )
                    ORDER BY r.room_number
                """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            useDatabase(conn);

            ps.setInt(1, bookingId);
            ps.setInt(2, bookingId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Room r = new Room();

                r.setRoomId(rs.getInt("room_id"));
                r.setRoomNumber(rs.getString("room_number"));
                r.setStatus(rs.getString("status"));
                r.setFloor(rs.getString("floor"));
                r.setTypeName(rs.getString("type_name"));

                list.add(r);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE,
                    "Error getAllAssignedRoomsForGroup", e);
        }

        return list;
    }

    public int countBookings(String status, String keyword) {

        int total = 0;

        StringBuilder sql = new StringBuilder("""
                    SELECT COUNT(*)
                    FROM Booking b
                    WHERE b.group_booking_id IS NULL
                """);

        if (!"All".equalsIgnoreCase(status)) {
            sql.append(" AND b.status = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("""
                        AND (
                            b.customer_name LIKE ?
                            OR CAST(b.booking_id AS VARCHAR(20)) LIKE ?
                        )
                    """);
        }

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int index = 1;

            if (!"All".equalsIgnoreCase(status)) {
                ps.setString(index++, status);
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                String k = "%" + keyword.trim() + "%";
                ps.setString(index++, k);
                ps.setString(index++, k);
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return total;
    }

    public List<Booking> getBookingsPaging(
            String status,
            String keyword,
            int offset,
            int pageSize) {

        List<Booking> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(BASE_SELECT);

        sql.append(" WHERE b.group_booking_id IS NULL ");

        if (!"All".equalsIgnoreCase(status)) {
            sql.append(" AND b.status = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("""
                        AND (
                            b.customer_name LIKE ?
                            OR CAST(b.booking_id AS VARCHAR(20)) LIKE ?
                        )
                    """);
        }

        sql.append("""
                    ORDER BY b.created_at DESC
                    OFFSET ? ROWS
                    FETCH NEXT ? ROWS ONLY
                """);

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int index = 1;

            if (!"All".equalsIgnoreCase(status)) {
                ps.setString(index++, status);
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                String k = "%" + keyword.trim() + "%";
                ps.setString(index++, k);
                ps.setString(index++, k);
            }

            ps.setInt(index++, offset);
            ps.setInt(index, pageSize);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public boolean updateGroupBookingStatus(int rootBookingId, String status) {

    String sql = """
        UPDATE Booking
        SET status = ?
        WHERE booking_id = ?
           OR group_booking_id = ?
        """;

    try (
            Connection conn = DBContext.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, status);
        ps.setInt(2, rootBookingId);
        ps.setInt(3, rootBookingId);

        return ps.executeUpdate() > 0;

    } catch (Exception e) {
        e.printStackTrace();
    }

    return false;
}
}
