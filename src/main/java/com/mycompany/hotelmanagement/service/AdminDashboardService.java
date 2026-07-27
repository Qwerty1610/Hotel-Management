package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AdminDashboardDAO;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.ChartSeries;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.DetailTable;

import java.sql.Date;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * AdminDashboardService
 * Tổng hợp số liệu giám sát toàn hệ thống cho Bảng điều khiển của Admin (UC 2.7.4).
 *
 * CHUẨN GHI NHẬN DOANH THU (thống nhất với trang Tổng quan của Manager —
 * xem DashboardService): doanh thu của mỗi đơn đã ghi nhận được RẢI ĐỀU THEO
 * TỪNG ĐÊM LƯU TRÚ (total_amount / số đêm), và chỉ phần số đêm nằm trong khoảng
 * lọc mới được cộng vào kỳ. Nhờ vậy một đơn vắt qua hai tháng được chia đúng
 * cho hai tháng, và số liệu của Admin luôn khớp với số liệu của Manager.
 *
 * Ngược lại, thẻ "Lượt đặt phòng", biểu đồ "Xu hướng lượt đặt phòng" và biểu đồ
 * "Phân bổ trạng thái đặt phòng" đo HOẠT ĐỘNG ĐẶT PHÒNG nên lọc theo ngày tạo
 * đơn (created_at).
 *
 * Mỗi thẻ KPI (đặt phòng / doanh thu) và mỗi biểu đồ có khoảng lọc riêng.
 * Chuỗi thời gian được gom nhóm tự động để biểu đồ luôn đọc được:
 * đến ~3 tháng hiển thị theo ngày, đến ~3 năm theo tháng, rộng hơn theo quý.
 * Mọi nhóm trống được điền 0 để trục thời gian liên tục.
 *
 * @author QuyPQ
 * Date: 08/07/2006
 * version: 2.0
 */
public class AdminDashboardService {

    /** Số dòng mỗi trang của danh sách chi tiết. */
    public static final int PAGE_SIZE = 20;

    /** Ngưỡng gom nhóm: đến 92 ngày → theo ngày; đến ~3 năm → theo tháng; hơn → theo quý. */
    private static final long MAX_DAY_BUCKETS = 92;
    private static final long MAX_MONTH_BUCKET_DAYS = 1100;

    private static final DateTimeFormatter DAY_LABEL_FMT = DateTimeFormatter.ofPattern("dd/MM");
    private static final DateTimeFormatter DAY_LABEL_FULL_FMT = DateTimeFormatter.ofPattern("dd/MM/yy");

    private final AdminDashboardDAO repo = new AdminDashboardDAO();

    /** Tham số truy vấn dashboard: khoảng lọc riêng của từng thẻ / biểu đồ + view chi tiết. */
    public static class DashboardQuery {
        public LocalDate bookingFrom, bookingTo;     // kỳ của thẻ "Lượt đặt phòng"
        public LocalDate revenueFrom, revenueTo;     // kỳ của thẻ "Tổng doanh thu"
        public LocalDate c1From, c1To;               // biểu đồ doanh thu theo thời gian
        public LocalDate c2From, c2To;               // biểu đồ trạng thái đặt phòng
        public LocalDate c3From, c3To;               // biểu đồ xu hướng lượt đặt phòng
        public LocalDate c4From, c4To;               // biểu đồ doanh thu theo loại phòng
        public String view;                          // accounts | active | bookings | revenue | null
        public int page = 1;
    }

