package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Room;

import java.sql.*;
import java.util.*;

public class HousekeepingDAO {

    // =========================
    // MAIN: GET ALL ROOMS SORTED
    // =========================
    public List<Room> getAllRooms() {

        List<Room> list = new ArrayList<>();

        String sql = """
    SELECT r.room_id,
           r.room_number,
           rt.type_name,
           r.status,
           r.floor,
           ri.image_url
    FROM Room r
    JOIN RoomType rt ON r.type_id = rt.type_id
    LEFT JOIN RoomImage ri ON ri.type_id = rt.type_id
    WHERE r.is_deleted = 0
""";

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setTypeName(rs.getString("type_name"));
                room.setStatus(rs.getString("status").trim());
                room.setFloor(rs.getString("floor"));
                room.setImageUrl(rs.getString("image_url"));

                list.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // =========================
        // SORT (KHÔNG CẦN DB CHANGE)
        // =========================
        list.sort(new Comparator<Room>() {
            @Override
            public int compare(Room a, Room b) {

                // 1. SORT FLOOR
                int floorA = extractNumber(a.getFloor());
                int floorB = extractNumber(b.getFloor());

                if (floorA != floorB) {
                    return Integer.compare(floorA, floorB);
                }

                // 2. SORT ROOM NUMBER
                int roomA = extractNumber(a.getRoomNumber());
                int roomB = extractNumber(b.getRoomNumber());

                return Integer.compare(roomA, roomB);
            }
        });

        return list;
    }

    // =========================
    // HELPERS
    // =========================
    private int extractNumber(String text) {
        if (text == null) {
            return 999;
        }

        try {
            return Integer.parseInt(text.replaceAll("\\D+", ""));
        } catch (Exception e) {
            return 999;
        }
    }

    // =========================
    // CLEANING ROOMS
    // =========================
    public List<Room> getCleaningRooms() {
        return getRoomsByStatus("Cleaning");
    }

    public List<Room> getMaintenanceRooms() {
        return getRoomsByStatus("Maintenance");
    }

    private List<Room> getRoomsByStatus(String status) {

        List<Room> list = new ArrayList<>();

        String sql = """
            SELECT r.room_id,
                   r.room_number,
                   rt.type_name,
                   r.status,
                   r.floor
            FROM Room r
            JOIN RoomType rt ON r.type_id = rt.type_id
            WHERE r.status = ? AND r.is_deleted = 0
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setTypeName(rs.getString("type_name"));
                room.setStatus(rs.getString("status"));
                room.setFloor(rs.getString("floor"));
                list.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // =========================
    // UPDATE STATUS
    // =========================
    public boolean updateRoomStatus(int roomId, String status) {

        String sql = """
        UPDATE Room
        SET status = ?
        WHERE room_id = ?
    """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, roomId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================
    // COUNTERS
    // =========================
    public int countCleaningRooms() {
        return count("Cleaning");
    }

    public int countMaintenanceRooms() {
        return count("Maintenance");
    }

    public int countAvailableRooms() {
        return count("Available");
    }

    public int countOutOfServiceRooms() {
        return count("OutOfService");
    }

    private int count(String status) {

        String sql = "SELECT COUNT(*) FROM Room WHERE status = ? AND is_deleted = 0";

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public Room getRoomById(int roomId) {

        String sql = """
SELECT r.room_id,
       r.room_number,
       rt.type_name,
       r.status,
       r.floor,
       ri.image_url
FROM Room r
JOIN RoomType rt ON r.type_id = rt.type_id
LEFT JOIN RoomImage ri ON ri.type_id = rt.type_id
WHERE r.room_id = ? AND r.is_deleted = 0
""";

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Room r = new Room();
                r.setRoomId(rs.getInt("room_id"));
                r.setRoomNumber(rs.getString("room_number"));
                r.setTypeName(rs.getString("type_name"));
                r.setStatus(rs.getString("status"));
                r.setFloor(rs.getString("floor"));
                r.setImageUrl(rs.getString("image_url"));
                return r;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
