package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.CheckOutDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.CheckOut;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: CheckOutService
 *
 * Description:
 * Lớp dịch vụ (Service) cho quy trình trả phòng. Lấy bản tóm tắt trả phòng
 * đầy đủ từ CheckOutDAO, bổ sung chi tiết lễ tân và thanh toán do controller
 * cung cấp, và ủy quyền lưu trữ cuối cùng trở lại DAO.
 *
 * Related Use Cases:
 * - UC-16 Check-Out Customer
 * 
 * Date: 09-07-2026
 * 
 * @author BinhHD
 * @version 1.0
 */

public class CheckOutService {
    private final CheckOutDAO checkOutDAO;

    public CheckOutService() {
        this.checkOutDAO = new CheckOutDAO();
    }

    public List<Booking> getCheckedInBookings(String search) {
        return checkOutDAO.getCheckedInBookings(search);
    }

    public CheckOut getCheckOutSummary(int bookingId) {
        return checkOutDAO.buildCheckOutSummary(bookingId);
    }

    public boolean processCheckOut(int bookingId, int receptionistId, String paymentMethod, String notes) {
        // Fetch current summary to get amounts
        CheckOut summary = checkOutDAO.buildCheckOutSummary(bookingId);
        if (summary.getBookingId() == 0) {
            return false; // Booking not found
        }

        // Populate additional fields for insert
        summary.setReceptionistId(receptionistId);
        summary.setPaymentMethod(paymentMethod);
        summary.setNotes(notes);

        return checkOutDAO.processCheckOut(summary);
    }
}
