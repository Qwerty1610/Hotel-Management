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
 * Project: Hotel Management System
 * Class: CustomerRequestDAO
 *
 * Description:
 * Tầng truy cập dữ liệu cho bảng CustomerRequest. Cung cấp các phương thức
 * lấy tất cả yêu cầu, lấy/đếm Maintenance requests có lọc và phân trang,
 * lấy/đếm yêu cầu theo nhân viên, lấy yêu cầu đang thực hiện của nhân viên,
 * gán nhân viên, cập nhật trạng thái, hủy yêu cầu (từ phía khách hàng), lấy
 * yêu cầu theo ID và thêm mới yêu cầu dịch vụ. Phân biệt Maintenance requests
 * (booking_id IS NULL) và Service requests (booking_id IS NOT NULL).
 * 
 * thêm 6 hàm để hỗ trợ việc render danh sách từ BE:
 * buildReqWhere: xây dựng hàm điều kiện theo input của người dùng
 * getRequests: lấy tất cả request theo bộ lọc
 * countRequests: đếm tổng request để phân trang
 * getRequestsByStaff: lấy danh sách công việc đã nhận hoặc được gán của nhân viên theo offset
 * countRequestsByStaff: tổng số công việc đã nhận của nhân viên
 * getInProgressByStaff: lấy công việc đang thực hiện của nhân viên
 * 
 * Related Use Cases:
 * - UC-09 Submit Service Request
 * - UC-34 View Service Requests
 * - UC-62 View Service Request History
 *
 * Date: 02-06-2026
 *
 * @author Pham Quoc Quy, KhanhTD
 * @version 1.0
 */
public class CustomerRequestDAO {

    public CustomerRequestDAO() {
        ensureBookingIdColumnExists();
        ensureCancelReasonColumnExists();
    }

