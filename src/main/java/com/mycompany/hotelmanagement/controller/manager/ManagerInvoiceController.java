package com.mycompany.hotelmanagement.controller.manager;

import com.mycompany.hotelmanagement.entity.Invoice;
import com.mycompany.hotelmanagement.service.InvoiceService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * ManagerInvoiceController
 * Trang riêng quản lý hóa đơn của Manager.
 *
 * GET  /manager/invoices            -> danh sách hóa đơn + KPI
 * GET  /manager/invoices?id=X       -> chi tiết hóa đơn X
 * POST /manager/invoices?action=surcharge -> thêm phụ phí (invoiceId, description, quantity, unitPrice)
 * POST /manager/invoices?action=refund    -> hoàn tiền (invoiceId, amount, reason)
 *
 * Date: 02/6/2026
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
                request.getRequestDispatcher("/WEB-INF/views/manager/invoice-detail.jsp")
                        .forward(request, response);
                return;
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/manager/invoices");
                return;
            }
        }

        // Trang danh sách
        request.setAttribute("invoices", service.getAllInvoices());
        request.setAttribute("unpaidTotal", service.getUnpaidTotal());
        request.setAttribute("refundingTotal", service.getRefundingTotal());
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
                service.addRefund(invoiceId, amount, reason);
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
}
