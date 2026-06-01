/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.hotelmanagement.dao;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import com.mycompany.hotelmanagement.entity.HotelService;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * Date: 31/5/2026
 * @author DUC BINH
 */

public class BookingDAO {

    /* ------------------------------------------------------------------ */
    /*  QUERY BASE                                                          */
    /* ------------------------------------------------------------------ */

    private static final String BASE_SELECT =
        "SELECT b.booking_id, b.account_id, b.customer_name, " +
        "       b.room_type_id, rt.type_name AS room_type_name, " +
        "       b.room_quantity, b.check_in_date, b.check_out_date, " +
        "       b.total_amount, b.status, b.note, CAST(b.created_at AS DATE) AS created_at " +
        "FROM dbo.Booking b " +
        "LEFT JOIN dbo.RoomType rt ON b.room_type_id = rt.type_id ";

    /* ------------------------------------------------------------------ */
    /*  1. XEM DANH SÁCH (USE CASE 2.4.1 & 2.4.2)                         */
    /* ------------------------------------------------------------------ */

    /**
     * Lấy danh sách booking theo status + từ khóa tìm kiếm.
     * @param statusFilter  "All" hoặc tên status cụ thể
     * @param keyword       Tìm theo tên khách hoặc mã booking (null = bỏ qua)
     */
    public List<Booking> getBookings(String statusFilter, String keyword) {
        List<Booking> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(BASE_SELECT);
        List<Object> params = new ArrayList<>();

        boolean hasWhere = false;

        // Filter by status
        if (statusFilter != null && !statusFilter.equalsIgnoreCase("All")) {
            sql.append("WHERE b.status = ? ");
            params.add(statusFilter);
            hasWhere = true;
        }

        // Filter by keyword (tên khách hoặc mã)
        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = "%" + keyword.trim() + "%";
            if (hasWhere) {
                sql.append("AND (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ?) ");
            } else {
                sql.append("WHERE (b.customer_name LIKE ? OR CAST(b.booking_id AS NVARCHAR) LIKE ?) ");
            }
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY b.created_at DESC, b.booking_id DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

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
     * Lấy 1 booking theo ID (dùng cho trang chi tiết)
     */
    public Booking getBookingById(int bookingId) {
        String sql = BASE_SELECT + "WHERE b.booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /* ------------------------------------------------------------------ */
    /*  2. XỬ LÝ YÊU CẦU - Confirm / Reject (USE CASE 2.4.6)             */
    /* ------------------------------------------------------------------ */

    /**
     * Cập nhật status và ghi note lý do
     * @param bookingId  ID booking cần cập nhật
     * @param newStatus  "Confirmed" | "Rejected"
     * @param note       Lý do (cho phép null)
     * @return true nếu thành công
     */
    public boolean updateBookingStatus(int bookingId, String newStatus, String note) {
        String sql = "UPDATE dbo.Booking " +
                     "SET status = ?, note = ?, updated_at = SYSDATETIME() " +
                     "WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setString(2, note != null ? note.trim() : "");
            ps.setInt(3, bookingId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /* ------------------------------------------------------------------ */
    /*  3. CẬP NHẬT THÔNG TIN BOOKING (USE CASE 2.4.2)                    */
    /* ------------------------------------------------------------------ */

    /**
     * Cập nhật thông tin chi tiết booking (tên, ngày, loại phòng, ghi chú)
     * Chỉ cho phép update khi status = Pending
     */
    public boolean updateBookingDetails(Booking b) {
        String sql = "UPDATE dbo.Booking " +
                     "SET customer_name = ?, room_type_id = ?, room_quantity = ?, " +
                     "    check_in_date = ?, check_out_date = ?, total_amount = ?, " +
                     "    note = ?, updated_at = SYSDATETIME() " +
                     "WHERE booking_id = ? AND status = N'Pending'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, b.getCustomerName());
            if (b.getRoomTypeId() != null) ps.setInt(2, b.getRoomTypeId());
            else ps.setNull(2, Types.INTEGER);
            ps.setInt(3, b.getRoomQuantity());
            ps.setDate(4, b.getCheckInDate());
            ps.setDate(5, b.getCheckOutDate());
            ps.setDouble(6, b.getTotalAmount());
            ps.setString(7, b.getNote());
            ps.setInt(8, b.getBookingId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Huỷ booking (Cancelled) — cho phép với bất kỳ status nào trừ CheckedIn/CheckedOut
     */
    public boolean cancelBooking(int bookingId, String reason) {
        String sql = "UPDATE dbo.Booking " +
                     "SET status = N'Cancelled', note = ?, updated_at = SYSDATETIME() " +
                     "WHERE booking_id = ? AND status NOT IN (N'CheckedIn', N'CheckedOut')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, reason != null ? reason.trim() : "Huỷ theo yêu cầu");
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /* ------------------------------------------------------------------ */
    /*  4. THỐNG KÊ NHANH cho Dashboard                                    */
    /* ------------------------------------------------------------------ */

    /** Đếm số booking theo từng status */
    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM dbo.Booking WHERE status = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* ------------------------------------------------------------------ */
    /*  PRIVATE HELPER                                                      */
    /* ------------------------------------------------------------------ */

    /* ------------------------------------------------------------------ */
    /*  5. RECEPTIONIST ITERATION 1 USE CASES                             */
    /* ------------------------------------------------------------------ */

    /**
     * Lấy danh sách phòng trống của 1 loại phòng
     */
    public List<RoomInfo> getAvailableRoomsForType(int typeId) {
        List<RoomInfo> list = new ArrayList<>();
        String sql = "SELECT r.room_id, r.room_number, r.type_id, r.status, r.floor, rt.type_name, rt.base_price " +
                     "FROM dbo.Room r " +
                     "JOIN dbo.RoomType rt ON r.type_id = rt.type_id " +
                     "WHERE r.type_id = ? AND r.status = N'Available'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, typeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoomInfo r = new RoomInfo();
                    r.setRoomId(rs.getInt("room_id"));
                    r.setRoomNumber(rs.getString("room_number"));
                    r.setTypeId(rs.getInt("type_id"));
                    r.setStatus(rs.getString("status"));
                    r.setFloor(rs.getString("floor"));
                    r.setTypeName(rs.getString("type_name"));
                    r.setBasePrice(rs.getDouble("base_price"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
     }

    /**
     * Gán phòng cho booking (gán duy nhất 1 phòng)
     */
    public boolean assignRoom(int bookingId, int roomId) {
        String delSql = "DELETE FROM dbo.BookingRoom WHERE booking_id = ?";
        String insSql = "INSERT INTO dbo.BookingRoom (booking_id, room_id) VALUES (?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(delSql);
                 PreparedStatement ps2 = conn.prepareStatement(insSql)) {
                ps1.setInt(1, bookingId);
                ps1.executeUpdate();
                
                ps2.setInt(1, bookingId);
                ps2.setInt(2, roomId);
                int rows = ps2.executeUpdate();
                
                conn.commit();
                return rows > 0;
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy phòng đã gán của booking
     */
    public RoomInfo getAssignedRoom(int bookingId) {
        String sql = "SELECT r.room_id, r.room_number, r.type_id, r.status, r.floor, rt.type_name, rt.base_price " +
                     "FROM dbo.BookingRoom br " +
                     "JOIN dbo.Room r ON br.room_id = r.room_id " +
                     "JOIN dbo.RoomType rt ON r.type_id = rt.type_id " +
                     "WHERE br.booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RoomInfo r = new RoomInfo();
                    r.setRoomId(rs.getInt("room_id"));
                    r.setRoomNumber(rs.getString("room_number"));
                    r.setTypeId(rs.getInt("type_id"));
                    r.setStatus(rs.getString("status"));
                    r.setFloor(rs.getString("floor"));
                    r.setTypeName(rs.getString("type_name"));
                    r.setBasePrice(rs.getDouble("base_price"));
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Check in customer
     */
    public boolean checkInBooking(int bookingId, int roomId) {
        String updB = "UPDATE dbo.Booking SET status = N'CheckedIn', updated_at = SYSDATETIME() WHERE booking_id = ?";
        String updR = "UPDATE dbo.Room SET status = N'Occupied' WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(updB);
                 PreparedStatement ps2 = conn.prepareStatement(updR)) {
                ps1.setInt(1, bookingId);
                ps1.executeUpdate();
                
                ps2.setInt(1, roomId);
                int rows = ps2.executeUpdate();
                
                conn.commit();
                return rows > 0;
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Check out customer
     */
    public boolean checkOutBooking(int bookingId, int roomId, double totalAmount) {
        String updB = "UPDATE dbo.Booking SET status = N'CheckedOut', total_amount = ?, updated_at = SYSDATETIME() WHERE booking_id = ?";
        String updR = "UPDATE dbo.Room SET status = N'Cleaning' WHERE room_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(updB);
                 PreparedStatement ps2 = conn.prepareStatement(updR)) {
                ps1.setDouble(1, totalAmount);
                ps1.setInt(2, bookingId);
                ps1.executeUpdate();
                
                ps2.setInt(1, roomId);
                int rows = ps2.executeUpdate();
                
                conn.commit();
                return rows > 0;
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm dịch vụ cho stay
     */
    public boolean addServiceToBooking(int bookingId, int serviceId, int quantity, double price) {
        String selectSql = "SELECT quantity FROM dbo.BookingService WHERE booking_id = ? AND service_id = ?";
        String insSql = "INSERT INTO dbo.BookingService (booking_id, service_id, quantity, price) VALUES (?, ?, ?, ?)";
        String updSql = "UPDATE dbo.BookingService SET quantity = ?, price = ? WHERE booking_id = ? AND service_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            boolean exists = false;
            int oldQty = 0;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, serviceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        exists = true;
                        oldQty = rs.getInt("quantity");
                    }
                }
            }
            if (exists) {
                try (PreparedStatement ps = conn.prepareStatement(updSql)) {
                    ps.setInt(1, oldQty + quantity);
                    ps.setDouble(2, price);
                    ps.setInt(3, bookingId);
                    ps.setInt(4, serviceId);
                    return ps.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement ps = conn.prepareStatement(insSql)) {
                    ps.setInt(1, bookingId);
                    ps.setInt(2, serviceId);
                    ps.setInt(3, quantity);
                    ps.setDouble(4, price);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa dịch vụ khỏi stay
     */
    public boolean removeServiceFromBooking(int bookingId, int serviceId) {
        String sql = "DELETE FROM dbo.BookingService WHERE booking_id = ? AND service_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.setInt(2, serviceId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy các dịch vụ đã dùng của booking
     */
    public List<HotelService> getBookingServices(int bookingId) {
        List<HotelService> list = new ArrayList<>();
        String sql = "SELECT bs.service_id, s.service_name, bs.quantity, bs.price " +
                     "FROM dbo.BookingService bs " +
                     "JOIN dbo.HotelService s ON bs.service_id = s.service_id " +
                     "WHERE bs.booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HotelService hs = new HotelService();
                    hs.setServiceId(rs.getInt("service_id"));
                    int qty = rs.getInt("quantity");
                    double unitPrice = rs.getDouble("price");
                    hs.setServiceName(rs.getString("service_name"));
                    hs.setDescription("Số lượng: " + qty);
                    hs.setUnit(String.valueOf(qty)); 
                    hs.setPrice(unitPrice * qty); 
                    list.add(hs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tạo booking walk-in tại quầy
     */
    public boolean createWalkInBooking(Booking b, int roomId) {
        String insB = "INSERT INTO dbo.Booking (customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note, created_at) " +
                      "VALUES (?, ?, 1, ?, ?, ?, N'CheckedIn', ?, SYSDATETIME())";
        String insBR = "INSERT INTO dbo.BookingRoom (booking_id, room_id) VALUES (?, ?)";
        String updR = "UPDATE dbo.Room SET status = N'Occupied' WHERE room_id = ?";
        
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(insB, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement ps2 = conn.prepareStatement(insBR);
                 PreparedStatement ps3 = conn.prepareStatement(updR)) {
                
                ps1.setString(1, b.getCustomerName());
                ps1.setInt(2, b.getRoomTypeId());
                ps1.setDate(3, b.getCheckInDate());
                ps1.setDate(4, b.getCheckOutDate());
                ps1.setDouble(5, b.getTotalAmount());
                ps1.setString(6, b.getNote() != null ? b.getNote() : "Đặt phòng tại quầy (Walk-in)");
                
                int affected = ps1.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }
                
                int bookingId = 0;
                try (ResultSet gk = ps1.getGeneratedKeys()) {
                    if (gk.next()) {
                        bookingId = gk.getInt(1);
                    }
                }
                
                if (bookingId == 0) {
                    conn.rollback();
                    return false;
                }
                
                // 2. Gán Room
                ps2.setInt(1, bookingId);
                ps2.setInt(2, roomId);
                ps2.executeUpdate();
                
                // 3. Mark Occupied
                ps3.setInt(1, roomId);
                ps3.executeUpdate();
                
                conn.commit();
                return true;
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getInt("booking_id"));
        int accountId = rs.getInt("account_id");
        if (!rs.wasNull()) b.setAccountId(accountId);
        b.setCustomerName(rs.getString("customer_name"));
        int typeId = rs.getInt("room_type_id");
        if (!rs.wasNull()) b.setRoomTypeId(typeId);
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

