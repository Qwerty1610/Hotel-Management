package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.service.BookingService;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.mycompany.hotelmanagement.service.RoomTypeService;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReceptionistBookingProcessController URL: /receptionist/booking/process
 *
 * handles room assignment and status approvals (Confirm, Reject, Cancel) for a
 * specific booking request on a standalone page.
 *
 * @author BinhHD, MinhTDP
 */
@WebServlet(name = "ReceptionistBookingProcessController", urlPatterns = {"/receptionist/booking/process"})
public class ReceptionistBookingProcessController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReceptionistBookingProcessController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authorization
        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");

        if ("loadRooms".equals(action)) {
            loadRooms(request, response);
            return;
        }
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            BookingService bookingService = new BookingService();
            Booking booking = bookingService.getBookingById(bookingId);

            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                return;
            }

            // Load Customer profile if accountId is set
            CustomerDetails customer = null;
            if (booking.getAccountId() != null) {
                customer = bookingService.getCustomerDetailsByAccountId(booking.getAccountId());
            }

            // Load all rooms in the hotel (to support dynamic client-side filtering)
            List<Room> rooms = bookingService.getAllRooms(
                    booking.getCheckInDate(),
                    booking.getCheckOutDate());

            // Load assigned rooms if any
            List<Room> assignedRooms = bookingService.getAssignedRoomsForBooking(
                    bookingId,
                    booking.getCheckInDate(),
                    booking.getCheckOutDate()
            );

            List<RoomTypeInfo> roomTypesList = new RoomTypeService().getAllRoomTypes();

            // Load child bookings (for group booking support)
            List<Booking> childBookings = bookingService.getChildBookings(bookingId);

            // Load assigned rooms for each child booking
            Map<Integer, List<Room>> childAssignedRoomsMap = new HashMap<>();
            for (Booking child : childBookings) {
                List<Room> childRooms = bookingService.getAssignedRoomsForBooking(child.getBookingId(),
                        booking.getCheckInDate(),
                        booking.getCheckOutDate());
                childAssignedRoomsMap.put(child.getBookingId(), childRooms);
            }

            request.setAttribute("booking", booking);
            request.setAttribute("customer", customer);
            request.setAttribute("rooms", rooms);
            request.setAttribute("assignedRooms", assignedRooms);
            request.setAttribute("roomTypesList", roomTypesList);
            request.setAttribute("childBookings", childBookings);
            request.setAttribute("childAssignedRoomsMap", childAssignedRoomsMap);

            request.getRequestDispatcher("/WEB-INF/views/receptionist/booking-process.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid bookingId format: " + bookingIdStr, e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=parse");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in ReceptionistBookingProcessController doGet", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=unknown");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/staff/login?error=unauthorized");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String action = request.getParameter("action");

        if (bookingIdStr == null || action == null || action.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            BookingService bookingService = new BookingService();
            Booking existing = bookingService.getBookingById(bookingId);

            if (existing == null) {
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                return;
            }

            boolean success = false;

            List<Booking> children = bookingService.getChildBookings(bookingId);

            if ("Pending".equals(existing.getStatus())
                    && ("update".equalsIgnoreCase(action) || "confirm".equalsIgnoreCase(action))) {
                String customerName = request.getParameter("customerName");
                String checkInStr = request.getParameter("checkInDate");
                String checkOutStr = request.getParameter("checkOutDate");
                String roomTypeStr = request.getParameter("roomTypeId");
                String qtyStr = request.getParameter("roomQuantity");
                String amountStr = request.getParameter("totalAmount");
                String note = request.getParameter("note");

                if (customerName != null && !customerName.trim().isEmpty() && customerName.trim().length() <= 100) {
                    existing.setCustomerName(customerName.trim());
                }

                if (checkInStr != null && !checkInStr.isEmpty() && checkOutStr != null && !checkOutStr.isEmpty()) {
                    try {
                        java.sql.Date checkInDate = java.sql.Date.valueOf(checkInStr);
                        java.sql.Date checkOutDate = java.sql.Date.valueOf(checkOutStr);
                        if (checkInDate.before(checkOutDate)) {
                            existing.setCheckInDate(checkInDate);
                            existing.setCheckOutDate(checkOutDate);
                        }
                    } catch (IllegalArgumentException e) {
                        LOGGER.log(Level.WARNING, "Date format parse error in process controller", e);
                    }
                }

                if (roomTypeStr != null && !roomTypeStr.trim().isEmpty()) {
                    try {
                        existing.setRoomTypeId(Integer.parseInt(roomTypeStr.trim()));
                    } catch (NumberFormatException e) {
                        LOGGER.log(Level.WARNING, "RoomType parse error", e);
                    }
                }

                if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                    try {
                        int qty = Integer.parseInt(qtyStr.trim());
                        if (qty > 0 && qty <= 100) {
                            existing.setRoomQuantity(qty);
                        }
                    } catch (NumberFormatException e) {
                    }
                }

                if (amountStr != null && !amountStr.trim().isEmpty()) {
                    try {
                        double amount = Double.parseDouble(amountStr.trim());
                        if (amount >= 0) {
                            existing.setTotalAmount(amount);
                        }
                    } catch (NumberFormatException e) {
                    }
                }

                if (note != null) {
                    existing.setNote(note.trim());
                }
                existing.setTotalAmount(
                        bookingService.calculateBookingAmount(existing)
                );
                bookingService.updateBookingDetails(existing);

                // Update child bookings
                for (Booking child : children) {
                    child.setCheckInDate(existing.getCheckInDate());
                    child.setCheckOutDate(existing.getCheckOutDate());
                    child.setCustomerName(existing.getCustomerName());

                    String cQtyStr = request.getParameter("childRoomQuantity_" + child.getBookingId());
                    if (cQtyStr != null && !cQtyStr.isBlank()) {
                        child.setRoomQuantity(Integer.parseInt(cQtyStr));
                    }

                    String cTypeStr = request.getParameter("childRoomTypeId_" + child.getBookingId());
                    if (cTypeStr != null && !cTypeStr.isBlank()) {
                        child.setRoomTypeId(Integer.parseInt(cTypeStr));
                    }

                    child.setTotalAmount(
                            bookingService.calculateBookingAmount(child)
                    );

                    bookingService.updateBookingDetails(child);
                }
            }

            switch (action.toLowerCase()) {
                case "update": {
                    if ("Pending".equals(existing.getStatus())) {
                        // Collect all submitted room IDs for validation
                        List<Integer> allSubmittedRoomIds = new ArrayList<>();
                        String[] roomIdStrings = request.getParameterValues("roomIds");
                        if (roomIdStrings != null && roomIdStrings.length == existing.getRoomQuantity()) {
                            for (String rIdStr : roomIdStrings) {
                                allSubmittedRoomIds.add(Integer.parseInt(rIdStr.trim()));
                            }
                        }
                        for (Booking child : children) {
                            String[] cRoomIdStrings = request.getParameterValues("childRoomIds_" + child.getBookingId());
                            if (cRoomIdStrings != null && cRoomIdStrings.length == child.getRoomQuantity()) {
                                for (String rIdStr : cRoomIdStrings) {
                                    allSubmittedRoomIds.add(Integer.parseInt(rIdStr.trim()));
                                }
                            }
                        }

                        // Check duplicates within the current request
                        java.util.Set<Integer> uniqueRoomIds = new java.util.HashSet<>(allSubmittedRoomIds);
                        if (uniqueRoomIds.size() < allSubmittedRoomIds.size()) {
                            response.sendRedirect(request.getContextPath() + "/receptionist/booking/process?bookingId="
                                    + bookingId + "&error=duplicate_room");
                            return;
                        }

                        // Check overlap with other bookings
                        List<Integer> conflicts = bookingService.getConflictingRooms(allSubmittedRoomIds, existing.getCheckInDate(), existing.getCheckOutDate(), bookingId);
                        if (!conflicts.isEmpty()) {
                            response.sendRedirect(request.getContextPath() + "/receptionist/booking/process?bookingId="
                                    + bookingId + "&error=conflict");
                            return;
                        }

                        // Parent assignment
                        if (roomIdStrings != null && roomIdStrings.length == existing.getRoomQuantity()) {
                            List<Integer> roomIds = new ArrayList<>();
                            for (String rIdStr : roomIdStrings) {
                                roomIds.add(Integer.parseInt(rIdStr.trim()));
                            }
                            bookingService.assignRoomsToBooking(bookingId, roomIds);
                        } else {
                            bookingService.assignRoomsToBooking(bookingId, new ArrayList<>());
                        }

                        // Child assignments
                        for (Booking child : children) {
                            String[] cRoomIdStrings = request.getParameterValues("childRoomIds_" + child.getBookingId());
                            if (cRoomIdStrings != null && cRoomIdStrings.length == child.getRoomQuantity()) {
                                List<Integer> cRoomIds = new ArrayList<>();
                                for (String rIdStr : cRoomIdStrings) {
                                    cRoomIds.add(Integer.parseInt(rIdStr.trim()));
                                }
                                bookingService.assignRoomsToBooking(child.getBookingId(), cRoomIds);
                            } else {
                                bookingService.assignRoomsToBooking(child.getBookingId(), new ArrayList<>());
                            }
                        }
                    }
                    success = true;
                    break;
                }

                case "confirm": {
                    // Check status validity
                    if (!"Pending".equals(existing.getStatus())) {
                        response.sendRedirect(
                                request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                        return;
                    }

                    List<Integer> allSubmittedRoomIds = new ArrayList<>();

                    // Validate selected room IDs for parent
                    String[] roomIdStrings = request.getParameterValues("roomIds");
                    if (roomIdStrings == null || roomIdStrings.length != existing.getRoomQuantity()) {
                        LOGGER.log(Level.WARNING, "Confirm failed: Room selection mismatch for booking: " + bookingId);
                        response.sendRedirect(request.getContextPath() + "/receptionist/booking/process?bookingId="
                                + bookingId + "&error=validation");
                        return;
                    }
                    for (String rIdStr : roomIdStrings) {
                        allSubmittedRoomIds.add(Integer.parseInt(rIdStr.trim()));
                    }

                    // Validate selected room IDs for children
                    for (Booking child : children) {
                        String[] cRoomIdStrings = request.getParameterValues("childRoomIds_" + child.getBookingId());
                        if (cRoomIdStrings == null || cRoomIdStrings.length != child.getRoomQuantity()) {
                            LOGGER.log(Level.WARNING, "Confirm failed: Room selection mismatch for child booking: " + child.getBookingId());
                            response.sendRedirect(request.getContextPath() + "/receptionist/booking/process?bookingId="
                                    + bookingId + "&error=validation");
                            return;
                        }
                        for (String rIdStr : cRoomIdStrings) {
                            allSubmittedRoomIds.add(Integer.parseInt(rIdStr.trim()));
                        }
                    }

                    // Check duplicates within the current request
                    java.util.Set<Integer> uniqueRoomIds = new java.util.HashSet<>(allSubmittedRoomIds);
                    if (uniqueRoomIds.size() < allSubmittedRoomIds.size()) {
                        response.sendRedirect(request.getContextPath() + "/receptionist/booking/process?bookingId="
                                + bookingId + "&error=duplicate_room");
                        return;
                    }

                    // Check overlap with other bookings
                    List<Integer> conflicts = bookingService.getConflictingRooms(allSubmittedRoomIds, existing.getCheckInDate(), existing.getCheckOutDate(), bookingId);
                    if (!conflicts.isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/receptionist/booking/process?bookingId="
                                + bookingId + "&error=conflict");
                        return;
                    }

                    // Perform database updates
                    String note = request.getParameter("note");
                    String noteText = (note != null && !note.trim().isEmpty()) ? note.trim()
                            : "Đã xác nhận và phân phòng";

                    // Parent
                    List<Integer> roomIds = new ArrayList<>();
                    for (String rIdStr : roomIdStrings) {
                        roomIds.add(Integer.parseInt(rIdStr.trim()));
                    }
                    boolean assigned = bookingService.assignRoomsToBooking(bookingId, roomIds);
                    if (assigned) {
                        success = bookingService.updateBookingStatus(bookingId, "Confirmed", noteText);
                    }

                    // Children
                    for (Booking child : children) {
                        List<Integer> cRoomIds = new ArrayList<>();
                        String[] cRoomIdStrings = request.getParameterValues("childRoomIds_" + child.getBookingId());
                        for (String rIdStr : cRoomIdStrings) {
                            cRoomIds.add(Integer.parseInt(rIdStr.trim()));
                        }
                        boolean cAssigned = bookingService.assignRoomsToBooking(child.getBookingId(), cRoomIds);
                        if (cAssigned) {
                            bookingService.updateBookingStatus(child.getBookingId(), "Confirmed", noteText);
                        }
                    }
                    break;
                }

                case "reject": {
                    if (!"Pending".equals(existing.getStatus())) {
                        response.sendRedirect(
                                request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                        return;
                    }

                    String reason = request.getParameter("reason");
                    if (reason == null || reason.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/receptionist/booking/process?bookingId="
                                + bookingId + "&error=validation");
                        return;
                    }

                    success = bookingService.updateBookingStatus(bookingId, "Rejected", reason.trim());
                    for (Booking child : children) {
                        bookingService.updateBookingStatus(child.getBookingId(), "Rejected", reason.trim());
                    }
                    break;
                }

                case "cancel": {
                    if ("CheckedIn".equals(existing.getStatus()) || "CheckedOut".equals(existing.getStatus())) {
                        response.sendRedirect(
                                request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                        return;
                    }

                    String reason = request.getParameter("reason");
                    String reasonText = (reason != null && !reason.trim().isEmpty()) ? reason.trim()
                            : "Huỷ theo yêu cầu";

                    success = bookingService.cancelBooking(bookingId, reasonText);
                    for (Booking child : children) {
                        bookingService.cancelBooking(child.getBookingId(), reasonText);
                    }
                    break;
                }

                default:
                    response.sendRedirect(
                            request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
                    return;
            }

            String result = success ? "success" : "fail";
            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=bookings&result=" + result
                    + "&action=" + action);

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Format parse error on post processing", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=parse");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in ReceptionistBookingProcessController doPost", e);
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=unknown");
        }
    }

    private void loadRooms(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {

            int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
            java.sql.Date checkIn = java.sql.Date.valueOf(request.getParameter("checkInDate"));
            java.sql.Date checkOut = java.sql.Date.valueOf(request.getParameter("checkOutDate"));

            BookingService bookingService = new BookingService();

            List<Room> rooms = bookingService.getRoomsByTypeId(
                    roomTypeId,
                    checkIn,
                    checkOut
            );

            StringBuilder json = new StringBuilder();
            json.append("[");

            for (int i = 0; i < rooms.size(); i++) {

                Room r = rooms.get(i);

                json.append("{")
                        .append("\"roomId\":").append(r.getRoomId()).append(",")
                        .append("\"roomNumber\":\"").append(escapeJson(r.getRoomNumber())).append("\",")
                        .append("\"status\":\"").append(escapeJson(r.getStatus())).append("\",")
                        .append("\"floor\":\"").append(escapeJson(r.getFloor())).append("\",")
                        .append("\"typeName\":\"").append(escapeJson(r.getTypeName())).append("\"")
                        .append("}");

                if (i < rooms.size() - 1) {
                    json.append(",");
                }
            }

            json.append("]");

            PrintWriter out = response.getWriter();
            out.print(json.toString());
            out.flush();

        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "loadRooms error", ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("[]");
        }
    }

    private String escapeJson(String text) {
        if (text == null) {
            return "";
        }
        return text
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "")
                .replace("\r", "");
    }
}
