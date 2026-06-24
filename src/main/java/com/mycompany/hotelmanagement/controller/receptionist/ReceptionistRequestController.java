package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.CustomerRequestDAO;
import com.mycompany.hotelmanagement.dal.HotelServiceRepository;
import com.mycompany.hotelmanagement.dal.InvoiceDAO;
import com.mycompany.hotelmanagement.entity.CustomerRequest;
import com.mycompany.hotelmanagement.entity.HotelService;
import com.mycompany.hotelmanagement.entity.Invoice;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReceptionistRequestController
 * URL: /receptionist/servicerequest
 *
 * Xử lý duyệt hoặc hủy yêu cầu dịch vụ của khách hàng từ phía lễ tân.
 * Hành động (action param):
 * - approve : Duyệt hoàn thành yêu cầu (status -> Completed, gán Lễ tân duyệt làm staff).
 *             Sau khi approve, nếu tồn tại Invoice liên kết với booking đó,
 *             tự động thêm dòng dịch vụ vào InvoiceItem để hóa đơn phản ánh đúng.
 * - cancel  : Hủy yêu cầu (status -> Cancelled)
 *
 * Date: 21/6/2026
 * ver 1.1 - Fix: Approve tự động thêm dịch vụ vào InvoiceItem
 * @author DINH KHANH
 */
@WebServlet(name = "ReceptionistRequestController", urlPatterns = { "/receptionist/servicerequest" })
public class ReceptionistRequestController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistRequestController.class.getName());
    private final CustomerRequestDAO requestDAO = new CustomerRequestDAO();
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final HotelServiceRepository hotelServiceRepo = new HotelServiceRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra xác thực & quyền hạn
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String requestIdStr = request.getParameter("requestId");

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
                response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
                return;
            }

            boolean success = false;

            switch (action.toLowerCase()) {
                case "approve":
                    // 2a. Lấy thông tin request TRƯỚC khi đổi status để có booking_id và service_id
                    CustomerRequest cr = requestDAO.getById(requestId);

                    // 2b. Duyệt yêu cầu dịch vụ: status -> Completed, gán lễ tân làm staff xử lý
                    success = requestDAO.updateStatusByReceptionist(requestId, "Completed", receptionistId);

                    // 2c. Nếu approve thành công và request có booking + service_id
                    //     → tự động thêm dịch vụ vào InvoiceItem của hóa đơn tương ứng
                    if (success && cr != null && cr.getBookingId() != null && cr.getServiceId() != null) {
                        addServiceToInvoice(cr);
                    }
                    break;

                case "cancel":
                    // Hủy yêu cầu dịch vụ
                    success = requestDAO.updateStatus(requestId, "Cancelled");
                    break;

                default:
                    LOGGER.log(Level.WARNING, "Unknown action received: " + action);
                    response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=invalid");
                    return;
            }

            String result = success ? "success" : "fail";
            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=servicerequests&result=" + result
                    + "&action=" + action);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in ReceptionistRequestController doPost", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests&error=unknown");
        }
    }

    /**
     * Tự động thêm dịch vụ đã được approve vào InvoiceItem của hóa đơn tương ứng.
     * Logic:
     * 1. Tìm Invoice theo booking_id của request
     * 2. Lấy thông tin HotelService (tên, giá) theo service_id
     * 3. Thêm dòng 'Service' vào InvoiceItem
     *
     * Nếu không tìm được invoice hoặc service, chỉ log cảnh báo,
     * không ném exception để tránh rollback toàn bộ approve.
     *
     * @param cr CustomerRequest đã được approve (có booking_id và service_id)
     */
    private void addServiceToInvoice(CustomerRequest cr) {
        try {
            // Tìm hóa đơn theo booking_id
            Invoice invoice = invoiceDAO.getInvoiceByBookingId(cr.getBookingId());
            if (invoice == null) {
                LOGGER.log(Level.WARNING, "No invoice found for booking_id={0}, skip adding service item",
                        cr.getBookingId());
                return;
            }

            // Lấy thông tin dịch vụ để biết tên và giá
            HotelService hs = hotelServiceRepo.getById(cr.getServiceId());
            if (hs == null) {
                LOGGER.log(Level.WARNING, "HotelService not found for service_id={0}, skip adding service item",
                        cr.getServiceId());
                return;
            }

            // Thêm dòng Service vào InvoiceItem
            boolean added = invoiceDAO.addServiceItem(
                    invoice.getInvoiceId(),
                    hs.getServiceName(),
                    1,
                    hs.getPrice()
            );

            if (added) {
                LOGGER.log(Level.INFO,
                        "Added service ''{0}'' (price={1}) to invoice #{2} for booking #{3}",
                        new Object[]{ hs.getServiceName(), hs.getPrice(), invoice.getInvoiceId(), cr.getBookingId() });
            } else {
                LOGGER.log(Level.WARNING,
                        "Failed to add service item to invoice #{0}", invoice.getInvoiceId());
            }
        } catch (Exception e) {
            // Chỉ log, không ném để tránh làm hỏng flow approve chính
            LOGGER.log(Level.SEVERE, "Exception when adding service to invoice", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=servicerequests");
    }
}
