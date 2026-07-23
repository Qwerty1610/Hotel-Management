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
import com.mycompany.hotelmanagement.service.CloudinaryService;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.*;

/**
 *
 * @author MinhTDP
 */
@MultipartConfig
@WebServlet(name = "ReceptionistCheckinDetailController", urlPatterns = {"/receptionist/checkin-detail"})
public class ReceptionistCheckInDetailController extends HttpServlet {

    private final CloudinaryService cloudinaryService = new CloudinaryService();
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));

        Booking booking = bookingDAO.getBookingById(bookingId);
        if ("CheckedIn".equalsIgnoreCase(booking.getStatus())) {

            CheckIn checkIn
                    = checkInDAO.getCheckInByBookingId(bookingId);

            request.setAttribute("checkIn", checkIn);

            if (checkIn != null) {

                request.setAttribute(
                        "companions",
                        checkInDAO.getCompanionsByCheckInId(
                                checkIn.getCheckInId()
                        )
                );

            }
        }

        if (booking == null) {
            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=checkin&error=notfound");
            return;
        }

        int rootBookingId
                = booking.getGroupBookingId() != null
                ? booking.getGroupBookingId()
                : booking.getBookingId();

        // Lấy tổng capacity của tất cả phòng được assign
        int totalCapacity
                = checkInDAO.getTotalCapacityByBookingId(rootBookingId);

        System.out.println(
                "TOTAL CAPACITY: " + totalCapacity
        );

        request.setAttribute(
                "totalCapacity",
                totalCapacity
        );

        request.setAttribute("booking", booking);

        request.setAttribute("rooms",
                bookingDAO.getAllAssignedRoomsForGroup(rootBookingId));

        request.getRequestDispatcher(
                "/WEB-INF/views/receptionist/checkin-detail.jsp"
        )
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));

        String specialRequest = request.getParameter("specialRequest");
        String notes = request.getParameter("notes");
        String extraFeeStr = request.getParameter("extraFee");

        BigDecimal extraFee = BigDecimal.ZERO;

        if (extraFeeStr != null && !extraFeeStr.isBlank()) {
            extraFee = new BigDecimal(extraFeeStr);
        }
        String[] companions = request.getParameterValues("companions");
        String[] ageRanges = request.getParameterValues("ageRanges");
        List<Part> companionParts = new ArrayList<>();

        for (Part part : request.getParts()) {
            if ("companionImage".equals(part.getName())) {
                companionParts.add(part);
            }
        }
        List<String> companionUrls = new ArrayList<>();

        for (Part part : companionParts) {

            String imageUrl = null;

            if (part.getSize() > 0) {
                imageUrl = cloudinaryService.uploadImage(part);
            }

            companionUrls.add(imageUrl);
        }
        Part customerImagePart = request.getPart("customerImage");
        String customerUrl = null;

        if (customerImagePart != null
                && customerImagePart.getSize() > 0) {

            customerUrl = cloudinaryService.uploadImage(customerImagePart);
        }
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

        Booking booking = bookingDAO.getBookingById(bookingId);

        int rootBookingId = booking.getGroupBookingId() != null
                ? booking.getGroupBookingId()
                : booking.getBookingId();

        List<Booking> allBookings = new ArrayList<>();
        allBookings.add(bookingDAO.getBookingById(rootBookingId));
        allBookings.addAll(bookingDAO.getChildBookings(rootBookingId));

        try {
            boolean success = true;

            for (Booking b : allBookings) {

                boolean result = checkInDAO.processCheckIn(
                        b.getBookingId(),
                        receptionistId,
                        specialRequest,
                        notes,
                        customerUrl,
                        extraFee,
                        companions,
                        companionUrls,
                        ageRanges
                );

                if (!result) {
                    success = false;
                    break;
                }

                new com.mycompany.hotelmanagement.dal.InvoiceDAO()
                        .createInvoiceForBooking(b.getBookingId());
            }

            if (!success) {
                response.sendRedirect(request.getContextPath()
                        + "/receptionist/checkin-detail?bookingId=" + bookingId + "&error=1");
                return;
            }

            bookingDAO.updateGroupBookingStatus(rootBookingId, "CheckedIn");

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

}