    public SystemDashboardStats getStats(DashboardQuery q) {
        SystemDashboardStats stats = new SystemDashboardStats();

        // KPI tài khoản (toàn hệ thống)
        stats.setTotalAccounts(repo.getTotalAccounts());
        stats.setActiveAccounts(repo.getActiveAccounts());
        stats.setLockedAccounts(repo.getLockedAccounts());

        // KPI đặt phòng (theo ngày tạo đơn) / doanh thu (rải theo đêm lưu trú),
        // mỗi thẻ một kỳ lọc riêng
        stats.setTotalBookings(repo.getBookingCount(Date.valueOf(q.bookingFrom), Date.valueOf(q.bookingTo)));
        stats.setTotalRevenue(sumValues(revenueByDay(q.revenueFrom, q.revenueTo)));

        // Biểu đồ 1: doanh thu theo thời gian (rải theo đêm, gom nhóm tự động)
        stats.setRevenueSeries(bucketizeDaily(q.c1From, q.c1To, revenueByDay(q.c1From, q.c1To)));

        // Biểu đồ 2: phân bổ trạng thái đặt phòng
        stats.setStatusSeries(buildStatusSeries(q.c2From, q.c2To));

        // Biểu đồ 3: xu hướng lượt đặt phòng (gom nhóm tự động)
        stats.setBookingTrendSeries(buildBookingTrendSeries(q.c3From, q.c3To));

        // Biểu đồ 4: doanh thu theo loại phòng
        stats.setRoomTypeRevenueSeries(buildRoomTypeSeries(q.c4From, q.c4To));

        // Danh sách chi tiết khi bấm vào một thẻ KPI
        if (q.view != null) {
            stats.setDetail(buildDetail(q));
        }

        return stats;
    }

    /** Năm sớm nhất có đơn đặt phòng (dựng danh sách năm cho bộ lọc); fallback năm hiện tại. */
    public int getEarliestBookingYear() {
        int year = repo.getEarliestBookingYear();
        int current = LocalDate.now().getYear();
        return (year <= 0 || year > current) ? current : year;
    }

    /* =====================================================================
       CHUỖI THỜI GIAN — gom nhóm tự động + điền 0
       ===================================================================== */

    /** Chọn mức gom nhóm theo độ rộng khoảng lọc để biểu đồ không bị chi chít. */
    private String granularityFor(LocalDate from, LocalDate to) {
        long days = ChronoUnit.DAYS.between(from, to) + 1;
        if (days <= MAX_DAY_BUCKETS) {
            return AdminDashboardDAO.GRAN_DAY;
        }
        if (days <= MAX_MONTH_BUCKET_DAYS) {
            return AdminDashboardDAO.GRAN_MONTH;
        }
        return AdminDashboardDAO.GRAN_QUARTER;
    }

    /**
     * Doanh thu rải đều theo từng đêm lưu trú trong [from, to] (key yyyy-MM-dd).
     *
     * Mỗi đơn đã ghi nhận đóng góp {@code total_amount / số đêm} cho mỗi đêm,
     * và chỉ những đêm nằm trong khoảng lọc mới được cộng — nên một đơn vắt qua
     * biên kỳ được chia đúng tỷ lệ giữa hai kỳ. Đơn 0 đêm bị bỏ qua.
     * Đây là chuẩn dùng chung với DashboardService của Manager.
     */
    private Map<String, Double> revenueByDay(LocalDate from, LocalDate to) {
        Map<String, Double> daily = new LinkedHashMap<>();
        for (Object[] stay : repo.getStaysOverlapping(Date.valueOf(from), Date.valueOf(to))) {
            LocalDate checkIn = ((Date) stay[0]).toLocalDate();
            LocalDate checkOut = ((Date) stay[1]).toLocalDate();
            double amount = (Double) stay[2];

            long nights = ChronoUnit.DAYS.between(checkIn, checkOut);
            if (nights <= 0) {
                continue;
            }
            double perNight = amount / nights;

            LocalDate start = checkIn.isBefore(from) ? from : checkIn;
            LocalDate end = checkOut.isAfter(to.plusDays(1)) ? to.plusDays(1) : checkOut;
            for (LocalDate d = start; d.isBefore(end); d = d.plusDays(1)) {
                daily.merge(d.toString(), perNight, Double::sum);
            }
        }
        return daily;
    }

    private double sumValues(Map<String, Double> daily) {
        double total = 0d;
        for (Double v : daily.values()) {
            total += v;
        }
        return total;
    }

