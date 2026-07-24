package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Feedback;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: FeedbackDAO
 *
 * Description:
 * Tầng truy cập dữ liệu cho bảng Feedback. Cung cấp các phương thức lấy
 * danh sách phòng đã trả kèm trạng thái đánh giá của khách hàng, kiểm tra
 * quyền đánh giá, kiểm tra đánh giá trùng lặp, tạo mới đánh giá, lấy danh
 * sách đánh giá theo loại phòng và tính điểm trung bình theo loại phòng.
 *
 * Related Use Cases:
 * - UC-35 Submit Stay Feedback
 * - UC-63 View Room Type Reviews
 *
 * Date: 11-07-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class FeedbackDAO {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /**
     * Lấy danh sách các phòng đã checkout kèm theo thông tin đánh giá (nếu có).
     * Phục vụ cho trang Feedback của khách hàng.
     */
    public List<Feedback> getCheckedOutRoomsByAccount(int accountId, String statusFilter, String keyword) {
        List<Feedback> list = new ArrayList<>();
        
        StringBuilder query = new StringBuilder(
            "SELECT b.booking_id, ra.room_id, r.room_number, rt.type_name, " +
            "b.check_in_date, b.check_out_date, co.checked_out_at, " +
            "f.feedback_id, f.rating, f.comment, f.created_at AS feedback_created_at " +
            "FROM dbo.Booking b " +
            "JOIN dbo.RoomAssignment ra ON b.booking_id = ra.booking_id " +
            "JOIN dbo.Room r ON ra.room_id = r.room_id " +
            "JOIN dbo.RoomType rt ON r.type_id = rt.type_id " +
            "JOIN dbo.CheckOut co ON b.booking_id = co.booking_id " +
            "LEFT JOIN dbo.Feedback f ON b.booking_id = f.booking_id AND ra.room_id = f.room_id " +
            "WHERE b.account_id = ? AND b.status = N'CheckedOut'"
        );

        // Lọc theo trạng thái review (whitelisted)
        if ("Reviewed".equalsIgnoreCase(statusFilter)) {
            query.append(" AND f.feedback_id IS NOT NULL");
        } else if ("NotReviewed".equalsIgnoreCase(statusFilter)) {
            query.append(" AND f.feedback_id IS NULL");
        }

        // Tìm kiếm theo từ khóa
        if (keyword != null && !keyword.trim().isEmpty()) {
            query.append(" AND (CAST(b.booking_id AS NVARCHAR(20)) LIKE ? OR r.room_number LIKE ? OR rt.type_name LIKE ?)");
        }

        query.append(" ORDER BY co.checked_out_at DESC");

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(query.toString())) {
                int paramIndex = 1;
                ps.setInt(paramIndex++, accountId);

                if (keyword != null && !keyword.trim().isEmpty()) {
                    String searchPattern = "%" + keyword.trim() + "%";
                    ps.setString(paramIndex++, searchPattern);
                    ps.setString(paramIndex++, searchPattern);
                    ps.setString(paramIndex++, searchPattern);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Feedback fb = new Feedback();
                        fb.setBookingId(rs.getInt("booking_id"));
                        fb.setRoomId(rs.getInt("room_id"));
                        fb.setRoomNumber(rs.getString("room_number"));
                        fb.setRoomTypeName(rs.getString("type_name"));
                        fb.setCheckInDate(rs.getDate("check_in_date"));
                        fb.setCheckOutDate(rs.getDate("check_out_date"));
                        fb.setCheckedOutAt(rs.getTimestamp("checked_out_at"));
                        
                        int feedbackId = rs.getInt("feedback_id");
                        if (!rs.wasNull()) {
                            fb.setFeedbackId(feedbackId);
                            fb.setRating(rs.getInt("rating"));
                            fb.setComment(rs.getString("comment"));
                            fb.setCreatedAt(rs.getTimestamp("feedback_created_at"));
                            fb.setReviewed(true);
                        } else {
                            fb.setReviewed(false);
                        }
                        list.add(fb);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiểm tra xem đã tồn tại feedback cho booking_id + room_id chưa.
     */
    public boolean existsFeedback(int bookingId, int roomId) {
        String sql = "SELECT 1 FROM dbo.Feedback WHERE booking_id = ? AND room_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, roomId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra xem phòng có được gán cho booking của accountId và đã checkout hoàn tất chưa.
     */
    public boolean isBookingRoomAssignedAndCheckedOut(int bookingId, int roomId, int accountId) {
        String sql = "SELECT 1 FROM dbo.Booking b " +
                     "JOIN dbo.RoomAssignment ra ON b.booking_id = ra.booking_id " +
                     "JOIN dbo.CheckOut co ON b.booking_id = co.booking_id " +
                     "WHERE b.booking_id = ? AND ra.room_id = ? AND b.account_id = ? AND b.status = N'CheckedOut'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, roomId);
                ps.setInt(3, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm feedback mới vào cơ sở dữ liệu.
     */
    public boolean createFeedback(Feedback feedback) {
        String sql = "INSERT INTO dbo.Feedback (booking_id, room_id, account_id, rating, comment, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, SYSDATETIME())";
                     
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, feedback.getBookingId());
                ps.setInt(2, feedback.getRoomId());
                ps.setInt(3, feedback.getAccountId());
                ps.setInt(4, feedback.getRating());
                
                if (feedback.getComment() != null) {
                    ps.setString(5, feedback.getComment());
                } else {
                    ps.setNull(5, java.sql.Types.NVARCHAR);
                }
                
                int affectedRows = ps.executeUpdate();
                return affectedRows > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách tối đa 10 feedback mới nhất thuộc loại phòng roomTypeId.
     */
    public List<Feedback> getFeedbacksByRoomTypeId(int roomTypeId) {
        List<Feedback> list = new java.util.ArrayList<>();
        String sql = "SELECT TOP 10 f.feedback_id, f.booking_id, f.room_id, f.account_id, f.rating, f.comment, f.created_at, " +
                     "r.room_number, a.full_name AS customer_name " +
                     "FROM dbo.Feedback f " +
                     "JOIN dbo.Room r ON f.room_id = r.room_id " +
                     "JOIN dbo.Account a ON f.account_id = a.account_id " +
                     "WHERE r.type_id = ? " +
                     "ORDER BY f.created_at DESC";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, roomTypeId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Feedback fb = new Feedback();
                        fb.setFeedbackId(rs.getInt("feedback_id"));
                        fb.setBookingId(rs.getInt("booking_id"));
                        fb.setRoomId(rs.getInt("room_id"));
                        fb.setAccountId(rs.getInt("account_id"));
                        fb.setRating(rs.getInt("rating"));
                        fb.setComment(rs.getString("comment"));
                        fb.setCreatedAt(rs.getTimestamp("created_at"));
                        fb.setRoomNumber(rs.getString("room_number"));
                        
                        String customerName = rs.getString("customer_name");
                        if (customerName == null || customerName.trim().isEmpty()) {
                            customerName = "Khách hàng";
                        }
                        fb.setCustomerName(customerName);
                        
                        list.add(fb);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thống kê feedback của một loại phòng (tổng lượt đánh giá và điểm trung bình).
     */
    public double[] getFeedbackStatsByRoomTypeId(int roomTypeId) {
        double[] stats = new double[]{0.0, 0.0}; // [totalReviews, averageRating]
        String sql = "SELECT COUNT(*) AS total_count, AVG(CAST(rating AS DECIMAL(5,2))) AS avg_rating " +
                     "FROM dbo.Feedback f " +
                     "JOIN dbo.Room r ON f.room_id = r.room_id " +
                     "WHERE r.type_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, roomTypeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats[0] = rs.getDouble("total_count");
                        stats[1] = rs.getDouble("avg_rating");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
}
