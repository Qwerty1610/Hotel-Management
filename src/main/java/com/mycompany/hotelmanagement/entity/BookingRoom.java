package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;

/**
 * Entity đại diện cho thông tin chi tiết từng phòng được đặt và họ tên khách nghỉ tương ứng.
 * Phục vụ cho chức năng đặt nhiều loại phòng và lưu danh sách khách nghỉ theo phòng.
 *
 * @author BinhHD
 * @date 20/06/2026
 * @version 1.0
 */
public class BookingRoom implements Serializable {
    private int bookingRoomId;
    private int bookingId;
    private int roomTypeId;
    private String roomTypeName;
    private int quantity;
    private double price;
    private String guestName;

    public BookingRoom() {
    }

    public BookingRoom(int bookingRoomId, int bookingId, int roomTypeId, String roomTypeName, int quantity, double price, String guestName) {
        this.bookingRoomId = bookingRoomId;
        this.bookingId = bookingId;
        this.roomTypeId = roomTypeId;
        this.roomTypeName = roomTypeName;
        this.quantity = quantity;
        this.price = price;
        this.guestName = guestName;
    }

    public int getBookingRoomId() {
        return bookingRoomId;
    }

    public void setBookingRoomId(int bookingRoomId) {
        this.bookingRoomId = bookingRoomId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getRoomTypeId() {
        return roomTypeId;
    }

    public void setRoomTypeId(int roomTypeId) {
        this.roomTypeId = roomTypeId;
    }

    public String getRoomTypeName() {
        return roomTypeName;
    }

    public void setRoomTypeName(String roomTypeName) {
        this.roomTypeName = roomTypeName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getGuestName() {
        return guestName;
    }

    public void setGuestName(String guestName) {
        this.guestName = guestName;
    }
}
