package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
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
    public boolean processCheckIn(int bookingId,
            int receptionistId,
            String specialRequest,
            String notes,
            String[] companions) {

        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. INSERT CHECKIN
            String sql = """
                INSERT INTO CheckIn (booking_id, receptionist_id, special_request, notes)
                VALUES (?, ?, ?, ?)
                """;

            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, bookingId);
            ps.setInt(2, receptionistId);
            ps.setString(3, specialRequest);
            ps.setString(4, notes);

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
                String sql2 = "INSERT INTO CheckInCompanion (check_in_id, full_name) VALUES (?, ?)";
                PreparedStatement ps2 = conn.prepareStatement(sql2);

                for (String name : companions) {
                    if (name != null && !name.trim().isEmpty()) {
                        ps2.setInt(1, checkInId);
                        ps2.setString(2, name.trim());
                        ps2.addBatch();
                    }
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
}
