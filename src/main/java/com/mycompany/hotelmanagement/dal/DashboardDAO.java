package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DashboardDAO
 * Truy vấn số liệu doanh thu và công suất phòng cho trang Tổng quan của Manager.
 * Mọi truy vấn doanh thu chỉ tính các đơn đã ghi nhận (Confirmed / CheckedIn / CheckedOut),
 * 
 *
 * Date: 02/6/2026
 * version 1.0
 * @author Pham Quoc Quy
 */
public class DashboardDAO {

    /** Các trạng thái được tính vào doanh thu / công suất. */
    private static final String REVENUE_STATUS_IN =
            "b.status IN (N'Confirmed', N'CheckedIn', N'CheckedOut')";

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /** Tổng số phòng vật lý của khách sạn (mẫu số khi tính công suất). */
    public int getTotalRooms() {
        String sql = "SELECT COUNT(*) FROM dbo.Room WHERE is_deleted = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Tổng doanh thu trong khoảng [from, to] (theo ngày nhận phòng). */
    public double getTotalRevenue(Date from, Date to) {
        String sql = "SELECT ISNULL(SUM(b.total_amount), 0) " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND b.check_in_date BETWEEN ? AND ?";
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

    /** Số lượt đặt phòng được ghi nhận trong khoảng. */
    public int getBookingCount(Date from, Date to) {
        String sql = "SELECT COUNT(*) " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND b.check_in_date BETWEEN ? AND ?";
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

    /** Tổng số phòng đã nhận (check-in) trong khoảng [from, to]. */
    public int getCheckInRooms(Date from, Date to) {
        String sql = "SELECT ISNULL(SUM(b.room_quantity), 0) " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND b.check_in_date BETWEEN ? AND ?";
        return countRoomsByDate(sql, from, to);
    }

    /** Tổng số phòng đã trả (check-out) trong khoảng [from, to]. */
    public int getCheckOutRooms(Date from, Date to) {
        String sql = "SELECT ISNULL(SUM(b.room_quantity), 0) " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND b.check_out_date BETWEEN ? AND ?";
        return countRoomsByDate(sql, from, to);
    }

    private int countRoomsByDate(String sql, Date from, Date to) {
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

    /** Doanh thu cộng dồn theo từng ngày nhận phòng. Key = ngày (yyyy-MM-dd). */
    public Map<String, Double> getRevenueByDay(Date from, Date to) {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT b.check_in_date AS d, SUM(b.total_amount) AS total " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND b.check_in_date BETWEEN ? AND ? " +
                "GROUP BY b.check_in_date " +
                "ORDER BY b.check_in_date";
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

    /** Doanh thu theo loại phòng. Key = tên loại phòng. */
    public Map<String, Double> getRevenueByRoomType(Date from, Date to) {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT ISNULL(rt.type_name, N'Khác') AS name, SUM(b.total_amount) AS total " +
                "FROM dbo.Booking b " +
                "LEFT JOIN dbo.RoomType rt ON b.room_type_id = rt.type_id " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND b.check_in_date BETWEEN ? AND ? " +
                "GROUP BY rt.type_name " +
                "ORDER BY total DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, from);
                ps.setDate(2, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        map.put(rs.getString("name"), rs.getDouble("total"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Số lượng đặt phòng theo từng trạng thái (mọi trạng thái) trong khoảng. */
    public Map<String, Integer> getBookingStatusCounts(Date from, Date to) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT b.status AS st, COUNT(*) AS cnt " +
                "FROM dbo.Booking b " +
                "WHERE b.check_in_date BETWEEN ? AND ? " +
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
     * Lấy các kỳ lưu trú (đã ghi nhận) có giao với khoảng [from, to],
     * phục vụ tính công suất phòng theo từng ngày.
     * Mỗi phần tử: [check_in_date, check_out_date, room_quantity].
     */
    public List<Object[]> getStaysOverlapping(Date from, Date to) {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT b.check_in_date, b.check_out_date, b.room_quantity " +
                "FROM dbo.Booking b " +
                "WHERE " + REVENUE_STATUS_IN +
                "  AND b.check_in_date <= ? " +
                "  AND b.check_out_date > ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, to);    // bắt đầu lưu trú trước/đúng cuối khoảng
                ps.setDate(2, from);  // kết thúc lưu trú sau đầu khoảng
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(new Object[]{
                            rs.getDate("check_in_date"),
                            rs.getDate("check_out_date"),
                            rs.getInt("room_quantity")
                        });
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
