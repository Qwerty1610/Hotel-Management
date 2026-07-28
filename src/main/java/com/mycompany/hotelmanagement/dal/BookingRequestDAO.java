package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.BookingRequest;
import com.mycompany.hotelmanagement.entity.BookingRequestItem;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data-access for customer booking-change and stay-extension requests
 * (table {@code dbo.BookingChangeRequest}). Raw JDBC, matching the project's
 * {@code DBContext.getConnection()} + {@code useDatabase} idiom.
 *
 * @author QuyPQ
 */
public class BookingRequestDAO {

    private static final Logger LOGGER = Logger.getLogger(BookingRequestDAO.class.getName());

    public BookingRequestDAO() {
        ensureItemTableExists();
    }

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (Exception e) {
            // Ignore
        }
    }

    /**
     * Tạo bảng chi tiết nếu CSDL đang chạy chưa có (theo đúng cách
     * {@code BookingDAO.ensureRoomAssignmentTableExists} vẫn làm), để tính năng
     * hoạt động được trên CSDL đã cài từ trước mà không phải chạy lại toàn bộ
     * script khởi tạo.
     */
    private void ensureItemTableExists() {
        String sql = "IF OBJECT_ID(N'dbo.BookingChangeRequestItem', N'U') IS NULL "
                + "BEGIN "
                + "  CREATE TABLE dbo.BookingChangeRequestItem ("
                + "    item_id           INT IDENTITY(1,1) PRIMARY KEY,"
                + "    request_id        INT NOT NULL,"
                + "    target_booking_id INT NULL,"
                + "    action            NVARCHAR(10) NOT NULL,"
                + "    old_room_type_id  INT NULL,"
                + "    old_room_quantity INT NULL,"
                + "    new_room_type_id  INT NULL,"
                + "    new_room_quantity INT NULL,"
                + "    CONSTRAINT FK_BCRI_Request FOREIGN KEY (request_id) "
                + "      REFERENCES dbo.BookingChangeRequest(request_id) ON DELETE CASCADE,"
                + "    CONSTRAINT FK_BCRI_Booking FOREIGN KEY (target_booking_id) REFERENCES dbo.Booking(booking_id),"
                + "    CONSTRAINT FK_BCRI_NewType FOREIGN KEY (new_room_type_id)  REFERENCES dbo.RoomType(type_id),"
                + "    CONSTRAINT CK_BCRI_Action CHECK (action IN (N'Update', N'Add', N'Remove'))"
                + "  );"
                + "  CREATE INDEX IX_BCRI_Request ON dbo.BookingChangeRequestItem(request_id);"
                + "END";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (Statement st = conn.createStatement()) {
                st.execute(sql);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error ensuring BookingChangeRequestItem table exists", e);
        }
    }

    /**
     * Ghi yêu cầu cùng toàn bộ chi tiết từng dòng phòng trong MỘT transaction và
     * trả về id vừa sinh (-1 nếu thất bại). Nửa vời — có bản ghi cha mà thiếu
     * item — sẽ khiến lễ tân duyệt một yêu cầu rỗng, nên hai bảng phải cùng
     * thành công hoặc cùng thất bại.
     */
    public int create(BookingRequest r) {
        if (r == null) {
            return -1;
        }
        String sql = "INSERT INTO dbo.BookingChangeRequest "
                + "(booking_id, account_id, request_type, old_check_in, old_check_out, "
                + " new_check_in, new_check_out, new_room_type_id, new_room_quantity, "
                + " additional_charge, reason, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        String itemSql = "INSERT INTO dbo.BookingChangeRequestItem "
                + "(request_id, target_booking_id, action, old_room_type_id, old_room_quantity, "
                + " new_room_type_id, new_room_quantity) VALUES (?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            useDatabase(conn);
            conn.setAutoCommit(false);

            int requestId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, r.getBookingId());
                ps.setInt(2, r.getAccountId());
                ps.setString(3, r.getRequestType());
                setDate(ps, 4, r.getOldCheckIn());
                setDate(ps, 5, r.getOldCheckOut());
                setDate(ps, 6, r.getNewCheckIn());
                setDate(ps, 7, r.getNewCheckOut());
                setInt(ps, 8, r.getNewRoomTypeId());
                setInt(ps, 9, r.getNewRoomQuantity());
                if (r.getAdditionalCharge() != null) ps.setDouble(10, r.getAdditionalCharge());
                else ps.setNull(10, Types.DECIMAL);
                ps.setString(11, r.getReason() != null ? r.getReason().trim() : null);
                ps.setString(12, r.getStatus() != null ? r.getStatus() : "Pending");

                if (ps.executeUpdate() > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            requestId = rs.getInt(1);
                        }
                    }
                }
            }

            if (requestId <= 0) {
                conn.rollback();
                return -1;
            }

            if (!r.getItems().isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                    for (BookingRequestItem item : r.getItems()) {
                        ps.setInt(1, requestId);
                        setInt(ps, 2, item.getTargetBookingId());
                        ps.setString(3, item.getAction());
                        setInt(ps, 4, item.getOldRoomTypeId());
                        setInt(ps, 5, item.getOldRoomQuantity());
                        setInt(ps, 6, item.getNewRoomTypeId());
                        setInt(ps, 7, item.getNewRoomQuantity());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            conn.commit();
            r.setRequestId(requestId);
            return requestId;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating booking request", e);
            rollbackQuietly(conn);
        } finally {
            closeQuietly(conn);
        }
        return -1;
    }

    /**
     * Có yêu cầu nào của đơn này (hoặc của một dòng con trong nhóm) đang chờ
     * duyệt không. Chặn ngay từ lúc gửi, tránh hai yêu cầu chồng nhau cùng được
     * duyệt và đơn bị đổi hai lần.
     */
    public boolean hasPendingRequest(int rootBookingId) {
        String sql = "SELECT 1 FROM dbo.BookingChangeRequest r "
                + "JOIN dbo.Booking b ON r.booking_id = b.booking_id "
                + "WHERE r.status = N'Pending' "
                + "  AND (b.booking_id = ? OR b.group_booking_id = ?)";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, rootBookingId);
                ps.setInt(2, rootBookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error checking pending request for booking " + rootBookingId, e);
        }
        // Không xác định được thì coi như đang có yêu cầu chờ: thà chặn khách gửi
        // còn hơn để lọt hai yêu cầu chồng nhau.
        return true;
    }

    /** Chi tiết từng dòng phòng của một yêu cầu, kèm tên loại phòng để hiển thị. */
    public List<BookingRequestItem> getItemsByRequest(int requestId) {
        Map<Integer, List<BookingRequestItem>> byRequest = getItemsByRequests(List.of(requestId));
        return byRequest.getOrDefault(requestId, new ArrayList<>());
    }

    /** Nạp chi tiết cho nhiều yêu cầu bằng một truy vấn (tránh N+1 khi dựng danh sách). */
    public Map<Integer, List<BookingRequestItem>> getItemsByRequests(List<Integer> requestIds) {
        Map<Integer, List<BookingRequestItem>> result = new HashMap<>();
        if (requestIds == null || requestIds.isEmpty()) {
            return result;
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < requestIds.size(); i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }
        String sql = "SELECT i.item_id, i.request_id, i.target_booking_id, i.action, "
                + "       i.old_room_type_id, i.old_room_quantity, i.new_room_type_id, i.new_room_quantity, "
                + "       ot.type_name AS old_room_type_name, nt.type_name AS new_room_type_name "
                + "FROM dbo.BookingChangeRequestItem i "
                + "LEFT JOIN dbo.RoomType ot ON i.old_room_type_id = ot.type_id "
                + "LEFT JOIN dbo.RoomType nt ON i.new_room_type_id = nt.type_id "
                + "WHERE i.request_id IN (" + placeholders + ") "
                + "ORDER BY i.item_id";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < requestIds.size(); i++) {
                    ps.setInt(i + 1, requestIds.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        BookingRequestItem item = new BookingRequestItem();
                        item.setItemId(rs.getInt("item_id"));
                        item.setRequestId(rs.getInt("request_id"));
                        item.setTargetBookingId(getInteger(rs, "target_booking_id"));
                        item.setAction(rs.getString("action"));
                        item.setOldRoomTypeId(getInteger(rs, "old_room_type_id"));
                        item.setOldRoomQuantity(getInteger(rs, "old_room_quantity"));
                        item.setNewRoomTypeId(getInteger(rs, "new_room_type_id"));
                        item.setNewRoomQuantity(getInteger(rs, "new_room_quantity"));
                        item.setOldRoomTypeName(rs.getString("old_room_type_name"));
                        item.setNewRoomTypeName(rs.getString("new_room_type_name"));
                        result.computeIfAbsent(item.getRequestId(), k -> new ArrayList<>()).add(item);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading request items", e);
        }
        return result;
    }

    /** Gắn chi tiết dòng phòng vào một danh sách yêu cầu vừa nạp. */
    private void attachItems(List<BookingRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return;
        }
        List<Integer> ids = new ArrayList<>();
        for (BookingRequest r : requests) {
            ids.add(r.getRequestId());
        }
        Map<Integer, List<BookingRequestItem>> byRequest = getItemsByRequests(ids);
        for (BookingRequest r : requests) {
            r.setItems(byRequest.get(r.getRequestId()));
        }
    }

    /** Returns the customer's requests (newest first) for status tracking. */
    public List<BookingRequest> getRequestsByAccount(int accountId) {
        List<BookingRequest> list = new ArrayList<>();
        String sql = "SELECT r.request_id, r.booking_id, r.account_id, r.request_type, "
                + "       r.old_check_in, r.old_check_out, r.new_check_in, r.new_check_out, "
                + "       r.new_room_type_id, r.new_room_quantity, r.additional_charge, "
                + "       r.reason, r.status, r.created_at, r.new_booking_id, "
                + "       nt.type_name AS new_room_type_name, ct.type_name AS current_room_type_name "
                + "FROM dbo.BookingChangeRequest r "
                + "LEFT JOIN dbo.RoomType nt ON r.new_room_type_id = nt.type_id "
                + "LEFT JOIN dbo.Booking b ON r.booking_id = b.booking_id "
                + "LEFT JOIN dbo.RoomType ct ON b.room_type_id = ct.type_id "
                + "WHERE r.account_id = ? "
                + "ORDER BY r.created_at DESC";
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
            LOGGER.log(Level.SEVERE, "Error loading requests for account " + accountId, e);
        }
        attachItems(list);
        return list;
    }

    /** Loads one request with joined display fields, or null if not found. */
    public BookingRequest getRequestById(int requestId) {
        String sql = SELECT_WITH_JOINS + "WHERE r.request_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        BookingRequest r = mapStaffRow(rs);
                        r.setItems(getItemsByRequest(requestId));
                        return r;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading request " + requestId, e);
        }
        return null;
    }

    /**
     * Staff list for UC 2.4.5 Process Booking Change: all customers' requests,
     * filtered by status/keyword (booking id or customer name), paged, newest first.
     */
    public List<BookingRequest> getRequestsForStaff(String statusFilter, String keyword, int offset, int limit) {
        List<BookingRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_WITH_JOINS + "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendStaffFilters(sql, params, statusFilter, keyword);
        sql.append("ORDER BY CASE WHEN r.status = N'Pending' THEN 0 ELSE 1 END, r.created_at DESC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(limit);

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapStaffRow(rs));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading staff request list", e);
        }
        attachItems(list);
        return list;
    }

    /** Counts requests matching the staff list filters. */
    public int countRequestsForStaff(String statusFilter, String keyword) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM dbo.BookingChangeRequest r "
                + "LEFT JOIN dbo.Booking b ON r.booking_id = b.booking_id "
                + "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendStaffFilters(sql, params, statusFilter, keyword);
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting staff requests", e);
        }
        return 0;
    }

    /** Updates a request's status (Pending -> Approved/Rejected). */
    public boolean updateStatus(int requestId, String newStatus) {
        String sql = "UPDATE dbo.BookingChangeRequest SET status = ? "
                + "WHERE request_id = ? AND status = N'Pending'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, requestId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating request status " + requestId, e);
        }
        return false;
    }

    private static final String SELECT_WITH_JOINS =
            "SELECT r.request_id, r.booking_id, r.account_id, r.request_type, "
            + "       r.old_check_in, r.old_check_out, r.new_check_in, r.new_check_out, "
            + "       r.new_room_type_id, r.new_room_quantity, r.additional_charge, "
            + "       r.reason, r.status, r.created_at, r.new_booking_id, "
            + "       nt.type_name AS new_room_type_name, ct.type_name AS current_room_type_name, "
            + "       b.customer_name AS customer_name, b.status AS booking_status "
            + "FROM dbo.BookingChangeRequest r "
            + "LEFT JOIN dbo.RoomType nt ON r.new_room_type_id = nt.type_id "
            + "LEFT JOIN dbo.Booking b ON r.booking_id = b.booking_id "
            + "LEFT JOIN dbo.RoomType ct ON b.room_type_id = ct.type_id ";

    private void appendStaffFilters(StringBuilder sql, List<Object> params, String statusFilter, String keyword) {
        if (statusFilter != null && !statusFilter.isBlank() && !"All".equalsIgnoreCase(statusFilter)) {
            sql.append("AND r.status = ? ");
            params.add(statusFilter.trim());
        }
        if (keyword != null && !keyword.isBlank()) {
            String kw = keyword.trim();
            sql.append("AND (b.customer_name LIKE ? OR CAST(r.booking_id AS NVARCHAR(20)) LIKE ?) ");
            params.add("%" + kw + "%");
            params.add("%" + kw + "%");
        }
    }

    private BookingRequest mapStaffRow(ResultSet rs) throws java.sql.SQLException {
        BookingRequest r = mapRow(rs);
        r.setCustomerName(rs.getString("customer_name"));
        r.setBookingStatus(rs.getString("booking_status"));
        return r;
    }

    private BookingRequest mapRow(ResultSet rs) throws java.sql.SQLException {
        BookingRequest r = new BookingRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setBookingId(rs.getInt("booking_id"));
        r.setAccountId(rs.getInt("account_id"));
        r.setRequestType(rs.getString("request_type"));
        r.setOldCheckIn(rs.getDate("old_check_in"));
        r.setOldCheckOut(rs.getDate("old_check_out"));
        r.setNewCheckIn(rs.getDate("new_check_in"));
        r.setNewCheckOut(rs.getDate("new_check_out"));
        int nt = rs.getInt("new_room_type_id");
        if (!rs.wasNull()) r.setNewRoomTypeId(nt);
        int nq = rs.getInt("new_room_quantity");
        if (!rs.wasNull()) r.setNewRoomQuantity(nq);
        double ac = rs.getDouble("additional_charge");
        if (!rs.wasNull()) r.setAdditionalCharge(ac);
        r.setReason(rs.getString("reason"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setNewBookingId(getInteger(rs, "new_booking_id"));
        r.setNewRoomTypeName(rs.getString("new_room_type_name"));
        r.setCurrentRoomTypeName(rs.getString("current_room_type_name"));
        return r;
    }

    private void setDate(PreparedStatement ps, int idx, java.sql.Date d) throws java.sql.SQLException {
        if (d != null) ps.setDate(idx, d);
        else ps.setNull(idx, Types.DATE);
    }

    private void setInt(PreparedStatement ps, int idx, Integer v) throws SQLException {
        if (v != null) ps.setInt(idx, v);
        else ps.setNull(idx, Types.INTEGER);
    }

    private Integer getInteger(ResultSet rs, String column) throws SQLException {
        int v = rs.getInt(column);
        return rs.wasNull() ? null : v;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.rollback();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error rolling back booking request transaction", e);
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.setAutoCommit(true);
        } catch (SQLException ignored) {
            // Connection sắp được trả về pool, không cần xử lý thêm
        }
        try {
            conn.close();
        } catch (SQLException ignored) {
            // idem
        }
    }
}
