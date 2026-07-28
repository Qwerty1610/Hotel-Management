package com.mycompany.hotelmanagement.dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.RoomInfo;

/**
 * Project: Hotel Management System
 * Class: RoomDAO
 *
 * Description:
 * Tầng truy cập dữ liệu cho bảng Room. Cung cấp các phương thức lấy toàn
 * bộ danh sách phòng kèm thông tin loại phòng, kiểm tra trùng số phòng,
 * lấy phòng bị xóa mềm theo số phòng, thêm mới, cập nhật, xóa (mềm),
 * khôi phục phòng và cập nhật trạng thái phòng.
 *
 * Related Use Cases:
 * - UC-03 Search Available Rooms
 * - UC-56 View Room List
 * - UC-57 Add Room
 * - UC-58 Edit Room
 *
 * Date: 01-06-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class RoomDAO {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    private static final java.util.logging.Logger LOGGER = java.util.logging.Logger.getLogger(RoomDAO.class.getName());

    public List<RoomInfo> getAllRooms() {
        return getRoomsByDate(new java.sql.Date(System.currentTimeMillis()));
    }

    public List<RoomInfo> getRoomsByDateRange(java.sql.Date fromDate, java.sql.Date toDate) {
        List<RoomInfo> list = new ArrayList<>();
        String sql = """
            SELECT 
                r.room_id,
                r.room_number,
                r.type_id,
                r.status AS operational_status,
                r.floor,
                rt.type_name,
                rt.base_price,
                rt.bed_type,
                rt.area,
                CASE 
                    WHEN r.status IN ('OutOfService', 'Maintenance') THEN r.status
                    WHEN EXISTS (
                        SELECT 1 
                        FROM RoomAssignment ra
                        JOIN Booking b ON ra.booking_id = b.booking_id
                        WHERE ra.room_id = r.room_id
                          AND b.status = 'CheckedIn'
                          AND b.check_in_date < ?
                          AND b.check_out_date > ?
                    ) THEN 'Occupied'
                    WHEN EXISTS (
                        SELECT 1 
                        FROM RoomAssignment ra
                        JOIN Booking b ON ra.booking_id = b.booking_id
                        WHERE ra.room_id = r.room_id
                          AND b.status = 'Confirmed'
                          AND b.check_in_date < ?
                          AND b.check_out_date > ?
                    ) THEN 'Confirmed'
                    WHEN r.status IN ('Cleaning', 'Refilling') THEN r.status
                    ELSE 'Available'
                END AS display_status,
                CASE 
                    WHEN EXISTS (
                        SELECT 1 
                        FROM RoomAssignment ra
                        JOIN Booking b ON ra.booking_id = b.booking_id
                        WHERE ra.room_id = r.room_id
                          AND b.status = 'CheckedIn'
                          AND CAST(SYSDATETIME() AS DATE) >= b.check_in_date
                          AND CAST(SYSDATETIME() AS DATE) < b.check_out_date
                    ) THEN 1
                    ELSE 0
                END AS currently_occupied,
                CASE 
                    WHEN EXISTS (
                        SELECT 1 
                        FROM RoomAssignment ra
                        JOIN Booking b ON ra.booking_id = b.booking_id
                        WHERE ra.room_id = r.room_id
                          AND b.status IN ('Confirmed', 'CheckedIn')
                          AND b.check_out_date > CAST(SYSDATETIME() AS DATE)
                    ) THEN 1
                    ELSE 0
                END AS has_active_or_future_booking,
                (
                    SELECT COUNT(*)
                    FROM RoomAssignment ra
                    JOIN Booking b ON ra.booking_id = b.booking_id
                    WHERE ra.room_id = r.room_id
                      AND b.status IN ('Confirmed', 'CheckedIn')
                      AND b.check_in_date < ?
                      AND b.check_out_date > ?
                ) AS overlapping_booking_count
            FROM Room r
            JOIN RoomType rt ON r.type_id = rt.type_id
            WHERE r.is_deleted = 0
            ORDER BY TRY_CAST(REPLACE(r.floor, N'Tầng ', '') AS INT), r.room_number
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setDate(1, toDate);
            ps.setDate(2, fromDate);
            ps.setDate(3, toDate);
            ps.setDate(4, fromDate);
            ps.setDate(5, toDate);
            ps.setDate(6, fromDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoomInfo room = new RoomInfo();
                    room.setRoomId(rs.getInt("room_id"));
                    room.setRoomNumber(rs.getString("room_number"));
                    room.setTypeId(rs.getInt("type_id"));
                    String opStatus = rs.getString("operational_status");
                    String dispStatus = rs.getString("display_status");
                    int overlapCount = rs.getInt("overlapping_booking_count");

                    room.setStatus(opStatus);
                    room.setOperationalStatus(opStatus);
                    room.setDisplayStatus(dispStatus);
                    room.setCurrentlyOccupied(rs.getInt("currently_occupied") == 1);
                    room.setHasActiveOrFutureBooking(rs.getInt("has_active_or_future_booking") == 1);
                    room.setFloor(rs.getString("floor"));
                    room.setTypeName(rs.getString("type_name"));
                    room.setBasePrice(rs.getDouble("base_price"));
                    room.setBedType(rs.getString("bed_type"));
                    room.setArea(rs.getString("area"));

                    if (("Maintenance".equalsIgnoreCase(opStatus) || "OutOfService".equalsIgnoreCase(opStatus)) && overlapCount > 0) {
                        LOGGER.warning(String.format(
                            "DATA CONFLICT WARNING: Room %s (ID: %d, Operational Status: %s) has %d overlapping booking(s) between %s and %s",
                            room.getRoomNumber(), room.getRoomId(), opStatus, overlapCount, fromDate.toString(), toDate.toString()
                        ));
                    }

                    list.add(room);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<RoomInfo> getRoomsByDate(java.sql.Date selectedDate) {
        java.sql.Date nextDate = java.sql.Date.valueOf(selectedDate.toLocalDate().plusDays(1));
        return getRoomsByDateRange(selectedDate, nextDate);
    }

    /**
     * Giống getRoomsByDateRange nhưng chỉ lấy 1 phòng theo roomId, kèm ảnh
     * phòng (image_url) — dùng cho trang chi tiết phòng ở sơ đồ phòng của
     * lễ tân, để display_status hiển thị giống HỆT với sơ đồ phòng (cùng
     * công thức tính theo khoảng ngày đang lọc), thay vì chỉ đọc status thô.
     */
    public RoomInfo getRoomByIdForDateRange(int roomId, java.sql.Date fromDate, java.sql.Date toDate) {
        String sql = """
            SELECT
                r.room_id,
                r.room_number,
                r.type_id,
                r.status AS operational_status,
                r.floor,
                rt.type_name,
                rt.base_price,
                rt.bed_type,
                rt.area,
                ri.image_url,
                CASE
                    WHEN r.status IN ('OutOfService', 'Maintenance', 'Cleaning', 'Refilling') THEN r.status
                    WHEN EXISTS (
                        SELECT 1
                        FROM RoomAssignment ra
                        JOIN Booking b ON ra.booking_id = b.booking_id
                        WHERE ra.room_id = r.room_id
                          AND b.status = 'CheckedIn'
                          AND b.check_in_date < ?
                          AND b.check_out_date > ?
                    ) THEN 'Occupied'
                    WHEN EXISTS (
                        SELECT 1
                        FROM RoomAssignment ra
                        JOIN Booking b ON ra.booking_id = b.booking_id
                        WHERE ra.room_id = r.room_id
                          AND b.status = 'Confirmed'
                          AND b.check_in_date < ?
                          AND b.check_out_date > ?
                    ) THEN 'Confirmed'
                    ELSE 'Available'
                END AS display_status
            FROM Room r
            JOIN RoomType rt ON r.type_id = rt.type_id
            LEFT JOIN RoomImage ri ON ri.type_id = rt.type_id
            WHERE r.room_id = ? AND r.is_deleted = 0
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setDate(1, toDate);
            ps.setDate(2, fromDate);
            ps.setDate(3, toDate);
            ps.setDate(4, fromDate);
            ps.setInt(5, roomId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RoomInfo room = new RoomInfo();
                    room.setRoomId(rs.getInt("room_id"));
                    room.setRoomNumber(rs.getString("room_number"));
                    room.setTypeId(rs.getInt("type_id"));
                    String opStatus = rs.getString("operational_status");
                    room.setStatus(opStatus);
                    room.setOperationalStatus(opStatus);
                    room.setDisplayStatus(rs.getString("display_status"));
                    room.setFloor(rs.getString("floor"));
                    room.setTypeName(rs.getString("type_name"));
                    room.setBasePrice(rs.getDouble("base_price"));
                    room.setBedType(rs.getString("bed_type"));
                    room.setArea(rs.getString("area"));
                    room.setImageUrl(rs.getString("image_url"));
                    return room;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isRoomCurrentlyOccupied(int roomId) {
        String sql = """
            SELECT COUNT(*)
            FROM RoomAssignment ra
            JOIN Booking b ON ra.booking_id = b.booking_id
            WHERE ra.room_id = ?
              AND b.status = 'CheckedIn'
              AND CAST(SYSDATETIME() AS DATE) >= b.check_in_date
              AND CAST(SYSDATETIME() AS DATE) < b.check_out_date
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String getRoomOperationalStatus(int roomId) {
        String sql = "SELECT status FROM Room WHERE room_id = ? AND is_deleted = 0";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE Room SET status = ? WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, status);
            ps.setInt(2, roomId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error updating room status for room " + roomId, e);
            return false;
        }
    }

    public boolean isRoomNumberDuplicate(String roomNumber, int excludeRoomId) {
        String sql = "SELECT COUNT(*) FROM Room WHERE room_number = ? AND room_id <> ? AND is_deleted = 0";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, roomNumber);
            ps.setInt(2, excludeRoomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean insertRoom(RoomInfo room) {
        String sql = "INSERT INTO Room (room_number, floor, type_id, status, is_deleted) VALUES (?, ?, ?, ?, 0)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getFloor());
            ps.setInt(3, room.getTypeId());
            ps.setString(4, room.getOperationalStatus());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateRoom(RoomInfo room) {
        String sql = "UPDATE Room SET room_number = ?, floor = ?, type_id = ?, status = ? WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getFloor());
            ps.setInt(3, room.getTypeId());
            ps.setString(4, room.getOperationalStatus());
            ps.setInt(5, room.getRoomId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<RoomInfo> getRoomsForIssueReport() {

        List<RoomInfo> rooms = new ArrayList<>();

        String sql = """
        SELECT
            room_id,
            room_number,
            status
        FROM Room
        WHERE is_deleted = 0
          AND status <> 'OutOfService'
        ORDER BY
            TRY_CAST(floor AS INT),
            room_number
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                RoomInfo room = new RoomInfo();

                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setStatus(rs.getString("status"));

                rooms.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return rooms;
    }

    public boolean updateRoomStatusByIssue(int roomId,
            String issueType,
            String severity) {

        int newPriority = getPriority(issueType, severity);

        String currentStatus = getCurrentRoomStatus(roomId);

        int currentPriority = getStatusPriority(currentStatus);

        // Priority mới thấp hơn -> không cập nhật
        if (newPriority > currentPriority) {
            return true;
        }

        String roomStatus;

        switch (issueType) {

            case "Damage":
                roomStatus = "Maintenance";
                break;

            case "Refill":
                roomStatus = "Refilling";
                break;

            case "Cleaning":
                roomStatus = "Cleaning";
                break;

            case "Other":

                if ("Low".equalsIgnoreCase(severity)) {
                    roomStatus = "Available";
                } else {
                    roomStatus = "Maintenance";
                }

                break;

            default:
                return false;
        }

        String sql = """
        UPDATE Room
        SET status = ?
        WHERE room_id = ?
        """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, roomStatus);
            ps.setInt(2, roomId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private int getPriority(String issueType, String severity) {

        if ("Damage".equals(issueType)) {
            return 1;
        }

        if ("Other".equals(issueType)) {

            if ("High".equals(severity)) {
                return 2;
            }

            if ("Medium".equals(severity)) {
                return 2;
            }

            return 4;
        }

        if ("Refill".equals(issueType)) {
            return 3;
        }

        // Cleaning ở mức độ Low, thấp hơn Refill (thiếu vật tư, mức Medium)
        // nên phải có số ưu tiên LỚN hơn (ít khẩn cấp hơn) Refill.
        if ("Cleaning".equals(issueType)) {
            return 4;
        }

        return Integer.MAX_VALUE;
    }

    private int getStatusPriority(String roomStatus) {

        switch (roomStatus) {

            case "Maintenance":
                return 1;

            case "Refilling":
                return 3;

            case "Cleaning":
                return 4;

            case "Available":
                return 4;

            default:
                return Integer.MAX_VALUE;
        }
    }

    private String getCurrentRoomStatus(int roomId) {

        String sql = """
        SELECT status
        FROM Room
        WHERE room_id = ?
        """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("status");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
