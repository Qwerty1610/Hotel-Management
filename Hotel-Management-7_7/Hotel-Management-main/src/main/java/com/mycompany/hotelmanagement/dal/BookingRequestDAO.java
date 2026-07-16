package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.BookingRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data-access for customer booking-change and stay-extension requests
 * (table {@code dbo.BookingChangeRequest}). Raw JDBC, matching the project's
 * {@code DBContext.getConnection()} + {@code useDatabase} idiom.
 *
 * @author QuyPQ
 */
public class BookingRequestDAO {

    private static final Logger LOGGER = Logger.getLogger(BookingRequestDAO.class.getName());

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (Exception e) {
            // Ignore
        }
    }

    /** Inserts a request and returns the generated id, or -1 on failure. */
    public int create(BookingRequest r) {
        if (r == null) {
            return -1;
        }
        String sql = "INSERT INTO dbo.BookingChangeRequest "
                + "(booking_id, account_id, request_type, old_check_in, old_check_out, "
                + " new_check_in, new_check_out, new_room_type_id, new_room_quantity, "
                + " additional_charge, reason, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, r.getBookingId());
                ps.setInt(2, r.getAccountId());
                ps.setString(3, r.getRequestType());
                setDate(ps, 4, r.getOldCheckIn());
                setDate(ps, 5, r.getOldCheckOut());
                setDate(ps, 6, r.getNewCheckIn());
                setDate(ps, 7, r.getNewCheckOut());
                if (r.getNewRoomTypeId() != null) ps.setInt(8, r.getNewRoomTypeId());
                else ps.setNull(8, Types.INTEGER);
                if (r.getNewRoomQuantity() != null) ps.setInt(9, r.getNewRoomQuantity());
                else ps.setNull(9, Types.INTEGER);
                if (r.getAdditionalCharge() != null) ps.setDouble(10, r.getAdditionalCharge());
                else ps.setNull(10, Types.DECIMAL);
                ps.setString(11, r.getReason() != null ? r.getReason().trim() : null);
                ps.setString(12, r.getStatus() != null ? r.getStatus() : "Pending");

                if (ps.executeUpdate() > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            return rs.getInt(1);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating booking request", e);
        }
        return -1;
    }

    /** True if a Pending request of the given type already exists for a booking. */
    public boolean hasPendingRequest(int bookingId, String requestType) {
        String sql = "SELECT 1 FROM dbo.BookingChangeRequest "
                + "WHERE booking_id = ? AND request_type = ? AND status = N'Pending'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                ps.setString(2, requestType);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error checking pending request", e);
        }
        return false;
    }

    /** Returns the customer's requests (newest first) for status tracking. */
    public List<BookingRequest> getRequestsByAccount(int accountId) {
        List<BookingRequest> list = new ArrayList<>();
        String sql = "SELECT r.request_id, r.booking_id, r.account_id, r.request_type, "
                + "       r.old_check_in, r.old_check_out, r.new_check_in, r.new_check_out, "
                + "       r.new_room_type_id, r.new_room_quantity, r.additional_charge, "
                + "       r.reason, r.status, r.created_at, "
                + "       nt.type_name AS new_room_type_name, ct.type_name AS current_room_type_name "
                + "FROM dbo.BookingChangeRequest r "
                + "LEFT JOIN dbo.RoomType nt ON r.new_room_type_id = nt.type_id "
                + "LEFT JOIN dbo.Booking b ON r.booking_id = b.booking_id "
                + "LEFT JOIN dbo.RoomType ct ON b.room_type_id = ct.type_id "
                + "WHERE r.account_id = ? "
                + "ORDER BY r.created_at DESC";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading requests for account " + accountId, e);
        }
        return list;
    }

    private BookingRequest mapRow(ResultSet rs) throws java.sql.SQLException {
        BookingRequest r = new BookingRequest();
        r.setRequestId(rs.getInt("request_id"));
        r.setBookingId(rs.getInt("booking_id"));
        r.setAccountId(rs.getInt("account_id"));
        r.setRequestType(rs.getString("request_type"));
        r.setOldCheckIn(rs.getDate("old_check_in"));
        r.setOldCheckOut(rs.getDate("old_check_out"));
        r.setNewCheckIn(rs.getDate("new_check_in"));
        r.setNewCheckOut(rs.getDate("new_check_out"));
        int nt = rs.getInt("new_room_type_id");
        if (!rs.wasNull()) r.setNewRoomTypeId(nt);
        int nq = rs.getInt("new_room_quantity");
        if (!rs.wasNull()) r.setNewRoomQuantity(nq);
        double ac = rs.getDouble("additional_charge");
        if (!rs.wasNull()) r.setAdditionalCharge(ac);
        r.setReason(rs.getString("reason"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setNewRoomTypeName(rs.getString("new_room_type_name"));
        r.setCurrentRoomTypeName(rs.getString("current_room_type_name"));
        return r;
    }

    private void setDate(PreparedStatement ps, int idx, java.sql.Date d) throws java.sql.SQLException {
        if (d != null) ps.setDate(idx, d);
        else ps.setNull(idx, Types.DATE);
    }
}
