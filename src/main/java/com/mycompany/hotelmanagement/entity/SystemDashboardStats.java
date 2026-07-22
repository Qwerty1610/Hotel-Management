package com.mycompany.hotelmanagement.entity;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * SystemDashboardStats
 * Tổng hợp số liệu giám sát toàn hệ thống cho Bảng điều khiển của Admin (UC 2.7.4).
 *
 * Các chỉ số tài khoản phản ánh trạng thái toàn hệ thống (mọi thời điểm).
 * Thẻ "Lượt đặt phòng" và "Tổng doanh thu" có bộ lọc kỳ riêng (tháng / quý / năm /
 * tùy chỉnh — {@link Period}); mỗi biểu đồ có khoảng lọc riêng và chuỗi dữ liệu
 * đã gom nhóm tự động theo ngày / tháng / quý ({@link ChartSeries}).
 * Khi Admin bấm vào một thẻ KPI, {@link DetailTable} chứa danh sách chi tiết
 * tương ứng, render ở backend và phân trang 20 dòng / trang.
 *
 * @author QuyPQ
 * Date: 08/07/2006
 * version: 1.1
 */
public class SystemDashboardStats {

    /* ---------- KPI tài khoản (toàn hệ thống) ---------- */
    private int totalAccounts;       // Tổng số tài khoản
    private int activeAccounts;      // Số tài khoản đang hoạt động
    private int lockedAccounts;      // Số tài khoản bị khóa

    /* ---------- KPI đặt phòng / doanh thu (theo kỳ lọc riêng của từng thẻ) ---------- */
    private int totalBookings;       // Tổng số lượt đặt phòng trong kỳ của thẻ
    private double totalRevenue;     // Tổng doanh thu ghi nhận trong kỳ của thẻ

    /* ---------- Bộ lọc kỳ của 2 thẻ KPI ---------- */
    private Period bookingPeriod;
    private Period revenuePeriod;

    /* ---------- 4 biểu đồ, mỗi biểu đồ một khoảng lọc riêng ---------- */
    private ChartSeries revenueSeries;         // Doanh thu theo thời gian
    private ChartSeries statusSeries;          // Phân bổ trạng thái đặt phòng
    private ChartSeries bookingTrendSeries;    // Xu hướng lượt đặt phòng
    private ChartSeries roomTypeRevenueSeries; // Doanh thu theo loại phòng

    /* ---------- Danh sách chi tiết khi bấm vào một thẻ KPI (có thể null) ---------- */
    private DetailTable detail;

    /* ---------- Getters & Setters ---------- */
    public int getTotalAccounts()              { return totalAccounts; }
    public void setTotalAccounts(int v)        { this.totalAccounts = v; }

    public int getActiveAccounts()             { return activeAccounts; }
    public void setActiveAccounts(int v)       { this.activeAccounts = v; }

    public int getLockedAccounts()             { return lockedAccounts; }
    public void setLockedAccounts(int v)       { this.lockedAccounts = v; }

    public int getTotalBookings()              { return totalBookings; }
    public void setTotalBookings(int v)        { this.totalBookings = v; }

    public double getTotalRevenue()            { return totalRevenue; }
    public void setTotalRevenue(double v)      { this.totalRevenue = v; }

    public Period getBookingPeriod()           { return bookingPeriod; }
    public void setBookingPeriod(Period v)     { this.bookingPeriod = v; }

    public Period getRevenuePeriod()           { return revenuePeriod; }
    public void setRevenuePeriod(Period v)     { this.revenuePeriod = v; }

    public ChartSeries getRevenueSeries()                 { return revenueSeries; }
    public void setRevenueSeries(ChartSeries v)           { this.revenueSeries = v; }

    public ChartSeries getStatusSeries()                  { return statusSeries; }
    public void setStatusSeries(ChartSeries v)            { this.statusSeries = v; }

    public ChartSeries getBookingTrendSeries()            { return bookingTrendSeries; }
    public void setBookingTrendSeries(ChartSeries v)      { this.bookingTrendSeries = v; }

    public ChartSeries getRoomTypeRevenueSeries()         { return roomTypeRevenueSeries; }
    public void setRoomTypeRevenueSeries(ChartSeries v)   { this.roomTypeRevenueSeries = v; }

    public DetailTable getDetail()             { return detail; }
    public void setDetail(DetailTable v)       { this.detail = v; }

    /* =====================================================================
       Kỳ lọc của một thẻ KPI: tháng / quý / năm / tùy chỉnh.
       Lưu cả giá trị thô (để render lại form) lẫn khoảng ngày đã phân giải.
       ===================================================================== */
    public static class Period {
        private String mode;         // month | quarter | year | custom
        private String monthValue;   // yyyy-MM   (mode=month)
        private String quarterValue; // yyyy-Qn   (mode=quarter)
        private String yearValue;    // yyyy      (mode=year)
        private String fromValue;    // yyyy-MM-dd (mode=custom, hiển thị lại form)
        private String toValue;      // yyyy-MM-dd
        private String label;        // Nhãn hiển thị: "Tháng 07/2026", "Quý 3/2026"...

        public String getMode()                 { return mode; }
        public void setMode(String v)           { this.mode = v; }

        public String getMonthValue()           { return monthValue; }
        public void setMonthValue(String v)     { this.monthValue = v; }

        public String getQuarterValue()         { return quarterValue; }
        public void setQuarterValue(String v)   { this.quarterValue = v; }

        public String getYearValue()            { return yearValue; }
        public void setYearValue(String v)      { this.yearValue = v; }

