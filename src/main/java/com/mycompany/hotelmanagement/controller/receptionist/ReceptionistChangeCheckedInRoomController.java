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

        System.out.println("===== CHANGE ROOM DO GET =====");
        System.out.println("bookingId = " + bookingId);

        BookingDAO bookingDAO = new BookingDAO();
        Booking booking = bookingDAO.getBookingById(bookingId);

        System.out.println("booking = " + booking);

        ChangeCheckedInRoomDAO dao = new ChangeCheckedInRoomDAO();

        List<Booking> groupBookings
                = dao.getGroupBookings(bookingId);

        System.out.println(
                "groupBookings size = "
                + groupBookings.size()
        );
        for (Booking b : groupBookings) {

            System.out.println(
                    "GROUP BOOKING = "
                    + b.getBookingId()
                    + " TYPE = "
                    + b.getRoomTypeName()
            );

        }
        List<RoomInfo> assignedRooms
                = dao.getCurrentAssignedRooms(bookingId);

        List<RoomInfo> availableRooms
                = dao.getAvailableRoomsForChange(bookingId);

        Map<String, List<RoomInfo>> assignedRoomMap = new LinkedHashMap<>();
        for (RoomInfo room : assignedRooms) {
            assignedRoomMap
                    .computeIfAbsent(
                            room.getTypeName(),
                            k -> new ArrayList<>())
                    .add(room);
        }
        Map<String, List<RoomInfo>> availableRoomMap = new LinkedHashMap<>();
        for (RoomInfo room : availableRooms) {
            availableRoomMap
                    .computeIfAbsent(
                            room.getTypeName(),
                            k -> new ArrayList<>())
                    .add(room);
        }

        System.out.println(
                "assignedRooms size = "
                + assignedRooms.size()
        );

        System.out.println(
                "availableRooms size = "
                + availableRooms.size()
        );

        request.setAttribute(
                "booking",
                booking
        );

        request.setAttribute(
                "groupBookings",
                groupBookings
        );

        request.setAttribute(
                "assignedRoomMap",
                assignedRoomMap
        );

        request.setAttribute(
                "availableRoomMap",
                availableRoomMap
        );

        request.setAttribute("assignedRoomMap", assignedRoomMap);
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

        String[] oldRoomIds = request.getParameterValues("oldRoomIds");

        List<String> oldRoomList = new ArrayList<>();
        List<String> newRoomList = new ArrayList<>();

        if (oldRoomIds != null) {

            for (String oldRoomId : oldRoomIds) {

                String newRoomId = request.getParameter(
                        "newRoom_" + oldRoomId
                );

                if (newRoomId != null && !newRoomId.isBlank()) {

                    oldRoomList.add(oldRoomId);
                    newRoomList.add(newRoomId);

                }
            }
        }

        String reason = request.getParameter("reason");

        // ================= VALIDATE =================
        if (oldRoomList.isEmpty()
                || newRoomList.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/receptionist/change-room?bookingId="
                    + bookingId
                    + "&error=noroom");

            return;
        }

        if (oldRoomList.size() != newRoomList.size()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/receptionist/change-room?bookingId="
                    + bookingId
                    + "&error=count");

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

        // Không cho đổi sang chính phòng cũ
        for (int i = 0; i < oldRoomList.size(); i++) {

            if (oldRoomList.get(i).equals(newRoomList.get(i))) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/receptionist/change-room?bookingId="
                        + bookingId
                        + "&error=sameroom");

                return;
            }
        }

        // ================= DAO =================
        ChangeCheckedInRoomDAO dao = new ChangeCheckedInRoomDAO();

        boolean success = dao.changeRooms(
                bookingId,
                oldRoomList.toArray(new String[0]),
                newRoomList.toArray(new String[0]),
                reason.trim()
        );

        if (success) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/receptionist/booking-detail?id="
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
