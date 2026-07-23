package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.DashboardStats.ServiceRow;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.BookingRow;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DashboardDAO
 * Truy vấn số liệu cho trang Tổng quan của Manager: các kỳ lưu trú (để tính
 * doanh thu rải theo đêm, công suất, RevPAR, ADR), tỷ lệ hủy, doanh thu theo
 * loại phòng (đã prorate theo phần đêm thuộc khoảng lọc), cơ cấu doanh thu
 * theo hóa đơn, top dịch vụ và các danh sách chi tiết phân trang.
 *
 * Mọi truy vấn doanh thu chỉ tính các đơn đã ghi nhận
 * (Confirmed / CheckedIn / CheckedOut).
 *
 * Date: 22/07/2026
 * version 2.0
 * @author Pham Quoc Quy
 */
public class DashboardDAO {

    /** Các trạng thái được tính vào doanh thu / công suất. */
    private static final String REVENUE_STATUS_IN =
            "b.status IN (N'Confirmed', N'CheckedIn', N'CheckedOut')";

    /** Các trạng thái được tính là hủy khi đo tỷ lệ hủy. */
    private static final String CANCELLED_STATUS_IN =
            "b.status IN (N'Cancelled', N'Rejected')";

    /** Điều kiện kỳ lưu trú [check_in, check_out) giao với khoảng [?, ?] = [to, from]. */
    private static final String STAY_OVERLAPS =
            "b.check_in_date <= ? AND b.check_out_date > ?";

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /** Tổng số phòng vật lý của khách sạn (mẫu số khi tính công suất / RevPAR). */
    public int getTotalRooms() {
        return scalarInt("SELECT COUNT(*) FROM dbo.Room WHERE is_deleted = 0");
    }

    /** Năm có đơn đặt phòng sớm nhất (dựng danh sách năm cho bộ lọc kỳ). */
    public int getEarliestBookingYear() {
        return scalarInt("SELECT MIN(YEAR(b.created_at)) FROM dbo.Booking b");
    }

