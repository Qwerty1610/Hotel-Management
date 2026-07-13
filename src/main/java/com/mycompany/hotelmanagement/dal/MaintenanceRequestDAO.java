/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.IssueType;
import com.mycompany.hotelmanagement.entity.MaintenanceRequest;
import com.mycompany.hotelmanagement.entity.MaintenanceRequestDetail;
import com.mycompany.hotelmanagement.entity.Room;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author MinhTDPCreated: 06/07/2026
 */
public class MaintenanceRequestDAO {

    private static final String BASE_SELECT = """
        SELECT
            mr.request_id,
            mr.booking_id,
            mr.customer_id,

            c.full_name AS customer_name,

            mr.description,
            mr.priority,
            mr.status,

            mr.assigned_staff_id,
            s.full_name AS staff_name,

            mr.resolution_note,
            mr.created_at,
            mr.updated_at,
            mr.completed_at,

            (
                SELECT STRING_AGG(room_number, ', ')
                FROM (
                    SELECT DISTINCT r.room_number
                    FROM MaintenanceRequestDetail d
                    JOIN Room r
                        ON d.room_id = r.room_id
                    WHERE d.request_id = mr.request_id
                ) roomList
            ) AS room_numbers,

            (
                SELECT STRING_AGG(issue_name, ', ')
                FROM (
                    SELECT it.issue_name
                    FROM MaintenanceRequestDetail d
                    JOIN IssueType it
                        ON d.issue_type_id = it.issue_type_id
                    WHERE d.request_id = mr.request_id
                ) issueList
            ) AS issue_names

        FROM MaintenanceRequest mr

        JOIN Account c
            ON mr.customer_id = c.account_id

        LEFT JOIN Account s
            ON mr.assigned_staff_id = s.account_id
        """;

