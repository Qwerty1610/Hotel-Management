package com.mycompany.hotelmanagement.dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Invoice;
import com.mycompany.hotelmanagement.entity.InvoiceItem;
import com.mycompany.hotelmanagement.entity.Refund;

/**
 * InvoiceDAO
 * Truy vấn hóa đơn, dòng chi tiết và hoàn tiền cho trang quản lý hóa đơn của Manager.
 * Tổng tiền hóa đơn được tính bằng subquery SUM(InvoiceItem.amount); tổng đã hoàn bằng
 * SUM(Refund.amount).
 *
 * Thêm 3 hàm hỗ trợ việc render các danh sách:
 * buildWhere: xây dựng câu lệnh điều kiện để lọc các hóa đơn theo input của người dùng
 * getInvoices: lấy hóa đơn theo bộ lọc buildWhere
 * countInvoices: đếm tổng hóa đơn theo bộ lọc buildWhere để phân trang
 *
 * Sửa 2 thẻ KPI vốn chỉ gom hóa đơn theo trạng thái nên báo sai số tiền:
 * sumNetUnpaidTotal: thay sumTotalByStatus("Pending") — cộng Thực thu, tính cả hóa đơn Refunding
 * sumPendingRefundTotal: thay sumTotalByStatus("Refunding") — lấy từ Refund(Pending)
 * Gom các biểu thức tiền vào hằng số dùng chung để không lệch định nghĩa giữa các truy vấn.
 *
 * Date: 25/7/2026
 * version 1.2
 * @author Pham Quoc Quy
 */
public class InvoiceDAO {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /* Các khoản tiền dẫn xuất của hóa đơn. Mọi truy vấn dùng lại phải đặt alias
       bảng Invoice là "i". Gom về một chỗ để danh sách, trang chi tiết và thẻ KPI
       không thể lệch định nghĩa với nhau. */
    private static final String TOTAL_EXPR =
            "(SELECT ISNULL(SUM(ii.amount),0) FROM dbo.InvoiceItem ii WHERE ii.invoice_id = i.invoice_id)";
    private static final String DEPOSIT_EXPR =
            "(SELECT ISNULL(SUM(pay.amount),0) FROM dbo.Payment pay WHERE pay.booking_id = i.booking_id AND pay.invoice_id IS NULL)";
    private static final String REFUNDED_EXPR =
            "(SELECT ISNULL(SUM(rf.amount),0) FROM dbo.Refund rf WHERE rf.invoice_id = i.invoice_id AND rf.status = N'Done')";
    private static final String PENDING_REFUND_EXPR =
            "(SELECT ISNULL(SUM(rf.amount),0) FROM dbo.Refund rf WHERE rf.invoice_id = i.invoice_id AND rf.status = N'Pending')";

    /** Thực thu của một hóa đơn = Tổng − Cọc − Đã hoàn. Bản SQL của Invoice.netAmount(). */
    private static final String NET_EXPR = TOTAL_EXPR + " - " + DEPOSIT_EXPR + " - " + REFUNDED_EXPR;

    private static final String MONEY_COLUMNS =
            "  " + TOTAL_EXPR + " AS total_amount, " +
            "  " + DEPOSIT_EXPR + " AS deposit_amount, " +
            "  " + REFUNDED_EXPR + " AS refunded_amount, " +
            "  " + PENDING_REFUND_EXPR + " AS pending_refund_amount ";

    private static final String BASE_SELECT =
            "SELECT i.invoice_id, i.booking_id, i.customer_name, i.room_number, i.status, i.created_at, " +
            MONEY_COLUMNS +
            "FROM dbo.Invoice i ";

