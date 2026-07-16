
package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.CheckOut;
import com.mycompany.hotelmanagement.service.CheckOutService;

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
 * Class: ReceptionistCheckOutController
 *
 * Description:
 * Controller cho quy trình trả phòng của lễ tân. GET kèm bookingId hiển thị
 * trang chi tiết trả phòng bao gồm các khoản phí và lịch sử thanh toán. POST
 * xử lý quyết toán cuối cùng thông qua CheckOutService, ghi lại phương thức
 * thanh toán và ghi chú, sau đó chuyển hướng về tab trả phòng trên dashboard.
 *
 * Related Use Cases:
 * - UC-16 Check-Out Customer
 * 
 * Date: 09-07-2026
 * 
 * @author BinhHD
 * @version 1.0
 */

@WebServlet(name = "ReceptionistCheckOutController", urlPatterns = { "/receptionist/checkout" })
public class ReceptionistCheckOutController extends HttpServlet {

    private final CheckOutService checkOutService = new CheckOutService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String bookingIdParam = request.getParameter("bookingId");

        // If bookingId is provided, show checkout detail page
        if (bookingIdParam != null && !bookingIdParam.trim().isEmpty()) {
            try {
                int bookingId = Integer.parseInt(bookingIdParam);
                CheckOut summary = checkOutService.getCheckOutSummary(bookingId);

                if (summary.getBookingId() == 0) {
                    // Booking not found or not suitable
                    response.sendRedirect(
                            request.getContextPath() + "/receptionist/dashboard?tab=checkout&error=not_found");
                    return;
                }

                request.setAttribute("summary", summary);
                request.getRequestDispatcher("/WEB-INF/views/receptionist/checkout-detail.jsp")
                        .forward(request, response);
                return;

            } catch (NumberFormatException e) {
                response.sendRedirect(
                        request.getContextPath() + "/receptionist/dashboard?tab=checkout&error=invalid_id");
                return;
            }
        }

        // Default: redirect to dashboard checkout tab
        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=checkout");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            String paymentMethod = request.getParameter("paymentMethod");
            String notes = request.getParameter("notes");

            HttpSession session = request.getSession(false);
            Integer receptionistId = null;
            if (session != null) {
                receptionistId = (Integer) session.getAttribute("accountId");
            }

            if (receptionistId == null) {
                response.sendRedirect(request.getContextPath() + "/staff/login");
                return;
            }

            boolean success = checkOutService.processCheckOut(bookingId, receptionistId, paymentMethod, notes);

            if (success) {
                response.sendRedirect(
                        request.getContextPath() + "/receptionist/dashboard?tab=checkout&msg=checkout_success");
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/receptionist/dashboard?tab=checkout&error=process_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=checkout&error=invalid_data");
        }
    }
}
