package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Project: Hotel Management System
 * Class: BookingController
 *
 * Description:
 * Servlet điểm khởi đầu chặn các người dùng chưa xác thực hoặc không phải khách
 * hàng cố gắng bắt đầu quy trình đặt phòng. Lưu URL yêu cầu gốc vào session
 * và chuyển hướng đến trang đăng nhập; khách hàng đã xác thực được chuyển tiếp
 * trực tiếp đến trang tạo đặt phòng.
 *
 * Related Use Cases:
 * - UC-11 Create Booking (Customer Online)
 * 
 * Date: 31-05-2026
 * 
 * @author BinhHD, TungNQ
 * @version 1.1
 */

@WebServlet(name = "BookingController", urlPatterns = { "/booking/start" })
public class BookingController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"CUSTOMER".equals(session.getAttribute("role"))) {
            // Guest or unauthorized role, save the redirect URL and redirect to login page
            HttpSession activeSession = request.getSession(true);
            String requestURI = request.getRequestURI();
            String queryString = request.getQueryString();
            String originalUrl = requestURI + (queryString != null ? "?" + queryString : "");
            activeSession.setAttribute("redirectAfterLogin", originalUrl);

            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }
        
        String typeId = request.getParameter("id");
        String redirectUrl = request.getContextPath() + "/customer/booking/create";
        if (typeId != null && !typeId.trim().isEmpty()) {
            redirectUrl += "?roomTypeId=" + typeId.trim();
        }
        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
