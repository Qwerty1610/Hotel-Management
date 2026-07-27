package com.mycompany.hotelmanagement.controller.receptionist;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import com.mycompany.hotelmanagement.dal.BookingServiceRequestDAO;
import com.mycompany.hotelmanagement.entity.BookingServiceRequest;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

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
    // Trang riêng đã được thay bằng popup ở tab "Quản lý yêu cầu dịch vụ"
    // ==========================
    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/receptionist/dashboard?tab=servicerequests");
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String redirectBase = request.getContextPath()
                + "/receptionist/dashboard?tab=servicerequests";

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

                response.sendRedirect(redirectBase + "&result=fail&error=noroom_checkedin");
                return;

            } else if (!dao.isServiceActive(serviceId)) {

                response.sendRedirect(redirectBase + "&result=fail&error=service_inactive");
                return;

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
                    response.sendRedirect(redirectBase + "&result=success&action=addservice");
                } else {
                    response.sendRedirect(redirectBase + "&result=fail&error=addservice_failed");
                }

            }

        } catch (Exception ex) {

            ex.printStackTrace();

            response.sendRedirect(redirectBase + "&result=fail&error=addservice_failed");
        }
    }
}
