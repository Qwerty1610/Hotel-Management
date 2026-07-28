package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.InvoiceDAO;
import com.mycompany.hotelmanagement.entity.Invoice;
import com.mycompany.hotelmanagement.entity.InvoiceItem;
import com.mycompany.hotelmanagement.entity.Refund;

import java.util.List;

/**
 * InvoiceService
 * Tầng nghiệp vụ cho trang quản lý hóa đơn của Manager.
 *
 * thêm 2 hàm:
 * getInvoices: lấy ra danh sách hóa đơn theo bộ lọc
 * countInvoices: đếm tổng hóa đơn khớp bộ lọc
 *
 * getUnpaidTotal/getRefundingTotal: đổi nguồn tính sang sumNetUnpaidTotal/sumPendingRefundTotal
 * để 2 thẻ KPI phản ánh đúng số tiền thay vì tổng hóa đơn theo trạng thái.
 *
 * Date: 25/7/2026
 * version 1.1
 * @author Pham Quoc Quy
 */
public class InvoiceService {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();

    public List<Invoice> getAllInvoices() {
        return invoiceDAO.getAllInvoices();
    }

    /**
     * Một trang hóa đơn theo bộ lọc (server-side).
     *
     * @param stay lọc theo tình trạng lưu trú: "open" (khách chưa trả phòng),
     *             "closed" (đã trả phòng / hóa đơn đã chốt), "all" hoặc null = tất cả
     */
    public List<Invoice> getInvoices(String keyword, String status, String stay, int offset, int pageSize) {
        return invoiceDAO.getInvoices(keyword, status, stay, offset, pageSize);
    }

    /** Tổng số hóa đơn khớp bộ lọc (server-side). */
    public int countInvoices(String keyword, String status, String stay) {
        return invoiceDAO.countInvoices(keyword, status, stay);
    }

    public Invoice getInvoiceById(int id) {
        return invoiceDAO.getInvoiceById(id);
    }

    public List<InvoiceItem> getItems(int invoiceId) {
        return invoiceDAO.getItems(invoiceId);
    }

    public List<Refund> getRefunds(int invoiceId) {
        return invoiceDAO.getRefunds(invoiceId);
    }

    public List<Refund> getPendingRefunds(int invoiceId) {
        return invoiceDAO.getPendingRefunds(invoiceId);
    }

    /**
     * KPI: tổng tiền khách còn phải trả (đã trừ tiền cọc và phần đã hoàn),
     * tính cả hóa đơn đang chờ hoàn vì đó vẫn là công nợ.
     */
    public double getUnpaidTotal() {
        return invoiceDAO.sumNetUnpaidTotal();
    }

    /** KPI: tổng số tiền của các khoản đang chờ hoàn. */
    public double getRefundingTotal() {
        return invoiceDAO.sumPendingRefundTotal();
    }

    /** Hóa đơn còn cho phép thêm phụ phí / khoản hoàn hay không (khách chưa trả phòng). */
    public boolean isInvoiceOpen(int invoiceId) {
        return invoiceDAO.isInvoiceOpen(invoiceId);
    }

    public boolean addSurcharge(int invoiceId, String description, int quantity, double unitPrice) {
        if (description == null || description.trim().isEmpty()) return false;
        // Đơn giá phụ phí phải lớn hơn 1
        if (quantity <= 0 || unitPrice <= 1) return false;
        Invoice inv = invoiceDAO.getInvoiceById(invoiceId);
        if (inv == null) return false;
        // Chốt theo lúc khách trả phòng, không theo trạng thái Paid: khách thanh toán
        // hết phần còn lại giữa kỳ lưu trú vẫn phải ghi thêm phụ phí được.
        if (!invoiceDAO.isInvoiceOpen(invoiceId)) return false;
        return invoiceDAO.addSurcharge(invoiceId, description.trim(), quantity, unitPrice);
    }

    /** Thêm một khoản chờ hoàn (không hoàn ngay, chờ xác nhận). */
    public boolean addPendingRefund(int invoiceId, double amount, String reason) {
        // Số tiền cần hoàn phải lớn hơn 1
        if (amount <= 1) return false;
        Invoice inv = invoiceDAO.getInvoiceById(invoiceId);
        if (inv == null) return false;
        // Cùng ranh giới với addSurcharge: mở tới khi khách trả phòng.
        if (!invoiceDAO.isInvoiceOpen(invoiceId)) return false;
        // Không cho tạo khoản hoàn vượt quá phần còn có thể hoàn
        if (amount > inv.getRefundableAmount()) return false;
        return invoiceDAO.addPendingRefund(invoiceId, amount, reason != null ? reason.trim() : "");
    }

    /** Xác nhận đã hoàn cho các khoản chờ hoàn được chọn. */
    public boolean confirmRefunds(int invoiceId, List<Integer> refundIds) {
        return invoiceDAO.confirmRefunds(invoiceId, refundIds);
    }
}
