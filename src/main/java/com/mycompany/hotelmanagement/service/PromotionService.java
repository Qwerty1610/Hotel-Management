package com.mycompany.hotelmanagement.service;

import java.util.List;

import com.mycompany.hotelmanagement.dal.PromotionRepository;
import com.mycompany.hotelmanagement.entity.Promotion;

/**
 * Project: Hotel Management System
 * Class: PromotionService
 *
 * Description:
 * Tầng nghiệp vụ quản lý khuyến mãi. Cung cấp các phương thức lấy toàn
 * bộ danh sách, lấy theo ID, kiểm tra trùng mã khuyến mãi, lưu (thêm mới
 * hoặc cập nhật), bật/tắt trạng thái và xóa khuyến mãi. Xóa chỉ cho phép
 * khi UsedCount = 0. Ủy quyền thao tác dữ liệu cho PromotionRepository.
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

    private final PromotionRepository promotionRepository = new PromotionRepository();

    /**
     * Lấy toàn bộ danh sách khuyến mãi.
     */
    public List<Promotion> getAllPromotions() {
        return promotionRepository.getAllPromotions();
    }

    /**
     * Lấy một khuyến mãi theo ID.
     */
    public Promotion getPromotionById(int promotionId) {
        return promotionRepository.getPromotionById(promotionId);
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
    public void savePromotion(Promotion promotion) {
        if (promotion.getPromotionId() <= 0) {
            promotionRepository.insertPromotion(promotion);
        } else {
            promotionRepository.updatePromotion(promotion);
        }
    }

    /**
     * Bật/Tắt trạng thái khuyến mãi.
     *
     * @param promotionId ID khuyến mãi
     * @param newStatus   "Active" hoặc "Inactive"
     */
    public void togglePromotionStatus(int promotionId, String newStatus) {
        promotionRepository.togglePromotionStatus(promotionId, newStatus);
    }

    /**
     * Xóa khuyến mãi. Chỉ cho phép nếu chưa được sử dụng (UsedCount = 0).
     *
     * @return true nếu xóa thành công, false nếu đã được sử dụng
     */
    public boolean deletePromotion(int promotionId) {
        return promotionRepository.deletePromotion(promotionId);
    }
}
