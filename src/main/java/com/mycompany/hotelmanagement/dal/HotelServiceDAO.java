package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.HotelService;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: HotelServiceDAO
 *
 * Description:
 * Tầng truy cập dữ liệu cho bảng HotelService. Cung cấp các phương thức
 * lấy toàn bộ danh sách dịch vụ, thêm mới, cập nhật, bật/tắt trạng thái
 * hoạt động (is_active) và xóa dịch vụ.
 *
 * Related Use Cases:
 * - UC-08 View Available Services
 * - UC-59 View Service Records
 * - UC-60 Add Service
 * - UC-61 Edit Service
 *
 * Date: 01-06-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class HotelServiceDAO {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    public java.util.Set<Integer> getUsedServiceIds() {
        java.util.Set<Integer> usedIds = new java.util.HashSet<>();
        String sql = "SELECT DISTINCT service_id FROM dbo.BookingServiceRequest WHERE status NOT IN (N'Cancelled', N'Rejected', 'Cancelled', 'Rejected')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    usedIds.add(rs.getInt("service_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return usedIds;
    }

    public List<HotelService> getAllServices() {
        List<HotelService> list = new ArrayList<>();
        String sql = "SELECT service_id, service_name, description, price, unit, is_active FROM HotelService ORDER BY service_id";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HotelService hs = new HotelService();
                    hs.setServiceId(rs.getInt("service_id"));
                    hs.setServiceName(rs.getString("service_name"));
                    hs.setDescription(rs.getString("description"));
                    hs.setPrice(rs.getDouble("price"));
                    hs.setUnit(rs.getString("unit"));
                    hs.setIsActive(rs.getBoolean("is_active"));
                    list.add(hs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private static final java.util.logging.Logger LOGGER = java.util.logging.Logger.getLogger(HotelServiceDAO.class.getName());

    public boolean deleteService(int serviceId) {
        String deleteRequestsSql = "DELETE FROM dbo.BookingServiceRequest WHERE service_id = ? AND status IN (N'Cancelled', N'Rejected', 'Cancelled', 'Rejected')";
        String deleteServiceSql = "DELETE FROM HotelService WHERE service_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement psReq = conn.prepareStatement(deleteRequestsSql)) {
                psReq.setInt(1, serviceId);
                psReq.executeUpdate();
            }
            try (PreparedStatement psService = conn.prepareStatement(deleteServiceSql)) {
                psService.setInt(1, serviceId);
                return psService.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error deleting hotel service " + serviceId, e);
            return false;
        }
    }

    public boolean toggleServiceStatus(int serviceId, boolean isActive) {
        String sql = "UPDATE HotelService SET is_active = ?, updated_at = SYSDATETIME() WHERE service_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setBoolean(1, isActive);
            ps.setInt(2, serviceId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error toggling status for service " + serviceId, e);
            return false;
        }
    }

    public boolean insertService(HotelService hs) {
        String sql = "INSERT INTO HotelService (service_name, description, price, unit, is_active) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, hs.getServiceName());
            ps.setString(2, hs.getDescription());
            ps.setDouble(3, hs.getPrice());
            ps.setString(4, hs.getUnit());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error inserting service", e);
            return false;
        }
    }

    public boolean updateService(HotelService hs) {
        String sql = "UPDATE HotelService SET service_name = ?, description = ?, price = ?, unit = ?, updated_at = SYSDATETIME() WHERE service_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, hs.getServiceName());
            ps.setString(2, hs.getDescription());
            ps.setDouble(3, hs.getPrice());
            ps.setString(4, hs.getUnit());
            ps.setInt(5, hs.getServiceId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error updating service " + hs.getServiceId(), e);
            return false;
        }
    }

    public List<HotelService> getActiveServices() {
        List<HotelService> list = new ArrayList<>();

        String sql = """
        SELECT service_id,
               service_name,
               description,
               price,
               unit,
               is_active
        FROM HotelService
        WHERE is_active = 1
        ORDER BY service_id
    """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            useDatabase(conn);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HotelService hs = new HotelService();

                    hs.setServiceId(rs.getInt("service_id"));
                    hs.setServiceName(rs.getString("service_name"));
                    hs.setDescription(rs.getString("description"));
                    hs.setPrice(rs.getDouble("price"));
                    hs.setUnit(rs.getString("unit"));
                    hs.setIsActive(rs.getBoolean("is_active"));

                    list.add(hs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
