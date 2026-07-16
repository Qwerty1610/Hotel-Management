package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.BookingServiceRequestDAO;
import com.mycompany.hotelmanagement.dal.RoomRepository;
import com.mycompany.hotelmanagement.dal.RoomTypeRepository;
import com.mycompany.hotelmanagement.dal.WalkInBookingDAO;
import com.mycompany.hotelmanagement.dal.CheckOutDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingServiceRequest;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Project: Hotel Management System
 * Class: ReceptionistDashboardController
 *
 * Description:
 * Controller chính cho dashboard của vai trò lễ tân. Quản lý điều hướng qua
 * các tab: danh sách đặt phòng (UC-12), danh sách chờ nhận phòng (UC-14),
 * danh sách chờ trả phòng (UC-16), yêu cầu dịch vụ (UC-35), sơ đồ phòng
 * (UC-38) và đặt phòng trực tiếp (UC-13). Tổng hợp dữ liệu từ BookingDAO,
 * CheckOutDAO, WalkInBookingDAO và BookingServiceRequestDAO.
 *
 * Related Use Cases:
 * - UC-12 Process Booking Request
 * - UC-13 Create Walk-in Booking
 * - UC-14 Check-In Customer
 * - UC-16 Check-Out Customer
 * - UC-35 View Service Requests
 * - UC-38 View Room Map
 * 
 * Date: 01-06-2026
 * 
 * @author BinhHD, KhanhTD, MinhTDP
 * @version 1.4
 */

