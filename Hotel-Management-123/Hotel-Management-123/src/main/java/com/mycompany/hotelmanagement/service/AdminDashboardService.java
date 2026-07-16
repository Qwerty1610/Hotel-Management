package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AdminDashboardRepository;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats;

import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * AdminDashboardService
 * Tổng hợp số liệu giám sát toàn hệ thống cho Bảng điều khiển của Admin (UC 2.7.4).
 *
 * Các chỉ số tài khoản (tổng / hoạt động / khóa, phân bổ theo vai trò) phản ánh
 * trạng thái toàn hệ thống. Các chỉ số đặt phòng / doanh thu được tính theo
 * khoảng thời gian lọc [from, to] do Admin chọn.
 *
 * @author QuyPQ
 */
public class AdminDashboardService {

    private final AdminDashboardRepository repo = new AdminDashboardRepository();
    private static final DateTimeFormatter LABEL_FMT = DateTimeFormatter.ofPattern("dd/MM");
    private static final int RECENT_LIMIT = 8;

    public SystemDashboardStats getStats(LocalDate from, LocalDate to) {
        SystemDashboardStats stats = new SystemDashboardStats();
        stats.setFromDate(from.toString());
        stats.setToDate(to.toString());

        Date sqlFrom = Date.valueOf(from);
        Date sqlTo = Date.valueOf(to);

        // KPI tài khoản (toàn hệ thống)
        stats.setTotalAccounts(repo.getTotalAccounts());
        stats.setActiveAccounts(repo.getActiveAccounts());
        stats.setLockedAccounts(repo.getLockedAccounts());

        // KPI đặt phòng / doanh thu (theo khoảng lọc)
        stats.setTotalBookings(repo.getBookingCount(sqlFrom, sqlTo));
        stats.setTotalRevenue(repo.getTotalRevenue(sqlFrom, sqlTo));

        // Phân bổ tài khoản theo vai trò
        Map<String, Integer> byRole = repo.getAccountCountsByRole();
        for (Map.Entry<String, Integer> e : byRole.entrySet()) {
            stats.getRoleLabels().add(e.getKey());
            stats.getRoleCounts().add(e.getValue());
        }

        // Phân bổ đặt phòng theo trạng thái
        Map<String, Integer> byStatus = repo.getBookingStatusCounts(sqlFrom, sqlTo);
        for (Map.Entry<String, Integer> e : byStatus.entrySet()) {
            stats.getStatusLabels().add(e.getKey());
            stats.getStatusCounts().add(e.getValue());
        }

        // Doanh thu theo ngày trong khoảng lọc (điền 0 cho các ngày trống)
        Map<String, Double> revByDay = repo.getRevenueByDay(sqlFrom, sqlTo);
        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            Double rev = revByDay.get(d.toString());
            stats.getDayLabels().add(d.format(LABEL_FMT));
            stats.getDayRevenue().add(rev != null ? rev : 0d);
        }

        // Hoạt động gần đây
        stats.setRecentActivities(repo.getRecentBookings(RECENT_LIMIT));

        return stats;
    }
}
