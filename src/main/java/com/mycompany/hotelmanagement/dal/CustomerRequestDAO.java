package com.mycompany.hotelmanagement.dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.CustomerRequest;

/**
 * CustomerRequestDAO
 * Truy vấn bảng CustomerRequest phục vụ trang quản lý yêu cầu khách hàng của Manager.
 *
 * thêm 6 hàm để hỗ trợ việc render danh sách từ BE:
 * buildReqWhere: xây dựng hàm điều kiện theo input của người dùng
 * getRequests: lấy tất cả request theo bộ lọc
 * countRequests: đếm tổng request để phân trang
 * getRequestsByStaff: lấy danh sách công việc đã nhận hoặc được gán của nhân viên theo offset
 * countRequestsByStaff: tổng số công việc đã nhận của nhân viên
 * getInProgressByStaff: lấy công việc đang thực hiện của nhân viên
 * 
 * Các hàm hỗ trợ UC Submit Service Request & View Service Request History (DINH KHANH):
 * insertRequest: Thêm yêu cầu dịch vụ mới của khách hàng vào CSDL
 * getRequestsByCustomer: Lấy danh sách lịch sử yêu cầu dịch vụ của khách hàng
 * cancelRequestByCustomer: Khách hàng tự hủy yêu cầu dịch vụ (khi trạng thái là Pending)
 *
 * Date: 02/6/2026
 * version 1.0
 * @author Pham Quoc Quy, DINH KHANH
 */
public class CustomerRequestDAO {

