package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.AccountRow;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.BookingRow;

import java.sql.Connection;
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
 * AdminDashboardDAO
 * Truy vấn số liệu giám sát toàn hệ thống cho Bảng điều khiển của Admin (UC 2.7.4):
 * thống kê tài khoản, đặt phòng theo trạng thái, chuỗi doanh thu / lượt đặt phòng
 * theo thời gian (gom nhóm ngày / tháng / quý) và các danh sách chi tiết phân trang.
 *
 * CHUẨN GHI NHẬN DOANH THU (dùng chung với trang Tổng quan của Manager —
 * xem DashboardDAO): doanh thu chỉ tính các đơn đã ghi nhận
 * (Confirmed / CheckedIn / CheckedOut) và được RẢI ĐỀU THEO TỪNG ĐÊM LƯU TRÚ,
 * mỗi đơn chỉ đóng góp phần số đêm nằm trong khoảng lọc. Đơn được chọn theo
 * điều kiện kỳ lưu trú giao với khoảng lọc, không theo created_at.
 *
 * Ngược lại, các chỉ số ĐO HOẠT ĐỘNG ĐẶT PHÒNG (lượt đặt phòng, phân bổ trạng
 * thái) vẫn lọc theo ngày tạo đơn (created_at) vì chúng đo hành vi đặt phòng
 * chứ không phải doanh thu.
 *
 * @author QuyPQ
 * Date: 08/07/2006
 * Version: 2.0
 */
public class AdminDashboardDAO {

    /** Các trạng thái được tính vào doanh thu. */
    private static final String REVENUE_STATUS_IN =
            "b.status IN (N'Confirmed', N'CheckedIn', N'CheckedOut')";

    /** Điều kiện kỳ lưu trú [check_in, check_out) giao với khoảng [?, ?] = [to, from]. */
    private static final String STAY_OVERLAPS =
            "b.check_in_date <= ? AND b.check_out_date > ?";

    /**
     * Loại các đơn được sinh ra để THAY THẾ một đơn cũ (khi lễ tân duyệt yêu
     * cầu thay đổi đặt phòng). Chúng không phải lượt đặt phòng mới của khách,
     * chỉ là hình thức kỹ thuật để áp thay đổi — đếm vào sẽ thổi mọi chỉ số đo
     * hoạt động đặt phòng lên mỗi lần có khách đổi đơn.
     */
    private static final String NOT_A_REPLACEMENT = "b.replaces_booking_id IS NULL";

    /** Mức gom nhóm chuỗi thời gian (xem AdminDashboardService.granularityFor). */
    public static final String GRAN_DAY = "day";
    public static final String GRAN_MONTH = "month";
    public static final String GRAN_QUARTER = "quarter";

    public AdminDashboardDAO() {
        // Các truy vấn dưới đây tham chiếu thẳng replaces_booking_id.
        BookingDAO.ensureChangeTrackingColumns();
    }

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /* =====================================================================
       KPI TÀI KHOẢN
       ===================================================================== */

    /** Tổng số tài khoản trong hệ thống. */
    public int getTotalAccounts() {
        return scalarCount("SELECT COUNT(*) FROM dbo.Account");
    }

    /** Số tài khoản đang hoạt động (is_active = 1). */
    public int getActiveAccounts() {
        return scalarCount("SELECT COUNT(*) FROM dbo.Account WHERE is_active = 1");
    }

    /** Số tài khoản bị khóa (is_active = 0). */
    public int getLockedAccounts() {
        return scalarCount("SELECT COUNT(*) FROM dbo.Account WHERE is_active = 0");
    }

