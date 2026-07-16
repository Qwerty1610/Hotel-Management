package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.AmenityInfo;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * AmenityDAO
 * 
 * Lớp tương tác cơ sở dữ liệu cho Tiện nghi khách sạn.
 * Các thao tác: get, insert, update, delete, gán loại phòng.
 * 
 * Date: 10/7/2026
 * 
 * @author BinhHD
 * @version 1.1
 */

public class AmenityDAO {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    public List<AmenityInfo> getAllAmenities(boolean onlyActive) {
        List<AmenityInfo> list = new ArrayList<>();
        String sql = "SELECT amenity_id, name, icon_url, is_active FROM Amenity";
        if (onlyActive) {
            sql += " WHERE is_active = 1";
        }
        sql += " ORDER BY amenity_id";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AmenityInfo a = new AmenityInfo();
                    a.setAmenityId(rs.getInt("amenity_id"));
                    a.setName(rs.getString("name"));
                    a.setIcon(rs.getString("icon_url"));
                    a.setActive(rs.getBoolean("is_active"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insertAmenity(AmenityInfo amenity) {
        String sql = "INSERT INTO Amenity (name, icon_url, is_active) VALUES (?, ?, 1)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, amenity.getName());
            ps.setString(2, amenity.getIcon());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateAmenity(AmenityInfo amenity) {
        String sql = "UPDATE Amenity SET name = ?, icon_url = ? WHERE amenity_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setString(1, amenity.getName());
            ps.setString(2, amenity.getIcon());
            ps.setInt(3, amenity.getAmenityId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void toggleAmenityStatus(int amenityId, boolean isActive) {
        String sql = "UPDATE Amenity SET is_active = ? WHERE amenity_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setBoolean(1, isActive);
            ps.setInt(2, amenityId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Integer> getAssignedRoomTypeIds(int amenityId) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT type_id FROM RoomType_Amenity WHERE amenity_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, amenityId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("type_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void assignToRoomTypes(int amenityId, List<Integer> roomTypeIds) {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            useDatabase(conn);
            try {
                // Delete existing
                String sqlDelete = "DELETE FROM RoomType_Amenity WHERE amenity_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlDelete)) {
                    ps.setInt(1, amenityId);
                    ps.executeUpdate();
                }

                // Insert new
                if (roomTypeIds != null && !roomTypeIds.isEmpty()) {
                    String sqlInsert = "INSERT INTO RoomType_Amenity (type_id, amenity_id) VALUES (?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
                        for (int typeId : roomTypeIds) {
                            ps.setInt(1, typeId);
                            ps.setInt(2, amenityId);
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteAmenity(int amenityId) {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            useDatabase(conn);
            try {
                // Delete mapping first to avoid FK constraint violation
                String sqlDeleteMapping = "DELETE FROM RoomType_Amenity WHERE amenity_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlDeleteMapping)) {
                    ps.setInt(1, amenityId);
                    ps.executeUpdate();
                }

                // Delete amenity
                String sqlDeleteAmenity = "DELETE FROM Amenity WHERE amenity_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlDeleteAmenity)) {
                    ps.setInt(1, amenityId);
                    ps.executeUpdate();
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
