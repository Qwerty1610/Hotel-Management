package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.DashboardStats;
import com.mycompany.hotelmanagement.entity.HotelService;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import com.mycompany.hotelmanagement.service.DashboardService;
import com.mycompany.hotelmanagement.service.HotelServiceService;
import com.mycompany.hotelmanagement.service.RoomTypeService;
import com.mycompany.hotelmanagement.service.RoomService;

@WebServlet(name = "ManagerDashboardController", urlPatterns = {"/manager/dashboard"})
public class ManagerDashboardController extends HttpServlet {

    private final HotelServiceService hotelServiceService = new HotelServiceService();
    private final RoomTypeService roomTypeService = new RoomTypeService();
    private final RoomService roomService = new RoomService();
    private final DashboardService dashboardService = new DashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tab = request.getParameter("tab");
        if (tab == null || "overview".equalsIgnoreCase(tab)) {
            loadOverview(request);
        }
        
        // Authorized (by AuthFilter), forward to Hotel Manager Dashboard view
        request.getRequestDispatcher("/WEB-INF/views/dashboard/manager.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Tải số liệu cho tab Tổng quan: doanh thu, công suất phòng theo khoảng ngày lọc.
     * Mặc định lọc 30 ngày gần nhất nếu người dùng chưa chọn.
     */
    private void loadOverview(HttpServletRequest request) {
        LocalDate today = LocalDate.now();
        LocalDate from = parseDate(request.getParameter("fromDate"), today.minusDays(29));
        LocalDate to = parseDate(request.getParameter("toDate"), today);

        // Đảm bảo from <= to, tránh khoảng âm
        if (from.isAfter(to)) {
            LocalDate tmp = from;
            from = to;
            to = tmp;
        }

        DashboardStats stats = dashboardService.getStats(from, to);
        request.setAttribute("stats", stats);
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
}
