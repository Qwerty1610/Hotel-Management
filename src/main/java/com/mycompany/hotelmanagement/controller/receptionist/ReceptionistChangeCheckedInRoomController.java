/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java
 */
package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.ChangeCheckedInRoomDAO;

import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomInfo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author MinhTDP Created: 14/07/2026
 */
@WebServlet(
        name = "ReceptionistChangeCheckedInRoomController",
        urlPatterns = {"/receptionist/change-room"}
)
public class ReceptionistChangeCheckedInRoomController extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int bookingId = Integer.parseInt(
                request.getParameter("bookingId")
        );

        BookingDAO bookingDAO = new BookingDAO();
        Booking booking = bookingDAO.getBookingById(bookingId);

        ChangeCheckedInRoomDAO dao = new ChangeCheckedInRoomDAO();

        List<Booking> groupBookings
                = dao.getGroupBookings(bookingId);

        List<RoomInfo> assignedRooms
                = dao.getCurrentAssignedRooms(bookingId);

        List<RoomInfo> availableRooms
                = dao.getAvailableRoomsForChange(bookingId);

        Map<String, List<RoomInfo>> availableRoomMap = new LinkedHashMap<>();
        for (RoomInfo room : availableRooms) {
            availableRoomMap
                    .computeIfAbsent(
                            room.getTypeName(),
                            k -> new ArrayList<>())
                    .add(room);
        }

        request.setAttribute("booking", booking);
        request.setAttribute("groupBookings", groupBookings);
        request.setAttribute("assignedRooms", assignedRooms);
        request.setAttribute("availableRoomMap", availableRoomMap);

        String error = request.getParameter("error");
        String success = request.getParameter("success");

        request.setAttribute("error", error);
        request.setAttribute("success", success);

        request.getRequestDispatcher(
                "/WEB-INF/views/receptionist/change-checkedin-room.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        int bookingId = Integer.parseInt(
                request.getParameter("bookingId")
        );

        String oldRoomIdRaw = request.getParameter("oldRoomId");
        String newRoomIdRaw = request.getParameter("newRoomId");
        String reason = request.getParameter("reason");

        // ================= VALIDATE =================
        if (oldRoomIdRaw == null || oldRoomIdRaw.isBlank()
                || newRoomIdRaw == null || newRoomIdRaw.isBlank()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/receptionist/change-room?bookingId="
                    + bookingId
                    + "&error=noroom");

            return;
        }

        if (reason == null || reason.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/receptionist/change-room?bookingId="
                    + bookingId
                    + "&error=reason");

            return;
        }

        int oldRoomId = Integer.parseInt(oldRoomIdRaw);
        int newRoomId = Integer.parseInt(newRoomIdRaw);

        if (oldRoomId == newRoomId) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/receptionist/change-room?bookingId="
                    + bookingId
                    + "&error=sameroom");

            return;
        }

        HttpSession session = request.getSession(false);
        Integer accountId = session == null
                ? null
                : (Integer) session.getAttribute("accountId");

        if (accountId == null) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
            return;
        }

        // ================= DAO =================
        ChangeCheckedInRoomDAO dao = new ChangeCheckedInRoomDAO();

        boolean success = dao.changeRoom(
                oldRoomId,
                newRoomId,
                reason.trim(),
                accountId
        );

        if (success) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/receptionist/change-room?bookingId="
                    + bookingId
                    + "&success=changed");

        } else {

            response.sendRedirect(
                    request.getContextPath()
                    + "/receptionist/change-room?bookingId="
                    + bookingId
                    + "&error=failed");
        }
    }
}
