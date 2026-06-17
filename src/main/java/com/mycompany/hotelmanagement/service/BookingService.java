package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Room;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
import java.util.List;

/**
 * BookingService
 * Business logic wrapper and mediator for Booking-related operations.
 *
 * @author DUC BINH
 */
public class BookingService {

    private final BookingDAO bookingDAO = new BookingDAO();

    public List<Booking> getBookings(String statusFilter, String keyword) {
        return bookingDAO.getBookings(statusFilter, keyword);
    }

    public Booking getBookingById(int bookingId) {
        return bookingDAO.getBookingById(bookingId);
    }

    public boolean updateBookingStatus(int bookingId, String newStatus, String note) {
        return bookingDAO.updateBookingStatus(bookingId, newStatus, note);
    }

    public boolean updateBookingDetails(Booking b) {
        return bookingDAO.updateBookingDetails(b);
    }

    public boolean cancelBooking(int bookingId, String reason) {
        return bookingDAO.cancelBooking(bookingId, reason);
    }

    public int countByStatus(String status) {
        return bookingDAO.countByStatus(status);
    }

    public int countAll() {
        return bookingDAO.countAll();
    }

    public List<Room> getRoomsByTypeId(int typeId) {
        return bookingDAO.getRoomsByTypeId(typeId);
    }

    public List<Room> getAllRooms() {
        return bookingDAO.getAllRooms();
    }

    public CustomerDetails getCustomerDetailsByAccountId(int accountId) {
        return bookingDAO.getCustomerDetailsByAccountId(accountId);
    }

    public boolean assignRoomsToBooking(int bookingId, List<Integer> roomIds) {
        return bookingDAO.assignRoomsToBooking(bookingId, roomIds);
    }

    public List<Room> getAssignedRoomsForBooking(int bookingId) {
        return bookingDAO.getAssignedRoomsForBooking(bookingId);
    }
}
