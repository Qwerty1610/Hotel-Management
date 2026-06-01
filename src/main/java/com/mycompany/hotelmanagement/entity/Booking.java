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
    private Date createdAt;

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
    public void setCustomerName(String v)   { this.customerName = v; }

    public Integer getRoomTypeId()          { return roomTypeId; }
    public void setRoomTypeId(Integer v)    { this.roomTypeId = v; }

    public String getRoomTypeName()         { return roomTypeName; }
    public void setRoomTypeName(String v)   { this.roomTypeName = v; }

    public int getRoomQuantity()            { return roomQuantity; }
    public void setRoomQuantity(int v)      { this.roomQuantity = v; }

    public Date getCheckInDate()            { return checkInDate; }
    public void setCheckInDate(Date v)      { this.checkInDate = v; }

    public Date getCheckOutDate()           { return checkOutDate; }
    public void setCheckOutDate(Date v)     { this.checkOutDate = v; }

    public double getTotalAmount()          { return totalAmount; }
    public void setTotalAmount(double v)    { this.totalAmount = v; }

    public String getStatus()               { return status; }
    public void setStatus(String v)         { this.status = v; }

    public String getNote()                 { return note; }
    public void setNote(String v)           { this.note = v; }

    public Date getCreatedAt()              { return createdAt; }
    public void setCreatedAt(Date v)        { this.createdAt = v; }

    /* ---------- Helper: số đêm ---------- */
    public long getNights() {
        if (checkInDate == null || checkOutDate == null) return 0;
        long diff = checkOutDate.getTime() - checkInDate.getTime();
        return diff / (1000L * 60 * 60 * 24);
    }
}

