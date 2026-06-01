/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.hotelmanagement.controller.receptionist;
import com.mycompany.hotelmanagement.dao.BookingDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;

/**
 * ReceptionistBookingController
 * URL: /receptionist/booking
 *
 * Xử lý 3 hành động (action param):
 *   - confirm  : Xác nhận booking (Pending → Confirmed)
 *   - reject   : Từ chối booking  (Pending → Rejected)
 *   - update   : Cập nhật thông tin booking (chỉ khi Pending)
 *   - cancel   : Huỷ booking
 * 
 * Date: 31/5/2026
 * @author DUC BINH
 */
@WebServlet(name = "ReceptionistBookingController", urlPatterns = {"/receptionist/booking"})
public class ReceptionistBookingController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra quyền
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/home/login?error=unauthorized");
            return;
        }

        String action      = request.getParameter("action");
        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr == null || action == null) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=invalid");
            return;
        }

        BookingDAO dao = new BookingDAO();
        boolean success = false;

        switch (action.toLowerCase()) {

            /* ---------- Xác nhận ---------- */
            case "confirm":
                String confirmNote = request.getParameter("note");
                success = dao.updateBookingStatus(bookingId, "Confirmed",
                        confirmNote != null ? confirmNote : "Đã xác nhận bởi lễ tân");
                break;

            /* ---------- Từ chối ---------- */
            case "reject":
                String rejectReason = request.getParameter("reason");
                if (rejectReason == null || rejectReason.trim().isEmpty()) {
                    rejectReason = "Không đáp ứng yêu cầu";
                }
                success = dao.updateBookingStatus(bookingId, "Rejected", rejectReason);
                break;

            /* ---------- Huỷ booking ---------- */
            case "cancel":
                String cancelReason = request.getParameter("reason");
                success = dao.cancelBooking(bookingId,
                        cancelReason != null ? cancelReason : "Huỷ theo yêu cầu khách");
                break;

            /* ---------- Gán phòng ---------- */
            case "assign":
                String assignRoomIdStr = request.getParameter("roomId");
                if (assignRoomIdStr != null) {
                    int assignRoomId = Integer.parseInt(assignRoomIdStr.trim());
                    success = dao.assignRoom(bookingId, assignRoomId);
                }
                break;

            /* ---------- Check in ---------- */
            case "checkin":
                RoomInfo assignedRoom = dao.getAssignedRoom(bookingId);
                if (assignedRoom != null) {
                    success = dao.checkInBooking(bookingId, assignedRoom.getRoomId());
                }
                break;

            /* ---------- Check out ---------- */
            case "checkout":
                RoomInfo assignedRoomOut = dao.getAssignedRoom(bookingId);
                String finalAmtStr = request.getParameter("totalAmount");
                if (assignedRoomOut != null && finalAmtStr != null) {
                    double finalAmt = Double.parseDouble(finalAmtStr.trim());
                    success = dao.checkOutBooking(bookingId, assignedRoomOut.getRoomId(), finalAmt);
                }
                break;

            /* ---------- Thêm dịch vụ ---------- */
            case "add_service":
                String addServiceIdStr = request.getParameter("serviceId");
                String addQtyStr       = request.getParameter("quantity");
                String addPriceStr     = request.getParameter("price");
                if (addServiceIdStr != null && addQtyStr != null && addPriceStr != null) {
                    int addServiceId = Integer.parseInt(addServiceIdStr.trim());
                    int addQty = Integer.parseInt(addQtyStr.trim());
                    double addPrice = Double.parseDouble(addPriceStr.trim());
                    success = dao.addServiceToBooking(bookingId, addServiceId, addQty, addPrice);
                }
                break;

            /* ---------- Xóa dịch vụ ---------- */
            case "remove_service":
                String remServiceIdStr = request.getParameter("serviceId");
                if (remServiceIdStr != null) {
                    int remServiceId = Integer.parseInt(remServiceIdStr.trim());
                    success = dao.removeServiceFromBooking(bookingId, remServiceId);
                }
                break;

            /* ---------- Đặt phòng trực tiếp (Walk-in) ---------- */
            case "walkin":
                String walkCustomerName = request.getParameter("customerName");
                String walkRoomTypeIdStr = request.getParameter("roomTypeId");
                String walkRoomIdStr     = request.getParameter("roomId");
                String walkCheckInStr    = request.getParameter("checkInDate");
                String walkCheckOutStr   = request.getParameter("checkOutDate");
                String walkAmountStr     = request.getParameter("totalAmount");
                String walkNote          = request.getParameter("note");

                try {
                    Booking b = new Booking();
                    b.setCustomerName(walkCustomerName.trim());
                    b.setRoomTypeId(Integer.parseInt(walkRoomTypeIdStr.trim()));
                    b.setCheckInDate(Date.valueOf(walkCheckInStr));
                    b.setCheckOutDate(Date.valueOf(walkCheckOutStr));
                    b.setTotalAmount(Double.parseDouble(walkAmountStr.trim()));
                    b.setNote(walkNote != null ? walkNote.trim() : "Đặt phòng tại quầy (Walk-in)");
                    
                    int walkRoomId = Integer.parseInt(walkRoomIdStr.trim());
                    success = dao.createWalkInBooking(b, walkRoomId);
                } catch (Exception ex) {
                    ex.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=walkin&error=parse");
                    return;
                }
                break;

            /* ---------- Cập nhật thông tin ---------- */
            case "update":
                Booking existing = dao.getBookingById(bookingId);
                if (existing != null && "Pending".equals(existing.getStatus())) {
                    // Đọc form fields
                    String customerName = request.getParameter("customerName");
                    String checkInStr   = request.getParameter("checkInDate");
                    String checkOutStr  = request.getParameter("checkOutDate");
                    String roomTypeStr  = request.getParameter("roomTypeId");
                    String qtyStr       = request.getParameter("roomQuantity");
                    String amountStr    = request.getParameter("totalAmount");
                    String note         = request.getParameter("note");

                    // Validate & parse
                    try {
                        if (customerName != null && !customerName.trim().isEmpty())
                            existing.setCustomerName(customerName.trim());

                        if (checkInStr != null && !checkInStr.isEmpty())
                            existing.setCheckInDate(Date.valueOf(checkInStr));
                        if (checkOutStr != null && !checkOutStr.isEmpty())
                            existing.setCheckOutDate(Date.valueOf(checkOutStr));

                        if (roomTypeStr != null && !roomTypeStr.trim().isEmpty())
                            existing.setRoomTypeId(Integer.parseInt(roomTypeStr.trim()));

                        if (qtyStr != null && !qtyStr.trim().isEmpty())
                            existing.setRoomQuantity(Integer.parseInt(qtyStr.trim()));

                        if (amountStr != null && !amountStr.trim().isEmpty())
                            existing.setTotalAmount(Double.parseDouble(amountStr.trim()));

                        existing.setNote(note);
                        success = dao.updateBookingDetails(existing);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        // Redirect với thông báo lỗi
                        response.sendRedirect(request.getContextPath()
                                + "/receptionist/dashboard?tab=bookings&error=parse");
                        return;
                    }
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings&error=unknown");
                return;
        }

        String targetTab = "bookings";
        if ("assign".equalsIgnoreCase(action) || "checkin".equalsIgnoreCase(action)) {
            targetTab = "checkin";
        } else if ("checkout".equalsIgnoreCase(action) || "add_service".equalsIgnoreCase(action) || "remove_service".equalsIgnoreCase(action)) {
            targetTab = "checkout";
        } else if ("walkin".equalsIgnoreCase(action)) {
            targetTab = "walkin";
        }

        // Redirect kèm thông báo kết quả
        String result = success ? "success" : "fail";
        response.sendRedirect(request.getContextPath()
                + "/receptionist/dashboard?tab=" + targetTab + "&result=" + result
                + "&action=" + action);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET không hỗ trợ – redirect về dashboard
        response.sendRedirect(request.getContextPath() + "/receptionist/dashboard?tab=bookings");
    }
}

