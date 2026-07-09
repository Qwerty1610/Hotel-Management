package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;

public class HotelService implements Serializable {
    private int serviceId;
    private String serviceName;
    private String description;
    private double price;
    private String unit;
    private boolean isActive;

    public HotelService() {
    }

    public HotelService(int serviceId, String serviceName, String description, double price, String unit, boolean isActive) {
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.description = description;
        this.price = price;
        this.unit = unit;
        this.isActive = isActive;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}
