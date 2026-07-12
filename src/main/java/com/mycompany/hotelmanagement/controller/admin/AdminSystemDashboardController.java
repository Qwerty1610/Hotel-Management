package com.mycompany.hotelmanagement.controller.admin;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.SystemDashboardStats;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.Period;
import com.mycompany.hotelmanagement.service.AdminDashboardService;
import com.mycompany.hotelmanagement.service.AdminDashboardService.DashboardQuery;

/**
 * AdminSystemDashboardController
 * Bảng điều khiển hệ thống của Admin (UC 2.7.4 - View System Dashboard).
 *
 * Mỗi thẻ KPI đặt phòng / doanh thu có bộ lọc kỳ riêng (tháng / quý / năm /
 * tùy chỉnh, tiền tố tham số {@code bk} / {@code rv}); mỗi biểu đồ có khoảng
 * lọc riêng (tiền tố {@code c1}..{@code c4}). Bấm vào một thẻ KPI mở danh sách
 * chi tiết render ở backend, phân trang ({@code view} + {@code page}).
 *
 * Quyền truy cập (role ADMIN) được kiểm soát bởi AuthFilter (E1 - BR/OR-20).
 *
 * @author QuyPQ
 */
@WebServlet(name = "AdminSystemDashboardController", urlPatterns = {"/admin/system-dashboard"})
public class AdminSystemDashboardController extends HttpServlet {

    private static final Pattern QUARTER_PATTERN = Pattern.compile("(\\d{4})-Q([1-4])");
    private static final DateTimeFormatter VN_DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final AdminDashboardService dashboardService = new AdminDashboardService();

    /** Kỳ lọc đã phân giải của một thẻ KPI: giá trị echo cho form + khoảng ngày để truy vấn. */
    private static class ResolvedPeriod {
        Period period = new Period();
        LocalDate from;
        LocalDate to;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate today = LocalDate.now();
        DashboardQuery q = new DashboardQuery();

        // Bộ lọc kỳ riêng của 2 thẻ KPI
        ResolvedPeriod bk = resolvePeriod(request, "bk", today);
        ResolvedPeriod rv = resolvePeriod(request, "rv", today);
        q.bookingFrom = bk.from;
        q.bookingTo = bk.to;
        q.revenueFrom = rv.from;
        q.revenueTo = rv.to;

        // Khoảng lọc riêng của 4 biểu đồ
        LocalDate[] c1 = resolveRange(request, "c1", today.minusDays(29), today);
        LocalDate[] c2 = resolveRange(request, "c2", today.minusDays(29), today);
        LocalDate[] c3 = resolveRange(request, "c3", today.minusDays(364), today);
        LocalDate[] c4 = resolveRange(request, "c4", today.minusDays(89), today);
        q.c1From = c1[0]; q.c1To = c1[1];
        q.c2From = c2[0]; q.c2To = c2[1];
        q.c3From = c3[0]; q.c3To = c3[1];
        q.c4From = c4[0]; q.c4To = c4[1];

        // Danh sách chi tiết khi bấm vào một thẻ KPI
        q.view = whitelistView(request.getParameter("view"));
        q.page = parsePositiveInt(request.getParameter("page"), 1);

        SystemDashboardStats stats = dashboardService.getStats(q);
        stats.setBookingPeriod(bk.period);
        stats.setRevenuePeriod(rv.period);

        // Danh sách năm / quý cho ô chọn của bộ lọc thẻ
        int earliestYear = dashboardService.getEarliestBookingYear();
        request.setAttribute("yearOptions", buildYearOptions(earliestYear, today.getYear()));
        request.setAttribute("quarterOptions", buildQuarterOptions(earliestYear, today));

        // Chuỗi query chuẩn hóa (không gồm view/page) để dựng link thẻ KPI & phân trang.
        // Dựng lại từ giá trị đã phân giải nên không mang dữ liệu thô từ người dùng.
        request.setAttribute("baseQuery", buildBaseQuery(bk, rv, c1, c2, c3, c4));

