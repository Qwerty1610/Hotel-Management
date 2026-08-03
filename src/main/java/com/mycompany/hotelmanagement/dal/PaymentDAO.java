package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Payment;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * PaymentDAO
 * Ghi nhận và truy vấn giao dịch thanh toán online qua SePay (bảng dbo.Payment).
 *
 * Điểm quan trọng: recordPaymentAndSettle chạy trong MỘT transaction —
 * ghi giao dịch, cộng dồn số tiền đã trả, nếu đủ thì chuyển hóa đơn sang Paid.
 * Ràng buộc UNIQUE trên sepay_tx_id đảm bảo webhook gửi lại không bị ghi trùng.
 *
 * Date: 08/7/2026
 * @author Pham Quoc Quy
 */
public class PaymentDAO {

    /** Kết quả xử lý một giao dịch webhook. */
    public enum SettleResult {
        PAID,       // đã ghi nhận và hóa đơn đủ tiền -> chuyển Paid
        PARTIAL,    // đã ghi nhận nhưng chưa đủ tiền (khách chuyển thiếu)
        DUPLICATE,  // giao dịch đã được xử lý trước đó (webhook gửi lại)
        ERROR
    }

    public PaymentDAO() {
        // resolveActiveBookingId đọc cột replaced_by_booking_id
        BookingDAO.ensureChangeTrackingColumns();
    }

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /** Đã xử lý giao dịch SePay này chưa (chống webhook gửi lại). */
    public boolean existsBySepayTxId(long sepayTxId) {
        String sql = "SELECT 1 FROM dbo.Payment WHERE sepay_tx_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, sepayTxId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Ghi nhận một giao dịch tiền vào và tất toán hóa đơn nếu đã đủ tiền.
     * Toàn bộ chạy trong một transaction:
     *   1. INSERT dbo.Payment (UNIQUE sepay_tx_id chặn ghi trùng)
     *   2. SUM số tiền đã trả của hóa đơn
     *   3. Nếu tổng đã trả >= số tiền phải trả -> UPDATE Invoice sang Paid
     *
     * @param p         giao dịch cần ghi (invoiceId, sepayTxId, amount... đã set)
     * @param dueAmount số tiền khách phải trả cho hóa đơn này (VND)
     */
    public SettleResult recordPaymentAndSettle(Payment p, double dueAmount) {
        String sumPaid = "SELECT ISNULL(SUM(amount),0) FROM dbo.Payment WHERE invoice_id = ?";
        String markPaid = "UPDATE dbo.Invoice SET status = N'Paid', updated_at = SYSDATETIME() "
                + "WHERE invoice_id = ? AND status = N'Pending'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            conn.setAutoCommit(false);
            try {
                insertPayment(conn, p);
                double paid = 0;
                try (PreparedStatement ps = conn.prepareStatement(sumPaid)) {
                    ps.setInt(1, p.getInvoiceId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) paid = rs.getDouble(1);
                    }
                }
                boolean settled = paid + 0.01 >= dueAmount;
                if (settled) {
                    try (PreparedStatement ps = conn.prepareStatement(markPaid)) {
                        ps.setInt(1, p.getInvoiceId());
                        ps.executeUpdate();
                    }
                }
                conn.commit();
                return settled ? SettleResult.PAID : SettleResult.PARTIAL;
            } catch (SQLException ex) {
                conn.rollback();
                // Vi phạm UNIQUE sepay_tx_id -> webhook gửi lại, coi như đã xử lý
                if (ex.getErrorCode() == 2627 || ex.getErrorCode() == 2601) {
                    return SettleResult.DUPLICATE;
                }
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return SettleResult.ERROR;
    }

    /**
     * Tự đánh dấu hóa đơn đã Paid mà KHÔNG cần bản ghi Payment đi kèm — dùng
     * khi hóa đơn không còn khoản nào phải trả (ví dụ mã khuyến mãi giảm về
     * 0đ) nên sẽ không bao giờ có giao dịch chuyển khoản thật để tất toán.
     */
    public boolean markInvoicePaidDirectly(int invoiceId) {
        String sql = "UPDATE dbo.Invoice SET status = N'Paid', updated_at = SYSDATETIME() "
                + "WHERE invoice_id = ? AND status <> N'Paid'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, invoiceId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Ghi nhận một giao dịch TIỀN CỌC đặt phòng (không đổi trạng thái Booking —
     * việc xác nhận đặt phòng do lễ tân thực hiện thủ công).
     * Idempotent theo sepay_tx_id như recordPaymentAndSettle.
     */
    public SettleResult recordDepositPayment(Payment p) {
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try {
                insertPayment(conn, p);
                return SettleResult.PAID;
            } catch (SQLException ex) {
                if (ex.getErrorCode() == 2627 || ex.getErrorCode() == 2601) {
                    return SettleResult.DUPLICATE;
                }
                throw ex;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return SettleResult.ERROR;
    }

    /** INSERT dùng chung cho cả thanh toán hóa đơn và tiền cọc. */
    private void insertPayment(Connection conn, Payment p) throws SQLException {
        String insert = "INSERT INTO dbo.Payment (invoice_id, booking_id, sepay_tx_id, amount, gateway, reference_code, content, transaction_date) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insert)) {
            ps.setObject(1, p.getInvoiceId());
            ps.setObject(2, p.getBookingId());
            ps.setLong(3, p.getSepayTxId());
            ps.setDouble(4, p.getAmount());
            ps.setString(5, p.getGateway());
            ps.setString(6, p.getReferenceCode());
            ps.setString(7, p.getContent());
            ps.setTimestamp(8, p.getTransactionDate());
            ps.executeUpdate();
        }
    }

    /** Tổng tiền cọc đã chuyển cho một đặt phòng. */
    public double sumPaidForBooking(int bookingId) {
        String sql = "SELECT ISNULL(SUM(amount),0) FROM dbo.Payment WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Tổng số tiền đã thanh toán online của một hóa đơn. */
    public double sumPaidForInvoice(int invoiceId) {
        String sql = "SELECT ISNULL(SUM(amount),0) FROM dbo.Payment WHERE invoice_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, invoiceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lịch sử thanh toán của một khách hàng (mới nhất trước), gồm cả
     * thanh toán hóa đơn (invoice_id) lẫn tiền cọc đặt phòng (booking_id).
     * Quyền sở hữu xác định qua account_id của booking tương ứng.
     */
    public List<Payment> getPaymentsByAccount(int accountId) {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT p.payment_id, p.invoice_id, p.booking_id, p.sepay_tx_id, p.amount, p.gateway, "
                + "  p.reference_code, p.content, p.transaction_date, p.created_at, "
                + "  i.status AS invoice_status, i.room_number, "
                + "  (SELECT ISNULL(SUM(ii.amount),0) FROM dbo.InvoiceItem ii WHERE ii.invoice_id = i.invoice_id) AS invoice_total "
                + "FROM dbo.Payment p "
                + "LEFT JOIN dbo.Invoice i ON i.invoice_id = p.invoice_id "
                + "LEFT JOIN dbo.Booking bi ON bi.booking_id = i.booking_id "
                + "LEFT JOIN dbo.Booking bd ON bd.booking_id = p.booking_id "
                + "WHERE ISNULL(bd.account_id, bi.account_id) = ? "
                + "ORDER BY p.created_at DESC, p.payment_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Payment p = new Payment();
                        p.setPaymentId(rs.getInt("payment_id"));
                        p.setInvoiceId((Integer) rs.getObject("invoice_id"));
                        p.setBookingId((Integer) rs.getObject("booking_id"));
                        p.setSepayTxId(rs.getLong("sepay_tx_id"));
                        p.setAmount(rs.getDouble("amount"));
                        p.setGateway(rs.getString("gateway"));
                        p.setReferenceCode(rs.getString("reference_code"));
                        p.setContent(rs.getString("content"));
                        p.setTransactionDate(rs.getTimestamp("transaction_date"));
                        p.setCreatedAt(rs.getTimestamp("created_at"));
                        p.setInvoiceStatus(rs.getString("invoice_status"));
                        p.setRoomNumber(rs.getString("room_number"));
                        p.setInvoiceTotal(rs.getDouble("invoice_total"));
                        list.add(p);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đặt phòng đang chờ xác nhận (status = Pending, booking gốc) của một khách,
     * kèm tổng tiền cả nhóm (booking cha + các booking con đặt kèm) để tính tiền cọc.
     * overallTotalAmount được gán = tổng nhóm.
     */
    public List<Booking> getPendingBookingsByAccount(int accountId) {
        List<Booking> list = new ArrayList<>();
        // Chỉ lấy dòng CHA (group_booking_id IS NULL) -> mỗi đơn đúng MỘT dòng cọc, số
        // tiền là 30% tổng CẢ NHÓM. Các cột dẫn xuất phải gom cả nhóm cho khớp:
        //   overall_total          - tổng tiền phòng của cả nhóm
        //   group_room_type_names  - mọi loại phòng trong nhóm ("test, test123"); thiếu
        //                            cột này thì cột "Loại phòng" chỉ hiện loại của dòng
        //                            cha, khách tưởng đơn chỉ có một phòng.
        // Dòng con đã Cancelled (bị gỡ khi khách đổi đặt phòng) không còn thuộc đơn nữa.
        String sql = "SELECT b.booking_id, b.customer_name, b.room_quantity, b.check_in_date, b.check_out_date, "
                + "  b.total_amount, b.status, rt.type_name, "
                + "  b.total_amount + ISNULL((SELECT SUM(c.total_amount) FROM dbo.Booking c "
                + "                           WHERE c.group_booking_id = b.booking_id "
                + "                             AND c.status <> N'Cancelled'), 0) AS overall_total, "
                + "  (SELECT STRING_AGG(dt.type_name, N', ') FROM ( "
                + "       SELECT DISTINCT srt.type_name "
                + "       FROM dbo.Booking sb "
                + "       JOIN dbo.RoomType srt ON srt.type_id = sb.room_type_id "
                + "       WHERE (sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id) "
                + "         AND sb.status <> N'Cancelled') AS dt) AS group_room_type_names, "
                + "  (SELECT SUM(sb.room_quantity) FROM dbo.Booking sb "
                + "    WHERE (sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id) "
                + "      AND sb.status <> N'Cancelled') AS total_room_quantity "
                + "FROM dbo.Booking b "
                + "LEFT JOIN dbo.RoomType rt ON rt.type_id = b.room_type_id "
                + "WHERE b.account_id = ? AND b.status = N'Pending' AND b.group_booking_id IS NULL "
                + "ORDER BY b.booking_id DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Booking b = new Booking();
                        b.setBookingId(rs.getInt("booking_id"));
                        b.setCustomerName(rs.getString("customer_name"));
                        b.setRoomQuantity(rs.getInt("room_quantity"));
                        b.setCheckInDate(rs.getDate("check_in_date"));
                        b.setCheckOutDate(rs.getDate("check_out_date"));
                        b.setTotalAmount(rs.getDouble("total_amount"));
                        b.setStatus(rs.getString("status"));
                        b.setRoomTypeName(rs.getString("type_name"));
                        b.setOverallTotalAmount(rs.getDouble("overall_total"));
                        b.setGroupRoomTypeNames(rs.getString("group_room_type_names"));
                        b.setTotalRoomQuantity(rs.getInt("total_room_quantity"));
                        list.add(b);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy một đặt phòng gốc theo id, ràng buộc chủ sở hữu (cho trang QR tiền cọc).
     * Trả về null nếu không tồn tại / không thuộc về khách / là booking con.
     */
    public Booking getBookingForCustomer(int bookingId, int accountId) {
        // Các cột dẫn xuất gom cả nhóm, khớp với getPendingBookingsByAccount: trang QR
        // phải hiện đúng những gì bảng "Đặt phòng chờ thanh toán cọc" đã hiện.
        String sql = "SELECT b.booking_id, b.customer_name, b.room_quantity, b.check_in_date, b.check_out_date, "
                + "  b.total_amount, b.status, rt.type_name, "
                + "  b.total_amount + ISNULL((SELECT SUM(c.total_amount) FROM dbo.Booking c "
                + "                           WHERE c.group_booking_id = b.booking_id "
                + "                             AND c.status <> N'Cancelled'), 0) AS overall_total, "
                + "  (SELECT STRING_AGG(dt.type_name, N', ') FROM ( "
                + "       SELECT DISTINCT srt.type_name "
                + "       FROM dbo.Booking sb "
                + "       JOIN dbo.RoomType srt ON srt.type_id = sb.room_type_id "
                + "       WHERE (sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id) "
                + "         AND sb.status <> N'Cancelled') AS dt) AS group_room_type_names, "
                + "  (SELECT SUM(sb.room_quantity) FROM dbo.Booking sb "
                + "    WHERE (sb.booking_id = b.booking_id OR sb.group_booking_id = b.booking_id) "
                + "      AND sb.status <> N'Cancelled') AS total_room_quantity "
                + "FROM dbo.Booking b "
                + "LEFT JOIN dbo.RoomType rt ON rt.type_id = b.room_type_id "
                + "WHERE b.booking_id = ? AND b.account_id = ? AND b.group_booking_id IS NULL";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Booking b = new Booking();
                        b.setBookingId(rs.getInt("booking_id"));
                        b.setCustomerName(rs.getString("customer_name"));
                        b.setRoomQuantity(rs.getInt("room_quantity"));
                        b.setCheckInDate(rs.getDate("check_in_date"));
                        b.setCheckOutDate(rs.getDate("check_out_date"));
                        b.setTotalAmount(rs.getDouble("total_amount"));
                        b.setStatus(rs.getString("status"));
                        b.setRoomTypeName(rs.getString("type_name"));
                        b.setOverallTotalAmount(rs.getDouble("overall_total"));
                        b.setGroupRoomTypeNames(rs.getString("group_room_type_names"));
                        b.setTotalRoomQuantity(rs.getInt("total_room_quantity"));
                        return b;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Đơn còn hiệu lực ở cuối chuỗi thay thế bắt đầu từ {@code bookingId}.
     * <p>
     * Khi lễ tân duyệt một yêu cầu thay đổi, đơn cũ bị huỷ và một đơn mới ra
     * đời, nên mã đơn của khách thay đổi. Mã QR đặt cọc ({@code COC<id>}) mà
     * khách đã lưu vẫn mang id cũ, và tiền chuyển trễ phải chảy về đơn đang
     * thực sự có hiệu lực chứ không phải đơn đã huỷ. Khách có thể đổi nhiều lần
     * nên phải đi hết chuỗi.
     *
     * @return id đơn đích, hoặc null nếu {@code bookingId} không tồn tại
     */
    public Integer resolveActiveBookingId(int bookingId) {
        // depth < 20 và MAXRECURSION 20 là hai lớp chặn độc lập: nếu dữ liệu
        // hỏng tạo thành vòng lặp thì truy vấn dừng chứ không treo connection.
        String sql = "WITH chain AS ("
                + "    SELECT booking_id, replaced_by_booking_id, 0 AS depth "
                + "    FROM dbo.Booking WHERE booking_id = ? "
                + "    UNION ALL "
                + "    SELECT b.booking_id, b.replaced_by_booking_id, c.depth + 1 "
                + "    FROM dbo.Booking b "
                + "    JOIN chain c ON b.booking_id = c.replaced_by_booking_id "
                + "    WHERE c.depth < 20"
                + ") "
                + "SELECT TOP 1 booking_id FROM chain ORDER BY depth DESC "
                + "OPTION (MAXRECURSION 20)";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Booking tồn tại? (cho webhook — không ràng buộc account) */
    public Integer getBookingIdIfExists(int bookingId) {
        String sql = "SELECT booking_id FROM dbo.Booking WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
