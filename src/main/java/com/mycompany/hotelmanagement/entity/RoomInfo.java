package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;

/**
 * Project: Hotel Management System
 * Class: RoomInfo
 *
 * Description:
 * Entity biểu diễn thông tin phòng kết hợp từ bảng Room và RoomType.
 * Bao gồm các thuộc tính roomId, roomNumber, typeId, status, floor và
 * các thuộc tính hiển thị từ RoomType (typeName, basePrice, bedType, area).
 * Được sử dụng cho trang quản lý phòng của Manager và danh sách tìm kiếm
 * phòng trống.
 *
 * Related Use Cases:
 * - UC-03 Search Available Rooms
 * - UC-29 Browse Available Room Types
 * - UC-56 View Room List
 * - UC-57 Add Room
 * - UC-58 Edit Room
 *
 * Date: 31-05-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
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

    private String operationalStatus;
    private String displayStatus;
    private boolean currentlyOccupied;

    public RoomInfo() {
    }

    public RoomInfo(int roomId, String roomNumber, int typeId, String status, String floor) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.typeId = typeId;
        this.status = status;
        this.operationalStatus = status;
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
        return displayStatus != null ? displayStatus : status;
    }

    public void setStatus(String status) {
        this.status = status;
        if (this.operationalStatus == null) {
            this.operationalStatus = status;
        }
    }

    public String getOperationalStatus() {
        return operationalStatus != null ? operationalStatus : status;
    }

    public void setOperationalStatus(String operationalStatus) {
        this.operationalStatus = operationalStatus;
    }

    public String getDisplayStatus() {
        return displayStatus != null ? displayStatus : status;
    }

    public void setDisplayStatus(String displayStatus) {
        this.displayStatus = displayStatus;
    }

    public boolean isCurrentlyOccupied() {
        return currentlyOccupied;
    }

    public void setCurrentlyOccupied(boolean currentlyOccupied) {
        this.currentlyOccupied = currentlyOccupied;
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
