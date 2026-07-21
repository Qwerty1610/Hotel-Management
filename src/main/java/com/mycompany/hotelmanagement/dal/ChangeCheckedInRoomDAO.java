/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.AssignedRoom;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomInfo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author MinhTDP Created: 14/07/2026
 */
public class ChangeCheckedInRoomDAO {

    private int getRoomAssignmentBookingId(
            Connection con,
            int bookingId
    ) throws Exception {

        String sql = """
        SELECT TOP 1
            ra.booking_id

        FROM RoomAssignment ra

        WHERE ra.booking_id = ?

        OR ra.booking_id IN
        (
            SELECT booking_id
            FROM Booking
            WHERE group_booking_id = ?
        )
    """;

        PreparedStatement ps
                = con.prepareStatement(sql);

        ps.setInt(1, bookingId);
        ps.setInt(2, bookingId);

        ResultSet rs
                = ps.executeQuery();

        if (rs.next()) {

            return rs.getInt("booking_id");

        }

        return bookingId;
    }

    public List<RoomInfo> getCurrentAssignedRooms(int bookingId) {

        List<RoomInfo> list = new ArrayList<>();

        String sql = """
    SELECT
        r.room_id,
        r.room_number,
        r.type_id,
        r.status,
        r.floor,
        rt.type_name

    FROM RoomAssignment ra

    JOIN Room r
        ON ra.room_id = r.room_id

    JOIN RoomType rt
        ON r.type_id = rt.type_id

    JOIN Booking b
        ON ra.booking_id = b.booking_id

    WHERE
        ra.booking_id = ?

    OR

        ra.booking_id IN
        (
            SELECT booking_id
            FROM Booking
            WHERE group_booking_id = ?

            UNION

            SELECT booking_id
            FROM Booking
            WHERE booking_id =
            (
                SELECT group_booking_id
                FROM Booking
                WHERE booking_id = ?
            )
        )

    ORDER BY
        rt.type_name,
        r.room_number
    """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            ps.setInt(2, bookingId);
            ps.setInt(3, bookingId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                RoomInfo room = new RoomInfo();

                room.setRoomId(
                        rs.getInt("room_id")
                );

                room.setRoomNumber(
                        rs.getString("room_number")
                );

                room.setTypeId(
                        rs.getInt("type_id")
                );

                room.setTypeName(
                        rs.getString("type_name")
                );

                room.setStatus(
                        rs.getString("status")
                );

                room.setFloor(
                        rs.getString("floor")
                );

                list.add(room);

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return list;
    }

    /**
     * Lấy các phòng có thể đổi cùng loại phòng với booking
     */
    public List<RoomInfo> getAvailableRoomsForChange(int bookingId) {

        List<RoomInfo> list = new ArrayList<>();

        String sql = """

        SELECT
            r.room_id,
            r.room_number,
            r.type_id,
            r.status,
            r.floor,
            rt.type_name
        FROM Room r
        JOIN RoomType rt
        ON r.type_id = rt.type_id
        WHERE
        r.type_id IN
        (
            SELECT DISTINCT
                r2.type_id
            FROM RoomAssignment ra2
            JOIN Room r2
                ON ra2.room_id = r2.room_id
            WHERE
            ra2.booking_id IN
            (
                SELECT booking_id
                FROM Booking
                WHERE
                booking_id = ?
                OR
                group_booking_id = ?
                OR
                group_booking_id =
                (
                    SELECT group_booking_id

                    FROM Booking

                    WHERE booking_id = ?

                )


            )

        )



        AND r.status NOT IN

        (

            'Maintenance',

            'OutOfService'

        )



        AND r.room_id NOT IN

        (

            SELECT room_id

            FROM RoomAssignment


            WHERE booking_id IN

            (

                SELECT booking_id

                FROM Booking


                WHERE

                booking_id = ?


                OR

                group_booking_id = ?


                OR

                group_booking_id =

                (

                    SELECT group_booking_id

                    FROM Booking

                    WHERE booking_id = ?

                )

            )

        )



        AND NOT EXISTS

        (

            SELECT 1


            FROM RoomAssignment ra3


            JOIN Booking b3

                ON ra3.booking_id = b3.booking_id



            WHERE

            ra3.room_id = r.room_id



            AND b3.status IN

            (

                'Confirmed',

                'CheckedIn'

            )



            AND b3.check_in_date <

            (

                SELECT check_out_date

                FROM Booking

                WHERE booking_id = ?

            )



            AND b3.check_out_date >

            (

                SELECT check_in_date

                FROM Booking

                WHERE booking_id = ?

            )

        )


        ORDER BY

        rt.type_name,

        r.room_number


        """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            ps.setInt(2, bookingId);
            ps.setInt(3, bookingId);
            ps.setInt(4, bookingId);
            ps.setInt(5, bookingId);
            ps.setInt(6, bookingId);
            ps.setInt(7, bookingId);
            ps.setInt(8, bookingId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                RoomInfo room = new RoomInfo();

                room.setRoomId(
                        rs.getInt("room_id")
                );

                room.setRoomNumber(
                        rs.getString("room_number")
                );

                room.setTypeId(
                        rs.getInt("type_id")
                );

                room.setTypeName(
                        rs.getString("type_name")
                );

                room.setStatus(
                        rs.getString("status")
                );

                room.setFloor(
                        rs.getString("floor")
                );

                list.add(room);

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return list;
    }

    private int getBookingIdByRoom(
            Connection con,
            int roomId
    ) throws SQLException {

        String sql = """
        SELECT booking_id
        FROM RoomAssignment
        WHERE room_id = ?
    """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, roomId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("booking_id");
            }

        }

        return -1;
    }

