package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Room;

import java.sql.*;
import java.util.*;

/**
 *
 * @author MinhTDP
 */
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
           ri.image_url,
           CASE WHEN EXISTS (
               SELECT 1 FROM RoomAssignment ra
               JOIN Booking b ON ra.booking_id = b.booking_id
               WHERE ra.room_id = r.room_id
                 AND b.status IN (N'Confirmed', N'CheckedIn')
                 AND CAST(GETDATE() AS DATE) >= b.check_in_date
                 AND CAST(GETDATE() AS DATE) < b.check_out_date
           ) THEN 1 ELSE 0 END AS has_guest
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
                room.setHasGuest(rs.getBoolean("has_guest"));

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
        return getRoomsByStatus("Cleaning",
                "Refilling");
    }

    public List<Room> getMaintenanceRooms() {
        return getRoomsByStatus("Maintenance");
    }

    private List<Room> getRoomsByStatus(String... status) {

        List<Room> list = new ArrayList<>();

        String placeholders = String.join(
                ",",
                Collections.nCopies(status.length, "?")
        );
        String sql = """
        SELECT r.room_id,
               r.room_number,
               rt.type_name,
               r.status,
               r.floor
        FROM Room r
        JOIN RoomType rt 
             ON r.type_id = rt.type_id
        WHERE r.status IN (%s)
          AND r.is_deleted = 0
        """.formatted(placeholders);

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            for (int i = 0; i < status.length; i++) {
                ps.setString(i + 1, status[i]);
            }

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
        return countByStatuses(
                "Cleaning",
                "Refilling"
        );
    }

    public int countMaintenanceRooms() {
        return countByStatuses("Maintenance");
    }

    public int countAvailableRooms() {
        return countByStatuses("Available");
    }

    public int countOutOfServiceRooms() {
        return countByStatuses("OutOfService");
    }

    private int countByStatuses(String... statuses) {

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Room WHERE status IN ("
        );

        for (int i = 0; i < statuses.length; i++) {
            sql.append("?");
            if (i < statuses.length - 1) {
                sql.append(",");
            }
        }

        sql.append(") AND is_deleted = 0");

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < statuses.length; i++) {
                ps.setString(i + 1, statuses[i]);
            }

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

    public boolean updateRoomAvailable(int roomId) {

        String sql = """
        UPDATE Room
        SET status = 'Available'
        WHERE room_id = ?
    """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }

    public boolean refreshRoomStatusByPendingIssues(int roomId) {

        String getIssueSql = """
        SELECT TOP 1
               issue_type,
               severity
        FROM RoomIssue
        WHERE room_id = ?
          AND status = 'Pending'
        ORDER BY
            CASE
                WHEN issue_type = 'Damage'
                     AND severity = 'High' THEN 1

                WHEN issue_type = 'Other'
                     AND severity IN ('High','Medium') THEN 2

                WHEN issue_type = 'Refill'
                     AND severity = 'Medium' THEN 3

                WHEN issue_type = 'Cleaning'
                     AND severity = 'Low' THEN 4

                WHEN issue_type = 'Other'
                     AND severity = 'Low' THEN 5

                ELSE 99
            END,
            issue_id
    """;

        String updateSql = """
        UPDATE Room
        SET status = ?
        WHERE room_id = ?
    """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement psIssue = conn.prepareStatement(getIssueSql); PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {

            psIssue.setInt(1, roomId);

            ResultSet rs = psIssue.executeQuery();

            String roomStatus = "Available";

            // Không còn Pending -> Available
            if (rs.next()) {

                String issueType = rs.getString("issue_type");
                String severity = rs.getString("severity");

                if ("Damage".equals(issueType)) {

                    roomStatus = "Maintenance";

                } else if ("Other".equals(issueType)) {

                    if ("High".equalsIgnoreCase(severity)
                            || "Medium".equalsIgnoreCase(severity)) {

                        roomStatus = "Maintenance";

                    } else {

                        roomStatus = "Available";
                    }

                } else if ("Refill".equals(issueType)) {

                    roomStatus = "Refilling";

                } else if ("Cleaning".equals(issueType)) {

                    roomStatus = "Cleaning";
                }
            }

            psUpdate.setString(1, roomStatus);
            psUpdate.setInt(2, roomId);

            return psUpdate.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