@WebServlet(name = "ReceptionistDashboardController", urlPatterns = { "/receptionist/dashboard" })
public class ReceptionistDashboardController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistDashboardController.class.getName());
    private static final int PAGE_SIZE = 8;
    private static final int PAGE_SIZE_CHECKIN = 11;

    private static final Set<String> ALLOWED_TABS = Set.of("bookings", "checkin", "checkout", "servicerequests",
            "roommap", "walkin-bookings");
    private static final Set<String> STATUS_WHITELIST = Set.of("All", "Pending", "Confirmed", "Rejected", "Cancelled",
            "CheckedIn", "CheckedOut");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra xác thực & phân quyền
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
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
            } else if ("servicerequests".equals(tab)) {
                loadServiceRequestsTab(request);
            } else if ("checkin".equals(tab)) {
                loadCheckInTab(request);
            } else if ("roommap".equals(tab)) {
                loadRoomMapTab(request);
            } else if ("walkin-bookings".equals(tab)) {
                loadWalkInBookingTab(request);
            } else if ("checkout".equals(tab)) {
                loadCheckOutTab(request);
            }

            // 4. Forward to view
            if ("servicerequests".equals(tab)) {
                request.getRequestDispatcher("/WEB-INF/views/receptionist/service-requests.jsp")
                        .forward(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/views/dashboard/receptionist.jsp")
                        .forward(request, response);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in doGet of ReceptionistDashboardController", e);
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unknown");
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
            String keyword = request.getParameter("keyword");

            int page = 1;
            try {
                String pageStr = request.getParameter("page");
                if (pageStr != null) {
                    page = Integer.parseInt(pageStr);
                }
            } catch (Exception e) {
                page = 1;
            }

            if (page < 1) {
                page = 1;
            }

            if (statusFilter == null || !STATUS_WHITELIST.contains(statusFilter.trim())) {
                statusFilter = "All";
            } else {
                statusFilter = statusFilter.trim();
            }

            // Load danh sách
            int totalItems = dao.countBookings(statusFilter, keyword);

            int totalPages = (int) Math.ceil(totalItems / (double) PAGE_SIZE);

            if (totalPages < 1) {
                totalPages = 1;
            }

            if (page > totalPages) {
                page = totalPages;
            }

            int offset = (page - 1) * PAGE_SIZE;

            List<Booking> bookingList = dao.getBookingsPaging(
                    statusFilter,
                    keyword,
                    offset,
                    PAGE_SIZE);

            // Load danh sách loại phòng để cập nhật thông tin loại phòng trong modal edit
            List<RoomTypeInfo> roomTypesList = roomTypeRepo.getAllRoomTypes();

            // Thống kê nhanh cho các badge đầu trang
            int cntAll = dao.countAll();
            int cntPending = dao.countByStatus("Pending");
            int cntConfirmed = dao.countByStatus("Confirmed");
            int cntRejected = dao.countByStatus("Rejected");
            int cntCancelled = dao.countByStatus("Cancelled");

            // Đẩy attribute sang JSP
            request.setAttribute("bookingList", bookingList);
            request.setAttribute("roomTypesList", roomTypesList);
            request.setAttribute("currentStatus", statusFilter);
            request.setAttribute("keyword", keyword != null ? keyword : "");
            request.setAttribute("cntAll", cntAll);
            request.setAttribute("cntPending", cntPending);
            request.setAttribute("cntConfirmed", cntConfirmed);
            request.setAttribute("cntRejected", cntRejected);
            request.setAttribute("cntCancelled", cntCancelled);

            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalItems", totalItems);

        } catch (Exception e) {
            throw new RuntimeException("Error in loadBookingTab of ReceptionistDashboardController", e);
        }
    }

    /**
     * UC-35: View Service Requests
     * Tải danh sách yêu cầu dịch vụ của khách hàng để hiển thị trên tab của Lễ tân,
     * hỗ trợ tìm kiếm, lọc theo trạng thái và phân trang.
     */
    private void loadServiceRequestsTab(HttpServletRequest request) {
        try {
            BookingServiceRequestDAO dao = new BookingServiceRequestDAO();
            String statusFilter = request.getParameter("status");
            String keyword = request.getParameter("keyword");

            if (statusFilter == null || statusFilter.trim().isEmpty()) {
                statusFilter = "All";
            } else {
                statusFilter = statusFilter.trim();
            }

            int page = 1;
            String pageStr = request.getParameter("page");
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr);
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            if (page < 1) {
                page = 1;
            }

            int pageSize = 10;
            int totalItems = dao.countReceptionistRequests(statusFilter, keyword);
            int totalPages = (int) Math.ceil((double) totalItems / pageSize);
            if (totalPages < 1) {
                totalPages = 1;
            }
            if (page > totalPages) {
                page = totalPages;
            }
            int offset = (page - 1) * pageSize;

            List<BookingServiceRequest> requestList = dao.getReceptionistRequests(statusFilter, keyword, offset,
                    pageSize);

            // KPI Counts (overall counts for the cards)
            int kpiTotal = dao.countReceptionistRequests("All", null);
            int kpiPending = dao.countReceptionistByStatus("Pending"); // counts Pending + InProgress
            int kpiCompleted = dao.countReceptionistByStatus("Completed");
            int kpiCancelled = dao.countReceptionistByStatus("Cancelled");

            request.setAttribute("requestList", requestList);
            request.setAttribute("currentStatus", statusFilter);
            request.setAttribute("keyword", keyword != null ? keyword : "");
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalItems", totalItems);
            request.setAttribute("pageSize", pageSize);

            request.setAttribute("kpiTotal", kpiTotal);
            request.setAttribute("kpiPending", kpiPending);
            request.setAttribute("kpiCompleted", kpiCompleted);
            request.setAttribute("kpiCancelled", kpiCancelled);

        } catch (Exception e) {
            throw new RuntimeException("Error in loadServiceRequestsTab of ReceptionistDashboardController", e);
        }
    }

    private void loadCheckInTab(HttpServletRequest request) {

        BookingDAO dao = new BookingDAO();

        String keyword = request.getParameter("keyword");

        // page
        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (Exception e) {
            page = 1;
        }

        if (page < 1) {
            page = 1;
        }

        // total
        int totalItems = dao.countCheckInBookings(keyword);
        int totalPages = (int) Math.ceil(totalItems / (double) PAGE_SIZE_CHECKIN);

        if (totalPages < 1) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
        }

        int offset = (page - 1) * PAGE_SIZE_CHECKIN;

        // DATA
        List<Booking> checkInList = dao.getCheckInBookings(keyword, offset, PAGE_SIZE_CHECKIN);

        // SET ATTRIBUTES
        request.setAttribute("checkInList", checkInList);
        request.setAttribute("keyword", keyword != null ? keyword : "");

        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
    }

    private void loadRoomMapTab(HttpServletRequest request) {

        RoomRepository repo = new RoomRepository();

        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        List<RoomInfo> roomList;

        if (fromDate != null
                && !fromDate.isBlank()
                && toDate != null
                && !toDate.isBlank()) {

            roomList = repo.getRoomMapByDate(
                    Date.valueOf(fromDate),
                    Date.valueOf(toDate));

        } else {

            roomList = repo.getAllRooms();
            for (RoomInfo room : roomList) {
                if ("Cleaning".equalsIgnoreCase(room.getStatus())) {
                    room.setStatus("Available");
                }
            }
        }

        if (roomList == null) {
            roomList = new ArrayList<>();
        }

        String status = request.getParameter("status");

        if (status == null || status.isBlank()) {
            status = "All";
        }

        List<RoomInfo> filtered = new ArrayList<>();

        for (RoomInfo room : roomList) {

            if ("All".equalsIgnoreCase(status)
                    || status.equalsIgnoreCase(room.getStatus())) {

                filtered.add(room);
            }
        }

        Map<String, List<RoomInfo>> roomByFloor = new LinkedHashMap<>();

        for (RoomInfo room : filtered) {

            String floor = room.getFloor();

            if (floor == null || floor.isBlank()) {
                floor = "Unknown";
            }

            roomByFloor
                    .computeIfAbsent(
                            floor,
                            k -> new ArrayList<>())
                    .add(room);
        }

        request.setAttribute("roomByFloor", roomByFloor);

        request.setAttribute("currentStatus", status);

        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
    }

    private void loadWalkInBookingTab(HttpServletRequest request) {
        RoomTypeRepository roomTypeRepo = new RoomTypeRepository();
        request.setAttribute("roomTypesList", roomTypeRepo.getAllRoomTypes());
    }

    private void loadCheckOutTab(HttpServletRequest request) {
        BookingDAO dao = new BookingDAO();
        String search = request.getParameter("search");
        List<Booking> list = dao.getBookings("CheckedIn", search);
        request.setAttribute("checkOutList", list);
        request.setAttribute("search", search != null ? search : "");
    }
}
