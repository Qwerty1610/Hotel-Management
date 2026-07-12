package com.mycompany.hotelmanagement.entity;

import java.sql.Timestamp;
import java.util.Date;

public class Feedback {
    private int feedbackId;
    private int bookingId;
    private int roomId;
    private int accountId;
    private int rating;
    private String comment;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Các thuộc tính hỗ trợ hiển thị
    private String roomNumber;
    private String roomTypeName;
    private Date checkInDate;
    private Date checkOutDate;
    private Timestamp checkedOutAt;
    private String customerName;
    private boolean reviewed;

    public Feedback() {
    }

    public Feedback(int bookingId, int roomId, int accountId, int rating, String comment) {
        this.bookingId = bookingId;
        this.roomId = roomId;
        this.accountId = accountId;
        this.rating = rating;
        this.comment = comment;
    }

    // Getters and Setters
    public int getFeedbackId() { return feedbackId; }
    public void setFeedbackId(int feedbackId) { this.feedbackId = feedbackId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomTypeName() { return roomTypeName; }
    public void setRoomTypeName(String roomTypeName) { this.roomTypeName = roomTypeName; }

    public Date getCheckInDate() { return checkInDate; }
    public void setCheckInDate(Date checkInDate) { this.checkInDate = checkInDate; }

    public Date getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(Date checkOutDate) { this.checkOutDate = checkOutDate; }

    public Timestamp getCheckedOutAt() { return checkedOutAt; }
    public void setCheckedOutAt(Timestamp checkedOutAt) { this.checkedOutAt = checkedOutAt; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public boolean isReviewed() { return reviewed; }
    public void setReviewed(boolean reviewed) { this.reviewed = reviewed; }
}