        request.setAttribute("stats", stats);
        request.setAttribute("activePage", "system-dashboard");

        request.getRequestDispatcher("/WEB-INF/views/dashboard/admin-system.jsp")
               .forward(request, response);
    }

    /* =====================================================================
       PHÂN GIẢI BỘ LỌC
       ===================================================================== */

    /**
     * Đọc bộ lọc kỳ của một thẻ KPI theo tiền tố ({@code bk} / {@code rv}):
     * {@code <p>Mode} = month | quarter | year | custom cùng giá trị tương ứng
     * {@code <p>Month} (yyyy-MM), {@code <p>Quarter} (yyyy-Qn), {@code <p>Year},
     * {@code <p>From}/{@code <p>To}. Giá trị thiếu / sai định dạng rơi về mặc định.
     */
    private ResolvedPeriod resolvePeriod(HttpServletRequest request, String prefix, LocalDate today) {
        ResolvedPeriod r = new ResolvedPeriod();
        String mode = request.getParameter(prefix + "Mode");
        if (!"quarter".equals(mode) && !"year".equals(mode) && !"custom".equals(mode)) {
            mode = "month";
        }
        r.period.setMode(mode);

        switch (mode) {
            case "quarter": {
                int year = today.getYear();
                int quarter = (today.getMonthValue() - 1) / 3 + 1;
                String rawQuarter = request.getParameter(prefix + "Quarter");
                if (rawQuarter != null) {
                    Matcher m = QUARTER_PATTERN.matcher(rawQuarter.trim());
                    if (m.matches()) {
                        year = Integer.parseInt(m.group(1));
                        quarter = Integer.parseInt(m.group(2));
                    }
                }
                r.from = LocalDate.of(year, (quarter - 1) * 3 + 1, 1);
                r.to = r.from.plusMonths(3).minusDays(1);
                r.period.setQuarterValue(year + "-Q" + quarter);
                r.period.setLabel("Quý " + quarter + "/" + year);
                break;
            }
            case "year": {
                int year = parsePositiveInt(request.getParameter(prefix + "Year"), today.getYear());
                if (year < 2000 || year > 2100) {
                    year = today.getYear();
                }
                r.from = LocalDate.of(year, 1, 1);
                r.to = LocalDate.of(year, 12, 31);
                r.period.setYearValue(String.valueOf(year));
                r.period.setLabel("Năm " + year);
                break;
            }
            case "custom": {
                LocalDate from = parseDate(request.getParameter(prefix + "From"), today.minusDays(29));
                LocalDate to = parseDate(request.getParameter(prefix + "To"), today);
                if (from.isAfter(to)) {
                    LocalDate tmp = from;
                    from = to;
                    to = tmp;
                }
                r.from = from;
                r.to = to;
                r.period.setFromValue(from.toString());
                r.period.setToValue(to.toString());
                r.period.setLabel(from.format(VN_DATE) + " – " + to.format(VN_DATE));
                break;
            }
            default: { // month
                YearMonth ym = YearMonth.from(today);
                String rawMonth = request.getParameter(prefix + "Month");
                if (rawMonth != null && !rawMonth.trim().isEmpty()) {
                    try {
                        ym = YearMonth.parse(rawMonth.trim());
                    } catch (DateTimeParseException e) {
                        // giữ tháng hiện tại
                    }
                }
                r.from = ym.atDay(1);
                r.to = ym.atEndOfMonth();
                r.period.setMonthValue(ym.toString());
                r.period.setLabel(String.format("Tháng %02d/%d", ym.getMonthValue(), ym.getYear()));
                break;
            }
        }
        return r;
    }

