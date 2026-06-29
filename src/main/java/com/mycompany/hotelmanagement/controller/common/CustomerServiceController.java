package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.dal.BookingServiceRequestDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingServiceRequest;
import com.mycompany.hotelmanagement.entity.HotelService;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.service.BookingService;
import com.mycompany.hotelmanagement.service.HotelServiceService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * CustomerServiceController
 * URL: /customer/services, /customer/services/history, /customer/services/cancel
 *
 * Xử lý các hành động của khách hàng (Customer) liên quan đến dịch vụ khách sạn:
 * - view/default GET (/customer/services): Xem danh sách các dịch vụ đang hoạt động (tên, mô tả, đơn giá) để lựa chọn đặt phòng/phòng đang ở (UC-09: View Available Service)
 * - submit POST (/customer/services): Khách hàng đang lưu trú gửi yêu cầu dịch vụ cho phòng của mình (UC-10: Submit Service Request)
 * - history GET (/customer/services/history): Xem danh sách lịch sử yêu cầu dịch vụ đã gửi cùng trạng thái hiện tại (Pending, Completed, Cancelled) (UC-64: View Service Request History)
 * - cancel POST (/customer/services/cancel): Khách hàng tự hủy yêu cầu dịch vụ ở trạng thái chờ xử lý (Pending) (UC-64: View Service Request History - Action Cancel)
 * 
 * Date: 21/6/2026
 * @author DINH KHANH
 */