    /** Toàn bộ hóa đơn, sắp xếp mặc định theo ngày tạo (mới nhất trước). */
    public List<Invoice> getAllInvoices() {
        List<Invoice> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY i.created_at DESC, i.invoice_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInvoice(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Xây mệnh đề WHERE lọc theo từ khóa (mã/khách/phòng) và trạng thái. */
    private String buildWhere(String keyword, String status, List<Object> params) {
        StringBuilder w = new StringBuilder(" WHERE 1 = 1 ");
        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = "%" + keyword.trim() + "%";
            String digits = keyword.replaceAll("\\D", "").replaceFirst("^0+", "");
            w.append(" AND (i.customer_name LIKE ? OR i.room_number LIKE ?");
            params.add(kw);
            params.add(kw);
            if (!digits.isEmpty()) {
                w.append(" OR CAST(i.invoice_id AS NVARCHAR(20)) LIKE ?");
                params.add("%" + digits + "%");
            }
            w.append(") ");
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            w.append(" AND i.status = ? ");
            params.add(status);
        }
        return w.toString();
    }

    /** Một trang hóa đơn theo bộ lọc, sắp xếp theo ngày tạo mới nhất. */
    public List<Invoice> getInvoices(String keyword, String status, int offset, int pageSize) {
        List<Invoice> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        String sql = BASE_SELECT + buildWhere(keyword, status, params)
                + " ORDER BY i.created_at DESC, i.invoice_id DESC "
                + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(offset);
        params.add(pageSize);
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapInvoice(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Tổng số hóa đơn khớp bộ lọc (để phân trang). */
    public int countInvoices(String keyword, String status) {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM dbo.Invoice i" + buildWhere(keyword, status, params);
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

    public Invoice getInvoiceById(int invoiceId) {
        String sql = BASE_SELECT + "WHERE i.invoice_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapInvoice(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<InvoiceItem> getItems(int invoiceId) {
        List<InvoiceItem> list = new ArrayList<>();
        String sql = "SELECT item_id, invoice_id, item_type, description, quantity, unit_price, amount " +
                "FROM dbo.InvoiceItem WHERE invoice_id = ? " +
                "ORDER BY CASE item_type WHEN N'Room' THEN 1 WHEN N'Service' THEN 2 ELSE 3 END, item_id";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        InvoiceItem it = new InvoiceItem();
                        it.setItemId(rs.getInt("item_id"));
                        it.setInvoiceId(rs.getInt("invoice_id"));
                        it.setItemType(rs.getString("item_type"));
                        it.setDescription(rs.getString("description"));
                        it.setQuantity(rs.getInt("quantity"));
                        it.setUnitPrice(rs.getDouble("unit_price"));
                        it.setAmount(rs.getDouble("amount"));
                        list.add(it);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lịch sử hoàn tiền (các khoản đã xác nhận hoàn — status = Done). */
    public List<Refund> getRefunds(int invoiceId) {
        return getRefundsByStatus(invoiceId, "Done", "confirmed_at");
    }

    /** Các khoản đang chờ hoàn (status = Pending). */
    public List<Refund> getPendingRefunds(int invoiceId) {
        return getRefundsByStatus(invoiceId, "Pending", "created_at");
    }

    private List<Refund> getRefundsByStatus(int invoiceId, String status, String orderCol) {
        List<Refund> list = new ArrayList<>();
        String sql = "SELECT refund_id, invoice_id, amount, reason, status, created_at, confirmed_at " +
                "FROM dbo.Refund WHERE invoice_id = ? AND status = ? " +
                "ORDER BY " + orderCol + " DESC, refund_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, invoiceId);
                ps.setString(2, status);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Refund rf = new Refund();
                        rf.setRefundId(rs.getInt("refund_id"));
                        rf.setInvoiceId(rs.getInt("invoice_id"));
                        rf.setAmount(rs.getDouble("amount"));
                        rf.setReason(rs.getString("reason"));
                        rf.setStatus(rs.getString("status"));
                        rf.setCreatedAt(rs.getTimestamp("created_at"));
                        rf.setConfirmedAt(rs.getTimestamp("confirmed_at"));
                        list.add(rf);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * KPI: tổng số tiền khách còn phải trả.
     * Cộng "Thực thu" (Tổng − Cọc − Đã hoàn) của các hóa đơn chưa tất toán. Hóa đơn
     * đang chờ hoàn (Refunding) vẫn là công nợ nên được tính vào; riêng các khoản CHỜ
     * hoàn thì chưa trừ vì manager có thể từ chối hoặc sửa lại số tiền.
     * Kẹp về 0 ở TỪNG hóa đơn (giống Invoice.netAmount()) để một hóa đơn âm không
     * ăn bớt công nợ của hóa đơn khác.
     */
    public double sumNetUnpaidTotal() {
        return queryDouble(
                "SELECT ISNULL(SUM(CASE WHEN t.net > 0 THEN t.net ELSE 0 END), 0) FROM (" +
                "SELECT " + NET_EXPR + " AS net FROM dbo.Invoice i " +
                "WHERE i.status IN (N'Pending', N'Refunding')) t");
    }

    /**
     * KPI: tổng các khoản giảm trừ đang chờ manager duyệt.
     * Lấy thẳng từ Refund(Pending) — đúng số tiền phải hoàn, không phải tổng hóa đơn.
     * Không cần lọc theo Invoice.status vì addPendingRefund/confirmRefunds đã giữ bất biến
     * "có khoản Pending" ⟺ "hóa đơn Refunding" trong cùng transaction.
     */
    public double sumPendingRefundTotal() {
        return queryDouble("SELECT ISNULL(SUM(rf.amount),0) FROM dbo.Refund rf WHERE rf.status = N'Pending'");
    }

    /** Chạy truy vấn không tham số trả về một giá trị số duy nhất. */
    private double queryDouble(String sql) {
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Thêm một dòng phụ phí (Surcharge) vào hóa đơn. */
    public boolean addSurcharge(int invoiceId, String description, int quantity, double unitPrice) {
        String sql = "INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) " +
                "VALUES (?, N'Surcharge', ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, invoiceId);
                ps.setString(2, description);
                ps.setInt(3, quantity);
                ps.setDouble(4, unitPrice);
                ps.setDouble(5, quantity * unitPrice);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    touchInvoice(conn, invoiceId);
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm một khoản CHỜ HOÀN (status = Pending) và chuyển hóa đơn sang trạng thái Refunding.
     */
    public boolean addPendingRefund(int invoiceId, double amount, String reason) {
        String insert = "INSERT INTO dbo.Refund (invoice_id, amount, reason, status) VALUES (?, ?, ?, N'Pending')";
        String update = "UPDATE dbo.Invoice SET status = N'Refunding', updated_at = SYSDATETIME() WHERE invoice_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(insert)) {
                    ps.setInt(1, invoiceId);
                    ps.setDouble(2, amount);
                    ps.setString(3, reason);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(update)) {
                    ps.setInt(1, invoiceId);
                    ps.executeUpdate();
                }
                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xác nhận đã hoàn cho các khoản chờ hoàn (chuyển status sang Done, ghi confirmed_at).
     * Sau khi xác nhận, nếu hóa đơn không còn khoản Pending nào thì chuyển về Pending
     * (chưa thanh toán).
     */
    public boolean confirmRefunds(int invoiceId, List<Integer> refundIds) {
        if (refundIds == null || refundIds.isEmpty()) return false;

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < refundIds.size(); i++) {
            placeholders.append(i == 0 ? "?" : ", ?");
        }
        String update = "UPDATE dbo.Refund SET status = N'Done', confirmed_at = SYSDATETIME() " +
                "WHERE invoice_id = ? AND status = N'Pending' AND refund_id IN (" + placeholders + ")";
        String countPending = "SELECT COUNT(*) FROM dbo.Refund WHERE invoice_id = ? AND status = N'Pending'";
        String markSettled = "UPDATE dbo.Invoice SET status = N'Pending', updated_at = SYSDATETIME() WHERE invoice_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(update)) {
                    ps.setInt(1, invoiceId);
                    for (int i = 0; i < refundIds.size(); i++) {
                        ps.setInt(i + 2, refundIds.get(i));
                    }
                    ps.executeUpdate();
                }
                int remaining = 0;
                try (PreparedStatement ps = conn.prepareStatement(countPending)) {
                    ps.setInt(1, invoiceId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) remaining = rs.getInt(1);
                    }
                }
                if (remaining == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(markSettled)) {
                        ps.setInt(1, invoiceId);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy hóa đơn theo booking_id — hỗ trợ cả root booking ID lẫn child booking ID.
     * Trả về null nếu booking chưa có hóa đơn.
     */
    public Invoice getInvoiceByBookingId(int bookingId) {
        String sql = "SELECT TOP 1 i.invoice_id, i.booking_id, i.customer_name, i.room_number, i.status, i.created_at, "
                + MONEY_COLUMNS
                + "FROM dbo.Invoice i "
                + "JOIN dbo.Booking b ON i.booking_id = b.booking_id OR i.booking_id = b.group_booking_id "
                + "WHERE b.booking_id = ? "
                + "ORDER BY i.invoice_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapInvoice(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tạo hóa đơn ở trạng thái Pending (Chưa thanh toán) kèm khoản tiền phòng cho một đặt phòng
     * nếu đặt phòng chưa có hóa đơn. Nếu đã có thì cập nhật lại số phòng nếu phòng đã phân.
     *
     * @param bookingId ID của đặt phòng cần tạo/cập nhật hóa đơn
     * @return invoice_id vừa tạo hoặc đã tồn tại, -1 nếu thất bại
     */
    public synchronized int createInvoiceForBooking(int bookingId) {
        if (bookingId <= 0) return -1;

        Invoice existing = getInvoiceByBookingId(bookingId);
        BookingDAO bookingDAO = new BookingDAO();
        Booking b = bookingDAO.getBookingById(bookingId);
        if (b == null) return -1;

        int rootBookingId = (b.getGroupBookingId() != null && b.getGroupBookingId() > 0)
                ? b.getGroupBookingId()
                : b.getBookingId();

        String assignedRooms = b.getAssignedRoomsStr();
        if (existing != null) {
            if (assignedRooms != null && !assignedRooms.trim().isEmpty()
                    && !assignedRooms.equals(existing.getRoomNumber())) {
                String updateRoom = "UPDATE dbo.Invoice SET room_number = ?, updated_at = SYSDATETIME() WHERE invoice_id = ?";
                try (Connection conn = DBContext.getConnection()) {
                    useDatabase(conn);
                    try (PreparedStatement ps = conn.prepareStatement(updateRoom)) {
                        ps.setString(1, assignedRooms);
                        ps.setInt(2, existing.getInvoiceId());
                        ps.executeUpdate();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            return existing.getInvoiceId();
        }

        if (rootBookingId != bookingId) {
            b = bookingDAO.getBookingById(rootBookingId);
            if (b == null) return -1;
            assignedRooms = b.getAssignedRoomsStr();
        }

        String customerName = b.getCustomerName() != null ? b.getCustomerName() : "Khách hàng";
        String roomNumber = (assignedRooms != null && !assignedRooms.trim().isEmpty())
                ? assignedRooms
                : (b.getRoomTypeName() != null ? b.getRoomTypeName() : "");
        double totalAmount = b.getOverallTotalAmount() > 0 ? b.getOverallTotalAmount() : b.getTotalAmount();

        String insertInvoice = "INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at) "
                + "VALUES (?, ?, ?, N'Pending', SYSDATETIME())";
        String insertRoomItem = "INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) "
                + "VALUES (?, N'Room', ?, 1, ?, ?)";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            conn.setAutoCommit(false);
            try {
                int invoiceId = -1;
                try (PreparedStatement ps = conn.prepareStatement(insertInvoice, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, rootBookingId);
                    ps.setString(2, customerName);
                    ps.setString(3, roomNumber);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) invoiceId = rs.getInt(1);
                    }
                }

                if (invoiceId > 0) {
                    String itemDesc = "Tiền phòng " + (roomNumber.isEmpty() ? "" : roomNumber)
                            + (b.getNights() > 0 ? " (" + b.getNights() + " đêm)" : "");
                    try (PreparedStatement ps = conn.prepareStatement(insertRoomItem)) {
                        ps.setInt(1, invoiceId);
                        ps.setString(2, itemDesc.trim());
                        ps.setDouble(3, totalAmount);
                        ps.setDouble(4, totalAmount);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
                return invoiceId;
            } catch (SQLException ex) {
                conn.rollback();
                ex.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Đảm bảo hóa đơn có dòng phụ phí check-in (vd: vượt số người tiêu chuẩn).
     *
     * Idempotent theo (invoiceId + description): nếu đã có dòng Surcharge cùng mô tả
     * thì KHÔNG chèn nữa. Nhờ vậy có thể gọi an toàn ở mỗi lần check-in, kể cả khi
     * hóa đơn đã được tạo từ trước (lúc xác nhận booking / thanh toán cọc) — đây là
     * lý do trước đây phụ phí không lọt vào hóa đơn: createInvoiceForBooking thấy
     * hóa đơn đã tồn tại nên return sớm mà không ghi phụ phí.
     *
     * Phụ phí là NGUỒN SỰ THẬT duy nhất về tiền nằm ở InvoiceItem; CheckIn.extra_fee
     * chỉ còn là bản ghi ngữ cảnh tại quầy.
     *
     * @param invoiceId   hóa đơn đích
     * @param extraFee    số tiền phụ phí (bỏ qua nếu <= 0)
     * @param description mô tả dòng phụ phí (dùng làm khóa chống trùng)
     * @return true nếu vừa chèn mới
     */
    public boolean ensureCheckInSurcharge(int invoiceId, double extraFee, String description) {
        if (invoiceId <= 0 || extraFee <= 0) return false;
        String desc = (description != null && !description.trim().isEmpty())
                ? description.trim() : "Phụ phí";
        String existsSql = "SELECT 1 FROM dbo.InvoiceItem "
                + "WHERE invoice_id = ? AND item_type = N'Surcharge' AND description = ?";
        String insertSql = "INSERT INTO dbo.InvoiceItem "
                + "(invoice_id, item_type, description, quantity, unit_price, amount) "
                + "VALUES (?, N'Surcharge', ?, 1, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(existsSql)) {
                ps.setInt(1, invoiceId);
                ps.setString(2, desc);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return false; // đã có -> không chèn trùng
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, invoiceId);
                ps.setString(2, desc);
                ps.setDouble(3, extraFee);
                ps.setDouble(4, extraFee);
                if (ps.executeUpdate() > 0) {
                    touchInvoice(conn, invoiceId);
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm một dòng dịch vụ (Service) vào hóa đơn.
     * Được gọi khi Receptionist duyệt (approve) một Service request của khách hàng.
     * Hóa đơn phải ở trạng thái Pending (chưa thanh toán) thì mới cho phép thêm.
     *
     * @param invoiceId   ID hóa đơn cần cập nhật
     * @param description Tên dịch vụ (title từ BookingServiceRequest)
     * @param quantity    Số lượng (mặc định 1)
     * @param unitPrice   Đơn giá lấy từ HotelService.price
     * @return true nếu thêm thành công
     */
    public boolean addServiceItem(int invoiceId, String description, int quantity, double unitPrice) {
        // Chỉ thêm khi hóa đơn chưa Paid (cho phép Pending, Refunding)
        String checkSql = "SELECT status FROM dbo.Invoice WHERE invoice_id = ?";
        String insertSql = "INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) "
                + "VALUES (?, N'Service', ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            // Kiểm tra trạng thái hóa đơn
            String invoiceStatus = null;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) invoiceStatus = rs.getString("status");
                }
            }
            if (invoiceStatus == null || "Paid".equals(invoiceStatus) || "Cancelled".equals(invoiceStatus)) {
                return false; // Không thêm vào hóa đơn đã đóng
            }
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, invoiceId);
                ps.setString(2, description);
                ps.setInt(3, quantity);
                ps.setDouble(4, unitPrice);
                ps.setDouble(5, quantity * unitPrice);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    touchInvoice(conn, invoiceId);
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy hóa đơn theo id nhưng ràng buộc quyền sở hữu: hóa đơn phải gắn với
     * booking thuộc về tài khoản khách hàng đang đăng nhập.
     * Dùng cho luồng thanh toán online của Customer.
     *
     * @return Invoice nếu đúng chủ sở hữu, null nếu không tồn tại / không thuộc về khách
     */
    public Invoice getInvoiceForCustomer(int invoiceId, int accountId) {
        String sql = BASE_SELECT
                + "JOIN dbo.Booking b ON b.booking_id = i.booking_id "
                + "WHERE i.invoice_id = ? AND b.account_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, invoiceId);
                ps.setInt(2, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapInvoice(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Danh sách hóa đơn CHƯA thanh toán (status = Pending) của một khách hàng,
     * mới nhất trước. Dùng cho trang Thanh toán của Customer.
     */
    public List<Invoice> getUnpaidInvoicesByAccount(int accountId) {
        List<Invoice> list = new ArrayList<>();
        String sql = BASE_SELECT
                + "JOIN dbo.Booking b ON b.booking_id = i.booking_id "
                + "WHERE b.account_id = ? AND i.status = N'Pending' "
                + "ORDER BY i.created_at DESC, i.invoice_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapInvoice(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void touchInvoice(Connection conn, int invoiceId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE dbo.Invoice SET updated_at = SYSDATETIME() WHERE invoice_id = ?")) {
            ps.setInt(1, invoiceId);
            ps.executeUpdate();
        }
    }

    private Invoice mapInvoice(ResultSet rs) throws SQLException {
        Invoice inv = new Invoice();
        inv.setInvoiceId(rs.getInt("invoice_id"));
        int bookingId = rs.getInt("booking_id");
        if (!rs.wasNull()) inv.setBookingId(bookingId);
        inv.setCustomerName(rs.getString("customer_name"));
        inv.setRoomNumber(rs.getString("room_number"));
        inv.setStatus(rs.getString("status"));
        inv.setCreatedAt(rs.getTimestamp("created_at"));
        inv.setTotalAmount(rs.getDouble("total_amount"));
        inv.setDepositAmount(rs.getDouble("deposit_amount"));
        inv.setRefundedAmount(rs.getDouble("refunded_amount"));
        inv.setPendingRefundAmount(rs.getDouble("pending_refund_amount"));
        return inv;
    }
}
