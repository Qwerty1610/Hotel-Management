package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.DashboardDAO;
import com.mycompany.hotelmanagement.entity.DashboardStats;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.ChartSeries;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.DetailTable;

import java.sql.Date;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DashboardService
 * Tổng hợp số liệu cho trang Tổng quan của Manager.
 *
 * KPI tính trên một kỳ báo cáo chung: doanh thu được rải đều theo từng đêm
 * lưu trú (proration) nên tổng doanh thu, RevPAR và ADR phản ánh đúng phần
 * doanh thu thuộc về kỳ; công suất tính theo phòng-đêm thực chiếm mỗi ngày.
 *   RevPAR = doanh thu kỳ / (tổng phòng × số ngày kỳ)
 *   ADR    = doanh thu kỳ / số phòng-đêm đã bán trong kỳ
 *   Tỷ lệ hủy = số đơn Cancelled/Rejected tạo trong kỳ / tổng đơn tạo trong kỳ
 *
 * Chuỗi thời gian của biểu đồ được gom nhóm tự động để luôn đọc được:
 * đến ~3 tháng hiển thị theo ngày, đến ~3 năm theo tháng, rộng hơn theo quý
 * (doanh thu cộng dồn theo nhóm, công suất lấy trung bình theo nhóm).
 *
 * Date: 22/07/2026
 * version 2.0
 * @author Pham Quoc Quy
 */
public class DashboardService {

    /** Số dòng mỗi trang của danh sách chi tiết. */
    public static final int PAGE_SIZE = 20;

    /** Số dịch vụ hiển thị trong bảng top dịch vụ. */
    public static final int TOP_SERVICE_LIMIT = 5;

    /** Ngưỡng gom nhóm: đến 92 ngày → theo ngày; đến ~3 năm → theo tháng; hơn → theo quý. */
    private static final long MAX_DAY_BUCKETS = 92;
    private static final long MAX_MONTH_BUCKET_DAYS = 1100;

    private static final String GRAN_DAY = "day";
    private static final String GRAN_MONTH = "month";
    private static final String GRAN_QUARTER = "quarter";

    private static final DateTimeFormatter DAY_LABEL_FMT = DateTimeFormatter.ofPattern("dd/MM");
    private static final DateTimeFormatter DAY_LABEL_FULL_FMT = DateTimeFormatter.ofPattern("dd/MM/yy");
    private static final DateTimeFormatter VN_DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final DashboardDAO repo = new DashboardDAO();

    /** Tham số truy vấn dashboard: kỳ KPI chung + khoảng lọc riêng của 4 biểu đồ + view chi tiết. */
    public static class DashboardQuery {
        public LocalDate kpiFrom, kpiTo;   // kỳ báo cáo chung của các thẻ KPI
        public LocalDate c1From, c1To;     // biểu đồ doanh thu theo thời gian
        public LocalDate c2From, c2To;     // biểu đồ công suất phòng theo thời gian
        public LocalDate c3From, c3To;     // biểu đồ doanh thu theo loại phòng
        public LocalDate c4From, c4To;     // cơ cấu doanh thu + top dịch vụ
        public String view;                // revenue | cancelled | null
        public int page = 1;
    }

