package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.BookingServiceRequest;
import com.mycompany.hotelmanagement.entity.RoomInfo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * BookingServiceRequestDAO Lớp truy xuất dữ liệu (DAO) cho các yêu cầu dịch vụ
 * phòng (Booking Service Request). Phục vụ các usecase gửi yêu cầu dịch vụ của
 * khách hàng và phê duyệt yêu cầu từ lễ tân.
 *
 * Date: 21/6/2026
 * @author KhanhTD
 */
public class BookingServiceRequestDAO {

    private void useDatabase(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB;");
        }
    }

    /**
     * UC-62: View Service Request History Lấy danh sách lịch sử yêu cầu dịch vụ
     * của khách hàng theo accountId và trạng thái lọc.
     *
     * @param accountId ID tài khoản của khách hàng
     * @param statusFilter trạng thái cần lọc (All, Pending, Completed,
     * Cancelled)
     * @return danh sách các yêu cầu dịch vụ của khách hàng
     */
    public List<BookingServiceRequest> getRequestsByCustomer(int accountId, String statusFilter) {
        List<BookingServiceRequest> list = new ArrayList<>();
        String sql = "SELECT bsr.service_request_id AS request_id, bsr.booking_id, bsr.room_id, bsr.service_id, "
                + "       hs.service_name AS title, bsr.notes AS description, bsr.quantity, bsr.status, "
                + "       bsr.processed_by_staff_id, bsr.created_at, bsr.updated_at, bsr.completed_at, bsr.cancel_reason, "
                + "       r.room_number, a.full_name AS staff_name, hs.unit AS unit, hs.price AS unit_price "
                + "FROM dbo.BookingServiceRequest bsr "
                + "JOIN dbo.Booking b ON bsr.booking_id = b.booking_id "
                + "JOIN dbo.HotelService hs ON bsr.service_id = hs.service_id "
                + "LEFT JOIN dbo.Room r ON bsr.room_id = r.room_id "
                + "LEFT JOIN dbo.Account a ON bsr.processed_by_staff_id = a.account_id "
                + "WHERE b.account_id = ? ";

        if (!"All".equalsIgnoreCase(statusFilter)) {
            sql += "  AND bsr.status = ? ";
        }
        sql += "ORDER BY bsr.created_at DESC";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, accountId);
                if (!"All".equalsIgnoreCase(statusFilter)) {
                    ps.setString(2, statusFilter);
                }
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
     * UC-09: Submit Service Request Thêm mới một yêu cầu dịch vụ phòng của
     * khách hàng vào cơ sở dữ liệu.
     *
     * @param r đối tượng BookingServiceRequest chứa thông tin yêu cầu
     * @return true nếu thêm thành công, ngược lại là false
     */
    public boolean insertRequest(BookingServiceRequest r) {
        String sql = "INSERT INTO dbo.BookingServiceRequest (booking_id, room_id, service_id, notes, quantity, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, r.getBookingId());
                if (r.getRoomId() != null) {
                    ps.setInt(2, r.getRoomId());
                } else {
                    ps.setNull(2, java.sql.Types.INTEGER);
                }

                if (r.getServiceId() != null) {
                    ps.setInt(3, r.getServiceId());
                } else {
                    ps.setNull(3, java.sql.Types.INTEGER);
                }

                ps.setString(4, r.getDescription());
                ps.setInt(5, r.getQuantity() > 0 ? r.getQuantity() : 1);
                ps.setString(6, r.getStatus());
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * UC-62: View Service Request History (Action Cancel) Khách hàng thực hiện
     * hủy yêu cầu dịch vụ của họ (chỉ cho phép khi trạng thái là Pending).
     *
     * @param requestId ID yêu cầu dịch vụ cần hủy
     * @param accountId ID tài khoản khách hàng sở hữu yêu cầu
     * @return true nếu hủy thành công, ngược lại là false
     */
    public boolean cancelRequestByCustomer(int requestId, int accountId) {
        String sql = "UPDATE bsr "
                + "SET bsr.status = N'Cancelled', bsr.updated_at = SYSDATETIME(), bsr.cancel_reason = N'Cancelled by customer' "
                + "FROM dbo.BookingServiceRequest bsr "
                + "JOIN dbo.Booking b ON bsr.booking_id = b.booking_id "
                + "WHERE bsr.service_request_id = ? AND b.account_id = ? AND bsr.status = N'Pending'";
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

    public BookingServiceRequest getRequestById(int requestId) {
        String sql = "SELECT bsr.service_request_id AS request_id, bsr.booking_id, bsr.room_id, bsr.service_id, "
                + "       hs.service_name AS title, bsr.notes AS description, bsr.quantity, bsr.status, "
                + "       bsr.processed_by_staff_id, bsr.created_at, bsr.updated_at, bsr.completed_at, bsr.cancel_reason, "
                + "       r.room_number, a.full_name AS staff_name, hs.unit AS unit, hs.price AS unit_price "
                + "FROM dbo.BookingServiceRequest bsr "
                + "JOIN dbo.HotelService hs ON bsr.service_id = hs.service_id "
                + "LEFT JOIN dbo.Room r ON bsr.room_id = r.room_id "
                + "LEFT JOIN dbo.Account a ON bsr.processed_by_staff_id = a.account_id "
                + "WHERE bsr.service_request_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapRow(rs);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * UC-34: View Service Requests Lễ tân lấy danh sách các yêu cầu dịch vụ của
     * khách hàng kèm theo phân trang và lọc từ khóa.
     *
     * @param statusFilter trạng thái yêu cầu lọc
     * @param keyword từ khóa tìm kiếm (theo tên dịch vụ, số phòng hoặc tên
     * khách hàng)
     * @param offset số dòng bỏ qua
     * @param pageSize số lượng dòng lấy
     * @return danh sách yêu cầu dịch vụ thỏa mãn bộ lọc
     */
    public List<BookingServiceRequest> getReceptionistRequests(String statusFilter, String keyword, int offset, int pageSize) {
        List<BookingServiceRequest> list = new ArrayList<>();
        String sql = "SELECT bsr.service_request_id AS request_id, bsr.booking_id, bsr.room_id, bsr.service_id, "
                + "       hs.service_name AS title, bsr.notes AS description, bsr.quantity, bsr.status, "
                + "       bsr.processed_by_staff_id, bsr.created_at, bsr.updated_at, bsr.completed_at, bsr.cancel_reason, "
                + "       r.room_number, a.full_name AS staff_name, b.customer_name AS customer_name, hs.unit AS unit, hs.price AS unit_price "
                + "FROM dbo.BookingServiceRequest bsr "
                + "JOIN dbo.Booking b ON bsr.booking_id = b.booking_id "
                + "JOIN dbo.HotelService hs ON bsr.service_id = hs.service_id "
                + "LEFT JOIN dbo.Room r ON bsr.room_id = r.room_id "
                + "LEFT JOIN dbo.Account a ON bsr.processed_by_staff_id = a.account_id "
                + "WHERE 1=1 ";

        if (!"All".equalsIgnoreCase(statusFilter)) {
            sql += "  AND bsr.status = ? ";
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "  AND (hs.service_name LIKE ? OR r.room_number LIKE ? OR b.customer_name LIKE ?) ";
        }
        sql += "ORDER BY bsr.created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int pIdx = 1;
                if (!"All".equalsIgnoreCase(statusFilter)) {
                    ps.setString(pIdx++, statusFilter);
                }
                if (keyword != null && !keyword.trim().isEmpty()) {
                    String kw = "%" + keyword.trim() + "%";
                    ps.setString(pIdx++, kw);
                    ps.setString(pIdx++, kw);
                    ps.setString(pIdx++, kw);
                }
                ps.setInt(pIdx++, offset);
                ps.setInt(pIdx++, pageSize);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        BookingServiceRequest item = mapRow(rs);
                        try {
                            item.setCustomerName(rs.getString("customer_name"));
                        } catch (Exception ignored) {
                        }
                        list.add(item);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * UC-34: View Service Requests Đếm tổng số lượng yêu cầu dịch vụ thỏa mãn
     * bộ lọc để tính toán phân trang phía Lễ tân.
     *
     * @param statusFilter trạng thái lọc
     * @param keyword từ khóa tìm kiếm
     * @return tổng số dòng thỏa mãn
     */
    public int countReceptionistRequests(String statusFilter, String keyword) {
        String sql = "SELECT COUNT(*) FROM dbo.BookingServiceRequest bsr "
                + "JOIN dbo.Booking b ON bsr.booking_id = b.booking_id "
                + "JOIN dbo.HotelService hs ON bsr.service_id = hs.service_id "
                + "LEFT JOIN dbo.Room r ON bsr.room_id = r.room_id "
                + "WHERE 1=1 ";

        if (!"All".equalsIgnoreCase(statusFilter)) {
            sql += "  AND bsr.status = ? ";
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "  AND (hs.service_name LIKE ? OR r.room_number LIKE ? OR b.customer_name LIKE ?) ";
        }

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int pIdx = 1;
                if (!"All".equalsIgnoreCase(statusFilter)) {
                    ps.setString(pIdx++, statusFilter);
                }
                if (keyword != null && !keyword.trim().isEmpty()) {
                    String kw = "%" + keyword.trim() + "%";
                    ps.setString(pIdx++, kw);
                    ps.setString(pIdx++, kw);
                    ps.setString(pIdx++, kw);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countReceptionistByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM dbo.BookingServiceRequest WHERE status = ?";
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
            e.printStackTrace();
        }
        return 0;
    }

    public boolean updateStatusByReceptionist(int requestId, String newStatus, int receptionistId) {
        return updateStatusByReceptionist(requestId, newStatus, receptionistId, null);
    }

    public boolean updateStatusByReceptionist(int requestId, String newStatus, int receptionistId, String cancelReason) {
        String sql = "UPDATE dbo.BookingServiceRequest "
                + "SET status = ?, processed_by_staff_id = ?, updated_at = SYSDATETIME(), completed_at = IIF(? = 'Completed', SYSDATETIME(), completed_at), cancel_reason = ? "
                + "WHERE service_request_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, receptionistId);
                ps.setString(3, newStatus);
                ps.setString(4, cancelReason);
                ps.setInt(5, requestId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private BookingServiceRequest mapRow(ResultSet rs) throws SQLException {
        BookingServiceRequest r = new BookingServiceRequest();
        r.setRequestId(rs.getInt("request_id"));

        int bookingId = rs.getInt("booking_id");
        if (!rs.wasNull()) {
            r.setBookingId(bookingId);
        }

        int roomId = rs.getInt("room_id");
        if (!rs.wasNull()) {
            r.setRoomId(roomId);
        }

        int serviceId = rs.getInt("service_id");
        if (!rs.wasNull()) {
            r.setServiceId(serviceId);
        }

        r.setTitle(rs.getString("title"));
        r.setDescription(rs.getString("description"));
        r.setQuantity(rs.getInt("quantity"));
        r.setStatus(rs.getString("status"));

        int staffId = rs.getInt("processed_by_staff_id");
        if (!rs.wasNull()) {
            r.setProcessedByStaffId(staffId);
        }

        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        r.setCompletedAt(rs.getTimestamp("completed_at"));
        r.setCancelReason(rs.getString("cancel_reason"));

        try {
            r.setRoomNumber(rs.getString("room_number"));
        } catch (Exception ignored) {
        }

        try {
            r.setAssignedStaffName(rs.getString("staff_name"));
        } catch (Exception ignored) {
        }

        try {
            r.setUnit(rs.getString("unit"));
        } catch (Exception ignored) {
        }

        try {
            r.setUnitPrice(rs.getDouble("unit_price"));
        } catch (Exception ignored) {
        }
        return r;
    }

    public List<RoomInfo> getCheckedInRooms() {

        List<RoomInfo> list = new ArrayList<>();

        String sql = """
        SELECT
            DISTINCT r.room_id,
            r.room_number,
            r.type_id,
            r.status,
            r.floor
        FROM RoomAssignment ra
        JOIN Room r ON ra.room_id = r.room_id
        JOIN Booking b ON ra.booking_id = b.booking_id
        WHERE b.status = N'CheckedIn'
        ORDER BY r.room_number
    """;

        try (Connection conn = DBContext.getConnection()) {

            useDatabase(conn);

            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    RoomInfo room = new RoomInfo();

                    room.setRoomId(rs.getInt("room_id"));
                    room.setRoomNumber(rs.getString("room_number"));
                    room.setTypeId(rs.getInt("type_id"));
                    room.setStatus(rs.getString("status"));
                    room.setFloor(rs.getString("floor"));

                    list.add(room);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Integer getCheckedInBookingIdByRoom(int roomId) {

        String sql = """
        SELECT TOP 1 b.booking_id
        FROM Booking b
        JOIN RoomAssignment ra
             ON b.booking_id = ra.booking_id
        WHERE ra.room_id = ?
          AND b.status = N'CheckedIn'
    """;

        try (Connection conn = DBContext.getConnection()) {

            useDatabase(conn);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, roomId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        return rs.getInt("booking_id");
                    }

                }

            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<BookingServiceRequest> getActiveServices() {

        List<BookingServiceRequest> list
                = new ArrayList<>();
        String sql = """
        SELECT
            service_id,
            service_name,
            description,
            price,
            unit
        FROM dbo.HotelService
        WHERE is_active = 1
    """;
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps
                    = conn.prepareStatement(sql)) {
                ResultSet rs
                        = ps.executeQuery();
                while (rs.next()) {
                    BookingServiceRequest r
                            = new BookingServiceRequest();
                    r.setServiceId(
                            rs.getInt("service_id")
                    );
                    r.setTitle(
                            rs.getString("service_name")
                    );
                    r.setDescription(
                            rs.getString("description")
                    );
                    r.setUnit(
                            rs.getString("unit")
                    );
                    r.setUnitPrice(
                            rs.getDouble("price")
                    );
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();

        }
        return list;
    }


    public boolean insertRequestByReceptionist(BookingServiceRequest r) {

        String sql = """
        INSERT INTO dbo.BookingServiceRequest
        (
            booking_id,
            room_id,
            service_id,
            notes,
            quantity,
            status,
            processed_by_staff_id,
            created_at
        )

        VALUES
        (
            ?,
            ?,
            ?,
            ?,
            ?,
            N'Pending',
            ?,
            SYSDATETIME()
        )
    """;
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps
                    = conn.prepareStatement(sql)) {
                ps.setInt(
                        1,
                        r.getBookingId()
                );
                if (r.getRoomId() != null) {
                    ps.setInt(
                            2,
                            r.getRoomId()
                    );
                } else {
                    ps.setNull(
                            2,
                            java.sql.Types.INTEGER
                    );
                }
                ps.setInt(
                        3,
                        r.getServiceId()
                );
                ps.setString(
                        4,
                        r.getDescription()
                );
                ps.setInt(
                        5,
                        r.getQuantity() > 0
                        ? r.getQuantity()
                        : 1
                );
                if (r.getProcessedByStaffId() != null) {
                    ps.setInt(
                            6,
                            r.getProcessedByStaffId()
                    );
                } else {
                    ps.setNull(
                            6,
                            java.sql.Types.INTEGER
                    );
                }
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isServiceActive(int serviceId) {

        String sql = """
        SELECT COUNT(*)
        FROM HotelService
        WHERE service_id = ?
          AND is_active = 1
    """;

        try (Connection conn = DBContext.getConnection()) {

            useDatabase(conn);

            try (PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, serviceId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        return rs.getInt(1) > 0;
                    }

                }

            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
