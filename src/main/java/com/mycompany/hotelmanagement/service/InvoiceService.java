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
 * Date: 02/6/2026
 */
public class InvoiceService {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();

    public List<Invoice> getAllInvoices() {
        return invoiceDAO.getAllInvoices();
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

    /** KPI: tổng tiền các hóa đơn chưa thanh toán. */
    public double getUnpaidTotal() {
        return invoiceDAO.sumTotalByStatus("Pending");
    }

    /** KPI: tổng tiền các hóa đơn đang chờ hoàn (Refunding). */
    public double getRefundingTotal() {
        return invoiceDAO.sumTotalByStatus("Refunding");
    }

    public boolean addSurcharge(int invoiceId, String description, int quantity, double unitPrice) {
        if (description == null || description.trim().isEmpty()) return false;
        if (quantity <= 0 || unitPrice < 0) return false;
        return invoiceDAO.addSurcharge(invoiceId, description.trim(), quantity, unitPrice);
    }

    public boolean addRefund(int invoiceId, double amount, String reason) {
        if (amount <= 0) return false;
        Invoice inv = invoiceDAO.getInvoiceById(invoiceId);
        if (inv == null) return false;
        // Không cho hoàn vượt quá phần còn lại của hóa đơn
        double remaining = inv.getTotalAmount() - inv.getRefundedAmount();
        if (amount > remaining) return false;
        return invoiceDAO.addRefund(invoiceId, amount, reason != null ? reason.trim() : "");
    }
}
