package com.mycompany.hotelmanagement.controller.receptionist;

import com.mycompany.hotelmanagement.dal.WalkInBookingDAO;
import com.mycompany.hotelmanagement.entity.Account;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;

@WebServlet("/receptionist/walkin-booking")
public class ReceptionistWalkInBookingController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {

            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        String action = request.getParameter("action");

        if ("searchAccount".equals(action)) {
            searchAccount(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login");
            return;
        }

        try {
            WalkInBookingDAO dao = new WalkInBookingDAO();
            Integer receptionistId = (Integer) session.getAttribute("accountId");

            if (receptionistId == null) {
                throw new RuntimeException(
                        "Không xác định được lễ tân");
            }

            String customerName = request.getParameter("customerName");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            String note = request.getParameter("note");
            String receptionistNote = request.getParameter("receptionistNote");
            String bookingMode = request.getParameter("bookingMode");
            boolean isCheckIn = "CHECKIN".equalsIgnoreCase(bookingMode);
            String[] companions = request.getParameterValues("companions[]");
            String customerRequest = request.getParameter("note");

            String checkInStr = request.getParameter("checkInDate");
            String checkOutStr = request.getParameter("checkOutDate");

            if (customerName == null || customerName.trim().isEmpty()) {
                throw new RuntimeException("Chưa nhập tên khách");
            }
            if (phone == null || phone.trim().isEmpty()) {
                throw new RuntimeException("Chưa nhập số điện thoại");
            }
            if (checkInStr == null || checkOutStr == null) {
                throw new RuntimeException("Chưa chọn ngày");
            }

            Date checkIn = Date.valueOf(checkInStr);
            Date checkOut = Date.valueOf(checkOutStr);
            if (!checkOut.after(checkIn)) {
                session.setAttribute(
                        "error",
                        "Ngày trả phòng phải sau ngày nhận phòng"
                );
                response.sendRedirect(
                        request.getContextPath()
                        + "/receptionist/dashboard?tab=walkin-bookings"
                );
                return;
            }
            String[] roomTypeIds = request.getParameterValues("roomTypeIds[]");
            String[] quantities = request.getParameterValues("roomQuantities[]");
            String[] guestCounts = request.getParameterValues("guestCounts[]");
            String[] selectedRooms = request.getParameterValues("roomIds");

            // validation nhẹ tránh NullPointer
            if (roomTypeIds == null || quantities == null || guestCounts == null || selectedRooms == null) {
                session.setAttribute("error", "Thiếu dữ liệu phòng");
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=walkin-bookings");
                return;
            }

            int totalRequired = 0;
            for (int i = 0; i < roomTypeIds.length; i++) {
                totalRequired += Integer.parseInt(quantities[i]);
            }
            if (selectedRooms == null) {
                throw new RuntimeException("Chưa chọn phòng");
            }
            if (selectedRooms.length < totalRequired) {
                throw new RuntimeException("Thiếu phòng đã chọn");
            }

            for (int i = 0; i < roomTypeIds.length; i++) {
                int typeId
                        = Integer.parseInt(roomTypeIds[i]);
                int qty
                        = Integer.parseInt(quantities[i]);
                int guests
                        = Integer.parseInt(guestCounts[i]);
                int capacity
                        = dao.getRoomCapacity(typeId);
                int maxGuests
                        = capacity * qty;

                if (guests > maxGuests) {
                    throw new RuntimeException(
                            "Số người vượt quá sức chứa");
                }
            }

            int bookingId = dao.createWalkInBooking(
                    receptionistId,
                    customerName,
                    phone,
                    email,
                    note,
                    checkIn,
                    checkOut,
                    roomTypeIds,
                    quantities,
                    selectedRooms,
                    isCheckIn,
                    receptionistNote,
                    customerRequest,
                    companions
            );

            if (bookingId <= 0) {
                session.setAttribute(
                        "error",
                        "Tạo booking thất bại");
                response.sendRedirect(
                        request.getContextPath()
                        + "/receptionist/dashboard?tab=walkin-bookings"
                );
                return;
            }

            if (isCheckIn) {
                session.setAttribute(
                        "success",
                        "Check-In thành công");

            } else {
                session.setAttribute(
                        "success",
                        "Đặt phòng thành công");
            }

            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=walkin-bookings");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect(request.getContextPath()
                    + "/receptionist/dashboard?tab=walkin-bookings");
        }
    }

    private void searchAccount(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");

        System.out.println("=== SEARCH ACCOUNT ===");
        System.out.println("Keyword: " + keyword);

        if (keyword == null || keyword.trim().isEmpty()) {
            response.getWriter().write("{}");
            return;
        }

        WalkInBookingDAO dao = new WalkInBookingDAO();

        Account account = dao.findAccountByEmailOrPhone(keyword.trim());

        if (account == null) {
            System.out.println("Account not found");
            response.getWriter().write("{}");
            return;
        }

        String json
                = "{"
                + "\"fullName\":\"" + escape(account.getFullName()) + "\","
                + "\"phone\":\"" + escape(account.getPhone()) + "\","
                + "\"email\":\"" + escape(account.getEmail()) + "\""
                + "}";

        System.out.println(json);

        response.getWriter().write(json);
    }

    private String escape(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"");
    }
}