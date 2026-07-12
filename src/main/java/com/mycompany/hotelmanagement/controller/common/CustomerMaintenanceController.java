/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.hotelmanagement.controller.common;

import com.mycompany.hotelmanagement.dal.MaintenanceRequestDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.IssueType;
import com.mycompany.hotelmanagement.entity.MaintenanceRequestDetail;
import com.mycompany.hotelmanagement.entity.Room;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author MinhTDP 
 * Created: 06/07/2026
 */
@WebServlet(
        name = "CustomerMaintenanceController",
        urlPatterns = {
            "/customer/maintenance",
            "/customer/maintenance/history"
        })
public class CustomerMaintenanceController extends HttpServlet {

    private final MaintenanceRequestDAO dao
            = new MaintenanceRequestDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CustomerMaintenanceController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CustomerMaintenanceController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountId") == null) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int customerId = (Integer) session.getAttribute("accountId");
        String uri = request.getRequestURI();
        MaintenanceRequestDAO dao = new MaintenanceRequestDAO();

        if (uri.endsWith("/history")) {

            request.setAttribute(
                    "maintenanceHistory",
                    dao.getMaintenanceHistoryByCustomer(customerId));

            request.getRequestDispatcher(
                    "/WEB-INF/views/customer/customer-maintenance-history.jsp")
                    .forward(request, response);

            return;
        }

        // Trang tạo yêu cầu
        request.setAttribute(
                "bookings",
                dao.getCheckedInBookingsByCustomer(customerId));

        request.setAttribute(
                "issueTypes",
                dao.getAllIssueTypes());

        request.getRequestDispatcher(
                "/WEB-INF/views/customer/customer-maintenance.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("accountId") == null) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        int customerId = (Integer) session.getAttribute("accountId");

        int bookingId = Integer.parseInt(
                request.getParameter("bookingId"));

        String[] issueTypeIds
                = request.getParameterValues("issueTypeId");

        String description
                = request.getParameter("description");

        MaintenanceRequestDAO dao
                = new MaintenanceRequestDAO();

        boolean success = dao.submitMaintenanceRequest(
                bookingId,
                customerId,
                issueTypeIds,
                description);

        if (success) {
            session.setAttribute(
                    "successMessage",
                    "Gửi báo cáo sự cố thành công.");
        } else {
            session.setAttribute(
                    "errorMessage",
                    "Không thể gửi báo cáo sự cố.");
        }

        response.sendRedirect(
                request.getContextPath()
                + "/customer/maintenance");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}