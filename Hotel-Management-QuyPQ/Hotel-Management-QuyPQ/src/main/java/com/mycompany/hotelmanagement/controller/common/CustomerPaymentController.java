package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Invoice;
import com.mycompany.hotelmanagement.service.PaymentService;
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
 * Controller cho 2 use case thanh toán của Customer (tích hợp SePay):
 * - Make Online Payment:
 *     GET /customer/payments/pay?invoiceId=..  -> trang mã QR chuyển khoản
 *     GET /customer/payments/status?invoiceId= -> JSON trạng thái (JS polling)
 * - View Payment History:
 *     GET /customer/payments                   -> lịch sử giao dịch + hóa đơn chờ trả
 *
 * Webhook xác nhận tiền vào nằm ở SePayWebhookController (/api/sepay-webhook).
 *
 * Date: 08/7/2026
 * @author Pham Quoc Quy
 * version: 1.0
 */
@WebServlet(name = "CustomerPaymentController", urlPatterns = { "/customer/payments", "/customer/payments/*" })
public class CustomerPaymentController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CustomerPaymentController.class.getName());
    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Authorize Customer (cùng pattern với CustomerBookingsController)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int accountId = (int) session.getAttribute("accountId");
        String pathInfo = request.getPathInfo();

        try {
            if ("/pay".equals(pathInfo)) {
                showPaymentPage(request, response, accountId);
            } else if ("/status".equals(pathInfo)) {
                writePaymentStatus(request, response, accountId);
            } else {
                showPaymentHistory(request, response, accountId);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in CustomerPaymentController", e);
            response.sendRedirect(request.getContextPath() + "/customer/payments?error=unknown");
        }
    }

    /** Trang lịch sử thanh toán + hóa đơn chờ thanh toán + đặt phòng chờ cọc. */
    private void showPaymentHistory(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        request.setAttribute("payments", paymentService.getPaymentHistory(accountId));
        request.setAttribute("unpaidInvoices", paymentService.getUnpaidInvoices(accountId));
        request.setAttribute("depositItems", paymentService.getPendingDeposits(accountId));

        String success = request.getParameter("success");
        if ("paid".equals(success)) {
            request.setAttribute("successMessage", "Thanh toán thành công! Cảm ơn bạn đã sử dụng dịch vụ.");
        } else if ("deposit_paid".equals(success)) {
            request.setAttribute("successMessage",
                    "Đã nhận tiền cọc! Đặt phòng của bạn đang chờ lễ tân xác nhận.");
        }
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorMessage", mapError(error));
        }
        request.getRequestDispatcher("/WEB-INF/views/customer/payment-history.jsp").forward(request, response);
    }

    /**
     * Trang mã QR SePay. Hỗ trợ 2 chế độ:
     * - ?invoiceId=..  : thanh toán hóa đơn Pending (nội dung CK HD{id})
     * - ?bookingId=..  : thanh toán tiền cọc đặt phòng Pending (nội dung CK COC{id})
     */
    private void showPaymentPage(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws ServletException, IOException {
        Integer invoiceId = parseId(request.getParameter("invoiceId"));
        Integer bookingId = parseId(request.getParameter("bookingId"));

        if (invoiceId != null) {
            Invoice invoice = paymentService.getPayableInvoice(invoiceId, accountId);
            if (invoice == null) {
                response.sendRedirect(request.getContextPath() + "/customer/payments?error=notpayable");
                return;
            }
            double remaining = paymentService.getRemainingAmount(invoice);
            if (remaining <= 0) {
                response.sendRedirect(request.getContextPath() + "/customer/payments?error=nothingdue");
                return;
            }
            String content = paymentService.buildTransferContent(invoiceId);
            request.setAttribute("mode", "invoice");
            request.setAttribute("invoice", invoice);
            request.setAttribute("remainingAmount", Math.round(remaining));
            request.setAttribute("qrUrl", paymentService.buildQrUrl(content, remaining));
            request.setAttribute("transferContent", content);
        } else if (bookingId != null) {
            Booking booking = paymentService.getPayableDepositBooking(bookingId, accountId);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/customer/payments?error=notpayable");
                return;
            }
            double remaining = paymentService.getDepositRemaining(booking);
            if (remaining <= 0) {
                response.sendRedirect(request.getContextPath() + "/customer/payments?error=nothingdue");
                return;
            }
            String content = paymentService.buildDepositTransferContent(bookingId);
            request.setAttribute("mode", "deposit");
            request.setAttribute("booking", booking);
            request.setAttribute("depositAmount", Math.round(paymentService.getDepositAmount(booking)));
            request.setAttribute("remainingAmount", Math.round(remaining));
            request.setAttribute("qrUrl", paymentService.buildQrUrl(content, remaining));
            request.setAttribute("transferContent", content);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/payments?error=notfound");
            return;
        }

        request.setAttribute("bankAccount", paymentService.getBankAccount());
        request.setAttribute("bankCode", paymentService.getBankCode());
        request.setAttribute("accountHolder", paymentService.getAccountHolder());
        request.getRequestDispatcher("/WEB-INF/views/customer/payment-qr.jsp").forward(request, response);
    }

    /** JSON trạng thái cho JS polling: hóa đơn (invoiceId) hoặc tiền cọc (bookingId). */
    private void writePaymentStatus(HttpServletRequest request, HttpServletResponse response, int accountId)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Integer invoiceId = parseId(request.getParameter("invoiceId"));
        Integer bookingId = parseId(request.getParameter("bookingId"));

        if (invoiceId != null) {
            Invoice invoice = paymentService.getCustomerInvoice(invoiceId, accountId);
            if (invoice == null) {
                writeNotFound(response);
                return;
            }
            boolean paid = "Paid".equals(invoice.getStatus());
            response.getWriter().write("{\"status\": \"" + invoice.getStatus() + "\", \"paid\": " + paid + "}");
        } else if (bookingId != null) {
            PaymentService.DepositItem item = paymentService.getDepositStatus(bookingId, accountId);
            if (item == null) {
                writeNotFound(response);
                return;
            }
            response.getWriter().write("{\"status\": \"" + item.getBooking().getStatus()
                    + "\", \"paid\": " + item.isFullyPaid() + "}");
        } else {
            writeNotFound(response);
        }
    }

    private void writeNotFound(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        response.getWriter().write("{\"error\": \"not_found\"}");
    }

    private Integer parseId(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        try {
            return Integer.valueOf(raw.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String mapError(String code) {
        switch (code) {
            case "notfound":   return "Không tìm thấy hóa đơn cần thanh toán.";
            case "notpayable": return "Hóa đơn không tồn tại, không thuộc về bạn hoặc đã được thanh toán.";
            case "nothingdue": return "Hóa đơn này không còn khoản nào cần thanh toán.";
            default:           return "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.";
        }
    }
}
