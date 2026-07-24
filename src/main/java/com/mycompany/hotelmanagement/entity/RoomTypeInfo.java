package com.mycompany.hotelmanagement.entity;

import java.util.List;

/**
 * Project: Hotel Management System
 * Class: RoomTypeInfo
 *
 * Description:
 * Entity biểu diễn thông tin loại phòng, bao gồm các thuộc tính cơ bản
 * (typeId, typeName, basePrice, pricePerHour, depositPercent, capacity,
 * description, area, bedType), danh sách hình ảnh, danh sách tiện nghi
 * và số phòng còn trống. Được sử dụng cho cả trang hiển thị công khai
 * lẫn trang quản lý của Manager.
 *
 * Related Use Cases:
 * - UC-29 Browse Available Room Types
 * - UC-30 View Room Type Detail
 * - UC-53 View Room Type Records
 * - UC-54 Add Room Type
 * - UC-55 Edit Room Type
 *
 * Date: 31-05-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class RoomTypeInfo {
    private int typeId;
    private String typeName;
    private double basePrice;
    private double pricePerHour;
    private double depositPercent;
    private int capacity;
    private String description;
    private String imageUrl;
    private List<String> amenities;
    
    // New fields for detail page
    private List<String> imageUrls;
    private List<AmenityInfo> amenityDetails;
    private int availableCount;
    
    // Spec fields
    private String area;
    private String bedType;

    // Delete guard: true if this room type currently has occupied guests
    private boolean hasOccupiedGuests;

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
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

    public double getPricePerHour() {
        return pricePerHour;
    }

    public void setPricePerHour(double pricePerHour) {
        this.pricePerHour = pricePerHour;
    }

    public double getDepositPercent() {
        return depositPercent;
    }

    public void setDepositPercent(double depositPercent) {
        this.depositPercent = depositPercent;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public List<String> getAmenities() {
        return amenities;
    }

    public void setAmenities(List<String> amenities) {
        this.amenities = amenities;
    }

    public List<String> getImageUrls() {
        return imageUrls;
    }

    public void setImageUrls(List<String> imageUrls) {
        this.imageUrls = imageUrls;
    }

    public List<AmenityInfo> getAmenityDetails() {
        return amenityDetails;
    }

    public void setAmenityDetails(List<AmenityInfo> amenityDetails) {
        this.amenityDetails = amenityDetails;
    }

    public int getAvailableCount() {
        return availableCount;
    }

    public void setAvailableCount(int availableCount) {
        this.availableCount = availableCount;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getBedType() {
        return bedType;
    }

    public void setBedType(String bedType) {
        this.bedType = bedType;
    }

    public boolean isHasOccupiedGuests() {
        return hasOccupiedGuests;
    }

    public void setHasOccupiedGuests(boolean hasOccupiedGuests) {
        this.hasOccupiedGuests = hasOccupiedGuests;
    }
}
