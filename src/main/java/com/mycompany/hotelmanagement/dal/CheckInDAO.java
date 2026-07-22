package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.CheckIn;
import com.mycompany.hotelmanagement.entity.CheckInCompanion;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CheckInDAO {

    private static final Logger LOGGER = Logger.getLogger(CheckInDAO.class.getName());

    /**
     * CREATE CHECK-IN + COMPANIONS + UPDATE BOOKING (TRANSACTION)
     */
    public boolean processCheckIn(
            int bookingId,
            int receptionistId,
            String specialRequest,
            String notes,
            String imageUrl,
            BigDecimal extraFee,
            String[] companions,
            List<String> companionImageUrls,
            String[] ageRanges
    ) {

        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. INSERT CHECKIN
            String sql = """
                INSERT INTO CheckIn
                (
                    booking_id,
                    receptionist_id,
                    special_request,
                    notes,
                    image_url,
                    extra_fee     
                )
                VALUES(?,?,?,?,?,?)
                """;

            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, bookingId);
            ps.setInt(2, receptionistId);
            ps.setString(3, specialRequest);
            ps.setString(4, notes);
            ps.setString(5, imageUrl);
            ps.setBigDecimal(6, extraFee);
            
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            int checkInId = -1;

            if (rs.next()) {
                checkInId = rs.getInt(1);
            }

            if (checkInId == -1) {
                conn.rollback();
                return false;
            }

            // 2. INSERT COMPANIONS
            if (companions != null) {
                String sql2 = """
                    INSERT INTO CheckInCompanion
                    (
                        check_in_id,
                        full_name,
                        age_range,
                        image_url
                    )
                    VALUES
                    (
                        ?, ?, ?, ?
                    )
                    """;
                PreparedStatement ps2 = conn.prepareStatement(sql2);

                for (int i = 0; i < companions.length; i++) {
                    String name = companions[i];
                    if (name == null || name.trim().isEmpty()) {
                        continue;
                    }
                    String image = null;
                    if (companionImageUrls != null && i < companionImageUrls.size()) {
                        image = companionImageUrls.get(i);
                    }
                    String age = null;
                    if (ageRanges != null && i < ageRanges.length) {
                        age = ageRanges[i];
                    }
                    ps2.setInt(1, checkInId);
                    ps2.setString(2, name.trim());
                    ps2.setString(3, age);
                    ps2.setString(4, image);

                    ps2.addBatch();
                }

                ps2.executeBatch();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        }
    }

    public CheckIn getCheckInByBookingId(int bookingId) {

        String sql = """
        SELECT
            check_in_id,
            booking_id,
            receptionist_id,
            special_request,
            notes,
            image_url,
            checked_in_at
        FROM CheckIn
        WHERE booking_id = ?
        """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                CheckIn checkIn = new CheckIn();

                checkIn.setCheckInId(
                        rs.getInt("check_in_id")
                );

                checkIn.setBookingId(
                        rs.getInt("booking_id")
                );

                checkIn.setReceptionistId(
                        rs.getInt("receptionist_id")
                );

                checkIn.setSpecialRequest(
                        rs.getString("special_request")
                );

                checkIn.setNotes(
                        rs.getString("notes")
                );

                checkIn.setImageUrl(
                        rs.getString("image_url")
                );

                checkIn.setCheckedInAt(
                        rs.getTimestamp("checked_in_at")
                );

                return checkIn;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<CheckInCompanion> getCompanionsByCheckInId(int checkInId) {

        List<CheckInCompanion> list = new ArrayList<>();

        String sql = """
        SELECT
            companion_id,
            check_in_id,
            full_name,
            age_range,
            image_url
        FROM CheckInCompanion
        WHERE check_in_id = ?
        ORDER BY companion_id
        """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, checkInId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                CheckInCompanion c = new CheckInCompanion();

                c.setCompanionId(rs.getInt("companion_id"));
                c.setCheckInId(rs.getInt("check_in_id"));
                c.setFullName(rs.getString("full_name"));
                c.setAgeRange(rs.getString("age_range"));
                c.setImageUrl(rs.getString("image_url"));

                list.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int getTotalCapacityByBookingId(int bookingId) {

        String sql = """
            SELECT SUM(rt.capacity) AS total_capacity
            FROM RoomAssignment ra
            JOIN Room r
                ON ra.room_id = r.room_id
            JOIN RoomType rt
                ON r.type_id = rt.type_id
            WHERE ra.booking_id = ?
               OR ra.booking_id IN
               (
                    SELECT booking_id
                    FROM Booking
                    WHERE group_booking_id = ?
               )
            """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            ps.setInt(2, bookingId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getInt("total_capacity");

            }

        } catch (Exception e) {

            LOGGER.log(
                    Level.SEVERE,
                    "Cannot calculate total capacity for booking "
                    + bookingId,
                    e
            );

        }

        return 0;
    }
}
