/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.hotelmanagement.entity;

import java.sql.Date;
/**
 *
 * Date: 31/5/2026
 * @author DUC BINH
 */

public class Booking {

    private int bookingId;
    private Integer accountId;       
    private String customerName;
    private Integer roomTypeId;      
    private String roomTypeName;     
    private int roomQuantity;
    private Date checkInDate;
    private Date checkOutDate;
    private double totalAmount;
    private String status;           
    private String note;
    private Integer groupBookingId;
    private Date createdAt;
    private String assignedRoomsStr;

    private int totalRoomQuantity;
    private String groupRoomTypeNames;
    private double overallTotalAmount;
    private int totalRoomTypes;


    /* ---------- Constructors ---------- */

    public Booking() {}

    public Booking(int bookingId, String customerName, int roomQuantity,
                   Date checkInDate, Date checkOutDate,
                   double totalAmount, String status) {
        this.bookingId     = bookingId;
        this.customerName  = customerName;
        this.roomQuantity  = roomQuantity;
        this.checkInDate   = checkInDate;
        this.checkOutDate  = checkOutDate;
        this.totalAmount   = totalAmount;
        this.status        = status;
    }

    /* ---------- Getters & Setters ---------- */

    public int getBookingId()               { return bookingId; }
    public void setBookingId(int v)         { this.bookingId = v; }

    public Integer getAccountId()           { return accountId; }
    public void setAccountId(Integer v)     { this.accountId = v; }

    public String getCustomerName()         { return customerName; }
    public void setCustomerName(String v)   {
        if (v == null || v.trim().isEmpty()) {
            throw new IllegalArgumentException("Customer name cannot be null or empty");
        }
        String trimmed = v.trim();
        if (trimmed.length() > 100) {
            throw new IllegalArgumentException("Customer name cannot exceed 100 characters");
        }
        this.customerName = trimmed;
    }

    public Integer getRoomTypeId()          { return roomTypeId; }
    public void setRoomTypeId(Integer v)    { this.roomTypeId = v; }

    public String getRoomTypeName()         { return roomTypeName; }
    public void setRoomTypeName(String v)   { this.roomTypeName = v; }

    public int getRoomQuantity()            { return roomQuantity; }
    public void setRoomQuantity(int v)      {
        if (v <= 0 || v > 100) {
            throw new IllegalArgumentException("Room quantity must be between 1 and 100");
        }
        this.roomQuantity = v;
    }

    public Date getCheckInDate()            { return checkInDate; }
    public void setCheckInDate(Date v)      {
        if (v == null) {
            throw new IllegalArgumentException("Check-in date cannot be null");
        }
        this.checkInDate = v;
    }

    public Date getCheckOutDate()           { return checkOutDate; }
    public void setCheckOutDate(Date v)     {
        if (v == null) {
            throw new IllegalArgumentException("Check-out date cannot be null");
        }
        this.checkOutDate = v;
    }

    public double getTotalAmount()          { return totalAmount; }
    public void setTotalAmount(double v)    {
        if (v < 0) {
            throw new IllegalArgumentException("Total amount cannot be negative");
        }
        this.totalAmount = v;
    }

    public String getStatus()               { return status; }
    public void setStatus(String v)         { this.status = v; }

    public String getNote()                 { return note; }
    public void setNote(String v)           { this.note = v; }

    public Integer getGroupBookingId()      { return groupBookingId; }
    public void setGroupBookingId(Integer v) { this.groupBookingId = v; }

    public Date getCreatedAt()              { return createdAt; }
    public void setCreatedAt(Date v)        { this.createdAt = v; }

    public String getAssignedRoomsStr()     { return assignedRoomsStr; }
    public void setAssignedRoomsStr(String v) { this.assignedRoomsStr = v; }

    public int getTotalRoomQuantity() {
        return totalRoomQuantity > 0 ? totalRoomQuantity : roomQuantity;
    }
    public void setTotalRoomQuantity(int v) {
        this.totalRoomQuantity = v;
    }

    public String getGroupRoomTypeNames() {
        return (groupRoomTypeNames != null && !groupRoomTypeNames.trim().isEmpty()) ? groupRoomTypeNames : roomTypeName;
    }
    public void setGroupRoomTypeNames(String v) {
        this.groupRoomTypeNames = v;
    }

    public double getOverallTotalAmount() {
        return overallTotalAmount > 0 ? overallTotalAmount : totalAmount;
    }
    public void setOverallTotalAmount(double v) {
        this.overallTotalAmount = v;
    }

    public int getTotalRoomTypes() {
        return totalRoomTypes > 0 ? totalRoomTypes : 1;
    }
    public void setTotalRoomTypes(int v) {
        this.totalRoomTypes = v;
    }


    /* ---------- Validation Logic ---------- */
    public boolean isValid() {
        if (customerName == null || customerName.trim().isEmpty() || customerName.trim().length() > 100) {
            return false;
        }
        if (roomQuantity <= 0 || roomQuantity > 100) {
            return false;
        }
        if (totalAmount < 0) {
            return false;
        }
        if (checkInDate == null || checkOutDate == null) {
            return false;
        }
        if (!checkInDate.before(checkOutDate)) {
            return false;
        }
        return true;
    }

    /* ---------- Helper: số đêm ---------- */
    public long getNights() {
        if (checkInDate == null || checkOutDate == null) return 0;
        long diff = checkOutDate.getTime() - checkInDate.getTime();
        return Math.max(0L, diff / (1000L * 60 * 60 * 24));
    }

    @Override
    public String toString() {
        return "Booking{" +
                "bookingId=" + bookingId +
                ", accountId=" + accountId +
                ", customerName='" + customerName + '\'' +
                ", roomTypeId=" + roomTypeId +
                ", roomTypeName='" + roomTypeName + '\'' +
                ", roomQuantity=" + roomQuantity +
                ", checkInDate=" + checkInDate +
                ", checkOutDate=" + checkOutDate +
                ", totalAmount=" + totalAmount +
                ", status='" + status + '\'' +
                ", note='" + note + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
