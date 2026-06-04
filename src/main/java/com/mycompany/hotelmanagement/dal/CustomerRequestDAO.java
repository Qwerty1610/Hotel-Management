package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.CustomerRequest;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * CustomerRequestDAO
 * Truy vấn bảng CustomerRequest phục vụ trang quản lý yêu cầu khách hàng của Manager.
 *
 * Date: 02/6/2026
 */
public class CustomerRequestDAO {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    private static final String BASE_SELECT =
            "SELECT cr.request_id, cr.room_id, rm.room_number, cr.title, cr.description, " +
            "       cr.priority, cr.status, cr.assigned_staff_id, acc.full_name AS staff_name, " +
            "       cr.created_at, cr.completed_at " +
            "FROM dbo.CustomerRequest cr " +
            "LEFT JOIN dbo.Room rm ON cr.room_id = rm.room_id " +
            "LEFT JOIN dbo.Account acc ON cr.assigned_staff_id = acc.account_id ";

    /** Toàn bộ yêu cầu, sắp xếp mặc định theo thời gian yêu cầu (mới nhất trước). */
    public List<CustomerRequest> getAllRequests() {
        List<CustomerRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY cr.created_at DESC, cr.request_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Đếm số yêu cầu theo trạng thái (Pending / InProgress / ...). */
    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM dbo.CustomerRequest WHERE status = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Gán yêu cầu cho một nhân viên. Nếu yêu cầu đang Pending thì chuyển sang InProgress.
     */
    public boolean assignRequest(int requestId, int staffId) {
        String sql = "UPDATE dbo.CustomerRequest " +
                "SET assigned_staff_id = ?, " +
                "    status = CASE WHEN status = N'Pending' THEN N'InProgress' ELSE status END, " +
                "    updated_at = SYSDATETIME() " +
                "WHERE request_id = ? AND status IN (N'Pending', N'InProgress')";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, staffId);
                ps.setInt(2, requestId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật trạng thái yêu cầu. Khi chuyển sang Completed sẽ ghi completed_at,
     * ngược lại xoá completed_at.
     */
    public boolean updateStatus(int requestId, String newStatus) {
        String sql = "UPDATE dbo.CustomerRequest " +
                "SET status = ?, " +
                "    completed_at = CASE WHEN ? = N'Completed' THEN SYSDATETIME() ELSE NULL END, " +
                "    updated_at = SYSDATETIME() " +
                "WHERE request_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setString(2, newStatus);
                ps.setInt(3, requestId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private CustomerRequest mapRow(ResultSet rs) throws SQLException {
        CustomerRequest r = new CustomerRequest();
        r.setRequestId(rs.getInt("request_id"));
        int roomId = rs.getInt("room_id");
        if (!rs.wasNull()) r.setRoomId(roomId);
        r.setRoomNumber(rs.getString("room_number"));
        r.setTitle(rs.getString("title"));
        r.setDescription(rs.getString("description"));
        r.setPriority(rs.getString("priority"));
        r.setStatus(rs.getString("status"));
        int staffId = rs.getInt("assigned_staff_id");
        if (!rs.wasNull()) r.setAssignedStaffId(staffId);
        r.setAssignedStaffName(rs.getString("staff_name"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setCompletedAt(rs.getTimestamp("completed_at"));
        return r;
    }
}
