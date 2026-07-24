package com.mycompany.hotelmanagement.controller.receptionist;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import com.mycompany.hotelmanagement.dal.BookingServiceRequestDAO;
import com.mycompany.hotelmanagement.entity.BookingServiceRequest;
import com.mycompany.hotelmanagement.entity.RoomInfo;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.util.List;

/**
 * Created: 14/07/2026
 *
 * @author MinhTDP
 */
@WebServlet(urlPatterns = {"/receptionist/add-booking-service"})
public class ReceptionistAddBookingServiceController extends HttpServlet {

    private BookingServiceRequestDAO dao;

    @Override
    public void init() {

        dao = new BookingServiceRequestDAO();

    }

    // ==========================
    // LOAD FORM
    // ==========================
    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            // Lấy tất cả phòng đang CheckedIn
            List<RoomInfo> rooms = dao.getCheckedInRooms();

            // Lấy tất cả dịch vụ còn hoạt động
            List<BookingServiceRequest> services = dao.getActiveServices();

            request.setAttribute("rooms", rooms);
            request.setAttribute("services", services);

            request.getRequestDispatcher(
                    "/WEB-INF/views/receptionist/add-booking-service.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }

    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {

            int roomId = Integer.parseInt(request.getParameter("roomId"));
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));

            int quantity = 1;
            try {
                quantity = Integer.parseInt(request.getParameter("quantity"));
                if (quantity <= 0) {
                    quantity = 1;
                }
            } catch (Exception ex) {
                quantity = 1;
            }

            String notes = request.getParameter("notes");

            Integer accountId = (Integer) request.getSession()
                    .getAttribute("accountId");

            if (accountId == null) {

                response.sendRedirect(
                        request.getContextPath() + "/home/login");

                return;
            }

            // ==========================
            // Lấy booking đang CheckedIn của phòng
            // ==========================
            Integer bookingId = dao.getCheckedInBookingIdByRoom(roomId);

            if (bookingId == null) {

                request.setAttribute("error",
                        "Phòng này hiện không có khách đang Check-in.");

            } else if (!dao.isServiceActive(serviceId)) {

                request.setAttribute("error",
                        "Dịch vụ đã ngừng hoạt động.");

            } else {

                BookingServiceRequest serviceRequest = new BookingServiceRequest();

                serviceRequest.setBookingId(bookingId);
                serviceRequest.setRoomId(roomId);
                serviceRequest.setServiceId(serviceId);
                serviceRequest.setQuantity(quantity);
                serviceRequest.setDescription(notes);
                serviceRequest.setProcessedByStaffId(accountId);

                boolean success = dao.insertRequestByReceptionist(serviceRequest);

                if (success) {

                    request.setAttribute("success",
                            "Đặt dịch vụ thành công.");

                } else {

                    request.setAttribute("error",
                            "Không thể đặt dịch vụ.");

                }

            }

        } catch (Exception ex) {

            ex.printStackTrace();

            request.setAttribute("error",
                    "Có lỗi xảy ra trong quá trình xử lý.");

        }

        // ==========================
        // Load lại dữ liệu cho JSP
        // ==========================
        request.setAttribute("rooms", dao.getCheckedInRooms());
        request.setAttribute("services", dao.getActiveServices());

        request.getRequestDispatcher(
                "/WEB-INF/views/receptionist/add-booking-service.jsp")
                .forward(request, response);
    }
}
