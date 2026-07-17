package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.FeedbackDAO;
import com.mycompany.hotelmanagement.entity.Feedback;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: FeedbackService
 *
 * Description:
 * Tầng nghiệp vụ quản lý đánh giá lưu trú của khách hàng. Cung cấp các
 * phương thức lấy danh sách phòng đã trả kèm trạng thái đánh giá, xử lý
 * logic gửi đánh giá bao gồm kiểm tra điểm số (1-5), độ dài nhận xét,
 * quyền đánh giá và trùng lặp. Cung cấp thêm danh sách đánh giá và thống
 * kê điểm trung bình theo loại phòng cho trang chi tiết loại phòng.
 *
 * Related Use Cases:
 * - UC-35 Submit Stay Feedback
 * - UC-63 View Room Type Reviews
 *
 * Date: 11-07-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
public class FeedbackService {
    public enum SubmitResult {
        SUCCESS,
        INVALID_RATING,
        COMMENT_TOO_LONG,
        NOT_ELIGIBLE,
        DUPLICATE,
        SYSTEM_ERROR
    }

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    public List<Feedback> getCheckedOutRoomsByAccount(int accountId, String statusFilter, String keyword) {
        // Validate filter (All, NotReviewed, Reviewed)
        String filter = "All";
        if ("Reviewed".equalsIgnoreCase(statusFilter) || "NotReviewed".equalsIgnoreCase(statusFilter)) {
            filter = statusFilter;
        }
        return feedbackDAO.getCheckedOutRoomsByAccount(accountId, filter, keyword);
    }

    public SubmitResult submitFeedback(int bookingId, int roomId, int accountId, int rating, String comment) {
        // 1. Validate Rating
        if (rating < 1 || rating > 5) {
            return SubmitResult.INVALID_RATING;
        }

        // 2. Validate Comment
        String processedComment = null;
        if (comment != null) {
            processedComment = comment.trim();
            if (processedComment.length() > 1000) {
                return SubmitResult.COMMENT_TOO_LONG;
            }
            if (processedComment.isEmpty()) {
                processedComment = null;
            }
        }

        // 3. Check Eligibility & Ownership
        boolean isEligible = feedbackDAO.isBookingRoomAssignedAndCheckedOut(bookingId, roomId, accountId);
        if (!isEligible) {
            return SubmitResult.NOT_ELIGIBLE;
        }

        // 4. Check if Duplicate
        boolean alreadyExists = feedbackDAO.existsFeedback(bookingId, roomId);
        if (alreadyExists) {
            return SubmitResult.DUPLICATE;
        }

        // 5. Create Feedback
        Feedback feedback = new Feedback(bookingId, roomId, accountId, rating, processedComment);
        boolean success = feedbackDAO.createFeedback(feedback);
        if (success) {
            return SubmitResult.SUCCESS;
        } else {
            return SubmitResult.SYSTEM_ERROR;
        }
    }

    public List<Feedback> getFeedbacksByRoomTypeId(int roomTypeId) {
        return feedbackDAO.getFeedbacksByRoomTypeId(roomTypeId);
    }

    public double[] getFeedbackStatsByRoomTypeId(int roomTypeId) {
        return feedbackDAO.getFeedbackStatsByRoomTypeId(roomTypeId);
    }
}
