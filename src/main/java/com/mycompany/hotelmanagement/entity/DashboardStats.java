package com.mycompany.hotelmanagement.entity;

import java.util.ArrayList;
import java.util.List;

import com.mycompany.hotelmanagement.entity.SystemDashboardStats.ChartSeries;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.DetailTable;
import com.mycompany.hotelmanagement.entity.SystemDashboardStats.Period;

/**
 * DashboardStats
 * Tổng hợp số liệu cho trang Tổng quan của Manager (UC - View Manager Dashboard).
 *
 * Bộ KPI theo chuẩn ngành khách sạn, tính trên một kỳ báo cáo chung
 * (tháng / quý / năm / tùy chỉnh — {@link Period}):
 * tổng doanh thu, RevPAR, ADR, công suất phòng trung bình và tỷ lệ hủy.
 * Doanh thu được rải đều theo từng đêm lưu trú (proration) nên các chỉ số
 * phản ánh đúng phần doanh thu thuộc về kỳ, thay vì dồn cả đơn vào ngày nhận phòng.
 *
 * Mỗi biểu đồ có khoảng lọc riêng và chuỗi dữ liệu đã gom nhóm tự động
 * theo ngày / tháng / quý ({@link ChartSeries}). Khi Manager bấm vào thẻ
 * "Tổng doanh thu" hoặc "Tỷ lệ hủy", {@link DetailTable} chứa danh sách
 * chi tiết tương ứng, render ở backend và phân trang 20 dòng / trang.
 *
 * Date: 22/07/2026
 * version 2.0
 * @author Pham Quoc Quy
 */
public class DashboardStats {

    /* ---------- KPI theo kỳ báo cáo chung ---------- */
    private double totalRevenue;      // Doanh thu thuộc về kỳ (đã rải theo đêm lưu trú)
    private int revenueBookings;      // Số đơn được tính doanh thu có lưu trú giao với kỳ
    private double revPar;            // Doanh thu / (tổng phòng × số ngày kỳ)
    private double adr;               // Doanh thu / số phòng-đêm đã bán
    private double avgOccupancy;      // Công suất phòng trung bình trong kỳ (%)
    private int roomNightsSold;       // Tổng phòng-đêm đã bán trong kỳ
    private int totalRooms;           // Tổng số phòng vật lý của khách sạn
    private int createdBookings;      // Tổng số đơn được tạo trong kỳ (mọi trạng thái)
    private int cancelledBookings;    // Số đơn Cancelled / Rejected tạo trong kỳ
    private double cancellationRate;  // cancelledBookings / createdBookings (%)

    /* ---------- Kỳ báo cáo chung của các thẻ KPI ---------- */
    private Period kpiPeriod;

    /* ---------- 4 biểu đồ, mỗi biểu đồ một khoảng lọc riêng ---------- */
    private ChartSeries revenueSeries;         // Doanh thu theo thời gian (rải theo đêm)
    private ChartSeries occupancySeries;       // Công suất phòng theo thời gian (%)
    private ChartSeries roomTypeRevenueSeries; // Doanh thu theo loại phòng
    private ChartSeries revenueMixSeries;      // Cơ cấu doanh thu Phòng / Dịch vụ / Phụ phí

    /* ---------- Top dịch vụ bán chạy (cùng khoảng lọc với cơ cấu doanh thu) ---------- */
    private List<ServiceRow> topServices = new ArrayList<>();

    /* ---------- Danh sách chi tiết khi bấm vào một thẻ KPI (có thể null) ---------- */
    private DetailTable detail;

    /* ---------- Getters & Setters ---------- */
    public double getTotalRevenue()            { return totalRevenue; }
    public void setTotalRevenue(double v)      { this.totalRevenue = v; }

    public int getRevenueBookings()            { return revenueBookings; }
    public void setRevenueBookings(int v)      { this.revenueBookings = v; }

    public double getRevPar()                  { return revPar; }
    public void setRevPar(double v)            { this.revPar = v; }

    public double getAdr()                     { return adr; }
    public void setAdr(double v)               { this.adr = v; }

    public double getAvgOccupancy()            { return avgOccupancy; }
    public void setAvgOccupancy(double v)      { this.avgOccupancy = v; }

    public int getRoomNightsSold()             { return roomNightsSold; }
    public void setRoomNightsSold(int v)       { this.roomNightsSold = v; }

    public int getTotalRooms()                 { return totalRooms; }
    public void setTotalRooms(int v)           { this.totalRooms = v; }

    public int getCreatedBookings()            { return createdBookings; }
    public void setCreatedBookings(int v)      { this.createdBookings = v; }

    public int getCancelledBookings()          { return cancelledBookings; }
    public void setCancelledBookings(int v)    { this.cancelledBookings = v; }

    public double getCancellationRate()        { return cancellationRate; }
    public void setCancellationRate(double v)  { this.cancellationRate = v; }

    public Period getKpiPeriod()               { return kpiPeriod; }
    public void setKpiPeriod(Period v)         { this.kpiPeriod = v; }

    public ChartSeries getRevenueSeries()                 { return revenueSeries; }
    public void setRevenueSeries(ChartSeries v)           { this.revenueSeries = v; }

    public ChartSeries getOccupancySeries()               { return occupancySeries; }
    public void setOccupancySeries(ChartSeries v)         { this.occupancySeries = v; }

    public ChartSeries getRoomTypeRevenueSeries()         { return roomTypeRevenueSeries; }
    public void setRoomTypeRevenueSeries(ChartSeries v)   { this.roomTypeRevenueSeries = v; }

    public ChartSeries getRevenueMixSeries()              { return revenueMixSeries; }
    public void setRevenueMixSeries(ChartSeries v)        { this.revenueMixSeries = v; }

    public List<ServiceRow> getTopServices()              { return topServices; }
    public void setTopServices(List<ServiceRow> v)        { this.topServices = v; }

    public DetailTable getDetail()             { return detail; }
    public void setDetail(DetailTable v)       { this.detail = v; }

    /** Một dòng trong bảng top dịch vụ bán chạy. */
    public static class ServiceRow {
        private String serviceName;
        private int quantity;      // tổng số lượt / số lượng đã hoàn thành
        private double revenue;    // doanh thu ước tính = số lượng × đơn giá

        public String getServiceName()         { return serviceName; }
        public void setServiceName(String v)   { this.serviceName = v; }

        public int getQuantity()               { return quantity; }
        public void setQuantity(int v)         { this.quantity = v; }

        public double getRevenue()             { return revenue; }
        public void setRevenue(double v)       { this.revenue = v; }
    }
}
