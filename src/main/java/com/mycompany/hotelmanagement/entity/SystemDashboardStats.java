package com.mycompany.hotelmanagement.entity;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * SystemDashboardStats
 * Tổng hợp số liệu giám sát toàn hệ thống cho Bảng điều khiển của Admin (UC 2.7.4):
 * số lượng tài khoản theo vai trò, người dùng đang hoạt động, số lượt đặt phòng
 * theo trạng thái, tổng doanh thu và hoạt động gần đây.
 *
 * Các chỉ số tài khoản phản ánh trạng thái toàn hệ thống (mọi thời điểm),
 * còn các chỉ số đặt phòng / doanh thu được tính theo khoảng thời gian lọc.
 *
 * @author QuyPQ
 */
public class SystemDashboardStats {

    /* ---------- KPI tài khoản (toàn hệ thống) ---------- */
    private int totalAccounts;       // Tổng số tài khoản
    private int activeAccounts;      // Số tài khoản đang hoạt động
    private int lockedAccounts;      // Số tài khoản bị khóa

    /* ---------- KPI đặt phòng / doanh thu (theo khoảng lọc) ---------- */
    private int totalBookings;       // Tổng số lượt đặt phòng trong khoảng
    private double totalRevenue;     // Tổng doanh thu ghi nhận trong khoảng

    /* ---------- Khoảng thời gian lọc (để hiển thị lại trên form) ---------- */
    private String fromDate;
    private String toDate;

    /* ---------- Phân bổ tài khoản theo vai trò ---------- */
    private List<String> roleLabels = new ArrayList<>();
    private List<Integer> roleCounts = new ArrayList<>();

    /* ---------- Phân bổ đặt phòng theo trạng thái ---------- */
    private List<String> statusLabels = new ArrayList<>();
    private List<Integer> statusCounts = new ArrayList<>();

    /* ---------- Doanh thu theo ngày (trong khoảng lọc) ---------- */
    private List<String> dayLabels = new ArrayList<>();
    private List<Double> dayRevenue = new ArrayList<>();

    /* ---------- Hoạt động gần đây (các lượt đặt phòng mới nhất) ---------- */
    private List<RecentActivity> recentActivities = new ArrayList<>();

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

    public String getFromDate()                { return fromDate; }
    public void setFromDate(String v)          { this.fromDate = v; }

    public String getToDate()                  { return toDate; }
    public void setToDate(String v)            { this.toDate = v; }

    public List<String> getRoleLabels()        { return roleLabels; }
    public void setRoleLabels(List<String> v)  { this.roleLabels = v; }

    public List<Integer> getRoleCounts()       { return roleCounts; }
    public void setRoleCounts(List<Integer> v) { this.roleCounts = v; }

    public List<String> getStatusLabels()         { return statusLabels; }
    public void setStatusLabels(List<String> v)   { this.statusLabels = v; }

    public List<Integer> getStatusCounts()        { return statusCounts; }
    public void setStatusCounts(List<Integer> v)  { this.statusCounts = v; }

    public List<String> getDayLabels()         { return dayLabels; }
    public void setDayLabels(List<String> v)   { this.dayLabels = v; }

    public List<Double> getDayRevenue()        { return dayRevenue; }
    public void setDayRevenue(List<Double> v)  { this.dayRevenue = v; }

    public List<RecentActivity> getRecentActivities()        { return recentActivities; }
    public void setRecentActivities(List<RecentActivity> v)  { this.recentActivities = v; }

    /**
     * Một dòng hoạt động gần đây trong hệ thống (một lượt đặt phòng mới nhất).
     */
    public static class RecentActivity {
        private int bookingId;
        private String customerName;
        private String status;
        private double totalAmount;
        private Date createdAt;

        public int getBookingId()              { return bookingId; }
        public void setBookingId(int v)        { this.bookingId = v; }

        public String getCustomerName()        { return customerName; }
        public void setCustomerName(String v)  { this.customerName = v; }

        public String getStatus()              { return status; }
        public void setStatus(String v)        { this.status = v; }

        public double getTotalAmount()         { return totalAmount; }
        public void setTotalAmount(double v)   { this.totalAmount = v; }

        public Date getCreatedAt()             { return createdAt; }
        public void setCreatedAt(Date v)       { this.createdAt = v; }
    }
}