    public DashboardStats getStats(DashboardQuery q) {
        DashboardStats stats = new DashboardStats();

        int totalRooms = repo.getTotalRooms();
        stats.setTotalRooms(totalRooms);

        // ----- KPI theo kỳ báo cáo chung -----
        Date kpiFrom = Date.valueOf(q.kpiFrom);
        Date kpiTo = Date.valueOf(q.kpiTo);
        DailyAggregate agg = aggregateDaily(repo.getStaysOverlapping(kpiFrom, kpiTo), q.kpiFrom, q.kpiTo, totalRooms);

        long days = ChronoUnit.DAYS.between(q.kpiFrom, q.kpiTo) + 1;
        stats.setTotalRevenue(agg.totalRevenue);
        stats.setRoomNightsSold(agg.roomNights);
        stats.setAvgOccupancy(round1(agg.occupancySum / days));
        stats.setRevPar(totalRooms > 0 ? agg.totalRevenue / (totalRooms * days) : 0d);
        stats.setAdr(agg.roomNights > 0 ? agg.totalRevenue / agg.roomNights : 0d);
        stats.setRevenueBookings(repo.getRevenueBookingCount(kpiFrom, kpiTo));

        int created = repo.getCreatedBookingCount(kpiFrom, kpiTo);
        int cancelled = repo.getCancelledBookingCount(kpiFrom, kpiTo);
        stats.setCreatedBookings(created);
        stats.setCancelledBookings(cancelled);
        stats.setCancellationRate(created > 0 ? round1(cancelled * 100d / created) : 0d);

        // ----- Biểu đồ 1: doanh thu theo thời gian (rải theo đêm, gom nhóm tự động) -----
        DailyAggregate c1 = aggregateDaily(repo.getStaysOverlapping(Date.valueOf(q.c1From), Date.valueOf(q.c1To)),
                q.c1From, q.c1To, totalRooms);
        stats.setRevenueSeries(bucketize(q.c1From, q.c1To, c1.revenueByDay, false));

        // ----- Biểu đồ 2: công suất phòng theo thời gian (trung bình theo nhóm) -----
        DailyAggregate c2 = aggregateDaily(repo.getStaysOverlapping(Date.valueOf(q.c2From), Date.valueOf(q.c2To)),
                q.c2From, q.c2To, totalRooms);
        stats.setOccupancySeries(bucketize(q.c2From, q.c2To, c2.occupancyByDay, true));

        // ----- Biểu đồ 3: doanh thu theo loại phòng (prorate trong SQL) -----
        stats.setRoomTypeRevenueSeries(buildCategorySeries(q.c3From, q.c3To,
                repo.getRevenueByRoomType(Date.valueOf(q.c3From), Date.valueOf(q.c3To)), null));

        // ----- Biểu đồ 4: cơ cấu doanh thu theo hóa đơn + top dịch vụ -----
        Map<String, String> mixLabels = new LinkedHashMap<>();
        mixLabels.put("Room", "Tiền phòng");
        mixLabels.put("Service", "Dịch vụ");
        mixLabels.put("Surcharge", "Phụ phí");
        stats.setRevenueMixSeries(buildCategorySeries(q.c4From, q.c4To,
                repo.getInvoiceRevenueMix(Date.valueOf(q.c4From), Date.valueOf(q.c4To)), mixLabels));
        stats.setTopServices(repo.getTopServices(Date.valueOf(q.c4From), Date.valueOf(q.c4To), TOP_SERVICE_LIMIT));

        // ----- Danh sách chi tiết khi bấm vào một thẻ KPI -----
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
       RẢI DOANH THU / CÔNG SUẤT THEO TỪNG NGÀY
       ===================================================================== */

    /** Kết quả duyệt các kỳ lưu trú trên một khoảng ngày. */
    private static class DailyAggregate {
        Map<String, Double> revenueByDay = new LinkedHashMap<>();   // key yyyy-MM-dd
        Map<String, Double> occupancyByDay = new LinkedHashMap<>(); // key yyyy-MM-dd, giá trị %
        double totalRevenue;
        int roomNights;
        double occupancySum; // tổng % công suất các ngày (chia số ngày = trung bình)
    }

    /**
     * Duyệt các kỳ lưu trú [check_in, check_out) giao với [from, to]:
     * doanh thu mỗi đơn rải đều theo đêm (amount / tổng số đêm), số phòng
     * chiếm mỗi ngày cộng theo room_quantity. Đơn 0 đêm bị bỏ qua.
     */
    private DailyAggregate aggregateDaily(List<Object[]> stays, LocalDate from, LocalDate to, int totalRooms) {
        DailyAggregate agg = new DailyAggregate();
        Map<String, Integer> occupiedByDay = new LinkedHashMap<>();

        for (Object[] stay : stays) {
            LocalDate checkIn = ((Date) stay[0]).toLocalDate();
            LocalDate checkOut = ((Date) stay[1]).toLocalDate();
            int qty = (Integer) stay[2];
            double amount = (Double) stay[3];

            long nights = ChronoUnit.DAYS.between(checkIn, checkOut);
            if (nights <= 0) {
                continue;
            }
            double perNight = amount / nights;

            LocalDate start = checkIn.isBefore(from) ? from : checkIn;
            LocalDate end = checkOut.isAfter(to.plusDays(1)) ? to.plusDays(1) : checkOut;
            for (LocalDate d = start; d.isBefore(end); d = d.plusDays(1)) {
                String key = d.toString();
                agg.revenueByDay.merge(key, perNight, Double::sum);
                occupiedByDay.merge(key, qty, Integer::sum);
                agg.totalRevenue += perNight;
                agg.roomNights += qty;
            }
        }

        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            int occupied = occupiedByDay.getOrDefault(d.toString(), 0);
            double pct = totalRooms > 0 ? Math.min(100d, occupied * 100d / totalRooms) : 0d;
            agg.occupancyByDay.put(d.toString(), round1(pct));
            agg.occupancySum += pct;
        }
        return agg;
    }

    /* =====================================================================
       CHUỖI THỜI GIAN — gom nhóm tự động từ dữ liệu theo ngày
       ===================================================================== */

    /** Chọn mức gom nhóm theo độ rộng khoảng lọc để biểu đồ không bị chi chít. */
    private String granularityFor(LocalDate from, LocalDate to) {
        long days = ChronoUnit.DAYS.between(from, to) + 1;
        if (days <= MAX_DAY_BUCKETS) {
            return GRAN_DAY;
        }
        if (days <= MAX_MONTH_BUCKET_DAYS) {
            return GRAN_MONTH;
        }
        return GRAN_QUARTER;
    }

