package com.mycompany.hotelmanagement.entity;

public class Room {

    private int roomId;
    private String roomNumber;
    private String typeName;
    private String status;
    private String floor;
    private String imageUrl; // ⭐ THÊM MỚI

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
}