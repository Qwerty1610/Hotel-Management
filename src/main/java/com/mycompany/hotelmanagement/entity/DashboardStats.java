package com.mycompany.hotelmanagement.entity;

import java.util.ArrayList;
import java.util.List;

/**
 * DashboardStats
 * Tổng hợp số liệu cho trang Tổng quan của Manager:
 * doanh thu, công suất phòng và các phân tích theo ngày / loại phòng / trạng thái.
 *
 * Date: 02/6/2026
 */
public class DashboardStats {

    /* ---------- KPI tổng ---------- */
    private double totalRevenue;     // Tổng doanh thu trong khoảng lọc
    private int totalBookings;       // Số lượt đặt phòng (đã xác nhận trở lên)
    private int checkInRooms;        // Tổng số phòng đã nhận (check-in) trong khoảng
    private int checkOutRooms;       // Tổng số phòng đã trả (check-out) trong khoảng
    private int totalRooms;          // Tổng số phòng của khách sạn
    private double avgOccupancy;     // Công suất phòng trung bình (%)

    /* ---------- Khoảng thời gian lọc (để hiển thị lại trên form) ---------- */
    private String fromDate;
    private String toDate;

    /* ---------- Chuỗi dữ liệu theo ngày ---------- */
    private List<String> dayLabels = new ArrayList<>();   // nhãn ngày (dd/MM)
    private List<Double> dayRevenue = new ArrayList<>();  // doanh thu mỗi ngày
    private List<Double> dayOccupancy = new ArrayList<>(); // công suất % mỗi ngày

    /* ---------- Doanh thu theo loại phòng ---------- */
    private List<String> roomTypeLabels = new ArrayList<>();
    private List<Double> roomTypeRevenue = new ArrayList<>();

    /* ---------- Phân bổ theo trạng thái đặt phòng ---------- */
    private List<String> statusLabels = new ArrayList<>();
    private List<Integer> statusCounts = new ArrayList<>();

    /* ---------- Getters & Setters ---------- */
    public double getTotalRevenue()            { return totalRevenue; }
    public void setTotalRevenue(double v)      { this.totalRevenue = v; }

    public int getTotalBookings()              { return totalBookings; }
    public void setTotalBookings(int v)        { this.totalBookings = v; }

    public int getCheckInRooms()               { return checkInRooms; }
    public void setCheckInRooms(int v)         { this.checkInRooms = v; }

    public int getCheckOutRooms()              { return checkOutRooms; }
    public void setCheckOutRooms(int v)        { this.checkOutRooms = v; }

    public int getTotalRooms()                 { return totalRooms; }
    public void setTotalRooms(int v)           { this.totalRooms = v; }

    public double getAvgOccupancy()            { return avgOccupancy; }
    public void setAvgOccupancy(double v)      { this.avgOccupancy = v; }

    public String getFromDate()                { return fromDate; }
    public void setFromDate(String v)          { this.fromDate = v; }

    public String getToDate()                  { return toDate; }
    public void setToDate(String v)            { this.toDate = v; }

    public List<String> getDayLabels()         { return dayLabels; }
    public void setDayLabels(List<String> v)   { this.dayLabels = v; }

    public List<Double> getDayRevenue()        { return dayRevenue; }
    public void setDayRevenue(List<Double> v)  { this.dayRevenue = v; }

    public List<Double> getDayOccupancy()      { return dayOccupancy; }
    public void setDayOccupancy(List<Double> v){ this.dayOccupancy = v; }

    public List<String> getRoomTypeLabels()        { return roomTypeLabels; }
    public void setRoomTypeLabels(List<String> v)  { this.roomTypeLabels = v; }

    public List<Double> getRoomTypeRevenue()       { return roomTypeRevenue; }
    public void setRoomTypeRevenue(List<Double> v) { this.roomTypeRevenue = v; }

    public List<String> getStatusLabels()          { return statusLabels; }
    public void setStatusLabels(List<String> v)    { this.statusLabels = v; }

    public List<Integer> getStatusCounts()         { return statusCounts; }
    public void setStatusCounts(List<Integer> v)   { this.statusCounts = v; }
}
