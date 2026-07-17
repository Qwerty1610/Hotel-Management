package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Promotion;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: PromotionRepository
 *
 * Description:
 * Tầng truy cập dữ liệu cho bảng Promotion. Cung cấp các phương thức lấy
 * toàn bộ danh sách khuyến mãi, lấy theo ID, kiểm tra trùng mã khuyến mãi,
 * thêm mới, cập nhật, bật/tắt trạng thái và xóa khuyến mãi. Xóa chỉ thực
 * hiện được khi used_count = 0.
 *
 * Related Use Cases:
 * - UC-46 View Promotions
 * - UC-64 Add Promotion
 * - UC-65 Edit Promotion
 *
 * Date: 11-07-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class PromotionRepository {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /**
     * Map a ResultSet row to a Promotion object.
     */
    private Promotion mapRow(ResultSet rs) throws SQLException {
        Promotion p = new Promotion();
        p.setPromotionId(rs.getInt("PromotionID"));
        p.setPromotionCode(rs.getString("PromotionCode"));
        p.setPromotionName(rs.getString("PromotionName"));
        p.setDescription(rs.getString("Description"));
        p.setDiscountType(rs.getString("DiscountType"));
        p.setDiscountValue(rs.getBigDecimal("DiscountValue"));

        Date startDate = rs.getDate("StartDate");
        if (startDate != null) p.setStartDate(startDate.toLocalDate());

        Date endDate = rs.getDate("EndDate");
        if (endDate != null) p.setEndDate(endDate.toLocalDate());

        p.setEventName(rs.getString("EventName"));
        p.setMinBookingAmount(rs.getBigDecimal("MinBookingAmount"));
        p.setMaxDiscountAmount(rs.getBigDecimal("MaxDiscountAmount"));

        int usageLimit = rs.getInt("UsageLimit");
        if (rs.wasNull()) {
            p.setUsageLimit(null);
        } else {
            p.setUsageLimit(usageLimit);
        }

        p.setUsedCount(rs.getInt("UsedCount"));
        p.setStatus(rs.getString("Status"));

        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        if (createdAt != null) p.setCreatedAt(createdAt.toLocalDateTime());

        Timestamp updatedAt = rs.getTimestamp("UpdatedAt");
        if (updatedAt != null) p.setUpdatedAt(updatedAt.toLocalDateTime());

        return p;
    }

    /**
     * Lấy toàn bộ danh sách khuyến mãi, mới nhất trước.
     */
    public List<Promotion> getAllPromotions() {
        List<Promotion> list = new ArrayList<>();
        String sql = "SELECT PromotionID, PromotionCode, PromotionName, Description, "
                + "DiscountType, DiscountValue, StartDate, EndDate, EventName, "
                + "MinBookingAmount, MaxDiscountAmount, UsageLimit, UsedCount, "
                + "Status, CreatedAt, UpdatedAt "
                + "FROM Promotion ORDER BY PromotionID DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy một khuyến mãi theo ID.
     */
    public Promotion getPromotionById(int promotionId) {
        String sql = "SELECT PromotionID, PromotionCode, PromotionName, Description, "
                + "DiscountType, DiscountValue, StartDate, EndDate, EventName, "
                + "MinBookingAmount, MaxDiscountAmount, UsageLimit, UsedCount, "
                + "Status, CreatedAt, UpdatedAt "
                + "FROM Promotion WHERE PromotionID = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, promotionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiểm tra mã khuyến mãi có bị trùng không (bỏ qua chính nó khi update).
     *
     * @param code        Mã cần kiểm tra
     * @param excludeId   ID cần bỏ qua (truyền -1 khi thêm mới)
     */
    public boolean isCodeDuplicate(String code, int excludeId) {
        String sql = "SELECT COUNT(1) FROM Promotion WHERE PromotionCode = ? AND PromotionID != ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, code);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm mới một khuyến mãi.
     */
    public void insertPromotion(Promotion p) {
        String sql = "INSERT INTO Promotion "
                + "(PromotionCode, PromotionName, Description, DiscountType, DiscountValue, "
                + "StartDate, EndDate, EventName, MinBookingAmount, MaxDiscountAmount, "
                + "UsageLimit, UsedCount, Status, CreatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 'Active', GETDATE())";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, p.getPromotionCode());
            ps.setString(2, p.getPromotionName());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getDiscountType());
            ps.setBigDecimal(5, p.getDiscountValue());
            ps.setDate(6, Date.valueOf(p.getStartDate()));
            ps.setDate(7, Date.valueOf(p.getEndDate()));
            ps.setString(8, p.getEventName());
            ps.setBigDecimal(9, p.getMinBookingAmount());
            ps.setBigDecimal(10, p.getMaxDiscountAmount());
            if (p.getUsageLimit() != null) {
                ps.setInt(11, p.getUsageLimit());
            } else {
                ps.setNull(11, Types.INTEGER);
            }
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Cập nhật thông tin khuyến mãi.
     */
    public void updatePromotion(Promotion p) {
        String sql = "UPDATE Promotion SET "
                + "PromotionCode = ?, PromotionName = ?, Description = ?, "
                + "DiscountType = ?, DiscountValue = ?, StartDate = ?, EndDate = ?, "
                + "EventName = ?, MinBookingAmount = ?, MaxDiscountAmount = ?, "
                + "UsageLimit = ?, UpdatedAt = GETDATE() "
                + "WHERE PromotionID = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, p.getPromotionCode());
            ps.setString(2, p.getPromotionName());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getDiscountType());
            ps.setBigDecimal(5, p.getDiscountValue());
            ps.setDate(6, Date.valueOf(p.getStartDate()));
            ps.setDate(7, Date.valueOf(p.getEndDate()));
            ps.setString(8, p.getEventName());
            ps.setBigDecimal(9, p.getMinBookingAmount());
            ps.setBigDecimal(10, p.getMaxDiscountAmount());
            if (p.getUsageLimit() != null) {
                ps.setInt(11, p.getUsageLimit());
            } else {
                ps.setNull(11, Types.INTEGER);
            }
            ps.setInt(12, p.getPromotionId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Bật/Tắt trạng thái khuyến mãi (Active / Inactive).
     */
    public void togglePromotionStatus(int promotionId, String newStatus) {
        String sql = "UPDATE Promotion SET Status = ?, UpdatedAt = GETDATE() WHERE PromotionID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, newStatus);
            ps.setInt(2, promotionId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Xóa khuyến mãi. Chỉ cho phép xóa nếu UsedCount = 0.
     *
     * @return true nếu xóa thành công, false nếu đã được sử dụng
     */
    public boolean deletePromotion(int promotionId) {
        // Kiểm tra UsedCount trước
        String checkSql = "SELECT UsedCount FROM Promotion WHERE PromotionID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            useDatabase(conn);
            checkPs.setInt(1, promotionId);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    int usedCount = rs.getInt("UsedCount");
                    if (usedCount > 0) {
                        return false; // Đã được sử dụng, không cho xóa
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        // Thực hiện xóa
        String deleteSql = "DELETE FROM Promotion WHERE PromotionID = ? AND UsedCount = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(deleteSql)) {
            useDatabase(conn);
            ps.setInt(1, promotionId);
            int affected = ps.executeUpdate();
            return affected > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
