package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Booking;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * BookingDAO
 * Package harmonized to dal for HMS Hotel-Management structure.
 * Standardized database selection utilizing useDatabase helper.
 * Date: 01/6/2026
 * 
 * @author DUC BINH
 */
public class BookingDAO {

    private static final Logger LOGGER = Logger.getLogger(BookingDAO.class.getName());
    
    private static final Set<String> STATUS_WHITELIST = Set.of("Pending", "Confirmed", "Rejected", "Cancelled");
    private static final Set<String> FILTER_STATUS_WHITELIST = Set.of("All", "Pending", "Confirmed", "Rejected", "Cancelled", "CheckedIn", "CheckedOut");

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    private static final String BASE_SELECT = "SELECT b.booking_id, b.account_id, b.customer_name, " +
            "       b.room_type_id, rt.type_name AS room_type_name, " +
            "       b.room_quantity, b.check_in_date, b.check_out_date, " +
            "       b.total_amount, b.status, b.note, CAST(b.created_at AS DATE) AS created_at " +
            "FROM dbo.Booking b " +
            "LEFT JOIN dbo.RoomType rt ON b.room_type_id = rt.type_id ";

    private String sanitizeLikeKeyword(String keyword) {
        if (keyword == null) return "";
        return keyword.replace("[", "[[]")
                      .replace("%", "[%]")
                      .replace("_", "[_]");
    }

    public List<Booking> getBookings(String statusFilter, String keyword) {
        List<Booking> list = new ArrayList<>();

        // Validate statusFilter
        if (statusFilter == null || !FILTER_STATUS_WHITELIST.contains(statusFilter)) {
            statusFilter = "All";
        }

        StringBuilder sql = new StringBuilder(BASE_SELECT);
        List<Object> params = new ArrayList<>();
        boolean hasWhere = false;

        // Filter by status
        if (!statusFilter.equalsIgnoreCase("All")) {
            sql.append("WHERE b.status = ? ");
            params.add(statusFilter);
            hasWhere = true;
        }

        // Filter by keyword (tên khách hoặc mã)
        if (keyword != null && !keyword.trim().isEmpty()) {
            String sanitizedKw = sanitizeLikeKeyword(keyword.trim());
            String kw = "%" + sanitizedKw + "%";
            if (hasWhere) {
                sql.append("AND (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ?) ");
            } else {
                sql.append("WHERE (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ?) ");
            }
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY b.created_at DESC, b.booking_id DESC");

        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getBookings: " + statusFilter + ", " + keyword, e);
        }
        return list;
    }

    public Booking getBookingById(int bookingId) {
        if (bookingId <= 0) {
            return null;
        }
        String sql = BASE_SELECT + "WHERE b.booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next())
                        return mapRow(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getBookingById: " + bookingId, e);
        }
        return null;
    }

    public boolean updateBookingStatus(int bookingId, String newStatus, String note) {
        if (bookingId <= 0) {
            return false;
        }
        if (newStatus == null || !STATUS_WHITELIST.contains(newStatus)) {
            LOGGER.log(Level.WARNING, "Invalid new status for booking update: " + newStatus);
            return false;
        }
        String sql = "UPDATE dbo.Booking " +
                "SET status = ?, note = ?, updated_at = SYSDATETIME() " +
                "WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setString(2, note != null ? note.trim() : "");
                ps.setInt(3, bookingId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in updateBookingStatus: id=" + bookingId + ", status=" + newStatus, e);
        }
        return false;
    }

    public boolean updateBookingDetails(Booking b) {
        if (b == null || !b.isValid()) {
            LOGGER.log(Level.WARNING, "Invalid Booking entity provided for update: " + b);
            return false;
        }
        String sql = "UPDATE dbo.Booking " +
                "SET customer_name = ?, room_type_id = ?, room_quantity = ?, " +
                "    check_in_date = ?, check_out_date = ?, total_amount = ?, " +
                "    note = ?, updated_at = SYSDATETIME() " +
                "WHERE booking_id = ? AND status = N'Pending'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, b.getCustomerName());
                if (b.getRoomTypeId() != null)
                    ps.setInt(2, b.getRoomTypeId());
                else
                    ps.setNull(2, Types.INTEGER);
                ps.setInt(3, b.getRoomQuantity());
                ps.setDate(4, b.getCheckInDate());
                ps.setDate(5, b.getCheckOutDate());
                ps.setDouble(6, b.getTotalAmount());
                ps.setString(7, b.getNote());
                ps.setInt(8, b.getBookingId());

                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in updateBookingDetails for id: " + b.getBookingId(), e);
        }
        return false;
    }

    public boolean cancelBooking(int bookingId, String reason) {
        if (bookingId <= 0) {
            return false;
        }
        String sql = "UPDATE dbo.Booking " +
                "SET status = N'Cancelled', note = ?, updated_at = SYSDATETIME() " +
                "WHERE booking_id = ? AND status NOT IN (N'CheckedIn', N'CheckedOut')";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, reason != null ? reason.trim() : "Huỷ theo yêu cầu");
                ps.setInt(2, bookingId);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in cancelBooking: id=" + bookingId, e);
        }
        return false;
    }

    public int countByStatus(String status) {
        if (status == null || !FILTER_STATUS_WHITELIST.contains(status)) {
            return 0;
        }
        String sql = "SELECT COUNT(*) FROM dbo.Booking WHERE status = ?";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next())
                        return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in countByStatus: " + status, e);
        }
        return 0;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM dbo.Booking";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in countAll", e);
        }
        return 0;
    }

    private Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getInt("booking_id"));
        int accountId = rs.getInt("account_id");
        if (!rs.wasNull())
            b.setAccountId(accountId);
        b.setCustomerName(rs.getString("customer_name"));
        int typeId = rs.getInt("room_type_id");
        if (!rs.wasNull())
            b.setRoomTypeId(typeId);
        b.setRoomTypeName(rs.getString("room_type_name"));
        b.setRoomQuantity(rs.getInt("room_quantity"));
        b.setCheckInDate(rs.getDate("check_in_date"));
        b.setCheckOutDate(rs.getDate("check_out_date"));
        b.setTotalAmount(rs.getDouble("total_amount"));
        b.setStatus(rs.getString("status"));
        b.setNote(rs.getString("note"));
        b.setCreatedAt(rs.getDate("created_at"));
        return b;
    }
}