    /**
     * Gom chuỗi theo ngày (key yyyy-MM-dd) thành chuỗi biểu đồ theo mức
     * gom nhóm tự động; nhóm trống điền 0. average=true lấy trung bình
     * trong nhóm (công suất %), ngược lại cộng dồn (doanh thu).
     */
    private ChartSeries bucketize(LocalDate from, LocalDate to, Map<String, Double> daily, boolean average) {
        String gran = granularityFor(from, to);
        ChartSeries s = new ChartSeries();
        s.setFromDate(from.toString());
        s.setToDate(to.toString());
        s.setGranularity(gran);

        if (GRAN_DAY.equals(gran)) {
            s.setGranularityLabel("Theo ngày");
            DateTimeFormatter fmt = from.getYear() == to.getYear() ? DAY_LABEL_FMT : DAY_LABEL_FULL_FMT;
            for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                s.getLabels().add(d.format(fmt));
                s.getValues().add(daily.getOrDefault(d.toString(), 0d));
            }
            return s;
        }

        // Gom theo tháng / quý: cộng dồn giá trị và đếm ngày của từng nhóm
        Map<String, double[]> buckets = new LinkedHashMap<>(); // key nhóm -> [tổng, số ngày]
        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            String key = GRAN_MONTH.equals(gran)
                    ? YearMonth.from(d).toString()
                    : d.getYear() + "-Q" + ((d.getMonthValue() - 1) / 3 + 1);
            double[] b = buckets.computeIfAbsent(key, k -> new double[2]);
            b[0] += daily.getOrDefault(d.toString(), 0d);
            b[1]++;
        }

        s.setGranularityLabel(GRAN_MONTH.equals(gran) ? "Theo tháng" : "Theo quý");
        for (Map.Entry<String, double[]> e : buckets.entrySet()) {
            String key = e.getKey();
            String label;
            if (GRAN_MONTH.equals(gran)) {
                YearMonth ym = YearMonth.parse(key);
                label = String.format("%02d/%d", ym.getMonthValue(), ym.getYear());
            } else {
                String[] parts = key.split("-");
                label = parts[1] + "/" + parts[0];
            }
            s.getLabels().add(label);
            double value = average ? e.getValue()[0] / e.getValue()[1] : e.getValue()[0];
            s.getValues().add(average ? round1(value) : value);
        }
        return s;
    }

    /* =====================================================================
       BIỂU ĐỒ PHÂN BỔ THEO NHÓM (loại phòng / cơ cấu doanh thu)
       ===================================================================== */

    /**
     * Chuỗi phân bổ theo nhóm; nếu truyền labelMap thì key được dịch sang
     * nhãn tiếng Việt (key lạ giữ nguyên).
     */
    private ChartSeries buildCategorySeries(LocalDate from, LocalDate to,
                                            Map<String, Double> raw, Map<String, String> labelMap) {
        ChartSeries s = new ChartSeries();
        s.setFromDate(from.toString());
        s.setToDate(to.toString());
        for (Map.Entry<String, Double> e : raw.entrySet()) {
            String label = labelMap != null
                    ? labelMap.getOrDefault(e.getKey(), e.getKey())
                    : e.getKey();
            s.getLabels().add(label);
            s.getValues().add(e.getValue());
        }
        return s;
    }

    /* =====================================================================
       DANH SÁCH CHI TIẾT — render backend, phân trang PAGE_SIZE dòng / trang
       ===================================================================== */

    private DetailTable buildDetail(DashboardQuery q) {
        DetailTable d = new DetailTable();
        d.setView(q.view);

        Date from = Date.valueOf(q.kpiFrom);
        Date to = Date.valueOf(q.kpiTo);
        d.setSubtitle(q.kpiFrom.format(VN_DATE) + " – " + q.kpiTo.format(VN_DATE));

        int total;
        switch (q.view) {
            case "revenue":
                d.setTitle("Đơn được tính doanh thu trong kỳ");
                total = repo.getRevenueBookingCount(from, to);
                break;
            case "cancelled":
                d.setTitle("Đơn hủy / từ chối trong kỳ");
                total = repo.getCancelledBookingCount(from, to);
                break;
            default:
                return null;
        }

        int totalPages = (int) Math.ceil(total / (double) PAGE_SIZE);
        int page = Math.max(1, Math.min(q.page, Math.max(totalPages, 1)));
        int offset = (page - 1) * PAGE_SIZE;

        d.setTotalRows(total);
        d.setTotalPages(totalPages);
        d.setPage(page);

        if (total > 0) {
            d.setBookings("revenue".equals(q.view)
                    ? repo.getRevenueBookingsPage(from, to, offset, PAGE_SIZE)
                    : repo.getCancelledBookingsPage(from, to, offset, PAGE_SIZE));
        }
        return d;
    }

    private double round1(double v) {
        return Math.round(v * 10d) / 10d;
    }
}
