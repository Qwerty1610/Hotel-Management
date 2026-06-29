package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.BookingServiceRequestDAO;
import com.mycompany.hotelmanagement.dal.HotelServiceRepository;
import com.mycompany.hotelmanagement.dal.InvoiceDAO;
import com.mycompany.hotelmanagement.entity.BookingServiceRequest;
import com.mycompany.hotelmanagement.entity.HotelService;
import com.mycompany.hotelmanagement.entity.Invoice;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReceptionistRequestController
 * URL: /receptionist/servicerequest
 *
 * Xử lý các hành động duyệt hoặc hủy yêu cầu dịch vụ của khách hàng từ phía lễ tân (UC-35: View Service Requests):
 * - approve POST: Duyệt yêu cầu dịch vụ. Thực hiện các bước:
 *   1. Đọc BookingServiceRequest để lấy bookingId và tên dịch vụ.
 *   2. Tra cứu đơn giá dịch vụ trong HotelService.
 *   3. Tìm Invoice tương ứng của booking.
 *   4. Thêm InvoiceItem loại 'Service' với đơn giá tra cứu được để tự động cập nhật tổng hóa đơn.
 *   5. Cập nhật trạng thái yêu cầu dịch vụ thành Completed.
 * - cancel POST: Hủy yêu cầu dịch vụ, ghi nhận người thực hiện và lý do hủy, cập nhật trạng thái yêu cầu thành Cancelled.
 *
 * Date: 21/6/2026 — updated 25/6/2026
 * @author DINH KHANH
 */
@WebServlet(name = "ReceptionistRequestController", urlPatterns = { "/receptionist/servicerequest" })
public class ReceptionistRequestController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistRequestController.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra xác thực & quyền hạn
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String requestIdStr = request.getParameter("requestId");
        String cancelReason = request.getParameter("cancelReason");

        try {
            if (action == null || requestIdStr == null || requestIdStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=invalid");
                return;
            }

            int requestId;
            try {
                requestId = Integer.parseInt(requestIdStr.trim());
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=invalid");
                return;
            }

            Integer receptionistId = (Integer) session.getAttribute("accountId");
            if (receptionistId == null) {
                response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
                return;
            }

            BookingServiceRequestDAO dao = new BookingServiceRequestDAO();
            boolean success = false;
            String extraParam = "";

            switch (action.toLowerCase()) {
                case "approve":
                    // ── Bước 1: Đọc BookingServiceRequest ──────────────────────────────────
                    BookingServiceRequest req = dao.getRequestById(requestId);
                    if (req == null) {
                        response.sendRedirect(request.getContextPath()
                                + "/receptionist/dashboard?tab=servicerequests&error=notfound");
                        return;
                    }

                    // ── Bước 2: Nếu là Service request (có booking_id), tạo InvoiceItem ──
                    if (req.getBookingId() != null) {
                        double servicePrice = 0.0;

                        // Tra giá dịch vụ từ HotelService theo tên (title của request)
                        HotelServiceRepository hsRepo = new HotelServiceRepository();
                        List<HotelService> allServices = hsRepo.getAllServices();
                        for (HotelService hs : allServices) {
                            if (hs.getServiceName().equalsIgnoreCase(req.getTitle()) && hs.isIsActive()) {
                                servicePrice = hs.getPrice();
                                break;
                            }
                        }

                        // ── Bước 3: Tìm Invoice của booking ─────────────────────────
                        InvoiceDAO invoiceDAO = new InvoiceDAO();
                        Invoice invoice = invoiceDAO.getInvoiceByBookingId(req.getBookingId());

                        if (invoice != null) {
                            // ── Bước 4: Tạo InvoiceItem loại Service ────────────────
                            boolean itemAdded = invoiceDAO.addServiceItem(
                                    invoice.getInvoiceId(),
                                    req.getTitle(),   // tên dịch vụ
                                    1,                // số lượng mặc định 1
                                    servicePrice      // đơn giá từ HotelService (0 nếu không tìm thấy)
                            );
                            if (!itemAdded) {
                                // Invoice đã Paid / Cancelled — vẫn approve request nhưng cảnh báo
                                extraParam = "&warn=invoice_closed";
                                LOGGER.log(Level.WARNING,
                                        "Cannot add service item to invoice {0} (status closed) for request {1}",
                                        new Object[]{invoice.getInvoiceId(), requestId});
                            }
                        } else {
                            // Booking chưa có hóa đơn — vẫn approve, ghi log để theo dõi
                            extraParam = "&warn=no_invoice";
                            LOGGER.log(Level.WARNING,
                                    "No invoice found for booking {0} when approving service request {1}",
                                    new Object[]{req.getBookingId(), requestId});
                        }
                    }

                    // ── Bước 5: Set BookingServiceRequest.status = Completed ───────────
                    success = dao.updateStatusByReceptionist(requestId, "Completed", receptionistId);
                    break;

                case "cancel":
                    // Hủy yêu cầu dịch vụ — cập nhật người hủy và lý do hủy
                    success = dao.updateStatusByReceptionist(requestId, "Cancelled", receptionistId, cancelReason);
                    break;

                default:
                    LOGGER.log(Level.WARNING, "Unknown action received: " + action);
                    response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=invalid");
                    return;
            }

            String result = success ? "success" : "fail";
            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=servicerequests&result=" + result
                    + "&action=" + action + extraParam);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in ReceptionistRequestController doPost", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=unknown");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests");
    }
}
