package com.mycompany.hotelmanagement.entity;

import java.sql.Timestamp;

public class CheckOut {
    private int checkOutId;
    private int bookingId;
    private int receptionistId;
    
    private double roomCharge;
    private double serviceCharge;
    private double extraCharge;
    private double totalAmount;
    private double amountPaid;
    private double remainingAmount;
    private String paymentMethod;
    
    private Timestamp checkedOutAt;
    private String notes;

    // Display fields for UI
    private String customerName;
    private String roomNumber;
    private Timestamp checkInDate;
    private Timestamp checkOutDate;
    private String roomTypeName;

    private java.util.List<InvoiceItem> serviceItems;
    private java.util.List<InvoiceItem> surchargeItems;
    private java.util.List<Payment> paymentHistory;

    public CheckOut() {}

    public int getCheckOutId() { return checkOutId; }
    public void setCheckOutId(int checkOutId) { this.checkOutId = checkOutId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getReceptionistId() { return receptionistId; }
    public void setReceptionistId(int receptionistId) { this.receptionistId = receptionistId; }

    public double getRoomCharge() { return roomCharge; }
    public void setRoomCharge(double roomCharge) { this.roomCharge = roomCharge; }

    public double getServiceCharge() { return serviceCharge; }
    public void setServiceCharge(double serviceCharge) { this.serviceCharge = serviceCharge; }

    public double getExtraCharge() { return extraCharge; }
    public void setExtraCharge(double extraCharge) { this.extraCharge = extraCharge; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public double getAmountPaid() { return amountPaid; }
    public void setAmountPaid(double amountPaid) { this.amountPaid = amountPaid; }

    public double getRemainingAmount() { return remainingAmount; }
    public void setRemainingAmount(double remainingAmount) { this.remainingAmount = remainingAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public Timestamp getCheckedOutAt() { return checkedOutAt; }
    public void setCheckedOutAt(Timestamp checkedOutAt) { this.checkedOutAt = checkedOutAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    // Display fields getters & setters
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public Timestamp getCheckInDate() { return checkInDate; }
    public void setCheckInDate(Timestamp checkInDate) { this.checkInDate = checkInDate; }

    public Timestamp getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(Timestamp checkOutDate) { this.checkOutDate = checkOutDate; }

    public String getRoomTypeName() { return roomTypeName; }
    public void setRoomTypeName(String roomTypeName) { this.roomTypeName = roomTypeName; }

    public java.util.List<InvoiceItem> getServiceItems() { return serviceItems; }
    public void setServiceItems(java.util.List<InvoiceItem> serviceItems) { this.serviceItems = serviceItems; }

    public java.util.List<InvoiceItem> getSurchargeItems() { return surchargeItems; }
    public void setSurchargeItems(java.util.List<InvoiceItem> surchargeItems) { this.surchargeItems = surchargeItems; }

    public java.util.List<Payment> getPaymentHistory() { return paymentHistory; }
    public void setPaymentHistory(java.util.List<Payment> paymentHistory) { this.paymentHistory = paymentHistory; }
}
