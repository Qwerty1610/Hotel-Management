package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.RecentActivity;

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
 * AdminDashboardRepository
 * Truy vấn số liệu giám sát toàn hệ thống cho Bảng điều khiển của Admin (UC 2.7.4):
 * thống kê tài khoản theo vai trò / trạng thái, đặt phòng theo trạng thái,
 * doanh thu theo ngày và các hoạt động gần đây.
 *
 * Doanh thu chỉ tính các đơn đã ghi nhận (Confirmed / CheckedIn / CheckedOut),
 * lọc theo ngày tạo đơn (created_at) để phản ánh hoạt động trong khoảng.
 *
 * @author QuyPQ
 */
public class AdminDashboardRepository {

    /** Các trạng thái được tính vào doanh thu. */
    private static final String REVENUE_STATUS_IN =
            "b.status IN (N'Confirmed', N'CheckedIn', N'CheckedOut')";

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

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

    /** Số lượng tài khoản theo từng vai trò. Key = tên vai trò. */
    public Map<String, Integer> getAccountCountsByRole() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT r.role_name AS name, COUNT(a.account_id) AS cnt " +
                "FROM dbo.Role r " +
                "LEFT JOIN dbo.Account a ON a.role_id = r.role_id " +
                "GROUP BY r.role_name " +
                "ORDER BY cnt DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("name"), rs.getInt("cnt"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Tổng số lượt đặt phòng được tạo trong khoảng [from, to]. */
    public int getBookingCount(java.sql.Date from, java.sql.Date to) {
        String sql = "SELECT COUNT(*) FROM dbo.Booking b " +
                "WHERE CAST(b.created_at AS DATE) BETWEEN ? AND ?";
        return countByDateRange(sql, from, to);
    }

    /** Tổng doanh thu ghi nhận của các đơn tạo trong khoảng [from, to]. */
    public double getTotalRevenue(java.sql.Date from, java.sql.Date to) {
        String sql = "SELECT ISNULL(SUM(b.total_amount), 0) FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND CAST(b.created_at AS DATE) BETWEEN ? AND ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, from);
                ps.setDate(2, to);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
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

    /** Số lượng đặt phòng theo từng trạng thái (mọi trạng thái) trong khoảng. */
    public Map<String, Integer> getBookingStatusCounts(java.sql.Date from, java.sql.Date to) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT b.status AS st, COUNT(*) AS cnt FROM dbo.Booking b " +
                "WHERE CAST(b.created_at AS DATE) BETWEEN ? AND ? " +
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

    /** Doanh thu ghi nhận cộng dồn theo ngày tạo đơn. Key = ngày (yyyy-MM-dd). */
    public Map<String, Double> getRevenueByDay(java.sql.Date from, java.sql.Date to) {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT CAST(b.check_in_date AS DATE) AS d, SUM(b.total_amount) AS total " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND CAST(b.check_in_date AS DATE) BETWEEN ? AND ? " +
                "GROUP BY CAST(b.check_in_date AS DATE) " +
                "ORDER BY d";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, from);
                ps.setDate(2, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        map.put(rs.getDate("d").toString(), rs.getDouble("total"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Lấy {@code limit} lượt đặt phòng mới nhất (mọi trạng thái) làm hoạt động gần đây. */
    public List<RecentActivity> getRecentBookings(int limit) {
        List<RecentActivity> list = new ArrayList<>();
        String sql = "SELECT TOP (?) b.booking_id, b.customer_name, b.status, b.total_amount, b.created_at " +
                "FROM dbo.Booking b " +
                "ORDER BY b.created_at DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        RecentActivity a = new RecentActivity();
                        a.setBookingId(rs.getInt("booking_id"));
                        a.setCustomerName(rs.getString("customer_name"));
                        a.setStatus(rs.getString("status"));
                        a.setTotalAmount(rs.getDouble("total_amount"));
                        Timestamp ts = rs.getTimestamp("created_at");
                        a.setCreatedAt(ts != null ? new java.util.Date(ts.getTime()) : null);
                        list.add(a);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
