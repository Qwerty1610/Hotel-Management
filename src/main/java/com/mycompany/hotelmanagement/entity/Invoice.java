package com.mycompany.hotelmanagement.entity;

import java.sql.Timestamp;

/**
 * Invoice
 * Hóa đơn (header). Tổng tiền = SUM(InvoiceItem.amount), tổng đã hoàn = SUM(Refund.amount),
 * đều được tính khi truy vấn nên là trường dẫn xuất.
 *
 * Chỉnh sửa điều kiện trong getRefundableAmount để tránh việc hoàn tiền khiến hóa đơn bị âm
 * 
 * Date: 11/6/2026
 * ver 1.1
 * @author Phạm Quốc Quý
 */
public class Invoice {

    private int invoiceId;
    private Integer bookingId;     // có thể null
    private String customerName;
    private String roomNumber;
    private String status;         // Pending / Paid / Refunding / Refunded / Cancelled
    private Timestamp createdAt;
    private double totalAmount;    // dẫn xuất: tổng các dòng chi tiết
    private double depositAmount;  // dẫn xuất: tiền cọc = 30% tiền phòng
    private double refundedAmount; // dẫn xuất: tổng đã hoàn (Refund status = Done)
    private double pendingRefundAmount; // dẫn xuất: tổng đang chờ hoàn (Refund status = Pending)

    public Invoice() {}

    /* ---------- Getters & Setters ---------- */
    public int getInvoiceId()              { return invoiceId; }
    public void setInvoiceId(int v)        { this.invoiceId = v; }

    public Integer getBookingId()          { return bookingId; }
    public void setBookingId(Integer v)    { this.bookingId = v; }

    public String getCustomerName()        { return customerName; }
    public void setCustomerName(String v)  { this.customerName = v; }

    public String getRoomNumber()          { return roomNumber; }
    public void setRoomNumber(String v)    { this.roomNumber = v; }

    public String getStatus()              { return status; }
    public void setStatus(String v)        { this.status = v; }

    public Timestamp getCreatedAt()        { return createdAt; }
    public void setCreatedAt(Timestamp v)  { this.createdAt = v; }

    public double getTotalAmount()         { return totalAmount; }
    public void setTotalAmount(double v)   { this.totalAmount = v; }

    public double getDepositAmount()       { return depositAmount; }
    public void setDepositAmount(double v) { this.depositAmount = v; }

    public double getRefundedAmount()      { return refundedAmount; }
    public void setRefundedAmount(double v){ this.refundedAmount = v; }

    public double getPendingRefundAmount()       { return pendingRefundAmount; }
    public void setPendingRefundAmount(double v) { this.pendingRefundAmount = v; }

    /** Thực thu = tổng cộng − tiền cọc đã trả − phần đã hoàn (không nhỏ hơn 0). */
    public double getNetAmount() {
        double net = totalAmount - depositAmount - refundedAmount;
        return net > 0 ? net : 0;
    }

    /**
     * Số tiền còn có thể tạo khoản hoàn.
     * Giới hạn để TỔNG hoàn (đã hoàn + đang chờ) không vượt quá (Tổng − Tiền cọc),
     * tức là Thực thu không bao giờ bị âm.
     * = Tổng − Tiền cọc − Đã hoàn − Đang chờ hoàn (kẹp về 0).
     */
    public double getRefundableAmount() {
        double r = totalAmount - depositAmount - refundedAmount - pendingRefundAmount;
        return r > 0 ? r : 0;
    }
}