    public boolean changeRooms(
            int bookingId,
            String[] oldRoomIds,
            String[] newRoomIds,
            String reason
    ) {

        Connection con = null;

        try {

            con = DBContext.getConnection();
            con.setAutoCommit(false);
            int assignmentBookingId
                    = getRoomAssignmentBookingId(
                            con,
                            bookingId
                    );
            System.out.println(
                    "CHANGE ROOM ASSIGNMENT BOOKING = "
                    + assignmentBookingId
            );
            if (oldRoomIds == null
                    || newRoomIds == null
                    || oldRoomIds.length != newRoomIds.length) {

                return false;
            }

            String deleteSql = """
            DELETE FROM RoomAssignment
            WHERE booking_id = ?
            AND room_id = ?
            """;

            String insertSql = """
            INSERT INTO RoomAssignment
            (
                booking_id,
                room_id,
                assigned_by,
                assigned_at,
                note
            )
            VALUES
            (
                ?,
                ?,
                ?,
                GETDATE(),
                ?
            )
            """;

            PreparedStatement deletePs
                    = con.prepareStatement(deleteSql);

            PreparedStatement insertPs
                    = con.prepareStatement(insertSql);

            for (int i = 0; i < oldRoomIds.length; i++) {

                if (oldRoomIds[i] == null
                        || newRoomIds[i] == null
                        || oldRoomIds[i].isBlank()
                        || newRoomIds[i].isBlank()) {
                    continue;
                }

                int oldRoomId = Integer.parseInt(oldRoomIds[i]);
                int newRoomId = Integer.parseInt(newRoomIds[i]);
                int realBookingId
                        = getBookingIdByRoom(
                                con,
                                oldRoomId
                        );
                if (realBookingId == -1) {
                    throw new SQLException(
                            "Room "
                            + oldRoomId
                            + " does not belong to any booking"
                    );
                }
                System.out.println(
                        "OLD ROOM = "
                        + oldRoomId
                        + " BELONGS BOOKING = "
                        + realBookingId
                );
                // Không đổi thì bỏ qua
                if (oldRoomId == newRoomId) {
                    continue;
                }

                // Xóa phòng cũ
                deletePs.setInt(1, assignmentBookingId);
                deletePs.setInt(2, oldRoomId);
                deletePs.executeUpdate();

                // Gán phòng mới
                insertPs.setInt(1, assignmentBookingId);
                insertPs.setInt(2, newRoomId);
                insertPs.setInt(3, 1); // TODO: thay bằng account đang đăng nhập
                insertPs.setString(4, reason);

                insertPs.executeUpdate();
            }

            deletePs.close();
            insertPs.close();

            con.commit();

            return true;

        } catch (Exception e) {

            e.printStackTrace();

            try {
                if (con != null) {
                    con.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            return false;

        } finally {

            try {

                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public List<Booking> getGroupBookings(int bookingId) {

        List<Booking> list = new ArrayList<>();

        String sql = """

    SELECT
        b.booking_id,
        b.room_type_id,
        rt.type_name,
        b.room_quantity,
        b.total_amount,
        b.status,
        b.group_booking_id


    FROM Booking b


    JOIN RoomType rt
        ON b.room_type_id = rt.type_id


    WHERE

    b.booking_id =
    (
        SELECT
            CASE

            WHEN group_booking_id IS NULL
            THEN booking_id

            ELSE group_booking_id

            END

        FROM Booking

        WHERE booking_id = ?

    )


    OR


    b.group_booking_id =
    (
        SELECT
            CASE

            WHEN group_booking_id IS NULL
            THEN booking_id

            ELSE group_booking_id

            END

        FROM Booking

        WHERE booking_id = ?

    )


    ORDER BY
        b.booking_id

    """;

        try (
                Connection con = DBContext.getConnection(); PreparedStatement ps
                = con.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            ps.setInt(2, bookingId);

            ResultSet rs
                    = ps.executeQuery();

            while (rs.next()) {

                Booking b
                        = new Booking();

                b.setBookingId(
                        rs.getInt("booking_id")
                );

                b.setRoomTypeId(
                        rs.getInt("room_type_id")
                );

                b.setRoomTypeName(
                        rs.getString("type_name")
                );

                b.setRoomQuantity(
                        rs.getInt("room_quantity")
                );

                b.setTotalAmount(
                        rs.getDouble("total_amount")
                );

                b.setStatus(
                        rs.getString("status")
                );

                // xử lý NULL
                int groupId
                        = rs.getInt(
                                "group_booking_id"
                        );

                if (rs.wasNull()) {

                    b.setGroupBookingId(null);

                } else {

                    b.setGroupBookingId(groupId);

                }

                list.add(b);

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return list;
    }
}
