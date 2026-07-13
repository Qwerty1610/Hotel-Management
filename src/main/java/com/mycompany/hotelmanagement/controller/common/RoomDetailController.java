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
 * RoomDetailController
 * URL: /rooms/detail
 *
 * Xử lý các hành động liên quan đến chi tiết loại phòng:
 * - view GET (/rooms/detail?id=...): Hiển thị thông tin chi tiết, hình ảnh, tiện nghi và số phòng còn trống của một loại phòng được chọn trước khi đặt phòng (UC-31: View Room Type Detail)
 * 
 * Date: 01/6/2026
 * @author DINH KHANH
 */
@WebServlet(name = "RoomDetailController", urlPatterns = {"/rooms/detail"})
public class RoomDetailController extends HttpServlet {

    private final RoomTypeService roomTypeService = new RoomTypeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        int typeId = -1;
        try {
            typeId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        // Fetch detail using Service
        RoomTypeInfo roomDetail = roomTypeService.getRoomTypeDetail(typeId);

        if (roomDetail == null) {
            // Room type ID does not exist in database or database query failed
            response.sendRedirect(request.getContextPath() + "/rooms");
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
        
        request.getRequestDispatcher("/WEB-INF/views/home/room_detail.jsp").forward(request, response);
    }
}
