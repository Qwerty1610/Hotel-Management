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
    /* Phần khách đã thanh toán THẲNG vào hóa đơn. Khác DEPOSIT_EXPR ở chỗ khoản cọc
       là Payment có invoice_id IS NULL (gắn với booking), còn đây là Payment đã gắn
       invoice_id. Hai biểu thức không bao giờ đếm trùng một dòng Payment. */
    private static final String PAID_EXPR =
            "(SELECT ISNULL(SUM(pi.amount),0) FROM dbo.Payment pi WHERE pi.invoice_id = i.invoice_id)";

    /** Thực thu của một hóa đơn = Tổng − Cọc − Đã hoàn. Bản SQL của Invoice.netAmount(). */
    private static final String NET_EXPR = TOTAL_EXPR + " - " + DEPOSIT_EXPR + " - " + REFUNDED_EXPR;

    private static final String MONEY_COLUMNS =
            "  " + TOTAL_EXPR + " AS total_amount, " +
            "  " + DEPOSIT_EXPR + " AS deposit_amount, " +
            "  " + REFUNDED_EXPR + " AS refunded_amount, " +
            "  " + PENDING_REFUND_EXPR + " AS pending_refund_amount, " +
            "  " + PAID_EXPR + " AS paid_amount ";

    /**
     * "Hóa đơn còn mở" dưới dạng SQL (1 = còn mở, 0 = đã chốt) — NGUỒN SỰ THẬT DUY NHẤT.
     * isInvoiceOpen(), cột hiển thị trên danh sách và bộ lọc "tình trạng lưu trú" đều
     * đọc từ đây, nên không thể lệch định nghĩa với nhau.
     *
     * Mọi truy vấn dùng lại phải đặt alias bảng Invoice là "i". Dùng subquery tương quan
     * (alias "bo") thay vì JOIN để không đụng alias "b" ở các truy vấn đã join Booking sẵn.
     */
    private static final String OPEN_EXPR =
            "CASE " +
            "  WHEN i.status IN (N'Cancelled', N'Refunded') THEN 0 " +
            "  WHEN NOT EXISTS (SELECT 1 FROM dbo.Booking bo WHERE bo.booking_id = i.booking_id) " +
            "       THEN CASE WHEN i.status = N'Paid' THEN 0 ELSE 1 END " +
            "  WHEN EXISTS (SELECT 1 FROM dbo.Booking bo WHERE bo.booking_id = i.booking_id " +
            "               AND bo.status IN (N'CheckedOut', N'Cancelled', N'Rejected')) THEN 0 " +
            "  ELSE 1 END";

    private static final String STATE_COLUMNS = ", " + OPEN_EXPR + " AS is_open ";

    private static final String BASE_SELECT =
            "SELECT i.invoice_id, i.booking_id, i.customer_name, i.room_number, i.status, i.created_at, " +
            MONEY_COLUMNS + STATE_COLUMNS +
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

    /**
     * Xây mệnh đề WHERE lọc theo từ khóa (mã/khách/phòng), trạng thái thanh toán và
     * tình trạng lưu trú.
     *
     * @param stay "open" = khách chưa trả phòng, "closed" = đã trả phòng / hóa đơn đã
     *             chốt, còn lại (null/"all") = không lọc
     */
    private String buildWhere(String keyword, String status, String stay, List<Object> params) {
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
        if ("open".equalsIgnoreCase(stay)) {
            w.append(" AND (").append(OPEN_EXPR).append(") = 1 ");
        } else if ("closed".equalsIgnoreCase(stay)) {
            w.append(" AND (").append(OPEN_EXPR).append(") = 0 ");
        }
        return w.toString();
    }

    /** Một trang hóa đơn theo bộ lọc, sắp xếp theo ngày tạo mới nhất. */
    public List<Invoice> getInvoices(String keyword, String status, String stay, int offset, int pageSize) {
        List<Invoice> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        String sql = BASE_SELECT + buildWhere(keyword, status, stay, params)
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
    public int countInvoices(String keyword, String status, String stay) {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM dbo.Invoice i" + buildWhere(keyword, status, stay, params);
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

    /* ============================================================
       Vòng đời "hóa đơn còn mở" (§ thanh toán trong lúc lưu trú)
       ------------------------------------------------------------
       Trạng thái Paid KHÔNG còn là ranh giới đóng hóa đơn: khách có thể trả hết
       phần còn lại ngay khi đang ở, rồi vẫn tiếp tục dùng dịch vụ. Ranh giới thật
       là lúc khách TRẢ PHÒNG. Vì vậy:
         - isInvoiceOpen()          quyết định còn được thêm phụ phí / khoản hoàn không
         - syncSettlementStatus()   quyết định hóa đơn hiển thị Đã/Chưa thanh toán
       ============================================================ */

    private static final double MONEY_EPSILON = 0.005; // dưới 1 xu -> coi như bằng 0

    /**
     * Hóa đơn còn mở để ghi thêm khoản (phụ phí, dịch vụ, khoản chờ hoàn) hay không.
     * Nguồn sự thật là trạng thái ĐẶT PHÒNG chứ không phải trạng thái hóa đơn: chừng
     * nào khách chưa trả phòng thì quầy vẫn phải ghi thêm được, kể cả khi khách đã
     * thanh toán hết phần còn lại từ trước.
     *
     * Quy tắc:
     *   - hóa đơn không tồn tại, hoặc đã Cancelled/Refunded  -> đóng
     *   - có booking  -> mở khi booking chưa CheckedOut/Cancelled/Rejected
     *   - không booking (hóa đơn rời) -> giữ nguyên hành vi cũ: mở khi chưa Paid
     */
    public boolean isInvoiceOpen(int invoiceId) {
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            return isInvoiceOpen(conn, invoiceId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Bản dùng lại connection/transaction của lời gọi. Đọc thẳng từ OPEN_EXPR. */
    private boolean isInvoiceOpen(Connection conn, int invoiceId) throws SQLException {
        String sql = "SELECT " + OPEN_EXPR + " AS is_open FROM dbo.Invoice i WHERE i.invoice_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt("is_open") == 1;
            }
        }
    }

    /**
     * Đồng bộ trạng thái tất toán của hóa đơn với số tiền thực sự còn phải trả.
     * Chạy TRONG transaction của lời gọi, ngay sau khi tiền của hóa đơn thay đổi.
     *
     *   còn phải trả = max(0, max(0, Tổng − Cọc − Đã hoàn) − Đã thanh toán)
     *
     *   - còn phải trả > 0 và đang Paid   -> Pending  (khách phát sinh thêm dịch vụ/phụ phí)
     *   - còn phải trả = 0 và đang Pending -> Paid    (khoản hoàn vừa xác nhận đã xóa hết công nợ)
     *
     * Hóa đơn đang Refunding KHÔNG bị đụng tới: còn khoản chờ manager duyệt thì
     * trạng thái phải giữ nguyên để không mất dấu quy trình hoàn tiền. Refunded và
     * Cancelled cũng vậy — đó là các trạng thái kết thúc.
     */
    private void syncSettlementStatus(Connection conn, int invoiceId) throws SQLException {
        String sql = "SELECT i.status AS inv_status, "
                + TOTAL_EXPR + " AS t, " + DEPOSIT_EXPR + " AS d, "
                + REFUNDED_EXPR + " AS r, " + PAID_EXPR + " AS p, "
                + "(SELECT COUNT(*) FROM dbo.Refund rf WHERE rf.invoice_id = i.invoice_id AND rf.status = N'Pending') AS pending_cnt "
                + "FROM dbo.Invoice i WHERE i.invoice_id = ?";

        String status;
        double remaining;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return;
                status = rs.getString("inv_status");
                if (rs.getInt("pending_cnt") > 0) return; // còn khoản chờ hoàn -> giữ Refunding
                double net = rs.getDouble("t") - rs.getDouble("d") - rs.getDouble("r");
                if (net < 0) net = 0;
                remaining = net - rs.getDouble("p");
                if (remaining < 0) remaining = 0;
            }
        }

        String target = null;
        if (remaining > MONEY_EPSILON && "Paid".equals(status)) {
            target = "Pending";
        } else if (remaining <= MONEY_EPSILON && "Pending".equals(status)) {
            target = "Paid";
        }
        if (target == null) return;

        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE dbo.Invoice SET status = ?, updated_at = SYSDATETIME() WHERE invoice_id = ? AND status = ?")) {
            ps.setString(1, target);
            ps.setInt(2, invoiceId);
            ps.setString(3, status);
            ps.executeUpdate();
        }
    }

    /**
     * Thêm một dòng phụ phí (Surcharge) vào hóa đơn.
     * Chèn dòng và đồng bộ lại trạng thái tất toán trong CÙNG một transaction — phụ phí
     * làm tổng hóa đơn tăng nên một hóa đơn đã Paid phải quay về Pending.
     */
    public boolean addSurcharge(int invoiceId, String description, int quantity, double unitPrice) {
        String sql = "INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) " +
                "VALUES (?, N'Surcharge', ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            conn.setAutoCommit(false);
            try {
                int rows;
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ps.setString(2, description);
                    ps.setInt(3, quantity);
                    ps.setDouble(4, unitPrice);
                    ps.setDouble(5, quantity * unitPrice);
                    rows = ps.executeUpdate();
                }
                if (rows <= 0) {
                    conn.rollback();
                    return false;
                }
                touchInvoice(conn, invoiceId);
                syncSettlementStatus(conn, invoiceId);
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
     * Sau khi xác nhận, nếu hóa đơn không còn khoản Pending nào thì thoát trạng thái
     * Refunding: về Pending nếu khách còn nợ, hoặc Paid nếu khoản vừa hoàn đã xóa hết
     * công nợ (trường hợp này chỉ có thể xảy ra khi khách đã thanh toán trước đó).
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
                    // Đã ra khỏi Refunding -> để syncSettlementStatus quyết định
                    // Pending hay Paid dựa trên số tiền còn phải trả thực tế.
                    syncSettlementStatus(conn, invoiceId);
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
                + MONEY_COLUMNS + STATE_COLUMNS
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
     * Toàn bộ số phòng ĐÃ PHÂN của một nhóm đặt phòng, gộp thành "103, 104".
     *
     * Không dùng Booking.getAssignedRoomsStr() cho việc này: cột assigned_rooms trong
     * BookingDAO.BASE_SELECT chỉ gom phòng của ĐÚNG MỘT dòng Booking (WHERE
     * ra.booking_id = b.booking_id), nên với đơn nhiều phòng nó chỉ trả về phòng của
     * dòng cha. Ở đây phải quét cả nhóm.
     *
     * Bỏ qua các dòng con đã Cancelled (bị gỡ khỏi đơn khi khách đổi đặt phòng) để
     * hóa đơn không kê phòng mà khách không còn ở.
     *
     * @param rootBookingId booking cha của nhóm
     * @return chuỗi số phòng, hoặc null nếu chưa phân phòng nào
     */
    private String getGroupAssignedRooms(Connection conn, int rootBookingId) throws SQLException {
        String sql = "SELECT STRING_AGG(r.room_number, N', ') WITHIN GROUP (ORDER BY r.room_number) "
                + "FROM dbo.RoomAssignment ra "
                + "JOIN dbo.Room r ON r.room_id = ra.room_id "
                + "WHERE ra.booking_id IN ( "
                + "    SELECT sb.booking_id FROM dbo.Booking sb "
                + "    WHERE (sb.booking_id = ? OR sb.group_booking_id = ?) AND sb.status <> N'Cancelled')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rootBookingId);
            ps.setInt(2, rootBookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String s = rs.getString(1);
                    return (s != null && !s.trim().isEmpty()) ? s.trim() : null;
                }
            }
        }
        return null;
    }

    /** Nhãn phòng cho hóa đơn: số phòng nếu đã phân, ngược lại là tên (các) loại phòng. */
    private String buildRoomLabel(String groupRooms, Booking root) {
        if (groupRooms != null) return groupRooms;
        String types = root.getGroupRoomTypeNames();
        return (types != null && !types.trim().isEmpty()) ? types.trim() : "";
    }

    /**
     * Dựng lại TOÀN BỘ các dòng tiền phòng của hóa đơn: MỘT DÒNG CHO MỖI PHÒNG, kèm
     * giá của riêng phòng đó. Chạy trong transaction của lời gọi.
     *
     * Số phòng thật của một dòng Booking = max(room_quantity, số phòng đã xếp) — dùng
     * max để đơn mới xếp được một nửa số phòng vẫn chia tiền theo đúng số phòng khách đặt.
     * Tiền của dòng Booking được chia đều cho các phòng của nó; phần dư (do chia không
     * hết) dồn vào phòng cuối cùng nên TỔNG các dòng luôn khớp tuyệt đối với tổng đơn —
     * đây là bất biến quan trọng nhất của hàm này.
     *
     * Xóa rồi chèn lại thay vì UPDATE: số phòng có thể thay đổi giữa hai lần gọi (khách
     * đổi đặt phòng, lễ tân xếp thêm phòng) nên số dòng cũng phải thay đổi theo.
     *
     * Nếu nhóm không còn dòng Booking nào sống thì KHÔNG xóa gì cả — thà giữ hóa đơn cũ
     * còn hơn âm thầm xóa sạch tiền phòng.
     *
     * @param invoiceId     hóa đơn cần dựng lại
     * @param rootBookingId booking cha của nhóm
     */
    public void rebuildRoomItems(Connection conn, int invoiceId, int rootBookingId) throws SQLException {
        String sql = "SELECT sb.room_quantity, sb.total_amount, "
                + "       ISNULL(rt.type_name, N'Phòng') AS type_name, "
                + "       DATEDIFF(day, sb.check_in_date, sb.check_out_date) AS nights, "
                + "       (SELECT STRING_AGG(r.room_number, N'|') WITHIN GROUP (ORDER BY r.room_number) "
                + "          FROM dbo.RoomAssignment ra JOIN dbo.Room r ON r.room_id = ra.room_id "
                + "         WHERE ra.booking_id = sb.booking_id) AS rooms "
                + "FROM dbo.Booking sb "
                + "LEFT JOIN dbo.RoomType rt ON rt.type_id = sb.room_type_id "
                + "WHERE (sb.booking_id = ? OR sb.group_booking_id = ?) AND sb.status <> N'Cancelled' "
                + "ORDER BY sb.booking_id";

        List<String> descs = new ArrayList<>();
        List<Double> amounts = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rootBookingId);
            ps.setInt(2, rootBookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int quantity = Math.max(1, rs.getInt("room_quantity"));
                    long rowTotal = Math.round(rs.getDouble("total_amount"));
                    String typeName = rs.getString("type_name");
                    int nights = rs.getInt("nights");
                    String roomsStr = rs.getString("rooms");

                    String[] rooms = (roomsStr == null || roomsStr.trim().isEmpty())
                            ? new String[0]
                            : roomsStr.split("\\|");
                    int n = Math.max(quantity, rooms.length);
                    long each = rowTotal / n;
                    String nightPart = nights > 0 ? ", " + nights + " đêm" : "";

                    for (int i = 0; i < n; i++) {
                        // Phòng cuối gánh phần dư để tổng không bị hụt/dư vài đồng.
                        long amount = (i == n - 1) ? rowTotal - each * (n - 1) : each;
                        descs.add(i < rooms.length
                                ? "Tiền phòng " + rooms[i] + " (" + typeName + nightPart + ")"
                                : "Tiền phòng " + typeName + " (chưa xếp phòng" + nightPart + ")");
                        amounts.add((double) amount);
                    }
                }
            }
        }
        if (descs.isEmpty()) return;

        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM dbo.InvoiceItem WHERE invoice_id = ? AND item_type = N'Room'")) {
            ps.setInt(1, invoiceId);
            ps.executeUpdate();
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) "
                + "VALUES (?, N'Room', ?, 1, ?, ?)")) {
            for (int i = 0; i < descs.size(); i++) {
                ps.setInt(1, invoiceId);
                ps.setString(2, descs.get(i));
                ps.setDouble(3, amounts.get(i));
                ps.setDouble(4, amounts.get(i));
                ps.addBatch();
            }
            ps.executeBatch();
        }
        touchInvoice(conn, invoiceId);
    }

    /**
     * Tạo hóa đơn ở trạng thái Pending (Chưa thanh toán) kèm khoản tiền phòng cho một
     * đặt phòng nếu chưa có; nếu đã có thì ĐỒNG BỘ LẠI dòng tiền phòng.
     *
     * Luôn quy về booking CHA và tính theo CẢ NHÓM. Trước đây hàm này lấy số phòng của
     * đúng dòng Booking được truyền vào, nên với đơn nhiều phòng:
     *   - luồng check-in gọi hàm cho từng dòng con, mỗi lần lại ghi đè room_number bằng
     *     phòng của riêng dòng đó -> hóa đơn chỉ còn MỘT phòng (phòng của dòng cuối);
     *   - dòng "Tiền phòng" chỉ được chèn một lần lúc xác nhận booking, khi phòng chưa
     *     phân, nên mô tả kẹt ở tên loại phòng và không bao giờ được cập nhật.
     * Nay cả room_number lẫn dòng InvoiceItem loại Room đều được đồng bộ ở mỗi lần gọi.
     *
     * @param bookingId ID của đặt phòng (dòng cha hoặc dòng con đều được)
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

        // Mọi con số trên hóa đơn đều lấy từ dòng CHA (tổng cả nhóm), không phải dòng được truyền vào.
        Booking root = (rootBookingId == bookingId) ? b : bookingDAO.getBookingById(rootBookingId);
        if (root == null) return -1;

        String customerName = root.getCustomerName() != null ? root.getCustomerName() : "Khách hàng";
        // Không tính tổng tiền ở đây: rebuildRoomItems dựng từng dòng phòng và tổng
        // hóa đơn là SUM(InvoiceItem.amount), nên chỉ có một nơi quyết định số tiền.

        String insertInvoice = "INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at) "
                + "VALUES (?, ?, ?, N'Pending', SYSDATETIME())";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            conn.setAutoCommit(false);
            try {
                String roomLabel = buildRoomLabel(getGroupAssignedRooms(conn, rootBookingId), root);

                int invoiceId;
                if (existing != null) {
                    invoiceId = existing.getInvoiceId();
                    if (!roomLabel.equals(existing.getRoomNumber())) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "UPDATE dbo.Invoice SET room_number = ?, updated_at = SYSDATETIME() WHERE invoice_id = ?")) {
                            ps.setString(1, roomLabel);
                            ps.setInt(2, invoiceId);
                            ps.executeUpdate();
                        }
                    }
                } else {
                    invoiceId = -1;
                    try (PreparedStatement ps = conn.prepareStatement(insertInvoice, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setInt(1, rootBookingId);
                        ps.setString(2, customerName);
                        ps.setString(3, roomLabel);
                        ps.executeUpdate();
                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            if (rs.next()) invoiceId = rs.getInt(1);
                        }
                    }
                    if (invoiceId <= 0) {
                        conn.rollback();
                        return -1;
                    }
                }

                rebuildRoomItems(conn, invoiceId, rootBookingId);
                if (existing != null) {
                    // Tiền phòng có thể vừa đổi -> tính lại còn nợ hay đã tất toán.
                    // Chỉ làm với hóa đơn đã tồn tại; hóa đơn vừa tạo luôn là Pending.
                    syncSettlementStatus(conn, invoiceId);
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
     *
     * Điều kiện là hóa đơn CÒN MỞ (khách chưa trả phòng), không phải là hóa đơn chưa
     * Paid: khách trả hết phần còn lại giữa kỳ lưu trú rồi vẫn gọi thêm dịch vụ là
     * việc bình thường. Dịch vụ mới làm hóa đơn phát sinh công nợ nên trạng thái được
     * đưa về Pending trong cùng transaction với câu INSERT.
     *
     * @param invoiceId   ID hóa đơn cần cập nhật
     * @param description Tên dịch vụ (title từ BookingServiceRequest)
     * @param quantity    Số lượng (mặc định 1)
     * @param unitPrice   Đơn giá lấy từ HotelService.price
     * @return true nếu thêm thành công
     */
    public boolean addServiceItem(int invoiceId, String description, int quantity, double unitPrice) {
        String insertSql = "INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) "
                + "VALUES (?, N'Service', ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            conn.setAutoCommit(false);
            try {
                if (!isInvoiceOpen(conn, invoiceId)) {
                    conn.rollback();
                    return false; // khách đã trả phòng -> hóa đơn đã chốt
                }
                int rows;
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, invoiceId);
                    ps.setString(2, description);
                    ps.setInt(3, quantity);
                    ps.setDouble(4, unitPrice);
                    ps.setDouble(5, quantity * unitPrice);
                    rows = ps.executeUpdate();
                }
                if (rows <= 0) {
                    conn.rollback();
                    return false;
                }
                touchInvoice(conn, invoiceId);
                syncSettlementStatus(conn, invoiceId);
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
        inv.setPaidAmount(rs.getDouble("paid_amount"));
        inv.setOpen(rs.getInt("is_open") == 1);
        return inv;
    }
}
