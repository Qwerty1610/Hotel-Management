package com.mycompany.hotelmanagement.controller.manager;

import com.mycompany.hotelmanagement.entity.Invoice;
import com.mycompany.hotelmanagement.service.InvoiceService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * ManagerInvoiceController
 * Trang riêng quản lý hóa đơn của Manager.
 *
 * GET  /manager/invoices            -> danh sách hóa đơn + KPI
 * GET  /manager/invoices?id=X       -> chi tiết hóa đơn X
 * POST /manager/invoices?action=surcharge -> thêm phụ phí (invoiceId, description, quantity, unitPrice)
 * POST /manager/invoices?action=refund    -> hoàn tiền (invoiceId, amount, reason)
 *
 * Thay xử lý render trang từ FE xuống BE
 * 
 * Date: 11/6/2026
 * version 1.1
 * @author Pham Quoc Quy
 */
@WebServlet(name = "ManagerInvoiceController", urlPatterns = {"/manager/invoices"})
public class ManagerInvoiceController extends HttpServlet {

    private final InvoiceService service = new InvoiceService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            // Trang chi tiết
            try {
                int id = Integer.parseInt(idParam.trim());
                Invoice invoice = service.getInvoiceById(id);
                if (invoice == null) {
                    response.sendRedirect(request.getContextPath() + "/manager/invoices");
                    return;
                }
                request.setAttribute("invoice", invoice);
                request.setAttribute("items", service.getItems(id));
                request.setAttribute("refunds", service.getRefunds(id));
                request.setAttribute("pendingRefunds", service.getPendingRefunds(id));
                request.getRequestDispatcher("/WEB-INF/views/manager/invoice-detail.jsp")
                        .forward(request, response);
                return;
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/manager/invoices");
                return;
            }
        }

        // Trang danh sách (lọc + phân trang server-side)
        String keyword = request.getParameter("q");
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) status = "all";

        final int pageSize = 8;
        int page = parseIntOr(request.getParameter("page"), 1);
        if (page < 1) page = 1;

        int totalItems = service.countInvoices(keyword, status);
        int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * pageSize;

        request.setAttribute("invoices", service.getInvoices(keyword, status, offset, pageSize));
        request.setAttribute("unpaidTotal", service.getUnpaidTotal());
        request.setAttribute("refundingTotal", service.getRefundingTotal());
        request.setAttribute("q", keyword == null ? "" : keyword);
        request.setAttribute("statusFilter", status);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);
        request.getRequestDispatcher("/WEB-INF/views/manager/invoices.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int invoiceId = -1;
        try {
            invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
            if ("surcharge".equalsIgnoreCase(action)) {
                String desc = request.getParameter("description");
                int qty = parseIntOr(request.getParameter("quantity"), 1);
                double unitPrice = parseDoubleOr(request.getParameter("unitPrice"), -1);
                service.addSurcharge(invoiceId, desc, qty, unitPrice);
            } else if ("refund".equalsIgnoreCase(action)) {
                double amount = parseDoubleOr(request.getParameter("amount"), -1);
                String reason = request.getParameter("reason");
                service.addPendingRefund(invoiceId, amount, reason);
            } else if ("confirmRefunds".equalsIgnoreCase(action)) {
                service.confirmRefunds(invoiceId, parseIds(request.getParameter("refundIds")));
            }
        } catch (NumberFormatException e) {
            // Tham số không hợp lệ -> bỏ qua
        }

        if (invoiceId > 0) {
            response.sendRedirect(request.getContextPath() + "/manager/invoices?id=" + invoiceId);
        } else {
            response.sendRedirect(request.getContextPath() + "/manager/invoices");
        }
    }

    private int parseIntOr(String v, int fallback) {
        try { return Integer.parseInt(v.trim()); } catch (Exception e) { return fallback; }
    }

    private double parseDoubleOr(String v, double fallback) {
        try { return Double.parseDouble(v.trim()); } catch (Exception e) { return fallback; }
    }

    /** Tách chuỗi id ngăn cách bởi dấu phẩy (vd "3,5,8") thành danh sách số nguyên. */
    private List<Integer> parseIds(String csv) {
        List<Integer> ids = new ArrayList<>();
        if (csv == null) return ids;
        for (String part : csv.split(",")) {
            try {
                ids.add(Integer.parseInt(part.trim()));
            } catch (NumberFormatException ignored) {
                // bỏ qua phần tử không hợp lệ
            }
        }
        return ids;
    }
}
