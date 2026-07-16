package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.CheckOutDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.CheckOut;
import java.util.List;

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
