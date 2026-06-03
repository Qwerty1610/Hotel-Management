package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.DashboardRepository;
import com.mycompany.hotelmanagement.entity.DashboardStats;

import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * DashboardService
 * Tổng hợp số liệu cho trang Tổng quan: doanh thu, công suất phòng theo ngày,
 * doanh thu theo loại phòng và phân bổ trạng thái đặt phòng.
 *
 * Công suất phòng được tính theo từng ngày trong khoảng lọc:
 *   occupancy(ngày) = số phòng đang có khách trong ngày / tổng số phòng.
 * Một kỳ lưu trú [check_in, check_out) chiếm phòng từ ngày nhận đến trước ngày trả.
 *
 * Date: 02/6/2026
 */
public class DashboardService {

    private final DashboardRepository repo = new DashboardRepository();
    private static final DateTimeFormatter LABEL_FMT = DateTimeFormatter.ofPattern("dd/MM");

    public DashboardStats getStats(LocalDate from, LocalDate to) {
        DashboardStats stats = new DashboardStats();
        stats.setFromDate(from.toString());
        stats.setToDate(to.toString());

        Date sqlFrom = Date.valueOf(from);
        Date sqlTo = Date.valueOf(to);

        // KPI tổng
        int totalRooms = repo.getTotalRooms();
        stats.setTotalRooms(totalRooms);
        stats.setTotalRevenue(repo.getTotalRevenue(sqlFrom, sqlTo));
        stats.setTotalBookings(repo.getBookingCount(sqlFrom, sqlTo));

        // Doanh thu theo ngày + công suất theo ngày
        Map<String, Double> revByDay = repo.getRevenueByDay(sqlFrom, sqlTo);
        List<Object[]> stays = repo.getStaysOverlapping(sqlFrom, sqlTo);

        double occupancySum = 0;     // cộng dồn % công suất từng ngày
        int dayCount = 0;
        int roomNightsSold = 0;

        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            // Doanh thu của ngày này (0 nếu không có)
            Double rev = revByDay.get(d.toString());
            stats.getDayLabels().add(d.format(LABEL_FMT));
            stats.getDayRevenue().add(rev != null ? rev : 0d);

            // Số phòng đang có khách trong ngày d
            int occupiedRooms = 0;
            for (Object[] stay : stays) {
                LocalDate checkIn = ((Date) stay[0]).toLocalDate();
                LocalDate checkOut = ((Date) stay[1]).toLocalDate();
                int qty = (Integer) stay[2];
                if (!d.isBefore(checkIn) && d.isBefore(checkOut)) {
                    occupiedRooms += qty;
                }
            }
            roomNightsSold += occupiedRooms;

            double occPct = totalRooms > 0
                    ? Math.min(100d, occupiedRooms * 100d / totalRooms)
                    : 0d;
            stats.getDayOccupancy().add(round1(occPct));
            occupancySum += occPct;
            dayCount++;
        }

        stats.setRoomNightsSold(roomNightsSold);
        stats.setAvgOccupancy(dayCount > 0 ? round1(occupancySum / dayCount) : 0d);

        // Doanh thu theo loại phòng
        Map<String, Double> revByType = repo.getRevenueByRoomType(sqlFrom, sqlTo);
        for (Map.Entry<String, Double> e : revByType.entrySet()) {
            stats.getRoomTypeLabels().add(e.getKey());
            stats.getRoomTypeRevenue().add(e.getValue());
        }

        // Phân bổ trạng thái đặt phòng
        Map<String, Integer> statusCounts = repo.getBookingStatusCounts(sqlFrom, sqlTo);
        for (Map.Entry<String, Integer> e : statusCounts.entrySet()) {
            stats.getStatusLabels().add(e.getKey());
            stats.getStatusCounts().add(e.getValue());
        }

        return stats;
    }

    private double round1(double v) {
        return Math.round(v * 10d) / 10d;
    }
}
