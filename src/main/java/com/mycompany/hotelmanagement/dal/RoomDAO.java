package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import com.mycompany.hotelmanagement.entity.RoomIssue;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

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

    public List<RoomInfo> getAllRooms() {
        List<RoomInfo> list = new ArrayList<>();
        String sql = "SELECT r.room_id, r.room_number, r.type_id, r.status, r.floor, "
                + "rt.type_name, rt.base_price, rt.bed_type, rt.area "
                + "FROM Room r "
                + "JOIN RoomType rt ON r.type_id = rt.type_id "
                + "WHERE r.is_deleted = 0 "
                + "ORDER BY r.room_number";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoomInfo room = new RoomInfo();
                    room.setRoomId(rs.getInt("room_id"));
                    room.setRoomNumber(rs.getString("room_number"));
                    room.setTypeId(rs.getInt("type_id"));
                    room.setStatus(rs.getString("status"));
                    room.setFloor(rs.getString("floor"));
                    room.setTypeName(rs.getString("type_name"));
                    room.setBasePrice(rs.getDouble("base_price"));
                    room.setBedType(rs.getString("bed_type"));
                    room.setArea(rs.getString("area"));
                    list.add(room);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean deleteRoom(int roomId) {
        // Check if room is available (only Available status is allowed for deletion)
        String checkSql = "SELECT status FROM Room WHERE room_id = ? AND is_deleted = 0";
        try (Connection conn = DBContext.getConnection(); PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            useDatabase(conn);
            psCheck.setInt(1, roomId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    if (!"Available".equalsIgnoreCase(status)) {
                        return false;
                    }
                } else {
                    return false; // Room not found or already deleted
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        String sql = "UPDATE Room SET is_deleted = 1 WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, roomId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE Room SET status = ? WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, status);
            ps.setInt(2, roomId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
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

    public RoomInfo getSoftDeletedRoomByNumber(String roomNumber) {
        String sql = "SELECT room_id, room_number, type_id, status, floor FROM Room WHERE room_number = ? AND is_deleted = 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, roomNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RoomInfo room = new RoomInfo();
                    room.setRoomId(rs.getInt("room_id"));
                    room.setRoomNumber(rs.getString("room_number"));
                    room.setTypeId(rs.getInt("type_id"));
                    room.setStatus(rs.getString("status"));
                    room.setFloor(rs.getString("floor"));
                    return room;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean restoreRoom(int roomId, RoomInfo room) {
        String sql = "UPDATE Room SET is_deleted = 0, floor = ?, type_id = ?, status = ? WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, room.getFloor());
            ps.setInt(2, room.getTypeId());
            ps.setString(3, room.getStatus());
            ps.setInt(4, roomId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean insertRoom(RoomInfo room) {
        String sql = "INSERT INTO Room (room_number, floor, type_id, status, is_deleted) VALUES (?, ?, ?, ?, 0)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getFloor());
            ps.setInt(3, room.getTypeId());
            ps.setString(4, room.getStatus());
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
            ps.setString(4, room.getStatus());
            ps.setInt(5, room.getRoomId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateRoomStatusByBooking(int bookingId, String status) {

        String roomStatus;

        if ("Confirmed".equals(status) || "CheckedIn".equals(status)) {
            roomStatus = "Occupied";
        } else {
            roomStatus = "Available";
        }

        String sql = """
        UPDATE Room
        SET status = ?
        WHERE room_id IN (
            SELECT room_id
            FROM RoomAssignment
            WHERE booking_id = ?
        )
    """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            useDatabase(conn);

            ps.setString(1, roomStatus);
            ps.setInt(2, bookingId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<RoomInfo> getRoomMapByDate(
            java.sql.Date checkIn,
            java.sql.Date checkOut) {

        List<RoomInfo> list = new ArrayList<>();

        String sql = """
        SELECT
            r.room_id,
            r.room_number,
            r.floor,
            rt.type_name,

            CASE

                WHEN r.status = 'Maintenance'
                THEN 'Maintenance'

                WHEN EXISTS (
                    SELECT 1
                    FROM Booking b
                    JOIN RoomAssignment ra
                        ON b.booking_id = ra.booking_id
                    WHERE ra.room_id = r.room_id
                      AND b.status IN ('Confirmed', 'CheckedIn')
                      AND b.check_in_date < ?
                      AND b.check_out_date > ?
                )
                THEN 'Occupied'

                ELSE 'Available'

            END AS display_status

        FROM Room r
        JOIN RoomType rt
            ON r.type_id = rt.type_id
        WHERE r.is_deleted = 0

        ORDER BY
            TRY_CAST(r.floor AS INT),
            r.room_number
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            useDatabase(conn);

            ps.setDate(1, checkOut);
            ps.setDate(2, checkIn);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                RoomInfo room = new RoomInfo();

                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setFloor(rs.getString("floor"));
                room.setTypeName(rs.getString("type_name"));
                room.setStatus(rs.getString("display_status"));

                list.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
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

        if ("Cleaning".equals(issueType)) {
            return 3;
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
                return 3;

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