@WebServlet(name = "CustomerServiceController", urlPatterns = {
    "/customer/services",
    "/customer/services/history",
    "/customer/services/cancel"
})
public class CustomerServiceController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CustomerServiceController.class.getName());
    private final BookingService bookingService = new BookingService();
    private final HotelServiceService hotelServiceService = new HotelServiceService();
    private final BookingServiceRequestDAO customerRequestDAO = new BookingServiceRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Authorize Customer
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int accountId = (int) session.getAttribute("accountId");
        String servletPath = request.getServletPath();

        try {
            if ("/customer/services/history".equals(servletPath)) {
                showRequestHistory(request, response, accountId);
            } else {
                showServicesAndForm(request, response, accountId);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in CustomerServiceController doGet", e);
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=MSG55");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Authorize Customer
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int accountId = (int) session.getAttribute("accountId");
        String servletPath = request.getServletPath();

        try {
            if ("/customer/services/cancel".equals(servletPath)) {
                handleCancelRequest(request, response, accountId);
            } else {
                handleSubmitRequest(request, response, accountId);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in CustomerServiceController doPost", e);
            response.sendRedirect(request.getContextPath() + "/customer/services?error=MSG55");
        }
    }

    /**
     * UC-09: View Available Service
     * Hiển thị danh sách dịch vụ đang hoạt động kèm phân trang và form gửi yêu cầu.
     */
    private void showServicesAndForm(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        // Fetch all active services
        List<HotelService> allServices = hotelServiceService.getAllServices();
        List<HotelService> activeServices = new ArrayList<>();
        for (HotelService hs : allServices) {
            if (hs.isIsActive()) {
                activeServices.add(hs);
            }
        }

        // Paginate active services (6 per page)
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 6;
        int totalItems = activeServices.size();
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int startIndex = (page - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalItems);

        List<HotelService> paginatedServices = new ArrayList<>();
        if (startIndex < totalItems) {
            paginatedServices = activeServices.subList(startIndex, endIndex);
        }

        // Fetch customer's active bookings (CheckedIn or Confirmed)
        List<Booking> allBookings = bookingService.getBookingsByAccount(accountId, "All", null);
        List<Booking> activeBookings = new ArrayList<>();
        for (Booking b : allBookings) {
            if ("CheckedIn".equals(b.getStatus()) || "Confirmed".equals(b.getStatus())) {
                activeBookings.add(b);
            }
        }

        request.setAttribute("services", paginatedServices);
        request.setAttribute("allActiveServices", activeServices);
        request.setAttribute("bookings", activeBookings);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);

        // Success / Error messages
        String success = request.getParameter("success");
        if (success != null) {
            request.setAttribute("successMessage", "Gửi yêu cầu dịch vụ thành công!");
        }
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorMessage", "Không thể gửi yêu cầu. Vui lòng thử lại sau.");
        }

        request.getRequestDispatcher("/WEB-INF/views/customer/customer-services.jsp").forward(request, response);
    }

    /**
     * UC-64: View Service Request History
     * Hiển thị danh sách lịch sử yêu cầu dịch vụ của khách hàng.
     */
    private void showRequestHistory(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
            statusFilter = "All";
        }
        List<BookingServiceRequest> requests = customerRequestDAO.getRequestsByCustomer(accountId, statusFilter);
        request.setAttribute("requests", requests);
        request.setAttribute("selectedStatus", statusFilter);

        // Success / Error messages
        String success = request.getParameter("success");
        if (success != null) {
            if ("cancelled".equals(success)) {
                request.setAttribute("successMessage", "Hủy yêu cầu dịch vụ thành công!");
            }
        }
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorMessage", "Không thể thực hiện thao tác. Vui lòng thử lại sau.");
        }

        request.getRequestDispatcher("/WEB-INF/views/customer/customer-services-history.jsp").forward(request, response);
    }

    /**
     * UC-10: Submit Service Request
     * Tiếp nhận và xử lý lưu thông tin yêu cầu dịch vụ của khách hàng vào cơ sở dữ liệu.
     */
    private void handleSubmitRequest(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        String bookingIdStr = request.getParameter("bookingId");
        String serviceName = request.getParameter("serviceName");

        if (bookingIdStr == null || serviceName == null || bookingIdStr.isEmpty() || serviceName.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/services?error=invalid_input");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingService.getBookingById(bookingId);

            // Verify booking ownership
            if (booking == null || booking.getAccountId() == null || booking.getAccountId() != accountId) {
                response.sendRedirect(request.getContextPath() + "/customer/services?error=unauthorized");
                return;
            }

            // Find service details
            List<HotelService> allServices = hotelServiceService.getAllServices();
            HotelService selectedService = null;
            for (HotelService hs : allServices) {
                if (hs.getServiceName().equals(serviceName) && hs.isIsActive()) {
                    selectedService = hs;
                    break;
                }
            }

            if (selectedService == null) {
                response.sendRedirect(request.getContextPath() + "/customer/services?error=service_not_found");
                return;
            }

            // Get room assignment if checked in
            Integer roomId = null;
            List<Room> assignedRooms = bookingService.getAssignedRoomsForBooking(bookingId,
                    booking.getCheckInDate(),
                    booking.getCheckOutDate());
            if (assignedRooms != null && !assignedRooms.isEmpty()) {
                roomId = assignedRooms.get(0).getRoomId();
            }

            BookingServiceRequest req = new BookingServiceRequest();
            req.setBookingId(bookingId);
            req.setRoomId(roomId);
            req.setTitle(serviceName);
            req.setDescription(selectedService.getDescription());
            req.setPriority("Medium");
            req.setStatus("Pending");

            boolean success = customerRequestDAO.insertRequest(req);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/customer/services?success=created");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/services?error=db_error");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/services?error=invalid_format");
        }
    }

    /**
     * UC-64: View Service Request History (Action Cancel)
     * Cho phép khách hàng tự hủy yêu cầu dịch vụ của họ nếu yêu cầu đó đang ở trạng thái chờ xử lý (Pending).
     */
    private void handleCancelRequest(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        String requestIdStr = request.getParameter("requestId");

        if (requestIdStr == null || requestIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/services/history?error=invalid_input");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr);
            boolean success = customerRequestDAO.cancelRequestByCustomer(requestId, accountId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/customer/services/history?success=cancelled");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/services/history?error=cancel_failed");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/services/history?error=invalid_format");
        }
    }
}
