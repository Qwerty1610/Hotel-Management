package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.mycompany.hotelmanagement.service.RoomTypeService;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.FeedbackService;
import com.mycompany.hotelmanagement.entity.Feedback;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: RoomDetailController
 *
 * Description:
 * Controller hiển thị thông tin chi tiết một loại phòng cho khách hàng
 * (Customer), bao gồm thông tin loại phòng, danh sách hình ảnh, tiện nghi,
 * số phòng còn trống và danh sách đánh giá kèm thống kê điểm trung bình.
 * Gọi RoomTypeService và FeedbackService để lấy dữ liệu, chuyển tiếp đến
 * trang room_detail.jsp.
 *
 * Related Use Cases:
 * - UC-30 View Room Type Detail
 * - UC-63 View Room Type Reviews
 *
 * Date: 31-05-2026
 *
 * @author KhanhTD
 * @version 1.0
 */
@WebServlet(name = "RoomDetailController", urlPatterns = {"/rooms/detail"})
public class RoomDetailController extends HttpServlet {

    private final RoomTypeService roomTypeService = new RoomTypeService();
    private final String ROOM_URL = "/rooms";
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + ROOM_URL);
            return;
        }

        int typeId = -1;
        try {
            typeId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + ROOM_URL);
            return;
        }

        String checkInParam = request.getParameter("checkIn");
        String checkOutParam = request.getParameter("checkOut");
        RoomsController.DateRangeResult dateResult = RoomsController.parseAndValidateDateRange(checkInParam, checkOutParam);

        java.time.LocalDate checkIn = dateResult.isValid() ? dateResult.checkIn : java.time.LocalDate.now();
        java.time.LocalDate checkOut = dateResult.isValid() ? dateResult.checkOut : java.time.LocalDate.now().plusDays(1);

        // Fetch detail using Service with date range
        RoomTypeInfo roomDetail = roomTypeService.getRoomTypeDetail(typeId, checkIn, checkOut);

        if (roomDetail == null) {
            // Room type ID does not exist in database or database query failed
            response.sendRedirect(request.getContextPath() + ROOM_URL);
            return;
        }

        // Fetch feedback using FeedbackService
        FeedbackService feedbackService = new FeedbackService();
        List<Feedback> feedbackList = feedbackService.getFeedbacksByRoomTypeId(typeId);
        double[] stats = feedbackService.getFeedbackStatsByRoomTypeId(typeId);
        int totalReviews = (int) stats[0];
        double averageRating = stats[1];

        // Set attributes and forward
        request.setAttribute("room", roomDetail);
        request.setAttribute("feedbackList", feedbackList);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("averageRating", averageRating);
        request.setAttribute("selectedCheckIn", checkIn.toString());
        request.setAttribute("selectedCheckOut", checkOut.toString());
        if (!dateResult.isValid()) {
            request.setAttribute("dateError", dateResult.error);
        }
        
        request.getRequestDispatcher("/WEB-INF/views/home/room_detail.jsp").forward(request, response);
    }
}
