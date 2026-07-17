package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.entity.Feedback;
import com.mycompany.hotelmanagement.service.FeedbackService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: CustomerFeedbackController
 *
 * Description:
 * Controller xử lý đánh giá lưu trú cho khách hàng (Customer). Hiển thị
 * danh sách phòng đã trả kèm trạng thái đánh giá, hỗ trợ lọc theo bộ lọc
 * và từ khoá. Tiếp nhận và xử lý yêu cầu gửi đánh giá, kiểm tra điểm số
 * (1-5), độ dài nhận xét, quyền đánh giá và trùng lặp. Ủy quyền xử lý
 * nghiệp vụ cho FeedbackService.
 *
 * Related Use Cases:
 * - UC-35 Submit Stay Feedback
 *
 * Date: 11-07-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
@WebServlet(
    name = "CustomerFeedbackController",
    urlPatterns = {"/customer/feedbacks"}
)
public class CustomerFeedbackController extends HttpServlet {

    private final FeedbackService feedbackService = new FeedbackService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int accountId = (int) session.getAttribute("accountId");
        String filter = request.getParameter("filter");
        String keyword = request.getParameter("keyword");

        List<Feedback> list = feedbackService.getCheckedOutRoomsByAccount(accountId, filter, keyword);
        request.setAttribute("feedbacks", list);
        request.setAttribute("filter", filter);
        request.setAttribute("keyword", keyword);

        String success = request.getParameter("success");
        if ("submitted".equals(success)) {
            request.setAttribute("successMessage", "Cảm ơn bạn đã gửi đánh giá.");
        }
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("errorMessage", mapError(error));
        }

        request.getRequestDispatcher("/WEB-INF/views/customer/customer-feedbacks.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int accountId = (int) session.getAttribute("accountId");

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");

            FeedbackService.SubmitResult result = feedbackService.submitFeedback(bookingId, roomId, accountId, rating, comment);
            switch (result) {
                case SUCCESS:
                    response.sendRedirect(request.getContextPath() + "/customer/feedbacks?success=submitted");
                    break;
                case INVALID_RATING:
                    response.sendRedirect(request.getContextPath() + "/customer/feedbacks?error=invalid_rating");
                    break;
                case COMMENT_TOO_LONG:
                    response.sendRedirect(request.getContextPath() + "/customer/feedbacks?error=comment_too_long");
                    break;
                case NOT_ELIGIBLE:
                    response.sendRedirect(request.getContextPath() + "/customer/feedbacks?error=not_eligible");
                    break;
                case DUPLICATE:
                    response.sendRedirect(request.getContextPath() + "/customer/feedbacks?error=duplicate");
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/customer/feedbacks?error=system_error");
                    break;
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/feedbacks?error=bad_input");
        }
    }

    private String mapError(String code) {
        switch (code) {
            case "invalid_rating":
                return "Số sao đánh giá phải từ 1 đến 5.";
            case "comment_too_long":
                return "Nội dung đánh giá không được vượt quá 1000 ký tự.";
            case "not_eligible":
                return "Bạn không có quyền đánh giá phòng này.";
            case "duplicate":
                return "Bạn đã đánh giá phòng này trước đó.";
            case "bad_input":
                return "Dữ liệu gửi lên không đúng định dạng.";
            default:
                return "Đã xảy ra lỗi. Vui lòng thử lại.";
        }
    }
}
