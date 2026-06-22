package com.mycompany.hotelmanagement.controller.common;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "BookingController", urlPatterns = { "/booking/start" })
public class BookingController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verify Session & Customer Role
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
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write("");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
