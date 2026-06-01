package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dao.BookingDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.HotelService;
import com.mycompany.hotelmanagement.config.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ReceptionistDashboardController
 * URL: /receptionist/dashboard
 *
 * Quản lý tab sidebar và load dữ liệu booking tương ứng.
 * Tab mặc định: "bookings"
 * 
 * Date: 31/5/2026
 * @author DUC BINH
 */
@WebServlet(name = "ReceptionistDashboardController", urlPatterns = {"/receptionist/dashboard"})
public class ReceptionistDashboardController extends HttpServlet {

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

        // 2. Xác định tab hiện tại
        String tab = request.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) tab = "bookings";

        // 3. Load dữ liệu theo tab
        if ("bookings".equalsIgnoreCase(tab)) {
            loadBookingTab(request);
        } else if ("checkin".equalsIgnoreCase(tab)) {
            loadCheckinTab(request);
        } else if ("checkout".equalsIgnoreCase(tab)) {
            loadCheckoutTab(request);
        } else if ("walkin".equalsIgnoreCase(tab)) {
            loadWalkinTab(request);
        }

        // 4. Forward to view
        request.getRequestDispatcher("/WEB-INF/views/dashboard/receptionist.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    /* ------------------------------------------------------------------ */

    private void loadBookingTab(HttpServletRequest request) {
        BookingDAO dao = new BookingDAO();

        // Tham số lọc
        String statusFilter = request.getParameter("status");
        String keyword      = request.getParameter("keyword");

        if (statusFilter == null || statusFilter.trim().isEmpty()) statusFilter = "All";

        // Load danh sách
        List<Booking> bookingList = dao.getBookings(statusFilter, keyword);

        // Load assigned room mapping
        Map<Integer, RoomInfo> assignedRoomsMap = new HashMap<>();
        for (Booking b : bookingList) {
            RoomInfo r = dao.getAssignedRoom(b.getBookingId());
            if (r != null) {
                assignedRoomsMap.put(b.getBookingId(), r);
            }
        }

        // Thống kê nhanh cho các badge đầu trang
        int cntAll       = dao.getBookings("All", null).size();
        int cntPending   = dao.countByStatus("Pending");
        int cntConfirmed = dao.countByStatus("Confirmed");
        int cntRejected  = dao.countByStatus("Rejected");
        int cntCancelled = dao.countByStatus("Cancelled");

        // Load room types
        List<RoomTypeInfo> roomTypesList = getRoomTypes();

        // Đẩy attribute sang JSP
        request.setAttribute("bookingList",    bookingList);
        request.setAttribute("assignedRoomsMap", assignedRoomsMap);
        request.setAttribute("roomTypesList",  roomTypesList);
        request.setAttribute("currentStatus",  statusFilter);
        request.setAttribute("keyword",        keyword != null ? keyword : "");
        request.setAttribute("cntAll",         cntAll);
        request.setAttribute("cntPending",     cntPending);
        request.setAttribute("cntConfirmed",   cntConfirmed);
        request.setAttribute("cntRejected",    cntRejected);
        request.setAttribute("cntCancelled",   cntCancelled);
    }

    private void loadCheckinTab(HttpServletRequest request) {
        BookingDAO dao = new BookingDAO();
        List<Booking> confirmedList = dao.getBookings("Confirmed", null);
        List<Booking> stayingList = dao.getBookings("CheckedIn", null);
        
        Map<Integer, RoomInfo> assignedRoomsMap = new HashMap<>();
        for (Booking b : confirmedList) {
            RoomInfo r = dao.getAssignedRoom(b.getBookingId());
            if (r != null) assignedRoomsMap.put(b.getBookingId(), r);
        }
        for (Booking b : stayingList) {
            RoomInfo r = dao.getAssignedRoom(b.getBookingId());
            if (r != null) assignedRoomsMap.put(b.getBookingId(), r);
        }
        
        // Available rooms map for assignment dropdown
        Map<Integer, List<RoomInfo>> availableRoomsMap = new HashMap<>();
        List<RoomTypeInfo> roomTypes = getRoomTypes();
        for (RoomTypeInfo rt : roomTypes) {
            availableRoomsMap.put(rt.getTypeId(), dao.getAvailableRoomsForType(rt.getTypeId()));
        }
        
        request.setAttribute("confirmedList", confirmedList);
        request.setAttribute("stayingList", stayingList);
        request.setAttribute("assignedRoomsMap", assignedRoomsMap);
        request.setAttribute("availableRoomsMap", availableRoomsMap);
    }

    private void loadCheckoutTab(HttpServletRequest request) {
        BookingDAO dao = new BookingDAO();
        List<Booking> stayingList = dao.getBookings("CheckedIn", null);
        
        Map<Integer, RoomInfo> assignedRoomsMap = new HashMap<>();
        Map<Integer, List<HotelService>> bookingServicesMap = new HashMap<>();
        
        for (Booking b : stayingList) {
            RoomInfo r = dao.getAssignedRoom(b.getBookingId());
            if (r != null) assignedRoomsMap.put(b.getBookingId(), r);
            
            List<HotelService> services = dao.getBookingServices(b.getBookingId());
            bookingServicesMap.put(b.getBookingId(), services);
        }
        
        List<HotelService> servicesList = getActiveServices();
        
        request.setAttribute("stayingList", stayingList);
        request.setAttribute("assignedRoomsMap", assignedRoomsMap);
        request.setAttribute("bookingServicesMap", bookingServicesMap);
        request.setAttribute("servicesList", servicesList);
    }

    private void loadWalkinTab(HttpServletRequest request) {
        BookingDAO dao = new BookingDAO();
        List<RoomTypeInfo> roomTypesList = getRoomTypes();
        Map<Integer, List<RoomInfo>> availableRoomsMap = new HashMap<>();
        for (RoomTypeInfo rt : roomTypesList) {
            availableRoomsMap.put(rt.getTypeId(), dao.getAvailableRoomsForType(rt.getTypeId()));
        }
        request.setAttribute("roomTypesList", roomTypesList);
        request.setAttribute("availableRoomsMap", availableRoomsMap);
    }

    private List<RoomTypeInfo> getRoomTypes() {
        List<RoomTypeInfo> list = new ArrayList<>();
        String sql = "SELECT type_id, type_name, base_price, capacity, area, bed_type FROM dbo.RoomType ORDER BY type_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RoomTypeInfo rt = new RoomTypeInfo();
                rt.setTypeId(rs.getInt("type_id"));
                rt.setTypeName(rs.getString("type_name"));
                rt.setBasePrice(rs.getDouble("base_price"));
                rt.setCapacity(rs.getInt("capacity"));
                rt.setArea(rs.getString("area"));
                rt.setBedType(rs.getString("bed_type"));
                list.add(rt);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<HotelService> getActiveServices() {
        List<HotelService> list = new ArrayList<>();
        String sql = "SELECT service_id, service_name, description, price, unit FROM dbo.HotelService WHERE is_active = 1 ORDER BY service_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                HotelService hs = new HotelService();
                hs.setServiceId(rs.getInt("service_id"));
                hs.setServiceName(rs.getString("service_name"));
                hs.setDescription(rs.getString("description"));
                hs.setPrice(rs.getDouble("price"));
                hs.setUnit(rs.getString("unit"));
                hs.setIsActive(true);
                list.add(hs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}

