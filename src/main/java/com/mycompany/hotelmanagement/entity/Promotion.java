package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Promotion entity
 * Đại diện cho một chương trình khuyến mãi / mã giảm giá trong hệ thống.
 *
 * UC-48: Manage Promotions
 * Date: 07/7/2026
 *
 * @author DINH KHANH
 */
public class Promotion implements Serializable {

    private int promotionId;
    private String promotionCode;
    private String promotionName;
    private String description;
    private String discountType;       // "PERCENT" or "FIXED"
    private BigDecimal discountValue;
    private LocalDate startDate;
    private LocalDate endDate;
    private String eventName;
    private BigDecimal minBookingAmount;
    private BigDecimal maxDiscountAmount;
    private Integer usageLimit;
    private int usedCount;
    private String status;             // "Active", "Inactive"
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Promotion() {
    }

    // ─── Getters & Setters ────────────────────────────────────────────────────

    public int getPromotionId() {
        return promotionId;
    }

    public void setPromotionId(int promotionId) {
        this.promotionId = promotionId;
    }

    public String getPromotionCode() {
        return promotionCode;
    }

    public void setPromotionCode(String promotionCode) {
        this.promotionCode = promotionCode;
    }

    public String getPromotionName() {
        return promotionName;
    }

    public void setPromotionName(String promotionName) {
        this.promotionName = promotionName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public BigDecimal getMinBookingAmount() {
        return minBookingAmount;
    }

    public void setMinBookingAmount(BigDecimal minBookingAmount) {
        this.minBookingAmount = minBookingAmount;
    }

    public BigDecimal getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    public Integer getUsageLimit() {
        return usageLimit;
    }

    public void setUsageLimit(Integer usageLimit) {
        this.usageLimit = usageLimit;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    /**
     * Trả về trạng thái hiển thị thực tế:
     * Nếu EndDate < hôm nay thì là "Expired" dù Status trong DB là "Active".
     * Nếu Status = "Inactive" thì là "Inactive".
     * Còn lại là "Active".
     *
     * @return "Active" | "Inactive" | "Expired"
     */
    public String getEffectiveStatus() {
        if (endDate != null && endDate.isBefore(LocalDate.now())) {
            return "Expired";
        }
        return status;
    }
}