    /** Khoảng lọc [from, to] của một biểu đồ theo tiền tố ({@code c1}..{@code c4}). */
    private LocalDate[] resolveRange(HttpServletRequest request, String prefix,
                                     LocalDate defaultFrom, LocalDate defaultTo) {
        LocalDate from = parseDate(request.getParameter(prefix + "From"), defaultFrom);
        LocalDate to = parseDate(request.getParameter(prefix + "To"), defaultTo);
        if (from.isAfter(to)) {
            LocalDate tmp = from;
            from = to;
            to = tmp;
        }
        return new LocalDate[]{from, to};
    }

    private String whitelistView(String view) {
        if ("accounts".equals(view) || "active".equals(view)
                || "bookings".equals(view) || "revenue".equals(view)) {
            return view;
        }
        return null;
    }

    private LocalDate parseDate(String value, LocalDate fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException e) {
            return fallback;
        }
    }

    private int parsePositiveInt(String value, int fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : fallback;
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    /* =====================================================================
       DỰNG DỮ LIỆU CHO VIEW
       ===================================================================== */

    /** Danh sách năm cho ô chọn (mới nhất trước). */
    private List<String> buildYearOptions(int earliestYear, int currentYear) {
        List<String> years = new ArrayList<>();
        for (int y = currentYear; y >= earliestYear; y--) {
            years.add(String.valueOf(y));
        }
        return years;
    }

    /** Danh sách quý [value, label] từ quý hiện tại lùi về quý 1 của năm sớm nhất. */
    private List<String[]> buildQuarterOptions(int earliestYear, LocalDate today) {
        List<String[]> options = new ArrayList<>();
        int year = today.getYear();
        int quarter = (today.getMonthValue() - 1) / 3 + 1;
        while (year > earliestYear || (year == earliestYear && quarter >= 1)) {
            options.add(new String[]{year + "-Q" + quarter, "Quý " + quarter + "/" + year});
            quarter--;
            if (quarter < 1) {
                quarter = 4;
                year--;
            }
        }
        return options;
    }

    /**
     * Chuỗi query gồm toàn bộ bộ lọc hiện hành (trừ view/page), kết thúc bằng
     * {@code &} nếu khác rỗng — JSP chỉ cần nối {@code view=...&page=...}.
     */
    private String buildBaseQuery(ResolvedPeriod bk, ResolvedPeriod rv,
                                  LocalDate[] c1, LocalDate[] c2, LocalDate[] c3, LocalDate[] c4) {
        StringBuilder sb = new StringBuilder();
        appendPeriod(sb, "bk", bk.period);
        appendPeriod(sb, "rv", rv.period);
        appendParam(sb, "c1From", c1[0].toString());
        appendParam(sb, "c1To", c1[1].toString());
        appendParam(sb, "c2From", c2[0].toString());
        appendParam(sb, "c2To", c2[1].toString());
        appendParam(sb, "c3From", c3[0].toString());
        appendParam(sb, "c3To", c3[1].toString());
        appendParam(sb, "c4From", c4[0].toString());
        appendParam(sb, "c4To", c4[1].toString());
        return sb.toString();
    }

    private void appendPeriod(StringBuilder sb, String prefix, Period p) {
        appendParam(sb, prefix + "Mode", p.getMode());
        switch (p.getMode()) {
            case "quarter":
                appendParam(sb, prefix + "Quarter", p.getQuarterValue());
                break;
            case "year":
                appendParam(sb, prefix + "Year", p.getYearValue());
                break;
            case "custom":
                appendParam(sb, prefix + "From", p.getFromValue());
                appendParam(sb, prefix + "To", p.getToValue());
                break;
            default:
                appendParam(sb, prefix + "Month", p.getMonthValue());
                break;
        }
    }

    private void appendParam(StringBuilder sb, String name, String value) {
        if (value == null) {
            return;
        }
        sb.append(URLEncoder.encode(name, StandardCharsets.UTF_8))
          .append('=')
          .append(URLEncoder.encode(value, StandardCharsets.UTF_8))
          .append('&');
    }
}
