package com.mycompany.hotelmanagement.service;

import java.util.List;

import com.mycompany.hotelmanagement.dal.PromotionDAO;
import com.mycompany.hotelmanagement.entity.Promotion;

/**
 * Project: Hotel Management System
 * Class: PromotionService
 *
 * Description:
 * Tầng nghiệp vụ quản lý khuyến mãi. Cung cấp các phương thức lấy toàn
 * bộ danh sách, lấy theo ID, kiểm tra trùng mã khuyến mãi, lưu (thêm mới
 * hoặc cập nhật), bật/tắt trạng thái và xóa khuyến mãi. Ủy quyền thao tác
 * dữ liệu cho PromotionDAO.
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
public class PromotionService {

    private final PromotionDAO promotionRepository = new PromotionDAO();

    /**
     * Lấy toàn bộ danh sách khuyến mãi.
     */
    public List<Promotion> getAllPromotions() {
        return promotionRepository.getAllPromotions();
    }

    /**
     * Kiểm tra mã khuyến mãi có bị trùng không.
     *
     * @param code      Mã cần kiểm tra
     * @param excludeId ID cần bỏ qua khi update (-1 khi thêm mới)
     */
    public boolean isCodeDuplicate(String code, int excludeId) {
        return promotionRepository.isCodeDuplicate(code, excludeId);
    }

    /**
     * Lưu khuyến mãi: thêm mới nếu promotionId <= 0, cập nhật nếu > 0.
     */
    public boolean savePromotion(Promotion promotion) {
        if (promotion.getPromotionId() <= 0) {
            return promotionRepository.insertPromotion(promotion);
        } else {
            return promotionRepository.updatePromotion(promotion);
        }
    }

    /**
     * Bật/Tắt trạng thái khuyến mãi.
     *
     * @param promotionId ID khuyến mãi
     * @param newStatus   "Active" hoặc "Inactive"
     */
    public boolean togglePromotionStatus(int promotionId, String newStatus) {
        return promotionRepository.togglePromotionStatus(promotionId, newStatus);
    }

    /**
     * Lấy một khuyến mãi theo ID.
     */
    public Promotion getPromotionById(int promotionId) {
        return promotionRepository.getPromotionById(promotionId);
    }

    /**
     * Lấy một khuyến mãi theo mã Code.
     */
    public Promotion getPromotionByCode(String code) {
        return promotionRepository.getPromotionByCode(code);
    }

    /**
     * Tăng số lượng đã sử dụng của khuyến mãi lên 1.
     */
    public boolean incrementUsedCount(int promotionId) {
        return promotionRepository.incrementUsedCount(promotionId);
    }

    public static class PromotionResult {
        public boolean success;
        public String message;
        public double discountAmount;
        public Promotion promotion;

        public PromotionResult(boolean success, String message, double discountAmount, Promotion promotion) {
            this.success = success;
            this.message = message;
            this.discountAmount = discountAmount;
            this.promotion = promotion;
        }
    }

    /**
     * Xác thực mã khuyến mãi và tính toán số tiền giảm (không kiểm tra tài khoản).
     */
    public PromotionResult validateAndCalculateDiscount(String code, double totalBookingAmount) {
        return validateAndCalculateDiscount(code, totalBookingAmount, null);
    }

    /**
     * Xác thực mã khuyến mãi, tính toán số tiền giảm và kiểm tra giới hạn 1 lần/người dùng đối với tài khoản accountId.
     */
    public PromotionResult validateAndCalculateDiscount(String code, double totalBookingAmount, Integer accountId) {
        if (code == null || code.trim().isEmpty()) {
            return new PromotionResult(false, "Vui lòng nhập mã khuyến mãi.", 0, null);
        }

        Promotion p = getPromotionByCode(code.trim());
        if (p == null) {
            return new PromotionResult(false, "Mã khuyến mãi không tồn tại.", 0, null);
        }

        if (!"Active".equalsIgnoreCase(p.getStatus())) {
            return new PromotionResult(false, "Mã khuyến mãi đã bị vô hiệu hóa.", 0, p);
        }

        String effectiveStatus = p.getEffectiveStatus();
        if ("Expired".equalsIgnoreCase(effectiveStatus)) {
            return new PromotionResult(false, "Mã khuyến mãi đã hết hạn.", 0, p);
        }

        java.time.LocalDate now = java.time.LocalDate.now();
        if (p.getStartDate() != null && now.isBefore(p.getStartDate())) {
            return new PromotionResult(false, "Mã khuyến mãi chưa đến thời gian áp dụng.", 0, p);
        }

        if (p.getUsageLimit() != null && p.getUsedCount() >= p.getUsageLimit()) {
            return new PromotionResult(false, "Mã khuyến mãi đã hết lượt sử dụng.", 0, p);
        }

        if (p.getMinBookingAmount() != null && totalBookingAmount < p.getMinBookingAmount().doubleValue()) {
            return new PromotionResult(false, "Đơn đặt phòng không đạt giá trị tối thiểu để áp dụng mã này.", 0, p);
        }

        // Kiểm tra xem tài khoản này đã từng áp dụng mã này ở đơn đặt phòng khác hay chưa
        if (accountId != null && accountId > 0) {
            if (promotionRepository.hasUserUsedPromotion(accountId, p.getPromotionId())) {
                return new PromotionResult(false, "Bạn đã sử dụng mã khuyến mãi này cho một đơn đặt phòng khác.", 0, p);
            }
        }

        double discountAmount = calculateDiscountAmount(p, totalBookingAmount);

        return new PromotionResult(true, "Áp dụng thành công", discountAmount, p);
    }

    /**
     * Tính số tiền được giảm theo công thức của 1 Promotion (percent/fixed,
     * có áp trần MaxDiscountAmount và không bao giờ vượt quá subtotal).
     * Hàm thuần (không kiểm tra Active/ngày hiệu lực/UsageLimit/MinBookingAmount)
     * — dùng để TÁI ÁP dụng lại discount mỗi khi subtotal đổi (đổi ngày/loại
     * phòng) mà không làm mã giảm giá "biến mất" nếu subtotal mới tụt dưới
     * MinBookingAmount ban đầu. Việc kiểm tra điều kiện hợp lệ chỉ thực hiện
     * MỘT LẦN lúc khách nhập mã, ở {@link #validateAndCalculateDiscount}.
     */
    public double calculateDiscountAmount(Promotion p, double subtotal) {
        if (p == null || subtotal <= 0) {
            return 0;
        }

        double discountAmount = 0;
        if ("PERCENT".equalsIgnoreCase(p.getDiscountType()) || "PERCENTAGE".equalsIgnoreCase(p.getDiscountType())) {
            discountAmount = subtotal * (p.getDiscountValue().doubleValue() / 100.0);
        } else if ("FIXED".equalsIgnoreCase(p.getDiscountType()) || "FIXED AMOUNT".equalsIgnoreCase(p.getDiscountType())) {
            discountAmount = p.getDiscountValue().doubleValue();
        }

        if (p.getMaxDiscountAmount() != null && p.getMaxDiscountAmount().doubleValue() > 0) {
            if (discountAmount > p.getMaxDiscountAmount().doubleValue()) {
                discountAmount = p.getMaxDiscountAmount().doubleValue();
            }
        }

        if (discountAmount > subtotal) {
            discountAmount = subtotal;
        }

        return discountAmount;
    }
}