        public String getFromValue()            { return fromValue; }
        public void setFromValue(String v)      { this.fromValue = v; }

        public String getToValue()              { return toValue; }
        public void setToValue(String v)        { this.toValue = v; }

        public String getLabel()                { return label; }
        public void setLabel(String v)          { this.label = v; }
    }

    /* =====================================================================
       Chuỗi dữ liệu của một biểu đồ: nhãn + giá trị đã gom nhóm,
       kèm khoảng lọc (để render lại form) và mức gom nhóm đã áp dụng.
       ===================================================================== */
    public static class ChartSeries {
        private List<String> labels = new ArrayList<>();
        private List<Double> values = new ArrayList<>();
        private String fromDate;         // yyyy-MM-dd
        private String toDate;           // yyyy-MM-dd
        private String granularity;      // day | month | quarter (rỗng với biểu đồ phân bổ)
        private String granularityLabel; // "Theo ngày" / "Theo tháng" / "Theo quý"

        public List<String> getLabels()            { return labels; }
        public void setLabels(List<String> v)      { this.labels = v; }

        public List<Double> getValues()            { return values; }
        public void setValues(List<Double> v)      { this.values = v; }

        public String getFromDate()                { return fromDate; }
        public void setFromDate(String v)          { this.fromDate = v; }

        public String getToDate()                  { return toDate; }
        public void setToDate(String v)            { this.toDate = v; }

        public String getGranularity()             { return granularity; }
        public void setGranularity(String v)       { this.granularity = v; }

        public String getGranularityLabel()        { return granularityLabel; }
        public void setGranularityLabel(String v)  { this.granularityLabel = v; }

        /** true nếu mọi giá trị đều bằng 0 (không có dữ liệu trong khoảng). */
        public boolean isEmptySeries() {
            for (Double v : values) {
                if (v != null && v != 0d) return false;
            }
            return true;
        }
    }

    /* =====================================================================
       Danh sách chi tiết khi bấm một thẻ KPI (render backend, 20 dòng / trang).
       view: accounts | active | bookings | revenue.
       ===================================================================== */
    public static class DetailTable {
        private String view;
        private String title;
        private String subtitle;   // Mô tả kỳ lọc áp dụng (nếu có)
        private int page;
        private int totalPages;
        private int totalRows;
        private List<AccountRow> accounts = new ArrayList<>();
        private List<BookingRow> bookings = new ArrayList<>();

        public String getView()                    { return view; }
        public void setView(String v)              { this.view = v; }

        public String getTitle()                   { return title; }
        public void setTitle(String v)             { this.title = v; }

        public String getSubtitle()                { return subtitle; }
        public void setSubtitle(String v)          { this.subtitle = v; }

        public int getPage()                       { return page; }
        public void setPage(int v)                 { this.page = v; }

        public int getTotalPages()                 { return totalPages; }
        public void setTotalPages(int v)           { this.totalPages = v; }

        public int getTotalRows()                  { return totalRows; }
        public void setTotalRows(int v)            { this.totalRows = v; }

        public List<AccountRow> getAccounts()          { return accounts; }
        public void setAccounts(List<AccountRow> v)    { this.accounts = v; }

        public List<BookingRow> getBookings()          { return bookings; }
        public void setBookings(List<BookingRow> v)    { this.bookings = v; }

        /** true nếu danh sách này hiển thị các tài khoản (accounts / active). */
        public boolean isAccountView() {
            return "accounts".equals(view) || "active".equals(view);
        }
    }

    /** Một dòng tài khoản trong danh sách chi tiết. */
    public static class AccountRow {
        private int accountId;
        private String fullName;
        private String email;
        private String roleName;
        private boolean active;
        private Date createdAt;

        public int getAccountId()              { return accountId; }
        public void setAccountId(int v)        { this.accountId = v; }

        public String getFullName()            { return fullName; }
        public void setFullName(String v)      { this.fullName = v; }

        public String getEmail()               { return email; }
        public void setEmail(String v)         { this.email = v; }

        public String getRoleName()            { return roleName; }
        public void setRoleName(String v)      { this.roleName = v; }

        public boolean isActive()              { return active; }
        public void setActive(boolean v)       { this.active = v; }

        public Date getCreatedAt()             { return createdAt; }
        public void setCreatedAt(Date v)       { this.createdAt = v; }
    }

    /** Một dòng đặt phòng trong danh sách chi tiết. */
    public static class BookingRow {
        private int bookingId;
        private String customerName;
        private Date checkInDate;
        private Date checkOutDate;
        private double totalAmount;
        private String status;
        private Date createdAt;
        private String note;

        public int getBookingId()              { return bookingId; }
        public void setBookingId(int v)        { this.bookingId = v; }

        public String getCustomerName()        { return customerName; }
        public void setCustomerName(String v)  { this.customerName = v; }

        public Date getCheckInDate()           { return checkInDate; }
        public void setCheckInDate(Date v)     { this.checkInDate = v; }

        public Date getCheckOutDate()          { return checkOutDate; }
        public void setCheckOutDate(Date v)    { this.checkOutDate = v; }

        public double getTotalAmount()         { return totalAmount; }
        public void setTotalAmount(double v)   { this.totalAmount = v; }

        public String getStatus()              { return status; }
        public void setStatus(String v)        { this.status = v; }

        public Date getCreatedAt()             { return createdAt; }
        public void setCreatedAt(Date v)       { this.createdAt = v; }

        public String getNote()                { return note; }
        public void setNote(String v)          { this.note = v; }
    }
}
