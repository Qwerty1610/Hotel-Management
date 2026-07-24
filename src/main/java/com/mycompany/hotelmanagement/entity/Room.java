package com.mycompany.hotelmanagement.entity;

/**
 * Project: Hotel Management System
 * Class: Room
 *
 * Description:
 * Entity biểu diễn một phòng khách sạn dùng trong ngữ cảnh hiển thị
 * danh sách phòng đã gán cho booking. Bao gồm các thuộc tính roomId,
 * roomNumber, typeName, status, floor và imageUrl.
 *
 * Related Use Cases:
 * - UC-56 View Room List
 * - UC-57 Add Room
 * - UC-58 Edit Room
 *
 * Date: 31-05-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class Room {

    private int roomId;
    private String roomNumber;
    private String typeName;
    private String status;
    private String floor;
    private String imageUrl;
    private boolean hasGuest;

    public Room() {
    }

    public Room(int roomId,
                String roomNumber,
                String typeName,
                String status,
                String floor,
                String imageUrl) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.typeName = typeName;
        this.status = status;
        this.floor = floor;
        this.imageUrl = imageUrl;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getFloor() {
        return floor;
    }

    public void setFloor(String floor) {
        this.floor = floor;
    }

    // ⭐ IMAGE
    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isHasGuest() {
        return hasGuest;
    }

    public void setHasGuest(boolean hasGuest) {
        this.hasGuest = hasGuest;
    }
}