    private void ensureBookingIdColumnExists() {
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            boolean exists = false;
            try (ResultSet rs = conn.getMetaData().getColumns("HotelManagementDB", "dbo", "CustomerRequest", "booking_id")) {
                if (rs.next()) {
                    exists = true;
                }
            }
            if (!exists) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("ALTER TABLE dbo.CustomerRequest ADD booking_id INT NULL");
                    stmt.execute("ALTER TABLE dbo.CustomerRequest ADD CONSTRAINT FK_CustomerRequest_Booking FOREIGN KEY (booking_id) REFERENCES dbo.Booking(booking_id)");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void ensureCancelReasonColumnExists() {
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            boolean exists = false;
            try (ResultSet rs = conn.getMetaData().getColumns("HotelManagementDB", "dbo", "CustomerRequest", "cancel_reason")) {
                if (rs.next()) {
                    exists = true;
                }
            }
            if (!exists) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("ALTER TABLE dbo.CustomerRequest ADD cancel_reason NVARCHAR(500) NULL");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    private static final String BASE_SELECT =
            "SELECT cr.request_id, cr.room_id, " +
            "       COALESCE(rm.room_number, ( " +
            "           SELECT STRING_AGG(r2.room_number, ', ') " +
            "           FROM dbo.RoomAssignment ra " +
            "           JOIN dbo.Room r2 ON ra.room_id = r2.room_id " +
            "           WHERE ra.booking_id = cr.booking_id " +
            "       )) AS room_number, " +
            "       cr.booking_id, bk.customer_name, cr.title, cr.description, " +
            "       cr.priority, cr.status, cr.assigned_staff_id, acc.full_name AS staff_name, " +
            "       cr.created_at, cr.completed_at, cr.cancel_reason, cr.updated_at " +
            "FROM dbo.CustomerRequest cr " +
            "LEFT JOIN dbo.Room rm ON cr.room_id = rm.room_id " +
            "LEFT JOIN dbo.Booking bk ON cr.booking_id = bk.booking_id " +
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

    /**
     * Lấy một yêu cầu theo request_id.
     * Dùng cho Receptionist khi cần đọc thông tin (booking_id, title) trước khi approve.
     */
    public CustomerRequest getRequestById(int requestId) {
        String sql = BASE_SELECT + " WHERE cr.request_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Maintenance requests (booking_id IS NULL) — dành cho Manager giao việc Housekeeping.
     * Một trang theo bộ lọc, sắp theo thời gian mới nhất.
     */
    public List<CustomerRequest> getMaintenanceRequests(String roomKw, String priority,
                                                        String staffFilter, String status,
                                                        int offset, int pageSize) {
        List<CustomerRequest> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        String sql = BASE_SELECT
                + " WHERE cr.booking_id IS NULL "
                + buildMaintenanceFilter(roomKw, priority, staffFilter, status, params)
                + " ORDER BY cr.created_at DESC, cr.request_id DESC "
                + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(offset);
        params.add(pageSize);
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Tổng số Maintenance requests khớp bộ lọc (phân trang cho Manager). */
    public int countMaintenanceRequests(String roomKw, String priority,
                                        String staffFilter, String status) {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM dbo.CustomerRequest cr "
                + "LEFT JOIN dbo.Room rm ON cr.room_id = rm.room_id "
                + " WHERE cr.booking_id IS NULL "
                + buildMaintenanceFilter(roomKw, priority, staffFilter, status, params);
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Số Maintenance requests đang ở trạng thái Pending (chưa gán) — KPI cho Manager. */
    public int countMaintenanceByStatus(String status) {
        String sql;
        if ("Pending".equals(status)) {
            sql = "SELECT COUNT(*) FROM dbo.CustomerRequest "
                + "WHERE booking_id IS NULL AND status IN (N'Pending', N'InProgress')";
        } else {
            sql = "SELECT COUNT(*) FROM dbo.CustomerRequest "
                + "WHERE booking_id IS NULL AND status = ?";
        }
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (!"Pending".equals(status)) ps.setString(1, status);
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
     * Xây phần điều kiện bổ sung (AND ...) cho Maintenance requests.
     * Khác với buildReqWhere: không có điều kiện WHERE đầu vì caller đã có
     * "WHERE cr.booking_id IS NULL".
     */
    private String buildMaintenanceFilter(String roomKw, String priority,
                                          String staffFilter, String status,
                                          List<Object> params) {
        StringBuilder w = new StringBuilder();
        if (roomKw != null && !roomKw.trim().isEmpty()) {
            w.append(" AND rm.room_number LIKE ? ");
            params.add("%" + roomKw.trim() + "%");
        }
        if (priority != null && !priority.trim().isEmpty() && !"all".equalsIgnoreCase(priority)) {
            w.append(" AND cr.priority = ? ");
            params.add(priority);
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            w.append(" AND cr.status = ? ");
            params.add(status);
        }
        if (staffFilter != null && !staffFilter.trim().isEmpty() && !"all".equalsIgnoreCase(staffFilter)) {
            if ("unassigned".equalsIgnoreCase(staffFilter)) {
                w.append(" AND cr.assigned_staff_id IS NULL ");
            } else {
                try {
                    int sid = Integer.parseInt(staffFilter.trim());
                    w.append(" AND cr.assigned_staff_id = ? ");
                    params.add(sid);
                } catch (NumberFormatException ignored) {}
            }
        }
        return w.toString();
    }

    /** Xây WHERE lọc yêu cầu theo phòng / ưu tiên / nhân viên / trạng thái. */
    private String buildReqWhere(String roomKw, String priority, String staffFilter, String status, List<Object> params) {
        StringBuilder w = new StringBuilder(" WHERE 1 = 1 ");
        if (roomKw != null && !roomKw.trim().isEmpty()) {
            w.append(" AND rm.room_number LIKE ? ");
            params.add("%" + roomKw.trim() + "%");
        }
        if (priority != null && !priority.trim().isEmpty() && !"all".equalsIgnoreCase(priority)) {
            w.append(" AND cr.priority = ? ");
            params.add(priority);
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            w.append(" AND cr.status = ? ");
            params.add(status);
        }
        if (staffFilter != null && !staffFilter.trim().isEmpty() && !"all".equalsIgnoreCase(staffFilter)) {
            if ("unassigned".equalsIgnoreCase(staffFilter)) {
                w.append(" AND cr.assigned_staff_id IS NULL ");
            } else {
                try {
                    int sid = Integer.parseInt(staffFilter.trim());
                    w.append(" AND cr.assigned_staff_id = ? ");
                    params.add(sid);
                } catch (NumberFormatException ignored) {
                    // bỏ qua giá trị nhân viên không hợp lệ
                }
            }
        }
        return w.toString();
    }

    /** Một trang yêu cầu theo bộ lọc, sắp xếp theo thời gian mới nhất. */
    public List<CustomerRequest> getRequests(String roomKw, String priority, String staffFilter,
                                             String status, int offset, int pageSize) {
        List<CustomerRequest> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        String sql = BASE_SELECT + buildReqWhere(roomKw, priority, staffFilter, status, params)
                + " ORDER BY cr.created_at DESC, cr.request_id DESC "
                + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(offset);
        params.add(pageSize);
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Tổng số yêu cầu khớp bộ lọc (để phân trang). */
    public int countRequests(String roomKw, String priority, String staffFilter, String status) {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM dbo.CustomerRequest cr " +
                "LEFT JOIN dbo.Room rm ON cr.room_id = rm.room_id"
                + buildReqWhere(roomKw, priority, staffFilter, status, params);
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Một trang công việc đã nhận / được gán của một nhân viên (mọi trạng thái). */
    public List<CustomerRequest> getRequestsByStaff(int staffId, int offset, int pageSize) {
        List<CustomerRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + " WHERE cr.assigned_staff_id = ? " +
                " ORDER BY cr.created_at DESC, cr.request_id DESC " +
                " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, staffId);
                ps.setInt(2, offset);
                ps.setInt(3, pageSize);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Tổng số công việc đã nhận của một nhân viên. */
    public int countRequestsByStaff(int staffId) {
        String sql = "SELECT COUNT(*) FROM dbo.CustomerRequest WHERE assigned_staff_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, staffId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Các công việc đang thực hiện (InProgress) của một nhân viên. */
    public List<CustomerRequest> getInProgressByStaff(int staffId) {
        List<CustomerRequest> list = new ArrayList<>();
        String sql = BASE_SELECT + " WHERE cr.assigned_staff_id = ? AND cr.status = N'InProgress' " +
                " ORDER BY cr.created_at DESC, cr.request_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, staffId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapRow(rs));
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
        // Không cho đánh dấu Completed nếu yêu cầu chưa được gán nhân viên nào.
        String sql = "UPDATE dbo.CustomerRequest " +
                "SET status = ?, " +
                "    completed_at = CASE WHEN ? = N'Completed' THEN SYSDATETIME() ELSE NULL END, " +
                "    updated_at = SYSDATETIME() " +
                "WHERE request_id = ? " +
                "  AND (? <> N'Completed' OR assigned_staff_id IS NOT NULL)";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setString(2, newStatus);
                ps.setInt(3, requestId);
                ps.setString(4, newStatus);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean insertRequest(CustomerRequest r) {
        String sql = "INSERT INTO dbo.CustomerRequest (room_id, booking_id, title, description, priority, status, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (r.getRoomId() != null) ps.setInt(1, r.getRoomId());
                else ps.setNull(1, java.sql.Types.INTEGER);
                
                if (r.getBookingId() != null) ps.setInt(2, r.getBookingId());
                else ps.setNull(2, java.sql.Types.INTEGER);
                
                ps.setString(3, r.getTitle());
                ps.setString(4, r.getDescription());
                ps.setString(5, r.getPriority());
                ps.setString(6, r.getStatus());
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
        int bookingId = rs.getInt("booking_id");
        if (!rs.wasNull()) r.setBookingId(bookingId);
        r.setCustomerName(rs.getString("customer_name"));
        r.setTitle(rs.getString("title"));
        r.setDescription(rs.getString("description"));
        r.setPriority(rs.getString("priority"));
        r.setStatus(rs.getString("status"));
        int staffId = rs.getInt("assigned_staff_id");
        if (!rs.wasNull()) r.setAssignedStaffId(staffId);
        r.setAssignedStaffName(rs.getString("staff_name"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setCompletedAt(rs.getTimestamp("completed_at"));
        r.setCancelReason(rs.getString("cancel_reason"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        return r;
    }
}

