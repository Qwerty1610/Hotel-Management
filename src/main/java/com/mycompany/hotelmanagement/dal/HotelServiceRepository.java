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

public class HotelServiceRepository {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    public List<HotelService> getAllServices() {
        List<HotelService> list = new ArrayList<>();
        String sql = "SELECT service_id, service_name, description, price, unit, is_active FROM HotelService ORDER BY service_id";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public void deleteService(int serviceId) {
        String sql = "DELETE FROM HotelService WHERE service_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, serviceId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void toggleServiceStatus(int serviceId, boolean isActive) {
        String sql = "UPDATE HotelService SET is_active = ?, updated_at = SYSDATETIME() WHERE service_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setBoolean(1, isActive);
            ps.setInt(2, serviceId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void insertService(HotelService hs) {
        String sql = "INSERT INTO HotelService (service_name, description, price, unit, is_active) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, hs.getServiceName());
            ps.setString(2, hs.getDescription());
            ps.setDouble(3, hs.getPrice());
            ps.setString(4, hs.getUnit());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateService(HotelService hs) {
        String sql = "UPDATE HotelService SET service_name = ?, description = ?, price = ?, unit = ?, updated_at = SYSDATETIME() WHERE service_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, hs.getServiceName());
            ps.setString(2, hs.getDescription());
            ps.setDouble(3, hs.getPrice());
            ps.setString(4, hs.getUnit());
            ps.setInt(5, hs.getServiceId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Lấy thông tin một dịch vụ theo service_id.
     * Dùng trong ReceptionistRequestController để lấy tên và giá tiền
     * khi tự động thêm dịch vụ đã approve vào InvoiceItem.
     *
     * @param serviceId ID dịch vụ cần tìm
     * @return HotelService nếu tìm thấy, null nếu không
     */
    public HotelService getById(int serviceId) {
        String sql = "SELECT service_id, service_name, description, price, unit, is_active FROM HotelService WHERE service_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HotelService hs = new HotelService();
                    hs.setServiceId(rs.getInt("service_id"));
                    hs.setServiceName(rs.getString("service_name"));
                    hs.setDescription(rs.getString("description"));
                    hs.setPrice(rs.getDouble("price"));
                    hs.setUnit(rs.getString("unit"));
                    hs.setIsActive(rs.getBoolean("is_active"));
                    return hs;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
