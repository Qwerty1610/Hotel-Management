package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class RoomRepository {

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
        String sql = "DELETE FROM Room WHERE room_id = ?";
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

    public void insertRoom(RoomInfo room) {
        String sql = "INSERT INTO Room (room_number, floor, type_id, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getFloor());
            ps.setInt(3, room.getTypeId());
            ps.setString(4, room.getStatus());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateRoom(RoomInfo room) {
        String sql = "UPDATE Room SET room_number = ?, floor = ?, type_id = ?, status = ? WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getFloor());
            ps.setInt(3, room.getTypeId());
            ps.setString(4, room.getStatus());
            ps.setInt(5, room.getRoomId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
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
}
