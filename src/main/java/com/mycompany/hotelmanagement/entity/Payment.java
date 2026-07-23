package com.mycompany.hotelmanagement.entity;

import java.sql.Timestamp;

/**
 * Payment
 * Một giao dịch thanh toán online qua SePay đã khớp được với hóa đơn.
 * Được ghi bởi webhook /api/sepay-webhook khi SePay báo có tiền vào
 * với nội dung chuyển khoản chứa mã hóa đơn (HD{invoiceId}).
 *
 * Các trường invoiceStatus / roomNumber / invoiceTotal là dẫn xuất
 * (join từ Invoice) phục vụ trang lịch sử thanh toán của khách.
 *
 * Date: 08/7/2026
 * @author Pham Quoc Quy
 */
public class Payment {

    private int paymentId;
    private Integer invoiceId;     // thanh toán hóa đơn (HD...) — null nếu là tiền cọc
    private Integer bookingId;     // tiền cọc đặt phòng (COC...) — null nếu là hóa đơn
    private long sepayTxId;        // ID giao dịch phía SePay
    private double amount;         // số tiền khách chuyển
    private String gateway;        // ngân hàng (MBBank, ACB...)
    private String referenceCode;  // mã tham chiếu của ngân hàng
    private String content;        // nội dung chuyển khoản gốc
    private Timestamp transactionDate;
    private Timestamp createdAt;

    // Dẫn xuất từ Invoice (cho trang lịch sử thanh toán)
    private String invoiceStatus;
    private String roomNumber;
    private double invoiceTotal;

    public Payment() {}

    /* ---------- Getters & Setters ---------- */
    public int getPaymentId()                { return paymentId; }
    public void setPaymentId(int v)          { this.paymentId = v; }

    public Integer getInvoiceId()            { return invoiceId; }
    public void setInvoiceId(Integer v)      { this.invoiceId = v; }

    public Integer getBookingId()            { return bookingId; }
    public void setBookingId(Integer v)      { this.bookingId = v; }

    /**
     * true nếu là giao dịch tiền cọc đặt phòng (hiển thị cột "Loại" trên JSP).
     * Cọc chỉ gắn booking_id; thanh toán hóa đơn online chỉ gắn invoice_id;
     * thanh toán tại quầy lúc trả phòng gắn cả hai nên phải loại trừ bằng
     * điều kiện invoice_id IS NULL, nếu không nó bị hiển thị nhầm thành cọc.
     */
    public boolean isDeposit()               { return bookingId != null && invoiceId == null; }

    public long getSepayTxId()               { return sepayTxId; }
    public void setSepayTxId(long v)         { this.sepayTxId = v; }

    public double getAmount()                { return amount; }
    public void setAmount(double v)          { this.amount = v; }

    public String getGateway()               { return gateway; }
    public void setGateway(String v)         { this.gateway = v; }

    public String getReferenceCode()         { return referenceCode; }
    public void setReferenceCode(String v)   { this.referenceCode = v; }

    public String getContent()               { return content; }
    public void setContent(String v)         { this.content = v; }

    public Timestamp getTransactionDate()    { return transactionDate; }
    public void setTransactionDate(Timestamp v) { this.transactionDate = v; }

    public Timestamp getCreatedAt()          { return createdAt; }
    public void setCreatedAt(Timestamp v)    { this.createdAt = v; }

    public String getInvoiceStatus()         { return invoiceStatus; }
    public void setInvoiceStatus(String v)   { this.invoiceStatus = v; }

    public String getRoomNumber()            { return roomNumber; }
    public void setRoomNumber(String v)      { this.roomNumber = v; }

    public double getInvoiceTotal()          { return invoiceTotal; }
    public void setInvoiceTotal(double v)    { this.invoiceTotal = v; }
}
