package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Promotion;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: PromotionDAO
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
public class PromotionDAO {

    private static final java.util.logging.Logger LOGGER = java.util.logging.Logger.getLogger(PromotionDAO.class.getName());

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
            LOGGER.log(java.util.logging.Level.SEVERE, "Error fetching promotions", e);
        }
        return list;
    }

    /**
     * Lấy một khuyến mãi theo PromotionID.
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
            LOGGER.log(java.util.logging.Level.SEVERE, "Error fetching promotion by ID: " + promotionId, e);
        }
        return null;
    }

    /**
     * Lấy một khuyến mãi theo mã Code.
     */
    public Promotion getPromotionByCode(String code) {
        String sql = "SELECT PromotionID, PromotionCode, PromotionName, Description, "
                + "DiscountType, DiscountValue, StartDate, EndDate, EventName, "
                + "MinBookingAmount, MaxDiscountAmount, UsageLimit, UsedCount, "
                + "Status, CreatedAt, UpdatedAt "
                + "FROM Promotion WHERE PromotionCode = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error fetching promotion by code: " + code, e);
        }
        return null;
    }

    /**
     * Tăng số lượng đã sử dụng (UsedCount) của khuyến mãi lên 1.
     */
    public boolean incrementUsedCount(int promotionId) {
        String sql = "UPDATE Promotion SET UsedCount = UsedCount + 1, UpdatedAt = GETDATE() WHERE PromotionID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, promotionId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error incrementing used count for promotion " + promotionId, e);
            return false;
        }
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
            LOGGER.log(java.util.logging.Level.SEVERE, "Error checking duplicate code: " + code, e);
        }
        return false;
    }

    /**
     * Thêm mới một khuyến mãi.
     */
    public boolean insertPromotion(Promotion p) {
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
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error inserting promotion", e);
            return false;
        }
    }

    /**
     * Cập nhật thông tin khuyến mãi (không thay đổi UsedCount).
     */
    public boolean updatePromotion(Promotion p) {
        if (p.getPromotionId() > 0 && p.getUsageLimit() != null) {
            Promotion existing = getPromotionById(p.getPromotionId());
            if (existing != null && p.getUsageLimit() < existing.getUsedCount()) {
                LOGGER.warning("Block update for promotion ID " + p.getPromotionId() + ": usageLimit (" + p.getUsageLimit() + ") < usedCount (" + existing.getUsedCount() + ")");
                return false;
            }
        }
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
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error updating promotion " + p.getPromotionId(), e);
            return false;
        }
    }

    /**
     * Bật/Tắt trạng thái khuyến mãi (Active / Inactive).
     */
    public boolean togglePromotionStatus(int promotionId, String newStatus) {
        String sql = "UPDATE Promotion SET Status = ?, UpdatedAt = GETDATE() WHERE PromotionID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, newStatus);
            ps.setInt(2, promotionId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error toggling status for promotion " + promotionId, e);
            return false;
        }
    }

    /**
     * Xóa khuyến mãi. Chỉ cho phép xóa khi UsedCount = 0.
     * Kiểm tra bắt buộc ở phía Server.
     *
     * @return true nếu xóa thành công, false nếu UsedCount > 0 hoặc không tìm thấy hoặc có lỗi DB
     */
    public boolean deletePromotion(int promotionId) {
        String checkSql = "SELECT UsedCount FROM Promotion WHERE PromotionID = ?";
        String deleteSql = "DELETE FROM Promotion WHERE PromotionID = ? AND UsedCount = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            useDatabase(conn);
            psCheck.setInt(1, promotionId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    int usedCount = rs.getInt("UsedCount");
                    if (usedCount > 0) {
                        LOGGER.warning("Block delete for promotion ID " + promotionId + " because UsedCount = " + usedCount);
                        return false;
                    }
                } else {
                    return false; // Not found
                }
            }

            try (PreparedStatement psDelete = conn.prepareStatement(deleteSql)) {
                psDelete.setInt(1, promotionId);
                int affected = psDelete.executeUpdate();
                return affected > 0;
            }
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error deleting promotion " + promotionId, e);
            return false;
        }
    }
}
