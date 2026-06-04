package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.RoomTypeRepository;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReceptionistDashboardController
 * URL: /receptionist/dashboard
 *
 * Quản lý tab sidebar và load dữ liệu booking tương ứng.
 * Tab mặc định: "bookings"
 * Standardized imports utilizing dal instead of dao.
 * Date: 01/6/2026
 * @author DUC BINH
 */
@WebServlet(name = "ReceptionistDashboardController", urlPatterns = {"/receptionist/dashboard"})
public class ReceptionistDashboardController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistDashboardController.class.getName());

    private static final Set<String> ALLOWED_TABS = Set.of("bookings", "checkin", "checkout");
    private static final Set<String> STATUS_WHITELIST = Set.of("All", "Pending", "Confirmed", "Rejected", "Cancelled", "CheckedIn", "CheckedOut");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra xác thực & phân quyền
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        try {
            // 2. Xác định tab hiện tại và validate
            String tab = request.getParameter("tab");
            if (tab == null || tab.trim().isEmpty() || !ALLOWED_TABS.contains(tab.trim().toLowerCase())) {
                tab = "bookings";
            } else {
                tab = tab.trim().toLowerCase();
            }

            // 3. Load dữ liệu theo tab
            if ("bookings".equals(tab)) {
                loadBookingTab(request);
            }

            // 4. Forward to view
            request.getRequestDispatcher("/WEB-INF/views/dashboard/receptionist.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in doGet of ReceptionistDashboardController", e);
            response.sendRedirect(request.getContextPath() + "/home/login?error=unknown");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void loadBookingTab(HttpServletRequest request) {
        try {
            BookingDAO dao = new BookingDAO();
            RoomTypeRepository roomTypeRepo = new RoomTypeRepository();

            // Tham số lọc
            String statusFilter = request.getParameter("status");
            String keyword      = request.getParameter("keyword");

            if (statusFilter == null || !STATUS_WHITELIST.contains(statusFilter.trim())) {
                statusFilter = "All";
            } else {
                statusFilter = statusFilter.trim();
            }

            // Load danh sách
            List<Booking> bookingList = dao.getBookings(statusFilter, keyword);

            // Load danh sách loại phòng để cập nhật thông tin loại phòng trong modal edit
            List<RoomTypeInfo> roomTypesList = roomTypeRepo.getAllRoomTypes();

            // Thống kê nhanh cho các badge đầu trang
            int cntAll       = dao.countAll();
            int cntPending   = dao.countByStatus("Pending");
            int cntConfirmed = dao.countByStatus("Confirmed");
            int cntRejected  = dao.countByStatus("Rejected");
            int cntCancelled = dao.countByStatus("Cancelled");

            // Đẩy attribute sang JSP
            request.setAttribute("bookingList",    bookingList);
            request.setAttribute("roomTypesList",  roomTypesList);
            request.setAttribute("currentStatus",  statusFilter);
            request.setAttribute("keyword",        keyword != null ? keyword : "");
            request.setAttribute("cntAll",         cntAll);
            request.setAttribute("cntPending",     cntPending);
            request.setAttribute("cntConfirmed",   cntConfirmed);
            request.setAttribute("cntRejected",    cntRejected);
            request.setAttribute("cntCancelled",   cntCancelled);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in loadBookingTab of ReceptionistDashboardController", e);
            throw e; // Rethrow to be handled by doGet try-catch
        }
    }
}
