package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomInfo;
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

    private static void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /**
     * Điều kiện dùng chung cho các subquery gộp theo nhóm đặt phòng trong
     * {@link #BASE_SELECT}: khớp mọi dòng thuộc cùng nhóm (chính nó hoặc có
     * group_booking_id trỏ về nó), trừ những dòng con đã bị khách bỏ khỏi đơn
     * nhiều phòng (Cancelled) trong khi đơn cha vẫn còn hiệu lực — dòng đó vẫn
     * nằm lại trong nhóm để tra soát nhưng không tính vào tổng số phòng/tổng
     * tiền nữa. Khi cả đơn đã bị huỷ thì mọi dòng đều Cancelled và vẫn hiển
     * thị đầy đủ như trước.
     */
    private static final String GROUP_SCOPE =
            "(sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id) "
            + "AND (sb.status <> N'Cancelled' OR b.status = N'Cancelled')";

    private static final String BASE_SELECT = """
            SELECT b.booking_id, b.account_id, b.customer_name, b.phone, b.email,
                   b.room_type_id, ISNULL(rt.type_name, N'Loại phòng cũ') AS room_type_name,
                   b.room_quantity, b.check_in_date, b.check_out_date,
                   b.total_amount, b.status, b.note, b.group_booking_id, b.promotion_id,
                   CAST(b.created_at AS DATE) AS created_at,
                   (SELECT STRING_AGG(r.room_number, ', ')
                    FROM dbo.RoomAssignment br
                    JOIN dbo.Room r ON br.room_id = r.room_id
                    WHERE br.booking_id IN (
                        SELECT sb.booking_id FROM dbo.Booking sb
                        WHERE sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id
                    )) AS assigned_rooms,
                   (SELECT SUM(sb.room_quantity) FROM dbo.Booking sb WHERE %1$s) AS total_room_quantity,
                   (SELECT STRING_AGG(type_name, ', ') FROM (
                        SELECT DISTINCT srt.type_name FROM dbo.Booking sb
                        JOIN dbo.RoomType srt ON sb.room_type_id = srt.type_id
                        WHERE %1$s
                    ) AS dt) AS group_room_type_names,
                   (SELECT COUNT(DISTINCT sb.room_type_id) FROM dbo.Booking sb WHERE %1$s) AS total_room_types,
                   (SELECT SUM(sb.total_amount) FROM dbo.Booking sb WHERE %1$s) AS overall_total_amount
            FROM dbo.Booking b
            LEFT JOIN dbo.RoomType rt ON b.room_type_id = rt.type_id
            """.formatted(GROUP_SCOPE);

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

        // Filter by keyword (tên khách, mã đặt phòng hoặc số phòng đã gán)
        if (keyword != null && !keyword.trim().isEmpty()) {
            String sanitizedKw = sanitizeLikeKeyword(keyword.trim());
            String kw = "%" + sanitizedKw + "%";
            sql.append("AND (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ? "
                    + "OR EXISTS ("
                    + "    SELECT 1 FROM dbo.RoomAssignment ra "
                    + "    JOIN dbo.Room r2 ON ra.room_id = r2.room_id "
                    + "    JOIN dbo.Booking sb2 ON ra.booking_id = sb2.booking_id "
                    + "    WHERE (sb2.booking_id = b.booking_id OR sb2.group_booking_id = b.booking_id) "
                    + "      AND r2.room_number LIKE ?"
                    + ")) ");
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

    /**
     * Toàn bộ lịch sử đặt phòng của một phòng cụ thể (qua RoomAssignment), ưu
     * tiên các đơn Confirmed/CheckedIn lên đầu, còn lại xếp theo ngày check-in.
     * Dùng cho trang chi tiết phòng ở sơ đồ phòng của lễ tân.
     */
    public List<Booking> getBookingHistoryByRoomId(int roomId) {
        List<Booking> list = new ArrayList<>();

        String sql = BASE_SELECT
                + "JOIN dbo.RoomAssignment ra ON ra.booking_id = b.booking_id "
                + "WHERE ra.room_id = ? "
                + "ORDER BY CASE WHEN b.status IN (N'Confirmed', N'CheckedIn') THEN 0 ELSE 1 END, "
                + "         b.check_in_date ASC";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, roomId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getBookingHistoryByRoomId: roomId=" + roomId, e);
        }

        return list;
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

    /**
     * Gắn (hoặc gỡ, nếu promotionId null) mã khuyến mãi cho một booking (cha).
     * Đây là method duy nhất được phép thay đổi cột promotion_id — các UPDATE
     * khác (updateBookingDetails, applyBookingChange...) không đụng tới cột
     * này, nhờ vậy promotion_id luôn được giữ nguyên khi sửa ngày/loại phòng.
     */
    public boolean updateBookingPromotion(int bookingId, Integer promotionId) {
        if (bookingId <= 0) {
            return false;
        }
        String sql = "UPDATE dbo.Booking SET promotion_id = ?, updated_at = SYSDATETIME() WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (promotionId != null) {
                    ps.setInt(1, promotionId);
                } else {
                    ps.setNull(1, Types.INTEGER);
                }
                ps.setInt(2, bookingId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in updateBookingPromotion for id: " + bookingId, e);
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
        int promotionId = rs.getInt("promotion_id");
        if (!rs.wasNull()) {
            b.setPromotionId(promotionId);
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

    /**
     * Các dòng con của một đơn nhiều loại phòng. Dòng con đã bị khách bỏ khỏi
     * đơn (Cancelled trong khi đơn cha vẫn còn hiệu lực) được lọc ra, để màn
     * hình xếp phòng / nhận phòng không hiển thị và không xếp phòng cho một
     * loại phòng khách đã bỏ. Khi cả đơn bị huỷ thì vẫn trả về đầy đủ.
     */
    public List<Booking> getChildBookings(int parentBookingId) {
        List<Booking> list = new ArrayList<>();
        String sql = BASE_SELECT
                + "WHERE b.group_booking_id = ? "
                + "  AND (b.status <> N'Cancelled' "
                + "       OR EXISTS (SELECT 1 FROM dbo.Booking p "
                + "                  WHERE p.booking_id = ? AND p.status = N'Cancelled'))";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, parentBookingId);
                ps.setInt(2, parentBookingId);
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

    public String getAssignedRoomsForBookingSelf(int bookingId) {
        String sql = "SELECT STRING_AGG(r.room_number, ', ') "
                   + "FROM dbo.RoomAssignment br "
                   + "JOIN dbo.Room r ON br.room_id = r.room_id "
                   + "WHERE br.booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting assigned rooms for self: " + bookingId, e);
        }
        return null;
    }

    public BookingDAO() {
        ensureRoomAssignmentTableExists();
        ensureChangeTrackingColumns();
    }

    /**
     * Chỉ chạy DDL kiểm tra cột một lần cho mỗi lần nạp classloader —
     * {@code BookingDAO} được {@code new()} ở hàng chục nơi nên không thể để
     * lệnh ALTER chạy theo từng instance.
     */
    private static final java.util.concurrent.atomic.AtomicBoolean CHANGE_COLUMNS_ENSURED =
            new java.util.concurrent.atomic.AtomicBoolean(false);

    /**
     * Tạo ba cột truy vết "đơn cũ ↔ đơn thay thế" nếu CSDL đang chạy chưa có.
     * Đây chỉ là lưới an toàn cho máy dev — bản triển khai thật phải chạy
     * {@code sql/hotel_management.sql} trước, vì {@code DashboardDAO} và
     * {@code PaymentDAO} tham chiếu thẳng các cột này trong mệnh đề WHERE.
     */
    public static void ensureChangeTrackingColumns() {
        if (!CHANGE_COLUMNS_ENSURED.compareAndSet(false, true)) {
            return;
        }
        // EXEC(N'...') là bắt buộc: trong MỘT batch JDBC (không có GO), câu
        // ALTER ... ADD được biên dịch cùng lúc với các câu sau nó, nên mọi
        // tham chiếu tới cột vừa thêm sẽ báo "Invalid column name".
        String sql = "IF COL_LENGTH(N'dbo.Booking', N'replaces_booking_id') IS NULL "
                + "  EXEC(N'ALTER TABLE dbo.Booking ADD replaces_booking_id INT NULL'); "
                + "IF COL_LENGTH(N'dbo.Booking', N'replaced_by_booking_id') IS NULL "
                + "  EXEC(N'ALTER TABLE dbo.Booking ADD replaced_by_booking_id INT NULL'); "
                + "IF COL_LENGTH(N'dbo.BookingChangeRequest', N'new_booking_id') IS NULL "
                + "  EXEC(N'ALTER TABLE dbo.BookingChangeRequest ADD new_booking_id INT NULL');";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(sql);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error ensuring booking change-tracking columns", e);
        }
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

    /**
     * Danh sách phòng kèm display_status (Occupied/Maintenance/OutOfService/
     * Available) theo khoảng ngày, dùng chung cho {@link #getRoomsByTypeId}
     * và {@link #getAllRooms} — hai method này chỉ khác nhau ở việc có lọc
     * theo loại phòng hay không.
     */
    private List<RoomInfo> queryRoomsWithDisplayStatus(Date checkIn, Date checkOut, Integer typeId) {
        List<RoomInfo> list = new ArrayList<>();
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
                        ) THEN 'Occupied'
                        WHEN r.status='Maintenance' THEN 'Maintenance'
                        WHEN r.status='OutOfService' THEN 'OutOfService'
                        ELSE 'Available'
                    END AS display_status,
                    r.floor,
                    rt.type_name
                FROM Room r
                JOIN RoomType rt ON rt.type_id=r.type_id
                WHERE r.is_deleted = 0
                """
                + (typeId != null ? "AND r.type_id = ? " : "")
                + "ORDER BY r.floor, r.room_number";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, checkOut);
                ps.setDate(2, checkIn);
                if (typeId != null) {
                    ps.setInt(3, typeId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        RoomInfo r = new RoomInfo();
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
            LOGGER.log(Level.SEVERE, "Error in queryRoomsWithDisplayStatus: typeId=" + typeId, e);
        }
        return list;
    }

    public List<RoomInfo> getRoomsByTypeId(int typeId, Date checkIn, Date checkOut) {
        return queryRoomsWithDisplayStatus(checkIn, checkOut, typeId);
    }

    public List<RoomInfo> getAllRooms(Date checkIn, Date checkOut) {
        return queryRoomsWithDisplayStatus(checkIn, checkOut, null);
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

    /** Id các phòng vật lý đang được xếp cho một dòng booking. */
    public List<Integer> getAssignedRoomIds(int bookingId) {
        List<Integer> list = new ArrayList<>();
        if (bookingId <= 0) {
            return list;
        }
        String sql = "SELECT room_id FROM dbo.RoomAssignment WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(rs.getInt("room_id"));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getAssignedRoomIds: bookingId=" + bookingId, e);
        }
        return list;
    }

    /**
     * Áp một thay đổi lên TOÀN BỘ nhóm đặt phòng trong một transaction duy nhất:
     * sửa các dòng hiện có, thêm dòng cho loại phòng mới, huỷ dòng khách đã bỏ,
     * gỡ xếp phòng của những dòng không còn phù hợp, và (nếu có) chuyển yêu cầu
     * sang Approved.
     * <p>
     * Gộp vào một transaction là bắt buộc: nếu chỉ dòng cha được ghi mà dòng con
     * thì không, đơn sẽ có hai khoảng ngày khác nhau; còn nếu đơn đã đổi mà
     * trạng thái yêu cầu chưa chuyển thì lễ tân duyệt lại lần nữa là đơn bị đổi
     * chồng lên.
     *
     * @param requestIdToApprove id yêu cầu cần chuyển sang Approved, hoặc 0 nếu
     *        không gắn với yêu cầu nào (lễ tân sửa trực tiếp). Nếu yêu cầu đã
     *        được xử lý bởi người khác, toàn bộ transaction bị huỷ bỏ.
     * @return true nếu đã commit thành công
     */
    public boolean applyGroupChange(List<Booking> updates, List<Booking> inserts,
            List<Integer> cancelIds, List<Integer> clearAssignmentIds, int requestIdToApprove) {

        String updateSql = "UPDATE dbo.Booking "
                + "SET room_type_id = ?, room_quantity = ?, check_in_date = ?, check_out_date = ?, "
                + "    total_amount = ?, updated_at = SYSDATETIME() "
                + "WHERE booking_id = ?";
        String insertSql = "INSERT INTO dbo.Booking (account_id, customer_name, phone, email, room_type_id, "
                + "room_quantity, check_in_date, check_out_date, total_amount, status, note, group_booking_id, "
                + "created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
        String cancelSql = "UPDATE dbo.Booking "
                + "SET status = N'Cancelled', total_amount = 0, "
                + "    note = ISNULL(note, '') + CHAR(13) + CHAR(10) + ?, updated_at = SYSDATETIME() "
                + "WHERE booking_id = ?";
        String clearAssignmentSql = "DELETE FROM dbo.RoomAssignment WHERE booking_id = ?";
        String approveSql = "UPDATE dbo.BookingChangeRequest SET status = N'Approved' "
                + "WHERE request_id = ? AND status = N'Pending'";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            useDatabase(conn);
            conn.setAutoCommit(false);

            if (updates != null && !updates.isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    for (Booking b : updates) {
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
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            if (inserts != null && !inserts.isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    for (Booking b : inserts) {
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
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            if (cancelIds != null && !cancelIds.isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(cancelSql)) {
                    for (Integer id : cancelIds) {
                        ps.setString(1, "Đã bỏ khỏi đơn theo yêu cầu thay đổi của khách.");
                        ps.setInt(2, id);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            if (clearAssignmentIds != null && !clearAssignmentIds.isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(clearAssignmentSql)) {
                    for (Integer id : clearAssignmentIds) {
                        ps.setInt(1, id);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            if (requestIdToApprove > 0) {
                try (PreparedStatement ps = conn.prepareStatement(approveSql)) {
                    ps.setInt(1, requestIdToApprove);
                    if (ps.executeUpdate() != 1) {
                        // Yêu cầu vừa bị người khác duyệt/từ chối -> không áp thay đổi
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in applyGroupChange", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Error rolling back applyGroupChange", ex);
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                    // Connection sắp trả về pool
                }
                try {
                    conn.close();
                } catch (SQLException ignored) {
                    // idem
                }
            }
        }
        return false;
    }

    /** Kết quả {@link #applyChangeAsNewBooking}: hoá đơn đang trong quy trình hoàn tiền. */
    public static final int CHANGE_ERR_INVOICE_LOCKED = -2;

    /**
     * Duyệt một yêu cầu thay đổi theo mô hình <b>đơn thay thế</b>: tạo một nhóm
     * Booking mới mang cấu hình khách yêu cầu (luôn ở trạng thái Pending),
     * chuyển tiền cọc và hoá đơn sang đơn mới, rồi huỷ nhóm cũ — tất cả trong
     * MỘT transaction.
     * <p>
     * Thứ tự các câu lệnh dưới đây là bắt buộc, không đảo được:
     * <ul>
     *   <li>Chuyển trạng thái yêu cầu <b>trước tiên</b>: câu UPDATE đó giữ khoá
     *       trên dòng yêu cầu tới hết transaction nên hai lễ tân bấm duyệt cùng
     *       lúc chỉ một người thắng; đồng thời fail sớm thì không đốt số
     *       IDENTITY của bảng Booking.</li>
     *   <li>Gỡ {@code promotion_id} khỏi nhóm cũ <b>trước khi</b> chèn dòng cha
     *       mới: {@code UX_Booking_Promotion} là filtered unique index trên
     *       {@code Booking(promotion_id)}, mà đơn cũ dù đã Cancelled vẫn giữ mã
     *       — chèn trước sẽ vi phạm ràng buộc và rollback cả transaction.</li>
     *   <li>Chuyển {@code Payment} và {@code Invoice} <b>cùng nhau</b>:
     *       {@code InvoiceDAO.DEPOSIT_EXPR} khớp hai bảng qua {@code booking_id},
     *       nên chuyển một bên thôi là tiền cọc trên hoá đơn sai.</li>
     * </ul>
     *
     * @param newRoot dòng cha mới (chưa có id, status đã là Pending)
     * @param newChildren các dòng con mới (chưa có id)
     * @param promotionId mã khuyến mãi đang gắn trên đơn cũ, null nếu không có
     * @param requestIdToApprove yêu cầu cần chuyển sang Approved, 0 nếu không có
     * @return booking_id của dòng cha mới, {@link #CHANGE_ERR_INVOICE_LOCKED}
     *         nếu hoá đơn đang hoàn tiền, hoặc -1 nếu thất bại (đã rollback)
     */
    public int applyChangeAsNewBooking(Booking newRoot, List<Booking> newChildren,
            int oldRootBookingId, Integer promotionId, int requestIdToApprove, String cancelNote) {

        if (newRoot == null || oldRootBookingId <= 0) {
            return -1;
        }

        String approveSql = "UPDATE dbo.BookingChangeRequest SET status = N'Approved' "
                + "WHERE request_id = ? AND status = N'Pending'";
        String invoiceGuardSql = "SELECT invoice_id, status FROM dbo.Invoice WHERE booking_id = ?";
        String serviceGuardSql = "SELECT TOP 1 1 FROM dbo.BookingServiceRequest sr "
                + "JOIN dbo.Booking b ON sr.booking_id = b.booking_id "
                + "WHERE b.booking_id = ? OR b.group_booking_id = ?";
        String clearPromotionSql = "UPDATE dbo.Booking SET promotion_id = NULL, updated_at = SYSDATETIME() "
                + "WHERE (booking_id = ? OR group_booking_id = ?) AND promotion_id IS NOT NULL";
        String cancelOldSql = "UPDATE dbo.Booking "
                + "SET status = N'Cancelled', "
                + "    note = LEFT(ISNULL(note, '') + CHAR(13) + CHAR(10) + ?, 500), "
                + "    updated_at = SYSDATETIME() "
                + "WHERE (booking_id = ? OR group_booking_id = ?) "
                + "  AND status NOT IN (N'CheckedIn', N'CheckedOut')";
        String clearAssignmentSql = "DELETE ra FROM dbo.RoomAssignment ra "
                + "JOIN dbo.Booking b ON ra.booking_id = b.booking_id "
                + "WHERE b.booking_id = ? OR b.group_booking_id = ?";
        String insertSql = "INSERT INTO dbo.Booking (account_id, customer_name, phone, email, room_type_id, "
                + "room_quantity, promotion_id, check_in_date, check_out_date, total_amount, status, note, "
                + "group_booking_id, replaces_booking_id, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
        String markReplacedSql = "UPDATE dbo.Booking SET replaced_by_booking_id = ?, updated_at = SYSDATETIME() "
                + "WHERE booking_id = ? OR group_booking_id = ?";
        String moveDepositSql = "UPDATE dbo.Payment SET booking_id = ? "
                + "WHERE booking_id IN (SELECT booking_id FROM dbo.Booking "
                + "                     WHERE booking_id = ? OR group_booking_id = ?) "
                + "  AND invoice_id IS NULL";
        String moveInvoiceSql = "UPDATE dbo.Invoice SET booking_id = ?, updated_at = SYSDATETIME() "
                + "WHERE invoice_id = ?";
        String linkRequestSql = "UPDATE dbo.BookingChangeRequest SET new_booking_id = ? WHERE request_id = ?";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            useDatabase(conn);
            conn.setAutoCommit(false);

            // 1. Chiếm quyền xử lý yêu cầu trước khi đụng tới dữ liệu đặt phòng
            if (requestIdToApprove > 0) {
                try (PreparedStatement ps = conn.prepareStatement(approveSql)) {
                    ps.setInt(1, requestIdToApprove);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return -1;
                    }
                }
            }

            // 2. Hoá đơn đang hoàn tiền thì không được tự động dời tiền cọc:
            //    làm vậy sẽ biến một hoá đơn đã đóng thành hoá đơn thiếu tiền.
            Integer invoiceId = null;
            try (PreparedStatement ps = conn.prepareStatement(invoiceGuardSql)) {
                ps.setInt(1, oldRootBookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String invoiceStatus = rs.getString("status");
                        if ("Refunding".equalsIgnoreCase(invoiceStatus)
                                || "Refunded".equalsIgnoreCase(invoiceStatus)
                                || "Cancelled".equalsIgnoreCase(invoiceStatus)) {
                            conn.rollback();
                            return CHANGE_ERR_INVOICE_LOCKED;
                        }
                        invoiceId = rs.getInt("invoice_id");
                    }
                }
            }

            // 3. Chốt chặn phòng xa: yêu cầu dịch vụ chỉ tạo được khi đã nhận
            //    phòng, mà luồng này chỉ chạy với đơn Pending/Confirmed — nếu có
            //    thì luồng nghiệp vụ đã đổi và huỷ đơn cũ sẽ làm mất dữ liệu.
            try (PreparedStatement ps = conn.prepareStatement(serviceGuardSql)) {
                ps.setInt(1, oldRootBookingId);
                ps.setInt(2, oldRootBookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        LOGGER.log(Level.SEVERE, "Booking {0} still has service requests; "
                                + "refusing to replace it", oldRootBookingId);
                        conn.rollback();
                        return -1;
                    }
                }
            }

            // 4. Gỡ khuyến mãi khỏi nhóm cũ (bắt buộc trước bước 7)
            try (PreparedStatement ps = conn.prepareStatement(clearPromotionSql)) {
                ps.setInt(1, oldRootBookingId);
                ps.setInt(2, oldRootBookingId);
                ps.executeUpdate();
            }

            // 5. Huỷ nhóm cũ. Cố tình KHÔNG xoá total_amount: đơn cũ vẫn phải
            //    tra soát được, và doanh thu đã loại trạng thái Cancelled.
            try (PreparedStatement ps = conn.prepareStatement(cancelOldSql)) {
                ps.setString(1, cancelNote != null ? cancelNote : "Đã thay bằng đơn mới.");
                ps.setInt(2, oldRootBookingId);
                ps.setInt(3, oldRootBookingId);
                if (ps.executeUpdate() < 1) {
                    // Không huỷ được dòng nào: đơn vừa được nhận phòng/trả phòng
                    // ngay giữa lúc lễ tân bấm duyệt. Tạo tiếp đơn mới sẽ thành
                    // hai đơn cùng tồn tại cho một lần lưu trú.
                    LOGGER.log(Level.WARNING, "Booking {0} is no longer cancellable; "
                            + "aborting replacement", oldRootBookingId);
                    conn.rollback();
                    return -1;
                }
            }

            // 6. Trả phòng đã xếp về kho (cancelBooking không làm việc này)
            try (PreparedStatement ps = conn.prepareStatement(clearAssignmentSql)) {
                ps.setInt(1, oldRootBookingId);
                ps.setInt(2, oldRootBookingId);
                ps.executeUpdate();
            }

            // 7. Dòng cha mới — nơi duy nhất giữ khuyến mãi của nhóm
            int newRootId;
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                bindNewBookingRow(ps, newRoot, null, promotionId, oldRootBookingId);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return -1;
                    }
                    newRootId = rs.getInt(1);
                }
            }

            // 8. Các dòng con mới
            if (newChildren != null && !newChildren.isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    for (Booking child : newChildren) {
                        bindNewBookingRow(ps, child, newRootId, null, oldRootBookingId);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            // 9. Nối nhóm cũ sang nhóm mới (đánh dấu mọi dòng, kể cả dòng con,
            //    vì KPI của Dashboard đếm cả dòng con)
            try (PreparedStatement ps = conn.prepareStatement(markReplacedSql)) {
                ps.setInt(1, newRootId);
                ps.setInt(2, oldRootBookingId);
                ps.setInt(3, oldRootBookingId);
                ps.executeUpdate();
            }

            // 10. Chuyển tiền cọc. invoice_id IS NULL chính là định nghĩa "giao
            //     dịch cọc" mà DEPOSIT_EXPR và sumPaidForBooking đang dùng;
            //     giao dịch có invoice_id là trả hoá đơn, đi theo Invoice.
            try (PreparedStatement ps = conn.prepareStatement(moveDepositSql)) {
                ps.setInt(1, newRootId);
                ps.setInt(2, oldRootBookingId);
                ps.setInt(3, oldRootBookingId);
                ps.executeUpdate();
            }

            // 11. Chuyển hoá đơn + dựng lại các dòng tiền phòng theo đơn MỚI.
            //     Hoá đơn có MỘT DÒNG CHO MỖI PHÒNG, và đơn mới có thể khác số phòng
            //     so với đơn cũ, nên phải dựng lại cả bộ chứ không UPDATE tại chỗ —
            //     một câu UPDATE ... WHERE item_type = N'Room' sẽ gán trọn tổng tiền
            //     cho TỪNG dòng, tức nhân tiền phòng lên đúng bằng số phòng.
            if (invoiceId != null) {
                try (PreparedStatement ps = conn.prepareStatement(moveInvoiceSql)) {
                    ps.setInt(1, newRootId);
                    ps.setInt(2, invoiceId);
                    ps.executeUpdate();
                }
                new InvoiceDAO().rebuildRoomItems(conn, invoiceId, newRootId);
            }

            // 12. Truy vết cho màn hình lễ tân và khách
            if (requestIdToApprove > 0) {
                try (PreparedStatement ps = conn.prepareStatement(linkRequestSql)) {
                    ps.setInt(1, newRootId);
                    ps.setInt(2, requestIdToApprove);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return newRootId;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in applyChangeAsNewBooking for booking " + oldRootBookingId, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Error rolling back applyChangeAsNewBooking", ex);
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                    // Connection sắp trả về pool
                }
                try {
                    conn.close();
                } catch (SQLException ignored) {
                    // idem
                }
            }
        }
        return -1;
    }

    /** Nạp tham số cho câu INSERT dòng Booking của nhóm thay thế. */
    private void bindNewBookingRow(PreparedStatement ps, Booking b, Integer groupBookingId,
            Integer promotionId, int replacesBookingId) throws SQLException {
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
        if (promotionId != null) {
            ps.setInt(7, promotionId);
        } else {
            ps.setNull(7, Types.INTEGER);
        }
        ps.setDate(8, b.getCheckInDate());
        ps.setDate(9, b.getCheckOutDate());
        ps.setDouble(10, b.getTotalAmount());
        ps.setString(11, b.getStatus() != null ? b.getStatus() : "Pending");
        ps.setString(12, b.getNote() != null ? b.getNote().trim() : "");
        if (groupBookingId != null) {
            ps.setInt(13, groupBookingId);
        } else {
            ps.setNull(13, Types.INTEGER);
        }
        ps.setInt(14, replacesBookingId);
    }

    public List<RoomInfo> getAssignedRoomsForBooking(int bookingId, Date checkIn, Date checkOut) {
        List<RoomInfo> list = new ArrayList<>();
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
                        RoomInfo r = new RoomInfo();
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
     * theo ngày cao điểm.
     * <p>
     * {@code excludeBookingIds} (nullable) là tập các dòng Booking <b>sẽ bị ghi
     * đè</b> bởi thay đổi đang xét — thường là toàn bộ dòng của một nhóm đặt
     * phòng — nên không được tính là đang chiếm phòng. Lưu ý bắt buộc: đã loại
     * cả nhóm khỏi phép đếm thì phải so sánh với <b>tổng nhu cầu của cả nhóm</b>
     * theo từng loại phòng, chứ không so theo từng dòng. So theo từng dòng sẽ
     * bỏ sót phần phòng mà các dòng còn lại trong nhóm vẫn đang giữ và dẫn tới
     * nhận quá số phòng thực có.
     */
    public int checkRoomAvailability(int roomTypeId, Date checkIn, Date checkOut,
            java.util.Collection<Integer> excludeBookingIds) {
        int totalRooms = 0;
        String countSql = "SELECT COUNT(*) FROM dbo.Room r JOIN dbo.RoomType rt ON r.type_id = rt.type_id WHERE r.type_id = ? AND r.status NOT IN (N'Maintenance', N'OutOfService') AND ISNULL(rt.is_active, 1) = 1";
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

        List<Integer> excluded = new ArrayList<>();
        if (excludeBookingIds != null) {
            for (Integer id : excludeBookingIds) {
                if (id != null && id > 0) {
                    excluded.add(id);
                }
            }
        }

        StringBuilder excludeClause = new StringBuilder();
        if (!excluded.isEmpty()) {
            excludeClause.append(" AND booking_id NOT IN (");
            for (int i = 0; i < excluded.size(); i++) {
                excludeClause.append(i == 0 ? "?" : ",?");
            }
            excludeClause.append(")");
        }

        String overlapSql = "SELECT check_in_date, check_out_date, room_quantity FROM dbo.Booking "
                + "WHERE room_type_id = ? AND status IN (N'Pending', N'Confirmed', N'CheckedIn') "
                + "AND check_in_date < ? AND check_out_date > ?"
                + excludeClause;

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(overlapSql)) {
                ps.setInt(1, roomTypeId);
                ps.setDate(2, checkOut);
                ps.setDate(3, checkIn);
                for (int i = 0; i < excluded.size(); i++) {
                    ps.setInt(4 + i, excluded.get(i));
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

    /**
     * Điều kiện lọc status/keyword dùng chung cho {@link #getCheckInBookings}
     * và {@link #countCheckInBookings} — phải khớp nhau tuyệt đối để phân
     * trang không bị lệch với tổng số bản ghi.
     */
    private void appendCheckInStatusKeywordFilter(StringBuilder sql, List<Object> params, String status,
            String keyword) {
        if ("Confirmed".equals(status) || "CheckedIn".equals(status) || "CheckedOut".equals(status)) {
            sql.append(" AND b.status = ? ");
            params.add(status);
        } else {
            sql.append(" AND b.status IN ('Confirmed','CheckedIn','CheckedOut') ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ?) ");
            String kw = "%" + sanitizeLikeKeyword(keyword.trim()) + "%";
            params.add(kw);
            params.add(kw);
        }
    }

    public List<Booking> getCheckInBookings(
            String status,
            String keyword,
            int offset,
            int pageSize) {

        List<Booking> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(BASE_SELECT);

        sql.append("WHERE b.group_booking_id IS NULL ");

        List<Object> params = new ArrayList<>();
        appendCheckInStatusKeywordFilter(sql, params, status, keyword);

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

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM dbo.Booking b WHERE b.group_booking_id IS NULL ");

        List<Object> params = new ArrayList<>();
        appendCheckInStatusKeywordFilter(sql, params, status, keyword);

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

    public List<RoomInfo> getAllAssignedRoomsForGroup(int bookingId) {

        List<RoomInfo> list = new ArrayList<>();

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

                RoomInfo r = new RoomInfo();

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

    /**
     * Điều kiện lọc status/keyword dùng chung cho {@link #countBookings} và
     * {@link #getBookingsPaging} — hai method này luôn phải lọc giống hệt
     * nhau, nếu không tổng số trang và dữ liệu hiển thị sẽ lệch nhau.
     */
    private void appendStatusKeywordFilter(StringBuilder sql, List<Object> params, String status, String keyword) {
        if (!"All".equalsIgnoreCase(status)) {
            sql.append(" AND b.status = ? ");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (b.customer_name LIKE ? OR CAST(b.booking_id AS VARCHAR(20)) LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
    }

    public int countBookings(String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM dbo.Booking b WHERE b.group_booking_id IS NULL ");
        List<Object> params = new ArrayList<>();
        appendStatusKeywordFilter(sql, params, status, keyword);

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Booking> getBookingsPaging(String status, String keyword, int offset, int pageSize) {
        List<Booking> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append("WHERE b.group_booking_id IS NULL ");
        List<Object> params = new ArrayList<>();
        appendStatusKeywordFilter(sql, params, status, keyword);
        sql.append("ORDER BY b.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
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
