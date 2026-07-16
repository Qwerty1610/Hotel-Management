package com.mycompany.hotelmanagement.entity;

import java.sql.Timestamp;

/**
 * Refund
 * Bản ghi hoàn tiền cho một hóa đơn (số tiền + lý do).
 *
 * Date: 02/6/2026
 * ver 1.0
 * @author Phạm Quốc Quý
 */
public class Refund {

    private int refundId;
    private int invoiceId;
    private double amount;
    private String reason;
    private String status;        // Pending (chờ hoàn) / Done (đã hoàn)
    private Timestamp createdAt;
    private Timestamp confirmedAt; // thời điểm xác nhận đã hoàn

    public Refund() {}

    /* ---------- Getters & Setters ---------- */
    public int getRefundId()              { return refundId; }
    public void setRefundId(int v)        { this.refundId = v; }

    public int getInvoiceId()             { return invoiceId; }
    public void setInvoiceId(int v)       { this.invoiceId = v; }

    public double getAmount()             { return amount; }
    public void setAmount(double v)       { this.amount = v; }

    public String getReason()             { return reason; }
    public void setReason(String v)       { this.reason = v; }

    public String getStatus()             { return status; }
    public void setStatus(String v)       { this.status = v; }

    public Timestamp getCreatedAt()       { return createdAt; }
    public void setCreatedAt(Timestamp v) { this.createdAt = v; }

    public Timestamp getConfirmedAt()       { return confirmedAt; }
    public void setConfirmedAt(Timestamp v) { this.confirmedAt = v; }
}
