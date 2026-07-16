package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Invoice;
import com.mycompany.hotelmanagement.entity.InvoiceItem;
import com.mycompany.hotelmanagement.entity.Refund;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

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
 * Date: 02/6/2026
 * version 1.1
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

    private static final String BASE_SELECT =
            "SELECT i.invoice_id, i.booking_id, i.customer_name, i.room_number, i.status, i.created_at, " +
            "  (SELECT ISNULL(SUM(ii.amount),0) FROM dbo.InvoiceItem ii WHERE ii.invoice_id = i.invoice_id) AS total_amount, " +
            "  (SELECT ISNULL(SUM(ii.amount),0) * 0.3 FROM dbo.InvoiceItem ii WHERE ii.invoice_id = i.invoice_id AND ii.item_type = N'Room') AS deposit_amount, " +
            "  (SELECT ISNULL(SUM(rf.amount),0) FROM dbo.Refund rf WHERE rf.invoice_id = i.invoice_id AND rf.status = N'Done') AS refunded_amount, " +
            "  (SELECT ISNULL(SUM(rf.amount),0) FROM dbo.Refund rf WHERE rf.invoice_id = i.invoice_id AND rf.status = N'Pending') AS pending_refund_amount " +
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

    /** Tổng tiền của các hóa đơn theo trạng thái (dùng cho KPI). */
    public double sumTotalByStatus(String status) {
        String sql = "SELECT ISNULL(SUM(ii.amount),0) " +
                "FROM dbo.Invoice i JOIN dbo.InvoiceItem ii ON ii.invoice_id = i.invoice_id " +
                "WHERE i.status = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getDouble(1);
                }
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
