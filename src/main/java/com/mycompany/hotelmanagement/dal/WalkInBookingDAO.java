package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WalkInBookingDAO {

    private void useDatabase(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement()) {
            st.execute("USE HotelManagementDB");
        }
    }

    public List<Room> getAvailableRoomsByType(
            int typeId) {

        List<Room> list = new ArrayList<>();

        String sql = """
        SELECT
            r.room_id,
            r.room_number,
            r.status,
            r.floor,
            rt.type_name
        FROM Room r
        JOIN RoomType rt
            ON r.type_id = rt.type_id
        WHERE r.type_id = ?
        AND r.is_deleted = 0
        AND r.status NOT IN
        (
            'Maintenance',
            'OutOfService'
        )
        ORDER BY r.room_number
    """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            useDatabase(conn);

            ps.setInt(1, typeId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Room r = new Room();

                r.setRoomId(rs.getInt("room_id"));
                r.setRoomNumber(rs.getString("room_number"));
                r.setStatus(rs.getString("status"));
                r.setFloor(rs.getString("floor"));
                r.setTypeName(rs.getString("type_name"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Room> getAvailableRoomsByType(
            int typeId,
            Date checkIn,
            Date checkOut) {

        List<Room> list = new ArrayList<>();

        String sql = """
        SELECT
            r.room_id,
            r.room_number,
            r.status,
            r.floor,
            rt.type_name
        FROM Room r
        JOIN RoomType rt
            ON r.type_id = rt.type_id
        WHERE r.type_id = ?
        AND r.is_deleted = 0
        AND r.status NOT IN
        (
            'Maintenance',
            'OutOfService'
        )
        AND r.room_id NOT IN
        (
            SELECT ra.room_id
            FROM RoomAssignment ra
            JOIN Booking b
                ON b.booking_id = ra.booking_id
            WHERE b.status IN
                ('Confirmed','CheckedIn')
            AND
            (
                ? < b.check_out_date
                AND
                ? > b.check_in_date
            )
        )
        ORDER BY r.room_number
        """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps
                = conn.prepareStatement(sql)) {
            useDatabase(conn);
            ps.setInt(1, typeId);
            ps.setDate(2, checkIn);
            ps.setDate(3, checkOut);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(
                        rs.getInt("room_id"));
                room.setRoomNumber(
                        rs.getString("room_number"));
                room.setStatus(
                        rs.getString("status"));
                room.setFloor(
                        rs.getString("floor"));
                room.setTypeName(
                        rs.getString("type_name"));
                list.add(room);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean hasOverlapBooking(
            Date checkIn,
            Date checkOut) {

        String sql = """
        SELECT TOP 1 booking_id
        FROM Booking
        WHERE status IN
        ('Pending','Confirmed','CheckedIn')
        AND check_in_date < ?
        AND check_out_date > ?
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            useDatabase(con);

            ps.setDate(1, checkOut);
            ps.setDate(2, checkIn);

            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<Room> getAvailableRooms(
            int typeId) {

        List<Room> list = new ArrayList<>();

        String sql = """
        SELECT *
        FROM Room
        WHERE type_id = ? AND is_deleted = 0
        AND status NOT IN
        (
            'Maintenance',
            'OutOfService'
        )
        ORDER BY room_number
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            useDatabase(con);

            ps.setInt(1, typeId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Room r = new Room();

                r.setRoomId(rs.getInt("room_id"));
                r.setRoomNumber(rs.getString("room_number"));
                r.setStatus(rs.getString("status"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countAvailableRooms(
            int typeId) {

        String sql = """
        SELECT COUNT(*)
        FROM Room
        WHERE type_id=? AND is_deleted = 0
        AND status NOT IN
        (
            'Maintenance',
            'OutOfService'
        )
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            useDatabase(con);

            ps.setInt(1, typeId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    private Integer findCustomerAccountIdByEmail(String email, Connection con) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }
        String cleanEmail = email.trim();
        String sql = """
        SELECT TOP 1 a.account_id
        FROM dbo.Account a
        JOIN dbo.Role r ON a.role_id = r.role_id
        WHERE LOWER(RTRIM(LTRIM(a.email))) = LOWER(?)
          AND a.is_active = 1
          AND LOWER(r.role_name) = 'customer'
        """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, cleanEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("account_id");
                }
            }
        }
        return null;
    }

    private int createChildBooking(
            Integer parentId,
            Integer accountId,
            String customerName,
            String phone,
            String email,
            int roomTypeId,
            int quantity,
            Date checkIn,
            Date checkOut,
            double amount,
            String note,
            String status,
            Connection con)
            throws SQLException {

        String sql = """
        INSERT INTO Booking
        (
            account_id,
            customer_name,
            phone,
            email,
            room_type_id,
            room_quantity,
            check_in_date,
            check_out_date,
            total_amount,
            status,
            note,
            group_booking_id
        )
        OUTPUT INSERTED.booking_id
        VALUES
        (
            ?,
            ?,?,?,?,?,?,
            ?,?,
            ?,
            ?,
            ?
        )
        """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            if (accountId == null) {
                ps.setNull(1, Types.INTEGER);
            } else {
                ps.setInt(1, accountId);
            }
            ps.setString(2, customerName);
            ps.setString(3, phone);
            ps.setString(4, email);

            ps.setInt(5, roomTypeId);
            ps.setInt(6, quantity);

            ps.setDate(7, checkIn);
            ps.setDate(8, checkOut);

            ps.setDouble(9, amount);
            ps.setString(10, status);
            ps.setString(11, note);
            if (parentId == null) {
                ps.setNull(12, Types.INTEGER);
            } else {
                ps.setInt(12, parentId);
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return -1;
    }

    public void assignRoom(
            int bookingId,
            int roomId,
            int receptionistId,
            Connection con)
            throws SQLException {

        String sql = """
        INSERT INTO RoomAssignment
        (
            booking_id,
            room_id,
            assigned_by,
            assigned_at
        )
        VALUES
        (
            ?,?,
            ?,
            SYSDATETIME()
        )
        """;

        try (
                PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            ps.setInt(2, roomId);
            ps.setInt(3, receptionistId);

            ps.executeUpdate();
        }
    }

    public int getRoomCapacity(int typeId) {

        String sql = """
        SELECT capacity
        FROM RoomType
        WHERE type_id=?
    """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            useDatabase(conn);

            ps.setInt(1, typeId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("capacity");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int createWalkInBooking(
            Integer receptionistId,
            String customerName,
            String phone,
            String email,
            String note,
            Date checkIn,
            Date checkOut,
            String[] roomTypeIds,
            String[] quantities,
            String[] selectedRooms,
            boolean isCheckIn,
            String receptionistNote,
            String customerRequest,
            String[] companions) {

        Connection con = null;

        try {

            con = DBContext.getConnection();

            useDatabase(con);

            con.setAutoCommit(false);

            String normalizedEmail = email != null ? email.trim() : null;
            Integer customerAccountId = findCustomerAccountIdByEmail(normalizedEmail, con);

            long nights
                    = (checkOut.getTime()
                    - checkIn.getTime())
                    / (1000L * 60 * 60 * 24);

            double grandTotal = 0;

            String bookingStatus
                    = isCheckIn
                            ? "CheckedIn"
                            : "Confirmed";

            for (int i = 0; i < roomTypeIds.length; i++) {

                int typeId
                        = Integer.parseInt(roomTypeIds[i]);

                int qty
                        = Integer.parseInt(quantities[i]);

                grandTotal
                        += getRoomPrice(typeId, con)
                        * qty
                        * nights;
            }

            //------------------------------------------------
            // PARENT BOOKING
            //------------------------------------------------
            boolean isGroupBooking = roomTypeIds.length > 1;

            int parentId = -1;

            //------------------------------------------------
            // CHILD BOOKINGS
            //------------------------------------------------
            int roomPointer = 0;
            int requiredRooms = 0;
            int firstBookingId = -1;
            for (String qty : quantities) {
                requiredRooms += Integer.parseInt(qty);
            }
            if (selectedRooms == null
                    || selectedRooms.length
                    != requiredRooms) {
                throw new RuntimeException(
                        "Số lượng phòng chọn không hợp lệ");
            }

            for (int i = 0; i < roomTypeIds.length; i++) {

                int typeId = Integer.parseInt(roomTypeIds[i]);

                int qty = Integer.parseInt(quantities[i]);

                double amount
                        = getRoomPrice(typeId, con)
                        * qty
                        * nights;

                Integer groupId = null;

                if (i > 0) {
                    groupId = parentId;
                }

                int childId
                        = createChildBooking(
                                groupId,
                                customerAccountId,
                                customerName,
                                phone,
                                normalizedEmail,
                                typeId,
                                qty,
                                checkIn,
                                checkOut,
                                amount,
                                note,
                                bookingStatus,
                                con);

                if (childId <= 0) {
                    con.rollback();
                    return -1;
                }
                if (firstBookingId == -1) {
                    firstBookingId = childId;
                    parentId = childId;
                }
                //------------------------------------
                // assign rooms
                //------------------------------------
                for (int j = 0; j < qty; j++) {

                    int roomId
                            = Integer.parseInt(
                                    selectedRooms[roomPointer]);

                    roomPointer++;

                    // Check room again before assign
                    if (!isRoomAvailableForPeriod(
                            roomId,
                            checkIn,
                            checkOut,
                            con)) {

                        throw new RuntimeException(
                                "Phòng đã được người khác đặt: "
                                + roomId);
                    }
                    assignRoom(
                            childId,
                            roomId,
                            receptionistId,
                            con);
                }
            }

            int bookingRootId
                    = isGroupBooking
                            ? parentId
                            : firstBookingId;

            if (isCheckIn) {

                createCheckInData(
                        bookingRootId,
                        receptionistId,
                        receptionistNote,
                        customerRequest,
                        companions,
                        con);

                if (isGroupBooking) {

                    updateGroupBookingStatus(
                            bookingRootId,
                            "CheckedIn",
                            con);

                } else {
                    updateBookingStatus(
                            bookingRootId,
                            "CheckedIn",
                            con);
                }
            } else {
                if (isGroupBooking) {
                    updateGroupBookingStatus(
                            bookingRootId,
                            "Confirmed",
                            con);
                } else {
                    updateBookingStatus(
                            bookingRootId,
                            "Confirmed",
                            con);
                }
            }
            con.commit();

            new InvoiceDAO().createInvoiceForBooking(bookingRootId);
            return bookingRootId;

        } catch (Exception e) {

            try {

                if (con != null) {
                    con.rollback();
                }

            } catch (Exception ex) {
            }

            e.printStackTrace();

            return -1;

        } finally {

            try {

                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }

            } catch (Exception ex) {
            }
        }
    }

    public boolean isRoomAvailableForPeriod(
            int roomId,
            Date checkIn,
            Date checkOut) {

        String sql = """
        SELECT TOP 1 ra.booking_id
        FROM RoomAssignment ra
        JOIN Booking b
            ON ra.booking_id = b.booking_id
        WHERE ra.room_id = ?
        AND b.status IN
        ('Pending','Confirmed','CheckedIn')
        AND b.check_in_date < ?
        AND b.check_out_date > ?
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            useDatabase(con);

            ps.setInt(1, roomId);
            ps.setDate(2, checkOut);
            ps.setDate(3, checkIn);

            ResultSet rs = ps.executeQuery();

            return !rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean isRoomAvailableForPeriod(
            int roomId,
            Date checkIn,
            Date checkOut,
            Connection con)
            throws SQLException {
        String roomSql = """
            SELECT status
            FROM Room
            WHERE room_id=? AND is_deleted = 0
        """;

        try (PreparedStatement ps
                = con.prepareStatement(roomSql)) {
            ps.setInt(1, roomId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String status
                        = rs.getString("status");

                if ("Maintenance".equals(status)
                        || "OutOfService".equals(status)) {
                    return false;
                }
            }
        }

        String sql = """
        SELECT TOP 1 ra.booking_id
        FROM RoomAssignment ra
        JOIN Booking b
            ON ra.booking_id = b.booking_id
        WHERE ra.room_id = ?
        AND b.status IN
        ('Pending','Confirmed','CheckedIn')
        AND b.check_in_date < ?
        AND b.check_out_date > ?
        """;

        try (PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ps.setDate(2, checkOut);
            ps.setDate(3, checkIn);

            ResultSet rs = ps.executeQuery();

            return !rs.next();
        }
    }

    private double getRoomPrice(
            int typeId,
            Connection con)
            throws SQLException {

        String sql = """
        SELECT base_price
        FROM RoomType
        WHERE type_id=?
        """;

        try (PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, typeId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getDouble("base_price");
            }
        }

        return 0;
    }

    public List<RoomTypeInfo> getAvailableRoomTypes(
            Date checkIn,
            Date checkOut) {

        List<RoomTypeInfo> list
                = new ArrayList<>();

        String sql
                = """
            SELECT
                rt.type_id,
                rt.type_name,
                rt.capacity,
                rt.base_price
            FROM RoomType rt
            WHERE EXISTS
            (
                SELECT 1
                FROM Room r
                WHERE r.type_id = rt.type_id
                AND r.is_deleted = 0
                AND r.status NOT IN
                (
                    'Maintenance',
                    'OutOfService'
                )
                AND r.room_id NOT IN
                (
                    SELECT ra.room_id
                    FROM RoomAssignment ra
                    JOIN Booking b
                        ON b.booking_id = ra.booking_id
                    WHERE
                        b.status IN
                        ('Confirmed','CheckedIn')

                        AND
                        (
                            ? < b.check_out_date
                            AND
                            ? > b.check_in_date
                        )
                )
            )
            """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setDate(1, checkIn);

            ps.setDate(2, checkOut);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                RoomTypeInfo rt
                        = new RoomTypeInfo();

                rt.setTypeId(
                        rs.getInt("type_id"));

                rt.setTypeName(
                        rs.getString("type_name"));

                rt.setCapacity(
                        rs.getInt("capacity"));

                rt.setBasePrice(
                        rs.getDouble("base_price"));

                list.add(rt);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countAvailableRoomsForPeriod(
            int typeId,
            Date checkIn,
            Date checkOut) {

        String sql = """
    SELECT COUNT(*)
    FROM Room r
    WHERE r.type_id = ? AND r.is_deleted = 0
    AND r.status NOT IN
    (
        'Maintenance',
        'OutOfService'
    )
    AND r.room_id NOT IN (

        SELECT ra.room_id

        FROM RoomAssignment ra

        JOIN Booking b
            ON ra.booking_id = b.booking_id

        WHERE b.status IN ('Confirmed','CheckedIn')

        AND b.check_in_date < ?
        AND b.check_out_date > ?
    )
    """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            useDatabase(con);

            ps.setInt(1, typeId);
            ps.setDate(2, checkOut);
            ps.setDate(3, checkIn);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int createCheckIn(
            int bookingId,
            int receptionistId,
            String notes,
            String specialRequest,
            Connection con)
            throws SQLException {

        String sql = """
        INSERT INTO CheckIn
        (
            booking_id,
            receptionist_id,
            notes,
            special_request
        )
        OUTPUT INSERTED.check_in_id
        VALUES
        (
            ?,
            ?,
            ?,
            ?
        )
        """;

        try (PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            ps.setInt(2, receptionistId);
            ps.setString(3, notes);
            ps.setString(4, specialRequest);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return -1;
    }

    public void insertCompanion(
            int checkInId,
            String fullName,
            Connection con)
            throws SQLException {
        String sql = """
        INSERT INTO CheckInCompanion
        (
            check_in_id,
            full_name
        )
        VALUES
        (
            ?,
            ?
        )
        """;
        try (PreparedStatement ps
                = con.prepareStatement(sql)) {
            ps.setInt(1, checkInId);
            ps.setString(2, fullName);
            ps.executeUpdate();
        }
    }

    public void createCheckInData(
            int bookingId,
            int receptionistId,
            String receptionistNote,
            String customerRequest,
            String[] companions,
            Connection con)
            throws SQLException {
        int checkInId
                = createCheckIn(
                        bookingId,
                        receptionistId,
                        receptionistNote,
                        customerRequest,
                        con);
        if (companions == null) {
            return;
        }
        for (String companion : companions) {
            if (companion == null
                    || companion.trim().isEmpty()) {
                continue;
            }
            insertCompanion(
                    checkInId,
                    companion.trim(),
                    con);
        }
    }

    private void updateBookingStatus(
            int bookingId,
            String status,
            Connection con)
            throws SQLException {

        String sql = """
        UPDATE Booking
        SET status = ?
        WHERE booking_id = ?
        """;

        try (PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, bookingId);

            ps.executeUpdate();
        }
    }

    private void updateGroupBookingStatus(
            int parentId,
            String status,
            Connection con)
            throws SQLException {

        String sql = """
        UPDATE Booking
        SET status = ?
        WHERE booking_id = ?
        OR group_booking_id = ?
        """;

        try (PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, parentId);
            ps.setInt(3, parentId);

            ps.executeUpdate();
        }
    }

    public Account findAccountByEmailOrPhone(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return null;
        }

        String sql = """
        SELECT TOP 1
            a.account_id,
            a.full_name,
            a.phone,
            a.email,
            r.role_name,
            a.is_active
        FROM Account a
        JOIN Role r ON a.role_id = r.role_id
        WHERE LOWER(RTRIM(LTRIM(a.phone))) = LOWER(RTRIM(LTRIM(?)))
           OR LOWER(RTRIM(LTRIM(a.email))) = LOWER(RTRIM(LTRIM(?)))
        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            useDatabase(con);

            ps.setString(1, keyword.trim());
            ps.setString(2, keyword.trim());

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                Account a = new Account();

                a.setAccountId(rs.getInt("account_id"));
                a.setFullName(rs.getString("full_name"));
                a.setPhone(rs.getString("phone"));
                a.setEmail(rs.getString("email"));
                a.setRoleName(rs.getString("role_name"));
                a.setActive(rs.getBoolean("is_active"));

                return a;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
