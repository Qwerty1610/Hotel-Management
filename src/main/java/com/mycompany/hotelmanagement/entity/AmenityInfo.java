package com.mycompany.hotelmanagement.entity;

/**
 * AmenityInfo
 * 
 * Lớp chứa thông tin (Model) của một Tiện nghi khách sạn.
 * 
 * Date: 10/7/2026
 * 
 * @author DUC BINH
 * @version 1.1
 */

public class AmenityInfo {
    private int amenityId;
    private String name;
    private String icon;
    private boolean isActive;

    public AmenityInfo() {}

    public AmenityInfo(String name, String icon) {
        this.name = name;
        this.icon = icon;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public int getAmenityId() {
        return amenityId;
    }

    public void setAmenityId(int amenityId) {
        this.amenityId = amenityId;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }
}
