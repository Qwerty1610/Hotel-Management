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
 * Date: 02/6/2026
 * version 1.0
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
            "  (SELECT ISNULL(SUM(rf.amount),0) FROM dbo.Refund rf WHERE rf.invoice_id = i.invoice_id) AS refunded_amount " +
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

    public List<Refund> getRefunds(int invoiceId) {
        List<Refund> list = new ArrayList<>();
        String sql = "SELECT refund_id, invoice_id, amount, reason, created_at " +
                "FROM dbo.Refund WHERE invoice_id = ? ORDER BY created_at DESC, refund_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Refund rf = new Refund();
                        rf.setRefundId(rs.getInt("refund_id"));
                        rf.setInvoiceId(rs.getInt("invoice_id"));
                        rf.setAmount(rs.getDouble("amount"));
                        rf.setReason(rs.getString("reason"));
                        rf.setCreatedAt(rs.getTimestamp("created_at"));
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
     * Ghi nhận một khoản hoàn tiền và chuyển hóa đơn sang trạng thái Refunded.
     */
    public boolean addRefund(int invoiceId, double amount, String reason) {
        String insert = "INSERT INTO dbo.Refund (invoice_id, amount, reason) VALUES (?, ?, ?)";
        String update = "UPDATE dbo.Invoice SET status = N'Refunded', updated_at = SYSDATETIME() WHERE invoice_id = ?";
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
        inv.setRefundedAmount(rs.getDouble("refunded_amount"));
        return inv;
    }
}
