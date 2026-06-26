package com.mycompany.hotelmanagement.controller.admin;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.SystemDashboardStats;
import com.mycompany.hotelmanagement.service.AdminDashboardService;

/**
 * AdminSystemDashboardController
 * Bảng điều khiển hệ thống của Admin (UC 2.7.4 - View System Dashboard).
 * Hiển thị các chỉ số KPI và biểu đồ tổng quan: tài khoản theo vai trò,
 * người dùng đang hoạt động, đặt phòng theo trạng thái, doanh thu và hoạt động gần đây.
 *
 * Quyền truy cập (role ADMIN) được kiểm soát bởi AuthFilter (E1 - BR/OR-20).
 *
 * @author QuyPQ
 */
@WebServlet(name = "AdminSystemDashboardController", urlPatterns = {"/admin/system-dashboard"})
public class AdminSystemDashboardController extends HttpServlet {

    private final AdminDashboardService dashboardService = new AdminDashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // AF-2: Admin có thể chọn khoảng thời gian báo cáo; mặc định 30 ngày gần nhất.
        LocalDate today = LocalDate.now();
        LocalDate from = parseDate(request.getParameter("fromDate"), today.minusDays(29));
        LocalDate to = parseDate(request.getParameter("toDate"), today);

        // Đảm bảo from <= to, tránh khoảng âm
        if (from.isAfter(to)) {
            LocalDate tmp = from;
            from = to;
            to = tmp;
        }

        SystemDashboardStats stats = dashboardService.getStats(from, to);
        request.setAttribute("stats", stats);
        request.setAttribute("activePage", "system-dashboard");

        request.getRequestDispatcher("/WEB-INF/views/dashboard/admin-system.jsp")
               .forward(request, response);
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