    /**
     * Gom chuỗi doanh thu theo ngày (key yyyy-MM-dd) thành chuỗi biểu đồ theo
     * mức gom nhóm tự động, cộng dồn trong nhóm; nhóm trống điền 0.
     */
    private ChartSeries bucketizeDaily(LocalDate from, LocalDate to, Map<String, Double> daily) {
        String gran = granularityFor(from, to);
        ChartSeries s = new ChartSeries();
        s.setFromDate(from.toString());
        s.setToDate(to.toString());
        s.setGranularity(gran);

        if (AdminDashboardDAO.GRAN_DAY.equals(gran)) {
            s.setGranularityLabel("Theo ngày");
            DateTimeFormatter fmt = from.getYear() == to.getYear() ? DAY_LABEL_FMT : DAY_LABEL_FULL_FMT;
            for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                s.getLabels().add(d.format(fmt));
                s.getValues().add(daily.getOrDefault(d.toString(), 0d));
            }
            return s;
        }

        // Gom theo tháng / quý: cộng dồn giá trị từng ngày vào nhóm tương ứng
        Map<String, Double> buckets = new LinkedHashMap<>();
        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            String key = AdminDashboardDAO.GRAN_MONTH.equals(gran)
                    ? YearMonth.from(d).toString()
                    : d.getYear() + "-Q" + ((d.getMonthValue() - 1) / 3 + 1);
            buckets.merge(key, daily.getOrDefault(d.toString(), 0d), Double::sum);
        }

        s.setGranularityLabel(AdminDashboardDAO.GRAN_MONTH.equals(gran) ? "Theo tháng" : "Theo quý");
        for (Map.Entry<String, Double> e : buckets.entrySet()) {
            String label;
            if (AdminDashboardDAO.GRAN_MONTH.equals(gran)) {
                YearMonth ym = YearMonth.parse(e.getKey());
                label = String.format("%02d/%d", ym.getMonthValue(), ym.getYear());
            } else {
                String[] parts = e.getKey().split("-");
                label = parts[1] + "/" + parts[0];
            }
            s.getLabels().add(label);
            s.getValues().add(e.getValue());
        }
        return s;
    }

    /**
     * Chuỗi số lượt đặt phòng theo thời gian trong [from, to] (theo ngày tạo
     * đơn), điền 0 cho nhóm trống.
     */
    private ChartSeries buildBookingTrendSeries(LocalDate from, LocalDate to) {
        String gran = granularityFor(from, to);
        Map<String, Double> raw = repo.getBookingSeries(Date.valueOf(from), Date.valueOf(to), gran);

        ChartSeries s = new ChartSeries();
        s.setFromDate(from.toString());
        s.setToDate(to.toString());
        s.setGranularity(gran);

        switch (gran) {
            case AdminDashboardDAO.GRAN_MONTH:
                s.setGranularityLabel("Theo tháng");
                for (YearMonth ym = YearMonth.from(from); !ym.isAfter(YearMonth.from(to)); ym = ym.plusMonths(1)) {
                    s.getLabels().add(String.format("%02d/%d", ym.getMonthValue(), ym.getYear()));
                    s.getValues().add(raw.getOrDefault(ym.toString(), 0d));
                }
                break;
            case AdminDashboardDAO.GRAN_QUARTER:
                s.setGranularityLabel("Theo quý");
                int year = from.getYear();
                int quarter = (from.getMonthValue() - 1) / 3 + 1;
                int endYear = to.getYear();
                int endQuarter = (to.getMonthValue() - 1) / 3 + 1;
                while (year < endYear || (year == endYear && quarter <= endQuarter)) {
                    s.getLabels().add("Q" + quarter + "/" + year);
                    s.getValues().add(raw.getOrDefault(year + "-Q" + quarter, 0d));
                    quarter++;
                    if (quarter > 4) {
                        quarter = 1;
                        year++;
                    }
                }
                break;
            default: // ngày
                s.setGranularityLabel("Theo ngày");
                DateTimeFormatter fmt = from.getYear() == to.getYear() ? DAY_LABEL_FMT : DAY_LABEL_FULL_FMT;
                for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                    s.getLabels().add(d.format(fmt));
                    s.getValues().add(raw.getOrDefault(d.toString(), 0d));
                }
                break;
        }
        return s;
    }

    /* =====================================================================
       BIỂU ĐỒ PHÂN BỔ
       ===================================================================== */

    /** Nhãn tiếng Việt cho trạng thái đặt phòng; trạng thái lạ giữ nguyên. */
    private String statusLabel(String status) {
        if (status == null) return "Không rõ";
        switch (status) {
            case "Pending":    return "Chờ xử lý";
            case "Confirmed":  return "Đã xác nhận";
            case "Rejected":   return "Từ chối";
            case "Cancelled":  return "Đã hủy";
            case "CheckedIn":  return "Đã nhận phòng";
            case "CheckedOut": return "Đã trả phòng";
            default:           return status;
        }
    }

    private ChartSeries buildStatusSeries(LocalDate from, LocalDate to) {
        ChartSeries s = new ChartSeries();
        s.setFromDate(from.toString());
        s.setToDate(to.toString());
        Map<String, Integer> raw = repo.getBookingStatusCounts(Date.valueOf(from), Date.valueOf(to));
        // Gộp các trạng thái trùng nhãn sau khi dịch (phòng dữ liệu bẩn)
        Map<String, Double> merged = new LinkedHashMap<>();
        for (Map.Entry<String, Integer> e : raw.entrySet()) {
            merged.merge(statusLabel(e.getKey()), (double) e.getValue(), Double::sum);
        }
        for (Map.Entry<String, Double> e : merged.entrySet()) {
            s.getLabels().add(e.getKey());
            s.getValues().add(e.getValue());
        }
        return s;
    }

    private ChartSeries buildRoomTypeSeries(LocalDate from, LocalDate to) {
        ChartSeries s = new ChartSeries();
        s.setFromDate(from.toString());
        s.setToDate(to.toString());
        Map<String, Double> raw = repo.getRevenueByRoomType(Date.valueOf(from), Date.valueOf(to));
        for (Map.Entry<String, Double> e : raw.entrySet()) {
            s.getLabels().add(e.getKey());
            s.getValues().add(e.getValue());
        }
        return s;
    }

    /* =====================================================================
       DANH SÁCH CHI TIẾT — render backend, phân trang PAGE_SIZE dòng / trang
       ===================================================================== */

    private static final DateTimeFormatter VN_DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private DetailTable buildDetail(DashboardQuery q) {
        DetailTable d = new DetailTable();
        d.setView(q.view);

        int total;
        LocalDate from = null;
        LocalDate to = null;
        boolean revenueOnly = false;

        switch (q.view) {
            case "accounts":
                d.setTitle("Danh sách tài khoản");
                total = repo.getTotalAccounts();
                break;
            case "active":
                d.setTitle("Tài khoản đang hoạt động");
                total = repo.getActiveAccounts();
                break;
            case "bookings":
                d.setTitle("Lượt đặt phòng trong kỳ");
                from = q.bookingFrom;
                to = q.bookingTo;
                total = repo.getBookingCount(Date.valueOf(from), Date.valueOf(to));
                break;
            case "revenue":
                d.setTitle("Đơn được tính doanh thu trong kỳ");
                from = q.revenueFrom;
                to = q.revenueTo;
                revenueOnly = true;
                // Cùng điều kiện lọc với getRevenueBookingsPage bên dưới nên
                // tổng số dòng luôn khớp danh sách hiển thị.
                total = repo.getRevenueBookingCount(Date.valueOf(from), Date.valueOf(to));
                break;
            default:
                return null;
        }

        if (from != null) {
            d.setSubtitle(from.format(VN_DATE) + " – " + to.format(VN_DATE));
        }

        int totalPages = (int) Math.ceil(total / (double) PAGE_SIZE);
        int page = Math.max(1, Math.min(q.page, Math.max(totalPages, 1)));
        int offset = (page - 1) * PAGE_SIZE;

        d.setTotalRows(total);
        d.setTotalPages(totalPages);
        d.setPage(page);

        if (total > 0) {
            if (d.isAccountView()) {
                d.setAccounts(repo.getAccountsPage("active".equals(q.view), offset, PAGE_SIZE));
            } else if (revenueOnly) {
                d.setBookings(repo.getRevenueBookingsPage(Date.valueOf(from), Date.valueOf(to),
                        offset, PAGE_SIZE));
            } else {
                d.setBookings(repo.getBookingsPage(Date.valueOf(from), Date.valueOf(to),
                        offset, PAGE_SIZE));
            }
        }
        return d;
    }
}