    private int scalarInt(String sql) {
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* =====================================================================
       KỲ LƯU TRÚ — nguồn tính doanh thu rải theo đêm + công suất
       ===================================================================== */

    /**
     * Các kỳ lưu trú đã ghi nhận có giao với khoảng [from, to].
     * Mỗi phần tử: [check_in_date, check_out_date, room_quantity, total_amount].
     * Service dùng chung cho: doanh thu theo ngày (rải đều mỗi đêm),
     * công suất theo ngày, tổng phòng-đêm đã bán, RevPAR và ADR.
     */
    public List<Object[]> getStaysOverlapping(Date from, Date to) {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT b.check_in_date, b.check_out_date, b.room_quantity, b.total_amount " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN + " AND " + STAY_OVERLAPS;
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, to);
                ps.setDate(2, from);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(new Object[]{
                            rs.getDate("check_in_date"),
                            rs.getDate("check_out_date"),
                            rs.getInt("room_quantity"),
                            rs.getDouble("total_amount")
                        });
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /* =====================================================================
       KPI TỶ LỆ HỦY (theo ngày tạo đơn)
       ===================================================================== */

    /** Tổng số đơn (mọi trạng thái) được tạo trong khoảng [from, to]. */
    public int getCreatedBookingCount(Date from, Date to) {
        String sql = "SELECT COUNT(*) FROM dbo.Booking b " +
                "WHERE CAST(b.created_at AS DATE) BETWEEN ? AND ?";
        return countByRange(sql, from, to);
    }

    /** Số đơn Cancelled / Rejected được tạo trong khoảng [from, to]. */
    public int getCancelledBookingCount(Date from, Date to) {
        String sql = "SELECT COUNT(*) FROM dbo.Booking b " +
                "WHERE " + CANCELLED_STATUS_IN +
                "  AND CAST(b.created_at AS DATE) BETWEEN ? AND ?";
        return countByRange(sql, from, to);
    }

    /** Số đơn được tính doanh thu có kỳ lưu trú giao với khoảng [from, to]. */
    public int getRevenueBookingCount(Date from, Date to) {
        String sql = "SELECT COUNT(*) FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN + " AND " + STAY_OVERLAPS;
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, to);
                ps.setDate(2, from);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int countByRange(String sql, Date from, Date to) {
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, from);
                ps.setDate(2, to);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* =====================================================================
       PHÂN BỔ DOANH THU
       ===================================================================== */

    /**
     * Doanh thu theo loại phòng trong khoảng [from, to], mỗi đơn chỉ tính
     * phần tương ứng với số đêm lưu trú nằm trong khoảng (proration).
     * Key = tên loại phòng, sắp giảm dần theo doanh thu.
     */
    public Map<String, Double> getRevenueByRoomType(Date from, Date to) {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT ISNULL(rt.type_name, N'Khác') AS name, " +
                "SUM(b.total_amount * " +
                "    CAST(DATEDIFF(DAY, " +
                "        CASE WHEN b.check_in_date > ? THEN b.check_in_date ELSE ? END, " +
                "        CASE WHEN b.check_out_date < DATEADD(DAY, 1, ?) THEN b.check_out_date ELSE DATEADD(DAY, 1, ?) END) AS FLOAT) " +
                "    / NULLIF(DATEDIFF(DAY, b.check_in_date, b.check_out_date), 0)) AS total " +
                "FROM dbo.Booking b " +
                "LEFT JOIN dbo.RoomType rt ON rt.type_id = b.room_type_id " +
                "WHERE " + REVENUE_STATUS_IN + " AND " + STAY_OVERLAPS + " " +
                "GROUP BY rt.type_name " +
                "ORDER BY total DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, from);
                ps.setDate(2, from);
                ps.setDate(3, to);
                ps.setDate(4, to);
                ps.setDate(5, to);
                ps.setDate(6, from);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        map.merge(rs.getString("name"), rs.getDouble("total"), Double::sum);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Cơ cấu doanh thu theo dòng hóa đơn (Room / Service / Surcharge)
     * của các hóa đơn không bị hủy, tạo trong khoảng [from, to].
     * Key = item_type gốc trong DB.
     */
    public Map<String, Double> getInvoiceRevenueMix(Date from, Date to) {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT ii.item_type AS t, SUM(ii.amount) AS total " +
                "FROM dbo.InvoiceItem ii " +
                "JOIN dbo.Invoice i ON i.invoice_id = ii.invoice_id " +
                "WHERE i.status <> N'Cancelled' " +
                "  AND CAST(i.created_at AS DATE) BETWEEN ? AND ? " +
                "GROUP BY ii.item_type " +
                "ORDER BY total DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, from);
                ps.setDate(2, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        map.put(rs.getString("t"), rs.getDouble("total"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Top dịch vụ theo doanh thu ước tính (số lượng đã hoàn thành × đơn giá hiện hành)
     * trong khoảng [from, to] theo ngày tạo yêu cầu.
     */
    public List<ServiceRow> getTopServices(Date from, Date to, int limit) {
        List<ServiceRow> list = new ArrayList<>();
        String sql = "SELECT TOP (?) hs.service_name, " +
                "       SUM(r.quantity) AS qty, SUM(r.quantity * hs.price) AS total " +
                "FROM dbo.BookingServiceRequest r " +
                "JOIN dbo.HotelService hs ON hs.service_id = r.service_id " +
                "WHERE r.status = N'Completed' " +
                "  AND CAST(r.created_at AS DATE) BETWEEN ? AND ? " +
                "GROUP BY hs.service_name " +
                "ORDER BY total DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, limit);
                ps.setDate(2, from);
                ps.setDate(3, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ServiceRow row = new ServiceRow();
                        row.setServiceName(rs.getString("service_name"));
                        row.setQuantity(rs.getInt("qty"));
                        row.setRevenue(rs.getDouble("total"));
                        list.add(row);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /* =====================================================================
       DANH SÁCH CHI TIẾT (phân trang, render ở backend)
       ===================================================================== */

    /** Một trang các đơn được tính doanh thu có lưu trú giao với khoảng, mới nhận phòng trước. */
    public List<BookingRow> getRevenueBookingsPage(Date from, Date to, int offset, int limit) {
        String sql = "SELECT b.booking_id, b.customer_name, b.check_in_date, b.check_out_date, " +
                "       b.total_amount, b.status, b.created_at, b.note " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN + " AND " + STAY_OVERLAPS + " " +
                "ORDER BY b.check_in_date DESC, b.booking_id DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        return queryBookingsPage(sql, to, from, offset, limit);
    }

    /** Số đơn hủy / từ chối tạo trong khoảng — dùng cho phân trang danh sách hủy. */
    public List<BookingRow> getCancelledBookingsPage(Date from, Date to, int offset, int limit) {
        String sql = "SELECT b.booking_id, b.customer_name, b.check_in_date, b.check_out_date, " +
                "       b.total_amount, b.status, b.created_at, b.note " +
                "FROM dbo.Booking b " +
                "WHERE " + CANCELLED_STATUS_IN +
                "  AND CAST(b.created_at AS DATE) BETWEEN ? AND ? " +
                "ORDER BY b.created_at DESC, b.booking_id DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        return queryBookingsPage(sql, from, to, offset, limit);
    }

    private List<BookingRow> queryBookingsPage(String sql, Date p1, Date p2, int offset, int limit) {
        List<BookingRow> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, p1);
                ps.setDate(2, p2);
                ps.setInt(3, offset);
                ps.setInt(4, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        BookingRow row = new BookingRow();
                        row.setBookingId(rs.getInt("booking_id"));
                        row.setCustomerName(rs.getString("customer_name"));
                        row.setCheckInDate(rs.getDate("check_in_date"));
                        row.setCheckOutDate(rs.getDate("check_out_date"));
                        row.setTotalAmount(rs.getDouble("total_amount"));
                        row.setStatus(rs.getString("status"));
                        Timestamp ts = rs.getTimestamp("created_at");
                        row.setCreatedAt(ts != null ? new java.util.Date(ts.getTime()) : null);
                        row.setNote(rs.getString("note"));
                        list.add(row);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
