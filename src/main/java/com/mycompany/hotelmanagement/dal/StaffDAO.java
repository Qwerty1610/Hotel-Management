package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.StaffInfo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * StaffDAO
 * Truy vấn thông tin nhân viên Housekeeping kèm số liệu công việc đã hoàn thành
 * (theo ngày / tháng) phục vụ trang theo dõi công việc của Manager.
 *
 * Date: 02/6/2026
 */
public class StaffDAO {

    private void useDatabase(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("USE HotelManagementDB");
        } catch (SQLException e) {
            // Ignore
        }
    }

    /**
     * Danh sách nhân viên Housekeeping (đang hoạt động tài khoản) kèm:
     * - số việc hoàn thành hôm nay
     * - số việc hoàn thành trong tháng hiện tại
     * - số việc đang được giao (chưa hoàn thành / chưa huỷ)
     */
    public List<StaffInfo> getHousekeepingStaff() {
        List<StaffInfo> list = new ArrayList<>();
        String sql =
            "SELECT a.account_id, a.full_name, a.email, " +
            "       ISNULL(a.work_status, N'Offline') AS work_status, " +
            "       (SELECT COUNT(*) FROM dbo.CustomerRequest cr " +
            "          WHERE cr.assigned_staff_id = a.account_id AND cr.status = N'Completed' " +
            "            AND CAST(cr.completed_at AS DATE) = CAST(GETDATE() AS DATE)) AS completed_today, " +
            "       (SELECT COUNT(*) FROM dbo.CustomerRequest cr " +
            "          WHERE cr.assigned_staff_id = a.account_id AND cr.status = N'Completed' " +
            "            AND YEAR(cr.completed_at) = YEAR(GETDATE()) " +
            "            AND MONTH(cr.completed_at) = MONTH(GETDATE())) AS completed_month, " +
            "       (SELECT COUNT(*) FROM dbo.CustomerRequest cr " +
            "          WHERE cr.assigned_staff_id = a.account_id AND cr.status = N'InProgress') AS active_assignments " +
            "FROM dbo.Account a " +
            "JOIN dbo.Role r ON a.role_id = r.role_id " +
            "WHERE r.role_name = N'Housekeeping' AND a.is_active = 1 " +
            "ORDER BY a.full_name";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StaffInfo s = new StaffInfo();
                    s.setAccountId(rs.getInt("account_id"));
                    s.setFullName(rs.getString("full_name"));
                    s.setEmail(rs.getString("email"));
                    s.setWorkStatus(rs.getString("work_status"));
                    s.setCompletedToday(rs.getInt("completed_today"));
                    s.setCompletedMonth(rs.getInt("completed_month"));
                    s.setActiveAssignments(rs.getInt("active_assignments"));
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Số nhân viên Housekeeping đang ở trạng thái Active. */
    public int countActiveStaff() {
        String sql = "SELECT COUNT(*) FROM dbo.Account a " +
                "JOIN dbo.Role r ON a.role_id = r.role_id " +
                "WHERE r.role_name = N'Housekeeping' AND a.is_active = 1 AND a.work_status = N'Active'";
        try (Connection conn = DBContext.getConnection()) {
            useDatabase(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