    private int scalarCount(String sql) {
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
       KPI ĐẶT PHÒNG / DOANH THU (theo khoảng lọc riêng của từng thẻ)
       ===================================================================== */

    /** Tổng số lượt đặt phòng được tạo trong khoảng [from, to]. */
    public int getBookingCount(java.sql.Date from, java.sql.Date to) {
        String sql = "SELECT COUNT(*) FROM dbo.Booking b " +
                "WHERE CAST(b.created_at AS DATE) BETWEEN ? AND ? AND " + NOT_A_REPLACEMENT;
        return countByDateRange(sql, from, to);
    }

    /**
     * Số đơn được tính doanh thu (Confirmed/CheckedIn/CheckedOut) có kỳ lưu trú
     * giao với khoảng [from, to] — cùng tập với doanh thu rải theo đêm.
     */
    public int getRevenueBookingCount(java.sql.Date from, java.sql.Date to) {
        String sql = "SELECT COUNT(*) FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN + " AND " + STAY_OVERLAPS;
        // STAY_OVERLAPS nhận tham số theo thứ tự (to, from)
        return countByDateRange(sql, to, from);
    }

    /**
     * Các kỳ lưu trú đã ghi nhận có giao với khoảng [from, to].
     * Mỗi phần tử: [check_in_date, check_out_date, total_amount].
     * Service dùng để rải doanh thu đều theo từng đêm (proration).
     */
    public List<Object[]> getStaysOverlapping(java.sql.Date from, java.sql.Date to) {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT b.check_in_date, b.check_out_date, b.total_amount " +
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

    private int countByDateRange(String sql, java.sql.Date from, java.sql.Date to) {
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
       CHUỖI THỜI GIAN (gom nhóm ngày / tháng / quý ngay trong SQL)

       Chỉ dùng cho chỉ số đo hoạt động đặt phòng — gom theo created_at.
       Chuỗi doanh thu KHÔNG đi qua đây: doanh thu được rải theo đêm lưu trú
       ở AdminDashboardService từ getStaysOverlapping().

       Khóa trả về theo dạng chuẩn để service điền 0 cho các nhóm trống:
       - day:     yyyy-MM-dd
       - month:   yyyy-MM
       - quarter: yyyy-Qn
       ===================================================================== */

    /** Số lượt đặt phòng (mọi trạng thái) theo nhóm thời gian, theo ngày tạo đơn. */
    public Map<String, Double> getBookingSeries(java.sql.Date from, java.sql.Date to, String granularity) {
        Map<String, Double> map = new LinkedHashMap<>();
        String where = "CAST(b.created_at AS DATE) BETWEEN ? AND ? AND " + NOT_A_REPLACEMENT;
        String sql;
        switch (granularity) {
            case GRAN_MONTH:
                sql = "SELECT YEAR(b.created_at) AS y, MONTH(b.created_at) AS p, COUNT(*) AS total " +
                        "FROM dbo.Booking b WHERE " + where + " " +
                        "GROUP BY YEAR(b.created_at), MONTH(b.created_at) ORDER BY y, p";
                break;
            case GRAN_QUARTER:
                sql = "SELECT YEAR(b.created_at) AS y, DATEPART(QUARTER, b.created_at) AS p, COUNT(*) AS total " +
                        "FROM dbo.Booking b WHERE " + where + " " +
                        "GROUP BY YEAR(b.created_at), DATEPART(QUARTER, b.created_at) ORDER BY y, p";
                break;
            default: // GRAN_DAY
                sql = "SELECT CAST(b.created_at AS DATE) AS d, COUNT(*) AS total " +
                        "FROM dbo.Booking b WHERE " + where + " " +
                        "GROUP BY CAST(b.created_at AS DATE) ORDER BY d";
                break;
        }
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, from);
                ps.setDate(2, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String key;
                        if (GRAN_DAY.equals(granularity)) {
                            key = rs.getDate("d").toString();
                        } else if (GRAN_MONTH.equals(granularity)) {
                            key = String.format("%04d-%02d", rs.getInt("y"), rs.getInt("p"));
                        } else {
                            key = rs.getInt("y") + "-Q" + rs.getInt("p");
                        }
                        map.put(key, rs.getDouble("total"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /* =====================================================================
       PHÂN BỔ (không theo chuỗi thời gian)
       ===================================================================== */

    /** Số lượng đặt phòng theo từng trạng thái (mọi trạng thái) trong khoảng. */
    public Map<String, Integer> getBookingStatusCounts(java.sql.Date from, java.sql.Date to) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT b.status AS st, COUNT(*) AS cnt FROM dbo.Booking b " +
                "WHERE CAST(b.created_at AS DATE) BETWEEN ? AND ? AND " + NOT_A_REPLACEMENT + " " +
                "GROUP BY b.status " +
                "ORDER BY cnt DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, from);
                ps.setDate(2, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        map.put(rs.getString("st"), rs.getInt("cnt"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Doanh thu theo loại phòng trong khoảng [from, to], mỗi đơn chỉ tính phần
     * tương ứng với số đêm lưu trú nằm trong khoảng (proration) — cùng chuẩn
     * ghi nhận với chuỗi doanh thu theo thời gian.
     * Đơn không rõ loại phòng gộp vào "Khác".
     */
    public Map<String, Double> getRevenueByRoomType(java.sql.Date from, java.sql.Date to) {
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
                        // Hai nhóm cùng hiển thị "Khác" (NULL và loại tên trùng) không xảy ra
                        // vì type_name là UNIQUE; NULL gộp thành một nhóm duy nhất.
                        map.merge(rs.getString("name"), rs.getDouble("total"), Double::sum);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Năm có đơn đặt phòng sớm nhất (dùng dựng danh sách năm cho bộ lọc). */
    public int getEarliestBookingYear() {
        String sql = "SELECT MIN(YEAR(b.created_at)) FROM dbo.Booking b";
        int year = scalarCount(sql);
        return year;
    }

    /* =====================================================================
       DANH SÁCH CHI TIẾT (phân trang, render ở backend)
       ===================================================================== */

    /** Một trang danh sách tài khoản, mới tạo trước. */
    public List<AccountRow> getAccountsPage(boolean activeOnly, int offset, int limit) {
        List<AccountRow> list = new ArrayList<>();
        String sql = "SELECT a.account_id, a.full_name, a.email, r.role_name, a.is_active, a.created_at " +
                "FROM dbo.Account a " +
                "JOIN dbo.Role r ON r.role_id = a.role_id " +
                (activeOnly ? "WHERE a.is_active = 1 " : "") +
                "ORDER BY a.created_at DESC, a.account_id DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, offset);
                ps.setInt(2, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        AccountRow row = new AccountRow();
                        row.setAccountId(rs.getInt("account_id"));
                        row.setFullName(rs.getString("full_name"));
                        row.setEmail(rs.getString("email"));
                        row.setRoleName(rs.getString("role_name"));
                        row.setActive(rs.getBoolean("is_active"));
                        Timestamp ts = rs.getTimestamp("created_at");
                        row.setCreatedAt(ts != null ? new java.util.Date(ts.getTime()) : null);
                        list.add(row);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Một trang danh sách đặt phòng tạo trong khoảng [from, to], mới tạo trước.
     * Cùng tập với thẻ KPI "Lượt đặt phòng" ({@link #getBookingCount}).
     */
    public List<BookingRow> getBookingsPage(java.sql.Date from, java.sql.Date to, int offset, int limit) {
        String sql = "SELECT b.booking_id, b.customer_name, b.check_in_date, b.check_out_date, " +
                "       b.total_amount, b.status, b.created_at " +
                "FROM dbo.Booking b " +
                "WHERE CAST(b.created_at AS DATE) BETWEEN ? AND ? AND " + NOT_A_REPLACEMENT + " " +
                "ORDER BY b.created_at DESC, b.booking_id DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        return queryBookingsPage(sql, from, to, offset, limit);
    }

    /**
     * Một trang các đơn được tính doanh thu có kỳ lưu trú giao với khoảng,
     * mới nhận phòng trước. Cùng tập với thẻ KPI "Tổng doanh thu"
     * ({@link #getRevenueBookingCount}) nên tổng số dòng luôn khớp KPI.
     */
    public List<BookingRow> getRevenueBookingsPage(java.sql.Date from, java.sql.Date to, int offset, int limit) {
        String sql = "SELECT b.booking_id, b.customer_name, b.check_in_date, b.check_out_date, " +
                "       b.total_amount, b.status, b.created_at " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN + " AND " + STAY_OVERLAPS + " " +
                "ORDER BY b.check_in_date DESC, b.booking_id DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        // STAY_OVERLAPS nhận tham số theo thứ tự (to, from)
        return queryBookingsPage(sql, to, from, offset, limit);
    }

    private List<BookingRow> queryBookingsPage(String sql, java.sql.Date p1, java.sql.Date p2,
                                               int offset, int limit) {
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