    public CustomerRequestDAO() {
        ensureBookingIdColumnExists();
        ensureServiceIdColumnExists();
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

    /**
     * Tự động thêm cột service_id vào CustomerRequest nếu chưa tồn tại (idempotent).
     * Cần thiết khi deploy trên DB cũ chưa chạy Section 12 của SQL.
     */
    private void ensureServiceIdColumnExists() {
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            boolean exists = false;
            try (ResultSet rs = conn.getMetaData().getColumns("HotelManagementDB", "dbo", "CustomerRequest", "service_id")) {
                if (rs.next()) {
                    exists = true;
                }
            }
            if (!exists) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("ALTER TABLE dbo.CustomerRequest ADD service_id INT NULL");
                    stmt.execute("ALTER TABLE dbo.CustomerRequest ADD CONSTRAINT FK_CustomerRequest_Service FOREIGN KEY (service_id) REFERENCES dbo.HotelService(service_id)");
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
            "       cr.created_at, cr.completed_at, cr.service_id " +
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

    /**
     * [UC Submit Service Request - DINH KHANH]
     * Thêm mới một yêu cầu dịch vụ (CustomerRequest) từ khách hàng vào cơ sở dữ liệu.
     * Trạng thái mặc định khi thêm mới là 'Pending', thời điểm tạo được lấy theo SYSDATETIME() của DB.
     * Lưu thêm service_id để khi receptionist approve có thể tra cứu giá tiền.
     *
     * @param r Đối tượng chứa thông tin yêu cầu dịch vụ (room_id, booking_id, service_id, title, description, priority, status)
     * @return true nếu thêm thành công, ngược lại trả về false
     */
    public boolean insertRequest(CustomerRequest r) {
        String sql = "INSERT INTO dbo.CustomerRequest (room_id, booking_id, service_id, title, description, priority, status, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (r.getRoomId() != null) ps.setInt(1, r.getRoomId());
                else ps.setNull(1, java.sql.Types.INTEGER);

                if (r.getBookingId() != null) ps.setInt(2, r.getBookingId());
                else ps.setNull(2, java.sql.Types.INTEGER);

                if (r.getServiceId() != null) ps.setInt(3, r.getServiceId());
                else ps.setNull(3, java.sql.Types.INTEGER);

                ps.setString(4, r.getTitle());
                ps.setString(5, r.getDescription());
                ps.setString(6, r.getPriority());
                ps.setString(7, r.getStatus());
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy một CustomerRequest theo request_id.
     * Dùng trong ReceptionistRequestController để lấy thông tin (booking_id, service_id)
     * trước khi tự động thêm dịch vụ vào InvoiceItem khi approve.
     *
     * @param requestId ID của yêu cầu dịch vụ
     * @return CustomerRequest nếu tìm thấy, null nếu không
     */
    public CustomerRequest getById(int requestId) {
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
     * [UC View Service Request History - DINH KHANH]
     * Lấy toàn bộ danh sách yêu cầu dịch vụ phòng mà một khách hàng cụ thể đã gửi.
     * Kết quả trả về kết hợp thông tin phòng (room_number) và tên nhân viên đã xử lý (staff_name) nếu có,
     * được sắp xếp giảm dần theo thời gian tạo (yêu cầu mới nhất hiển thị đầu tiên).
     *
     * @param accountId ID tài khoản của khách hàng
     * @return Danh sách các đối tượng CustomerRequest tương ứng
     */
    public List<CustomerRequest> getRequestsByCustomer(int accountId) {
        List<CustomerRequest> list = new ArrayList<>();
        String sql = "SELECT cr.request_id, cr.room_id, " +
                     "       COALESCE(rm.room_number, ( " +
                     "           SELECT STRING_AGG(r2.room_number, ', ') " +
                     "           FROM dbo.RoomAssignment ra " +
                     "           JOIN dbo.Room r2 ON ra.room_id = r2.room_id " +
                     "           WHERE ra.booking_id = cr.booking_id " +
                     "       )) AS room_number, " +
                     "       cr.booking_id, bk.customer_name, cr.title, cr.description, " +
                     "       cr.priority, cr.status, cr.assigned_staff_id, acc.full_name AS staff_name, " +
                     "       cr.created_at, cr.completed_at " +
                     "FROM dbo.CustomerRequest cr " +
                     "LEFT JOIN dbo.Room rm ON cr.room_id = rm.room_id " +
                     "LEFT JOIN dbo.Account acc ON cr.assigned_staff_id = acc.account_id " +
                     "INNER JOIN dbo.Booking bk ON cr.booking_id = bk.booking_id " +
                     "WHERE bk.account_id = ? " +
                     "ORDER BY cr.created_at DESC, cr.request_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * [UC View Service Request History - DINH KHANH]
     * Cho phép khách hàng tự hủy yêu cầu dịch vụ của chính họ.
     * Yêu cầu chỉ được phép hủy nếu đang ở trạng thái 'Pending' (Chờ xử lý).
     *
     * @param requestId ID của yêu cầu dịch vụ cần hủy
     * @param accountId ID tài khoản của khách hàng thực hiện hủy để xác thực quyền sở hữu
     * @return true nếu cập nhật trạng thái sang 'Cancelled' thành công, ngược lại trả về false
     */
    public boolean cancelRequestByCustomer(int requestId, int accountId) {
        String sql = "UPDATE cr " +
                     "SET cr.status = N'Cancelled', cr.updated_at = SYSDATETIME() " +
                     "FROM dbo.CustomerRequest cr " +
                     "INNER JOIN dbo.Booking bk ON cr.booking_id = bk.booking_id " +
                     "WHERE cr.request_id = ? AND bk.account_id = ? AND cr.status = N'Pending'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, requestId);
                ps.setInt(2, accountId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Ánh xạ (Map) một dòng dữ liệu từ ResultSet thu được từ cơ sở dữ liệu
     * thành một đối tượng thực thể CustomerRequest.
     *
     * @param rs ResultSet hiện tại từ truy vấn SQL
     * @return Một đối tượng CustomerRequest chứa đầy đủ dữ liệu
     * @throws SQLException nếu xảy ra lỗi truy vấn cơ sở dữ liệu
     */
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
        int serviceId = rs.getInt("service_id");
        if (!rs.wasNull()) r.setServiceId(serviceId);
        return r;
    }

    /**
     * [UC View Service Requests - DINH KHANH]
     * Lấy danh sách phân trang các yêu cầu dịch vụ của khách hàng hiển thị trên giao diện của Lễ tân.
     * Hỗ trợ lọc theo trạng thái (Pending/Completed/Cancelled) và tìm kiếm theo từ khóa (tên khách, phòng, mã yêu cầu).
     *
     * @param statusFilter Trạng thái cần lọc (All, Pending, Completed, Cancelled)
     * @param keyword Từ khóa tìm kiếm (tên khách, số phòng, mã yêu cầu)
     * @param offset Vị trí bắt đầu lấy bản ghi (phục vụ phân trang)
     * @param pageSize Số lượng bản ghi tối đa trên một trang
     * @return Danh sách các CustomerRequest thỏa mãn điều kiện
     */
    public List<CustomerRequest> getReceptionistRequests(String statusFilter, String keyword, int offset, int pageSize) {
        List<CustomerRequest> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append(" WHERE cr.booking_id IS NOT NULL ");
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"All".equalsIgnoreCase(statusFilter)) {
            if ("Pending".equalsIgnoreCase(statusFilter)) {
                sql.append(" AND (cr.status = N'Pending' OR cr.status = N'InProgress') ");
            } else {
                sql.append(" AND cr.status = ? ");
                params.add(statusFilter.trim());
            }
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (bk.customer_name LIKE ? OR rm.room_number LIKE ? OR cr.title LIKE ? OR CAST(cr.request_id AS VARCHAR) = ? OR ('#' + CAST(cr.request_id AS VARCHAR)) LIKE ?) ");
            String lkw = "%" + keyword.trim() + "%";
            params.add(lkw);
            params.add(lkw);
            params.add(lkw);
            params.add(keyword.trim().replace("#REQ-", "").replace("REQ-", "").replace("#", ""));
            params.add(lkw);
        }
        sql.append(" ORDER BY cr.created_at DESC, cr.request_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
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

    /**
     * [UC View Service Requests - DINH KHANH]
     * Đếm tổng số lượng yêu cầu dịch vụ thỏa mãn điều kiện lọc và tìm kiếm từ phía Lễ tân,
     * phục vụ tính toán số trang cho phân trang giao diện.
     *
     * @param statusFilter Trạng thái cần lọc
     * @param keyword Từ khóa tìm kiếm
     * @return Tổng số bản ghi thỏa mãn điều kiện
     */
    public int countReceptionistRequests(String statusFilter, String keyword) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM dbo.CustomerRequest cr " +
                "LEFT JOIN dbo.Room rm ON cr.room_id = rm.room_id " +
                "LEFT JOIN dbo.Booking bk ON cr.booking_id = bk.booking_id " +
                "LEFT JOIN dbo.Account acc ON cr.assigned_staff_id = acc.account_id ");
        sql.append(" WHERE cr.booking_id IS NOT NULL ");
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"All".equalsIgnoreCase(statusFilter)) {
            if ("Pending".equalsIgnoreCase(statusFilter)) {
                sql.append(" AND (cr.status = N'Pending' OR cr.status = N'InProgress') ");
            } else {
                sql.append(" AND cr.status = ? ");
                params.add(statusFilter.trim());
            }
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (bk.customer_name LIKE ? OR rm.room_number LIKE ? OR cr.title LIKE ? OR CAST(cr.request_id AS VARCHAR) = ? OR ('#' + CAST(cr.request_id AS VARCHAR)) LIKE ?) ");
            String lkw = "%" + keyword.trim() + "%";
            params.add(lkw);
            params.add(lkw);
            params.add(lkw);
            params.add(keyword.trim().replace("#REQ-", "").replace("REQ-", "").replace("#", ""));
            params.add(lkw);
        }
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
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

    /**
     * [UC View Service Requests - DINH KHANH]
     * Cho phép Lễ tân cập nhật trạng thái yêu cầu dịch vụ (ví dụ: duyệt hoàn thành 'Completed').
     * Nếu yêu cầu chưa có nhân viên đảm nhận, hệ thống tự động gán cho chính lễ tân duyệt (`receptionistId`),
     * đồng thời cập nhật thời gian hoàn thành `completed_at`.
     *
     * @param requestId ID của yêu cầu dịch vụ
     * @param newStatus Trạng thái mới cần cập nhật (Completed, Cancelled)
     * @param receptionistId ID tài khoản của lễ tân đang thực hiện thao tác duyệt
     * @return true nếu cập nhật thành công, ngược lại trả về false
     */
    public boolean updateStatusByReceptionist(int requestId, String newStatus, int receptionistId) {
        String sql = "UPDATE dbo.CustomerRequest " +
                "SET status = ?, " +
                "    assigned_staff_id = COALESCE(assigned_staff_id, ?), " +
                "    completed_at = CASE WHEN ? = N'Completed' THEN SYSDATETIME() ELSE NULL END, " +
                "    updated_at = SYSDATETIME() " +
                "WHERE request_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, receptionistId);
                ps.setString(3, newStatus);
                ps.setInt(4, requestId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * [UC View Service Requests - DINH KHANH]
     * Đếm tổng số lượng yêu cầu dịch vụ của khách hàng theo trạng thái cụ thể
     * để hiển thị trên các thẻ thống kê KPI của giao diện Lễ tân.
     *
     * @param status Trạng thái cần đếm (Pending, Completed, Cancelled)
     * @return Số lượng yêu cầu tương ứng với trạng thái đó
     */
    public int countReceptionistByStatus(String status) {
        String sql = "";
        if ("Pending".equals(status)) {
            sql = "SELECT COUNT(*) FROM dbo.CustomerRequest WHERE (status = N'Pending' OR status = N'InProgress') AND booking_id IS NOT NULL";
        } else {
            sql = "SELECT COUNT(*) FROM dbo.CustomerRequest WHERE status = ? AND booking_id IS NOT NULL";
        }
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (!"Pending".equals(status)) {
                    ps.setString(1, status);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
