package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Project: Hotel Management System
 * Class: Promotion
 *
 * Description:
 * Entity biểu diễn một chương trình khuyến mãi. Bao gồm các thuộc tính
 * promotionId, promotionCode, promotionName, description, discountType
 * (PERCENT/FIXED), discountValue, startDate, endDate, eventName,
 * minBookingAmount, maxDiscountAmount, usageLimit, usedCount và status.
 * Cung cấp phương thức getEffectiveStatus() để tính trạng thái hiển thị
 * thực tế dựa trên endDate và status trong cơ sở dữ liệu.
 *
 * Related Use Cases:
 * - UC-46 View Promotions
 * - UC-64 Add Promotion
 * - UC-65 Edit Promotion
 *
 * Date: 11-07-2026
 *
 * @author KhanhTD
 * @version 1.0
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