    public List<IssueType> getAllIssueTypes() {
        List<IssueType> list = new ArrayList<>();

        String sql = """
                 SELECT
                     issue_type_id,
                     issue_name,
                     description,
                     is_active,
                     created_at
                 FROM IssueType
                 WHERE is_active = 1
                 ORDER BY issue_name
                 """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                IssueType issue = new IssueType();

                issue.setIssueTypeId(rs.getInt("issue_type_id"));
                issue.setIssueName(rs.getString("issue_name"));
                issue.setDescription(rs.getString("description"));
                issue.setActive(rs.getBoolean("is_active"));

                Timestamp created = rs.getTimestamp("created_at");
                if (created != null) {
                    issue.setCreatedAt(created.toLocalDateTime());
                }

                list.add(issue);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean submitMaintenanceRequest(
            int bookingId,
            int customerId,
            String[] issueTypeIds,
            String description) {

        String getRoomSql = """
        SELECT TOP 1 ra.room_id
        FROM RoomAssignment ra
        JOIN Booking b ON b.booking_id = ra.booking_id
        WHERE b.booking_id = ?
          AND b.account_id = ?
          AND b.status = 'CheckedIn'
        """;

        String insertRequestSql = """
        INSERT INTO MaintenanceRequest
        (
            booking_id,
            customer_id,
            description,
            priority,
            status
        )
        VALUES
        (
            ?,
            ?,
            ?,
            N'Low',
            N'Pending'
        )
        """;

        String insertDetailSql = """
        INSERT INTO MaintenanceRequestDetail
        (
            request_id,
            room_id,
            issue_type_id
        )
        VALUES
        (
            ?,
            ?,
            ?
        )
        """;

        Connection con = null;

        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            // ===============================
            // Lấy room_id
            // ===============================
            int roomId = -1;

            try (PreparedStatement ps = con.prepareStatement(getRoomSql)) {

                ps.setInt(1, bookingId);
                ps.setInt(2, customerId);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    roomId = rs.getInt("room_id");
                }
            }

            if (roomId == -1) {
                con.rollback();
                return false;
            }

            // ===============================
            // Insert MaintenanceRequest
            // ===============================
            int requestId = 0;

            try (PreparedStatement ps = con.prepareStatement(
                    insertRequestSql,
                    Statement.RETURN_GENERATED_KEYS)) {

                ps.setInt(1, bookingId);
                ps.setInt(2, customerId);
                ps.setString(3, description);

                ps.executeUpdate();

                ResultSet rs = ps.getGeneratedKeys();

                if (rs.next()) {
                    requestId = rs.getInt(1);
                }
            }

            // ===============================
            // Insert MaintenanceRequestDetail
            // ===============================
            try (PreparedStatement ps = con.prepareStatement(insertDetailSql)) {
                for (String issueId : issueTypeIds) {
                    if (issueId == null || issueId.isBlank()) {
                        continue;
                    }
                    ps.setInt(1, requestId);
                    ps.setInt(2, roomId);
                    ps.setInt(3, Integer.parseInt(issueId));
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            con.commit();
            return true;

        } catch (Exception e) {

            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            e.printStackTrace();
            return false;

        } finally {

            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

        }
    }

    public List<Booking> getCheckedInBookingsByCustomer(int customerId) {

        List<Booking> list = new ArrayList<>();

        String sql = """
        SELECT
            b.booking_id,
            b.room_type_id,
            rt.type_name,
            STRING_AGG(r.room_number, ', ') AS assigned_rooms
        FROM Booking b
        JOIN RoomAssignment ra
            ON b.booking_id = ra.booking_id
        JOIN Room r
            ON ra.room_id = r.room_id
        LEFT JOIN RoomType rt
            ON b.room_type_id = rt.type_id
        WHERE b.account_id = ?
          AND b.status = 'CheckedIn'
        GROUP BY
            b.booking_id,
            b.room_type_id,
            rt.type_name
        ORDER BY
            b.booking_id DESC
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Booking booking = new Booking();

                booking.setBookingId(rs.getInt("booking_id"));

                booking.setRoomTypeId(rs.getInt("room_type_id"));

                booking.setRoomTypeName(rs.getString("type_name"));

                booking.setAssignedRoomsStr(
                        rs.getString("assigned_rooms"));

                list.add(booking);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<MaintenanceRequest> getMaintenanceHistoryByCustomer(int customerId) {

        List<MaintenanceRequest> list = new ArrayList<>();

        String sql = """
            SELECT
                mr.request_id,
                mr.booking_id,
                mr.description,
                mr.resolution_note,
                mr.status,
                mr.created_at,

                (
                    SELECT STRING_AGG(room_number, ', ')
                    FROM (
                        SELECT DISTINCT r.room_number
                        FROM MaintenanceRequestDetail d
                        JOIN Room r
                            ON d.room_id = r.room_id
                        WHERE d.request_id = mr.request_id
                    ) roomList
                ) AS room_numbers,

                (
                    SELECT STRING_AGG(issue_name, ', ')
                    FROM (
                        SELECT it.issue_name
                        FROM MaintenanceRequestDetail d
                        JOIN IssueType it
                            ON d.issue_type_id = it.issue_type_id
                        WHERE d.request_id = mr.request_id
                    ) issueList
                ) AS issue_names

            FROM MaintenanceRequest mr
            WHERE mr.customer_id = ?
            ORDER BY mr.created_at DESC
            """;

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                MaintenanceRequest request = new MaintenanceRequest();

                request.setRequestId(rs.getInt("request_id"));
                request.setBookingId(rs.getInt("booking_id"));
                request.setDescription(rs.getString("description"));
                request.setResolutionNote(rs.getString("resolution_note"));
                request.setStatus(rs.getString("status"));

                Timestamp created = rs.getTimestamp("created_at");
                if (created != null) {
                    request.setCreatedAt(created.toLocalDateTime());
                }

                request.setRoomNumbers(rs.getString("room_numbers"));
                request.setIssueNames(rs.getString("issue_names"));

                list.add(request);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<MaintenanceRequest> getMaintenanceRequests(String status) {

        List<MaintenanceRequest> list = new ArrayList<>();

        String sql = BASE_SELECT;
        if (status != null && !status.equalsIgnoreCase("all")) {
            sql += " WHERE mr.status = ?";
        }

        sql += " ORDER BY mr.created_at DESC";

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            if (status != null && !status.equalsIgnoreCase("all")) {
                ps.setString(1, status);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                MaintenanceRequest request = new MaintenanceRequest();

                request.setRequestId(rs.getInt("request_id"));
                request.setBookingId(rs.getInt("booking_id"));
                request.setCustomerId(rs.getInt("customer_id"));

                request.setDescription(rs.getString("description"));
                request.setPriority(rs.getString("priority"));
                request.setStatus(rs.getString("status"));
                request.setResolutionNote(rs.getString("resolution_note"));

                // Customer
                Account customer = new Account();
                customer.setAccountId(rs.getInt("customer_id"));
                customer.setFullName(rs.getString("customer_name"));
                request.setCustomer(customer);

                // Assigned Staff
                int staffId = rs.getInt("assigned_staff_id");

                if (!rs.wasNull()) {
                    request.setAssignedStaffId(staffId);

                    Account staff = new Account();
                    staff.setAccountId(staffId);
                    staff.setFullName(rs.getString("staff_name"));

                    request.setAssignedStaff(staff);
                }

                Timestamp created = rs.getTimestamp("created_at");
                if (created != null) {
                    request.setCreatedAt(created.toLocalDateTime());
                }

                Timestamp updated = rs.getTimestamp("updated_at");
                if (updated != null) {
                    request.setUpdatedAt(updated.toLocalDateTime());
                }

                Timestamp completed = rs.getTimestamp("completed_at");
                if (completed != null) {
                    request.setCompletedAt(completed.toLocalDateTime());
                }

                request.setRoomNumbers(rs.getString("room_numbers"));
                request.setIssueNames(rs.getString("issue_names"));

                list.add(request);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public MaintenanceRequest getMaintenanceRequestById(int requestId) {

        String sql = """
        SELECT
            mr.request_id,
            mr.booking_id,
            mr.customer_id,

            c.full_name AS customer_name,

            mr.description,
            mr.priority,
            mr.status,

            mr.assigned_staff_id,
            s.full_name AS staff_name,

            mr.resolution_note,
            mr.created_at,
            mr.updated_at,
            mr.completed_at,

            (
                SELECT STRING_AGG(room_number, ', ')
                FROM (
                    SELECT DISTINCT r.room_number
                    FROM MaintenanceRequestDetail d
                    JOIN Room r
                        ON d.room_id = r.room_id
                    WHERE d.request_id = mr.request_id
                ) roomList
            ) AS room_numbers,

            (
                SELECT STRING_AGG(issue_name, ', ')
                FROM (
                    SELECT it.issue_name
                    FROM MaintenanceRequestDetail d
                    JOIN IssueType it
                        ON d.issue_type_id = it.issue_type_id
                    WHERE d.request_id = mr.request_id
                ) issueList
            ) AS issue_names

        FROM MaintenanceRequest mr

        JOIN Account c
            ON mr.customer_id = c.account_id

        LEFT JOIN Account s
            ON mr.assigned_staff_id = s.account_id

        WHERE mr.request_id = ?
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                MaintenanceRequest request = new MaintenanceRequest();

                request.setRequestId(rs.getInt("request_id"));
                request.setBookingId(rs.getInt("booking_id"));
                request.setCustomerId(rs.getInt("customer_id"));

                request.setDescription(rs.getString("description"));
                request.setPriority(rs.getString("priority"));
                request.setStatus(rs.getString("status"));
                request.setResolutionNote(rs.getString("resolution_note"));

                Account customer = new Account();
                customer.setAccountId(rs.getInt("customer_id"));
                customer.setFullName(rs.getString("customer_name"));
                request.setCustomer(customer);

                int staffId = rs.getInt("assigned_staff_id");
                if (!rs.wasNull()) {
                    request.setAssignedStaffId(staffId);

                    Account staff = new Account();
                    staff.setAccountId(staffId);
                    staff.setFullName(rs.getString("staff_name"));
                    request.setAssignedStaff(staff);
                }

                Timestamp created = rs.getTimestamp("created_at");
                if (created != null) {
                    request.setCreatedAt(created.toLocalDateTime());
                }

                Timestamp updated = rs.getTimestamp("updated_at");
                if (updated != null) {
                    request.setUpdatedAt(updated.toLocalDateTime());
                }

                Timestamp completed = rs.getTimestamp("completed_at");
                if (completed != null) {
                    request.setCompletedAt(completed.toLocalDateTime());
                }

                request.setRoomNumbers(rs.getString("room_numbers"));
                request.setIssueNames(rs.getString("issue_names"));

                return request;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean startProcessing(int requestId, int staffId) {

        String sql = """
        UPDATE MaintenanceRequest
        SET
            status = 'InProgress',
            assigned_staff_id = ?,
            updated_at = SYSDATETIME()
        WHERE request_id = ?
          AND status = 'Pending'
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setInt(2, requestId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean resolveRequest(int requestId,
            String resolutionNote) {

        String sql = """
        UPDATE MaintenanceRequest
        SET
            status = 'Resolved',
            resolution_note = ?,
            updated_at = SYSDATETIME(),
            completed_at = SYSDATETIME()
        WHERE request_id = ?
          AND status IN ('InProgress', 'Unresolvable')
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, resolutionNote);
            ps.setInt(2, requestId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean markUnresolvable(int requestId,
            String resolutionNote) {

        String sql = """
        UPDATE MaintenanceRequest
        SET
            status = 'Unresolvable',
            resolution_note = ?,
            updated_at = SYSDATETIME()
        WHERE request_id = ?
          AND status = 'InProgress'
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, resolutionNote);
            ps.setInt(2, requestId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public int countAll() {

        String sql = "SELECT COUNT(*) FROM MaintenanceRequest";

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int countByStatus(String status) {

        String sql = """
        SELECT COUNT(*)
        FROM MaintenanceRequest
        WHERE status = ?
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }
}
