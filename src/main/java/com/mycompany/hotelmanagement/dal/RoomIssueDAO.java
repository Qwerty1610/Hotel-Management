package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.RoomIssue;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author MinhTDP Created: 10/07/2026
 */
public class RoomIssueDAO {

    public boolean insert(RoomIssue issue) {

        String sql = """
                INSERT INTO RoomIssue
                (
                    room_id,
                    issue_type,
                    severity,
                    description,
                    note,
                    reported_by
                )
                VALUES
                (
                    ?, ?, ?, ?, ?, ?
                )
                """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, issue.getRoomId());
            ps.setString(2, issue.getIssueType());
            ps.setString(3, issue.getSeverity());
            ps.setString(4, issue.getDescription());
            ps.setString(5, issue.getNote());

            if (issue.getReportedBy() == null) {
                ps.setNull(6, java.sql.Types.INTEGER);
            } else {
                ps.setInt(6, issue.getReportedBy());
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean existsPendingIssue(
            int roomId,
            String issueType) {

        String sql = """
        SELECT COUNT(*)
        FROM RoomIssue
        WHERE room_id = ?
        AND issue_type = ?
        AND status = 'Pending'
        """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);

            ps.setString(2, issueType);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getInt(1) > 0;

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }
    // ==========================
    // GET ISSUES BY ROOM
    // ==========================

    public List<RoomIssue> getIssuesByRoomId(int roomId) {

        List<RoomIssue> list = new ArrayList<>();

        String sql = """
        SELECT 
            issue_id,
            room_id,
            issue_type,
            severity,
            description,
            note,
            status,
            reported_by
        FROM RoomIssue
        WHERE room_id = ?
        ORDER BY issue_id DESC
    """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                RoomIssue issue = new RoomIssue();

                issue.setIssueId(
                        rs.getInt("issue_id")
                );

                issue.setRoomId(
                        rs.getInt("room_id")
                );

                issue.setIssueType(
                        rs.getString("issue_type")
                );

                issue.setSeverity(
                        rs.getString("severity")
                );

                issue.setDescription(
                        rs.getString("description")
                );

                issue.setNote(
                        rs.getString("note")
                );

                issue.setStatus(
                        rs.getString("status")
                );

                // xử lý Integer có thể NULL
                int reportedBy = rs.getInt("reported_by");

                if (!rs.wasNull()) {
                    issue.setReportedBy(reportedBy);
                }

                list.add(issue);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ==========================
    // COMPLETE ISSUE
    // Pending -> Success
    // ==========================
    public boolean completeIssue(int issueId) {

        String sql = """
            UPDATE RoomIssue
            SET status = 'Success'
            WHERE issue_id = ?
              AND status = 'Pending'
        """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, issueId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {

            e.printStackTrace();

        }

        return false;
    }

    public boolean hasPendingIssue(int roomId) {

        String sql = """
        SELECT COUNT(*)
        FROM RoomIssue
        WHERE room_id = ?
          AND status = 'Pending'
    """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getInt(1) > 0;

            }

        } catch (Exception e) {

            e.printStackTrace();

        }
        return false;
    }
    /* ==========================
       GET HIGHEST PRIORITY PENDING ISSUE
       ========================== */

    public RoomIssue getHighestPriorityPendingIssue(int roomId) {

        String sql = """
        SELECT TOP 1
            issue_id,
            room_id,
            issue_type,
            severity,
            description,
            note,
            status,
            reported_by
        FROM RoomIssue
        WHERE room_id = ?
          AND status = 'Pending'
        ORDER BY
            CASE
                WHEN issue_type = 'Damage' THEN 1
                WHEN issue_type = 'Other'
                     AND severity IN ('High','Medium') THEN 2
                WHEN issue_type = 'Refill' THEN 3
                WHEN issue_type = 'Cleaning' THEN 3
                WHEN issue_type = 'Other'
                     AND severity = 'Low' THEN 4
                ELSE 99
            END,
            issue_id
    """;

        try (
                Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                RoomIssue issue = new RoomIssue();

                issue.setIssueId(rs.getInt("issue_id"));
                issue.setRoomId(rs.getInt("room_id"));
                issue.setIssueType(rs.getString("issue_type"));
                issue.setSeverity(rs.getString("severity"));
                issue.setDescription(rs.getString("description"));
                issue.setNote(rs.getString("note"));
                issue.setStatus(rs.getString("status"));

                int reportedBy = rs.getInt("reported_by");

                if (!rs.wasNull()) {
                    issue.setReportedBy(reportedBy);
                }

                return issue;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
