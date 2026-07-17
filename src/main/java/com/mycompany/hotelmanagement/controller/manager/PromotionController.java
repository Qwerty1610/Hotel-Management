package com.mycompany.hotelmanagement.controller.manager;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mycompany.hotelmanagement.entity.Promotion;
import com.mycompany.hotelmanagement.service.PromotionService;

/**
 * Project: Hotel Management System
 * Class: PromotionController
 *
 * Description:
 * Controller quản lý khuyến mãi cho Hotel Manager, xử lý hiển thị danh sách,
 * thêm mới, chỉnh sửa, bật/tắt trạng thái và xóa khuyến mãi. Class thực hiện
 * validation đầy đủ các trường (mã, tên, loại giảm giá, giá trị, ngày hiệu lực,
 * giới hạn sử dụng, số tiền tối thiểu/tối đa), kiểm tra mã khuyến mãi trùng
 * lặp và ủy quyền lưu trữ cho PromotionService.
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
@WebServlet(name = "PromotionController", urlPatterns = {"/manager/promotions"})
public class PromotionController extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        int promotionId = -1;

        try {
            if (idParam != null && !idParam.trim().isEmpty()) {
                promotionId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions");
            return;
        }

        if ("delete".equalsIgnoreCase(action) && promotionId != -1) {
            boolean deleted = promotionService.deletePromotion(promotionId);
            if (deleted) {
                response.sendRedirect(request.getContextPath() + "/manager/promotions?success=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/promotions?error=cannotDelete");
            }
            return;
        }

        if ("toggle".equalsIgnoreCase(action) && promotionId != -1) {
            String newStatus = request.getParameter("status");
            if ("Inactive".equalsIgnoreCase(newStatus)) {
                newStatus = "Inactive";
            } else {
                newStatus = "Active";
            }
            promotionService.togglePromotionStatus(promotionId, newStatus);
            response.sendRedirect(request.getContextPath() + "/manager/promotions?success=toggled");
            return;
        }

        // Default: show list
        List<Promotion> promotionList = promotionService.getAllPromotions();
        request.setAttribute("promotionList", promotionList);
        request.getRequestDispatcher("/WEB-INF/views/manager/promotions-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (!"save".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions");
            return;
        }

        // ── Parse form fields ──────────────────────────────────────────────────
        String promotionIdParam  = request.getParameter("promotionId");
        String code              = trimOrNull(request.getParameter("code"));
        String name              = trimOrNull(request.getParameter("name"));
        String description       = trimOrNull(request.getParameter("description"));
        String discountType      = trimOrNull(request.getParameter("discountType"));
        String discountValueParam = request.getParameter("discountValue");
        String startDateParam    = trimOrNull(request.getParameter("startDate"));
        String endDateParam      = trimOrNull(request.getParameter("endDate"));
        String eventName         = trimOrNull(request.getParameter("eventName"));
        String minAmountParam    = request.getParameter("minBookingAmount");
        String maxDiscountParam  = request.getParameter("maxDiscountAmount");
        String usageLimitParam   = request.getParameter("usageLimit");

        // ── Validation ────────────────────────────────────────────────────────
        // 1. PromotionCode
        if (code == null || code.isEmpty() || !code.matches("[A-Z0-9_]+")) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidCode");
            return;
        }

        // 2. PromotionName
        if (name == null || name.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidName");
            return;
        }

        // 3. DiscountType
        if (!"PERCENT".equals(discountType) && !"FIXED".equals(discountType)) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidType");
            return;
        }

        // 4. DiscountValue
        BigDecimal discountValue;
        try {
            discountValue = new BigDecimal(discountValueParam.trim());
            if (discountValue.compareTo(BigDecimal.ZERO) <= 0) {
                response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidValue");
                return;
            }
            if ("PERCENT".equals(discountType) && discountValue.compareTo(new BigDecimal("100")) > 0) {
                response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidValue");
                return;
            }
        } catch (NumberFormatException | NullPointerException e) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidValue");
            return;
        }

        // 5. Dates
        LocalDate startDate;
        LocalDate endDate;
        try {
            startDate = LocalDate.parse(startDateParam);
            endDate   = LocalDate.parse(endDateParam);
        } catch (DateTimeParseException | NullPointerException e) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidDate");
            return;
        }
        if (startDate.isAfter(endDate)) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions?error=dateRange");
            return;
        }

        // 6. UsageLimit (optional, must be > 0 if provided)
        Integer usageLimit = null;
        if (usageLimitParam != null && !usageLimitParam.trim().isEmpty()) {
            try {
                int ul = Integer.parseInt(usageLimitParam.trim());
                if (ul <= 0) {
                    response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidLimit");
                    return;
                }
                usageLimit = ul;
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidLimit");
                return;
            }
        }

        // 7. MinBookingAmount & MaxDiscountAmount (optional, >= 0 if provided)
        BigDecimal minBookingAmount = null;
        if (minAmountParam != null && !minAmountParam.trim().isEmpty()) {
            try {
                minBookingAmount = new BigDecimal(minAmountParam.trim());
                if (minBookingAmount.compareTo(BigDecimal.ZERO) < 0) {
                    response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidMin");
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidMin");
                return;
            }
        }

        BigDecimal maxDiscountAmount = null;
        if (maxDiscountParam != null && !maxDiscountParam.trim().isEmpty()) {
            try {
                maxDiscountAmount = new BigDecimal(maxDiscountParam.trim());
                if (maxDiscountAmount.compareTo(BigDecimal.ZERO) < 0) {
                    response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidMax");
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/manager/promotions?error=invalidMax");
                return;
            }
        }

        // ── Determine add or edit ─────────────────────────────────────────────
        int promotionId = -1;
        if (promotionIdParam != null && !promotionIdParam.trim().isEmpty()) {
            try {
                promotionId = Integer.parseInt(promotionIdParam.trim());
            } catch (NumberFormatException e) {
                // Ignore, treat as new
            }
        }

        // 8. Duplicate code check
        if (promotionService.isCodeDuplicate(code, promotionId)) {
            response.sendRedirect(request.getContextPath() + "/manager/promotions?error=duplicateCode");
            return;
        }

        // ── Build entity & save ───────────────────────────────────────────────
        Promotion promotion = new Promotion();
        promotion.setPromotionId(promotionId);
        promotion.setPromotionCode(code);
        promotion.setPromotionName(name);
        promotion.setDescription(description);
        promotion.setDiscountType(discountType);
        promotion.setDiscountValue(discountValue);
        promotion.setStartDate(startDate);
        promotion.setEndDate(endDate);
        promotion.setEventName(eventName);
        promotion.setMinBookingAmount(minBookingAmount);
        promotion.setMaxDiscountAmount(maxDiscountAmount);
        promotion.setUsageLimit(usageLimit);

        promotionService.savePromotion(promotion);
        response.sendRedirect(request.getContextPath() + "/manager/promotions?success=saved");
    }

    // ── Utility ───────────────────────────────────────────────────────────────

    private String trimOrNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
