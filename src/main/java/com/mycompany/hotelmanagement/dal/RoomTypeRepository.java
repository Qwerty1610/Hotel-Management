package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.AmenityInfo;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoomTypeRepository {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    public Map<Integer, List<String>> getAllRoomImages() {
        Map<Integer, List<String>> typeImages = new HashMap<>();
        String sql = "SELECT type_id, image_url FROM RoomImage";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            useDatabase(conn);
            while (rs.next()) {
                int tId = rs.getInt("type_id");
                String url = rs.getString("image_url");
                typeImages.computeIfAbsent(tId, k -> new ArrayList<>()).add(url);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return typeImages;
    }

    public List<String> getRoomImagesByTypeId(int typeId) {
        List<String> imageUrls = new ArrayList<>();
        String sql = "SELECT image_url FROM RoomImage WHERE type_id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    imageUrls.add(rs.getString("image_url"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return imageUrls;
    }

    public Map<Integer, List<String>> getAllRoomAmenities() {
        Map<Integer, List<String>> typeAmenities = new HashMap<>();
        String sql = "SELECT ra.type_id, a.name FROM Amenity a JOIN RoomType_Amenity ra ON a.amenity_id = ra.amenity_id";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            useDatabase(conn);
            while (rs.next()) {
                int tId = rs.getInt("type_id");
                String name = rs.getString("name");
                typeAmenities.computeIfAbsent(tId, k -> new ArrayList<>()).add(name);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return typeAmenities;
    }

    public List<AmenityInfo> getAmenityDetailsByTypeId(int typeId) {
        List<AmenityInfo> amenityDetails = new ArrayList<>();
        String sql = "SELECT a.name, a.icon_url FROM Amenity a JOIN RoomType_Amenity ra ON a.amenity_id = ra.amenity_id WHERE ra.type_id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("name");
                    String icon = rs.getString("icon_url");
                    amenityDetails.add(new AmenityInfo(name, icon));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return amenityDetails;
    }

    public List<RoomTypeInfo> getAllRoomTypes() {
        List<RoomTypeInfo> list = new ArrayList<>();
        String sql = "SELECT type_id, type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type FROM RoomType ORDER BY type_id";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            useDatabase(conn);
            while (rs.next()) {
                RoomTypeInfo info = new RoomTypeInfo();
                info.setTypeId(rs.getInt("type_id"));
                info.setTypeName(rs.getString("type_name"));
                info.setBasePrice(rs.getDouble("base_price"));
                info.setPricePerHour(rs.getDouble("price_per_hour"));
                info.setDepositPercent(rs.getDouble("deposit_percent"));
                info.setCapacity(rs.getInt("capacity"));
                info.setDescription(rs.getString("description"));
                info.setArea(rs.getString("area"));
                info.setBedType(rs.getString("bed_type"));
                list.add(info);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public RoomTypeInfo getRoomTypeById(int typeId) {
        String sql = "SELECT type_id, type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type FROM RoomType WHERE type_id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RoomTypeInfo info = new RoomTypeInfo();
                    info.setTypeId(rs.getInt("type_id"));
                    info.setTypeName(rs.getString("type_name"));
                    info.setBasePrice(rs.getDouble("base_price"));
                    info.setPricePerHour(rs.getDouble("price_per_hour"));
                    info.setDepositPercent(rs.getDouble("deposit_percent"));
                    info.setCapacity(rs.getInt("capacity"));
                    info.setDescription(rs.getString("description"));
                    info.setArea(rs.getString("area"));
                    info.setBedType(rs.getString("bed_type"));
                    return info;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int getAvailableRoomCount(int typeId) {
        String sql = "SELECT COUNT(*) FROM Room WHERE type_id = ? AND status = 'Available' AND is_deleted = 0";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Write operations (transaction-aware)

    public int insertRoomType(RoomTypeInfo rt, Connection conn) throws SQLException {
        useDatabase(conn);
        String sql = "INSERT INTO RoomType (type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, rt.getTypeName());
            ps.setDouble(2, rt.getBasePrice());
            ps.setDouble(3, rt.getPricePerHour());
            ps.setDouble(4, rt.getDepositPercent());
            ps.setInt(5, rt.getCapacity());
            ps.setString(6, rt.getDescription());
            ps.setString(7, rt.getArea());
            ps.setString(8, rt.getBedType());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public void updateRoomType(RoomTypeInfo rt, Connection conn) throws SQLException {
        useDatabase(conn);
        String sql = "UPDATE RoomType SET type_name = ?, base_price = ?, price_per_hour = ?, deposit_percent = ?, capacity = ?, description = ?, area = ?, bed_type = ? WHERE type_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rt.getTypeName());
            ps.setDouble(2, rt.getBasePrice());
            ps.setDouble(3, rt.getPricePerHour());
            ps.setDouble(4, rt.getDepositPercent());
            ps.setInt(5, rt.getCapacity());
            ps.setString(6, rt.getDescription());
            ps.setString(7, rt.getArea());
            ps.setString(8, rt.getBedType());
            ps.setInt(9, rt.getTypeId());
            ps.executeUpdate();
        }
    }

    public void deleteRoomImages(int typeId, Connection conn) throws SQLException {
        useDatabase(conn);
        String sql = "DELETE FROM RoomImage WHERE type_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            ps.executeUpdate();
        }
    }

    public void insertRoomImage(int typeId, String imageUrl, Connection conn) throws SQLException {
        useDatabase(conn);
        String sql = "INSERT INTO RoomImage (type_id, image_url) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            ps.setString(2, imageUrl);
            ps.executeUpdate();
        }
    }

    public void deleteRoomAmenities(int typeId, Connection conn) throws SQLException {
        useDatabase(conn);
        String sql = "DELETE FROM RoomType_Amenity WHERE type_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            ps.executeUpdate();
        }
    }

    public int getAmenityIdByName(String name, Connection conn) throws SQLException {
        useDatabase(conn);
        String sql = "SELECT amenity_id FROM Amenity WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("amenity_id");
                }
            }
        }
        return -1;
    }

    public int insertAmenity(String name, String iconUrl, Connection conn) throws SQLException {
        useDatabase(conn);
        String sql = "INSERT INTO Amenity (name, icon_url) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setString(2, iconUrl);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public void insertRoomTypeAmenityMapping(int typeId, int amenityId, Connection conn) throws SQLException {
        useDatabase(conn);
        String sql = "INSERT INTO RoomType_Amenity (type_id, amenity_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            ps.setInt(2, amenityId);
            ps.executeUpdate();
        }
    }

    public void deleteRoomType(int typeId) {
        String sql = "DELETE FROM RoomType WHERE type_id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, typeId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
