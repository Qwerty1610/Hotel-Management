package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;

public class RoomInfo implements Serializable {
    private int roomId;
    private String roomNumber;
    private int typeId;
    private String status;
    private String floor;
    
    // Joint properties from RoomType for dashboard display
    private String typeName;
    private double basePrice;
    private String bedType;
    private String area;

    public RoomInfo() {
    }

    public RoomInfo(int roomId, String roomNumber, int typeId, String status, String floor) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.typeId = typeId;
        this.status = status;
        this.floor = floor;
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

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
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

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public String getBedType() {
        return bedType;
    }

    public void setBedType(String bedType) {
        this.bedType = bedType;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }
}
