/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.CheckInDAO;
import com.mycompany.hotelmanagement.entity.Account;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.CheckIn;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Arrays;

/**
 *
 * @author MinhTDP
 */
@WebServlet(name = "ReceptionistCheckinDetailController", urlPatterns = {"/receptionist/checkin-detail"})
public class ReceptionistCheckInDetailController extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final CheckInDAO checkInDAO = new CheckInDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ReceptionistCheckInDetailController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ReceptionistCheckInDetailController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null) {
            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=checkin&error=notfound");
            return;
        }

        int rootBookingId
                = booking.getGroupBookingId() != null
                ? booking.getGroupBookingId()
                : booking.getBookingId();

        request.setAttribute("booking", booking);

        request.setAttribute("rooms",
                bookingDAO.getAllAssignedRoomsForGroup(rootBookingId));

        request.getRequestDispatcher("/WEB-INF/views/receptionist/checkin-detail.jsp")
                .forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));

        String specialRequest = request.getParameter("specialRequest");
        String notes = request.getParameter("notes");
        String[] companions = request.getParameterValues("companions");

        HttpSession session = request.getSession();

        Integer receptionistId = (Integer) session.getAttribute("accountId");

        if (receptionistId == null) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        if (receptionistId == null) {
            response.sendRedirect(request.getContextPath() + "/staff/login");
            return;
        }

        try {
            boolean success = checkInDAO.processCheckIn(
                    bookingId,
                    receptionistId,
                    specialRequest,
                    notes,
                    companions
            );

            if (!success) {
                response.sendRedirect(request.getContextPath()
                        + "/receptionist/checkin-detail?bookingId=" + bookingId + "&error=1");
                return;
            }

            bookingDAO.updateStatus(bookingId, "CheckedIn");
            Booking booking = bookingDAO.getBookingById(bookingId);

            String customerName = (booking != null && booking.getCustomerName() != null)
                    ? booking.getCustomerName()
                    : "khách";

            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=checkin"
                    + "&checkinSuccess=1"
                    + "&customerName=" + java.net.URLEncoder.encode(customerName, "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/receptionist/checkin-detail?bookingId=" + bookingId + "&error=exception");
        }
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
