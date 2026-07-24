package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.CheckOut;
import com.mycompany.hotelmanagement.entity.InvoiceItem;
import com.mycompany.hotelmanagement.entity.Payment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Project: Hotel Management System
 * Class: CheckOutDAO
 *
 * Description:
 * Đối tượng truy cập dữ liệu (DAO) cho quy trình trả phòng. Truy vấn các đơn
 * đã nhận phòng, xây dựng bản tóm tắt trả phòng đầy đủ (chi tiết phí phòng/
 * dịch vụ/phụ phí, lịch sử thanh toán) và lưu hồ sơ trả phòng cuối cùng đồng
 * thời cập nhật trạng thái đặt phòng thành CheckedOut.
 *
 * Related Use Cases:
 * - UC-16 Check-Out Customer
 * 
 * Date: 09-07-2026
 * 
 * @author BinhHD
 * @version 1.0
 */

public class CheckOutDAO {

    // 1. Get all bookings with CheckedIn status for the Check-out list
    public List<Booking> getCheckedInBookings(String search) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.*, "
                + "(SELECT STRING_AGG(r.room_number, ', ') "
                + " FROM dbo.RoomAssignment ra "
                + " JOIN dbo.Room r ON ra.room_id = r.room_id "
                + " WHERE ra.booking_id = b.booking_id) AS assigned_rooms "
                + "FROM dbo.Booking b "
                + "WHERE b.status = N'CheckedIn'";

        if (search != null && !search.trim().isEmpty()) {
            sql += " AND (b.customer_name LIKE ? OR "
                    + " b.booking_id IN (SELECT ra.booking_id FROM dbo.RoomAssignment ra "
                    + " JOIN dbo.Room r ON ra.room_id = r.room_id WHERE r.room_number LIKE ?))";
        }
        sql += " ORDER BY b.check_out_date ASC";

        try (Connection con = DBContext.getConnection();
                PreparedStatement st = con.prepareStatement(sql)) {

            if (search != null && !search.trim().isEmpty()) {
                String keyword = "%" + search.trim() + "%";
                st.setString(1, keyword);
                st.setString(2, keyword);
            }

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Booking b = new Booking();
                    b.setBookingId(rs.getInt("booking_id"));
                    b.setCustomerName(rs.getString("customer_name"));
                    b.setCheckInDate(rs.getDate("check_in_date"));
                    b.setCheckOutDate(rs.getDate("check_out_date"));
                    b.setStatus(rs.getString("status"));
                    b.setAssignedRoomsStr(rs.getString("assigned_rooms"));
                    list.add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Build the checkout summary for a specific booking
    public CheckOut buildCheckOutSummary(int bookingId) {
        CheckOut summary = new CheckOut();
        summary.setBookingId(bookingId);

        String sql = "SELECT "
                + "  b.customer_name, "
                + "  b.check_in_date, "
                + "  b.check_out_date, "
                + "  rt.type_name, "
                + "  (SELECT STRING_AGG(r.room_number, ', ') FROM dbo.RoomAssignment ra JOIN dbo.Room r ON ra.room_id = r.room_id WHERE ra.booking_id = b.booking_id) AS room_number, "
                + "  b.total_amount AS booking_room_charge, "
                + "  i.invoice_id, "
                + "  ISNULL((SELECT SUM(amount) FROM dbo.InvoiceItem WHERE invoice_id = i.invoice_id AND item_type = N'Service'), 0) AS service_charge, "
                // Phụ phí quá người ở từ CheckIn (riêng)
                + "  ISNULL((SELECT TOP 1 extra_fee FROM dbo.CheckIn ci WHERE ci.booking_id = b.booking_id), 0) AS checkin_extra_fee, "
                // Tổng phụ phí = checkin_extra_fee + Surcharge Manager thêm
                + "  (ISNULL((SELECT TOP 1 extra_fee FROM dbo.CheckIn ci WHERE ci.booking_id = b.booking_id), 0) "
                + "   + ISNULL((SELECT SUM(amount) FROM dbo.InvoiceItem WHERE invoice_id = i.invoice_id AND item_type = N'Surcharge'), 0)) AS extra_charge, "
                // Một truy vấn với OR thay vì cộng hai subquery: giao dịch gắn cả
                // invoice_id lẫn booking_id (thanh toán tại quầy, dữ liệu cọc cũ)
                // sẽ chỉ được cộng ĐÚNG MỘT LẦN vào số đã trả.
                + "  ISNULL((SELECT SUM(amount) FROM dbo.Payment WHERE invoice_id = i.invoice_id OR booking_id = b.booking_id), 0) AS amount_paid "
                + "FROM dbo.Booking b "
                + "LEFT JOIN dbo.RoomType rt ON b.room_type_id = rt.type_id "
                + "LEFT JOIN dbo.Invoice i ON b.booking_id = i.booking_id "
                + "WHERE b.booking_id = ?";

        try (Connection con = DBContext.getConnection();
                PreparedStatement st = con.prepareStatement(sql)) {

            st.setInt(1, bookingId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    summary.setCustomerName(rs.getString("customer_name"));
                    summary.setCheckInDate(rs.getTimestamp("check_in_date"));
                    summary.setCheckOutDate(rs.getTimestamp("check_out_date"));
                    summary.setRoomTypeName(rs.getString("type_name"));
                    summary.setRoomNumber(rs.getString("room_number"));

                    double roomCharge = rs.getDouble("booking_room_charge");
                    double serviceCharge = rs.getDouble("service_charge");
                    double checkInExtraFee = rs.getDouble("checkin_extra_fee");
                    double extraCharge = rs.getDouble("extra_charge");
                    double totalAmount = roomCharge + serviceCharge + extraCharge;
                    double amountPaid = rs.getDouble("amount_paid");

                    summary.setRoomCharge(roomCharge);
                    summary.setServiceCharge(serviceCharge);
                    summary.setCheckInExtraFee(checkInExtraFee);
                    summary.setExtraCharge(extraCharge);
                    summary.setTotalAmount(totalAmount);
                    summary.setAmountPaid(amountPaid);
                    summary.setRemainingAmount(Math.max(0, totalAmount - amountPaid));

                    List<InvoiceItem> services = new ArrayList<>();
                    List<InvoiceItem> surcharges = new ArrayList<>();
                    List<Payment> payments = new ArrayList<>();

                    int invoiceId = rs.getInt("invoice_id");
                    if (!rs.wasNull()) {
                        String itemSql = "SELECT * FROM dbo.InvoiceItem WHERE invoice_id = ? AND item_type IN (N'Service', N'Surcharge')";
                        try (PreparedStatement itemSt = con.prepareStatement(itemSql)) {
                            itemSt.setInt(1, invoiceId);
                            try (ResultSet irs = itemSt.executeQuery()) {
                                while (irs.next()) {
                                    InvoiceItem item = new InvoiceItem();
                                    item.setItemId(irs.getInt("item_id"));
                                    item.setInvoiceId(irs.getInt("invoice_id"));
                                    item.setItemType(irs.getString("item_type"));
                                    item.setDescription(irs.getString("description"));
                                    item.setQuantity(irs.getInt("quantity"));
                                    item.setUnitPrice(irs.getDouble("unit_price"));
                                    item.setAmount(irs.getDouble("amount"));
                                    if ("Service".equals(item.getItemType())) {
                                        services.add(item);
                                    } else {
                                        surcharges.add(item);
                                    }
                                }
                            }
                        }
                    }

                    String paySql = "SELECT * FROM dbo.Payment WHERE invoice_id = ? OR booking_id = ? ORDER BY created_at ASC";
                    try (PreparedStatement paySt = con.prepareStatement(paySql)) {
                        if (invoiceId > 0) {
                            paySt.setInt(1, invoiceId);
                        } else {
                            paySt.setNull(1, java.sql.Types.INTEGER);
                        }
                        paySt.setInt(2, bookingId);
                        try (ResultSet prs = paySt.executeQuery()) {
                            while (prs.next()) {
                                Payment p = new Payment();
                                p.setPaymentId(prs.getInt("payment_id"));
                                p.setAmount(prs.getDouble("amount"));
                                p.setTransactionDate(prs.getTimestamp("transaction_date"));
                                p.setReferenceCode(prs.getString("reference_code"));
                                p.setSepayTxId(prs.getLong("sepay_tx_id"));
                                p.setBookingId((Integer) prs.getObject("booking_id"));
                                p.setInvoiceId((Integer) prs.getObject("invoice_id"));
                                p.setContent(prs.getString("content"));
                                p.setGateway(prs.getString("gateway"));
                                p.setCreatedAt(prs.getTimestamp("created_at"));
                                payments.add(p);
                            }
                        }
                    }

                    summary.setServiceItems(services);
                    summary.setSurchargeItems(surcharges);
                    summary.setPaymentHistory(payments);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return summary;
    }

    // 3. Save CheckOut, update Booking, Room and Invoice statuses in a transaction
    public boolean processCheckOut(CheckOut co) {
        String insertCheckOut = "INSERT INTO dbo.CheckOut (booking_id, receptionist_id, room_charge, service_charge, extra_charge, total_amount, amount_paid, remaining_amount, payment_method, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String updateBooking = "UPDATE dbo.Booking SET status = N'CheckedOut', updated_at = SYSDATETIME() WHERE booking_id = ?";
        String updateRoom = "UPDATE dbo.Room SET status = N'Cleaning' WHERE room_id IN (SELECT room_id FROM dbo.RoomAssignment WHERE booking_id = ?)";
        String updateInvoice = "UPDATE dbo.Invoice SET status = N'Paid' WHERE booking_id = ?";

        Connection con = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false); // Start transaction

            // 1. Insert CheckOut
            try (PreparedStatement st1 = con.prepareStatement(insertCheckOut)) {
                st1.setInt(1, co.getBookingId());
                st1.setInt(2, co.getReceptionistId());
                st1.setDouble(3, co.getRoomCharge());
                st1.setDouble(4, co.getServiceCharge());
                st1.setDouble(5, co.getExtraCharge());
                st1.setDouble(6, co.getTotalAmount());
                st1.setDouble(7, co.getAmountPaid());
                st1.setDouble(8, co.getRemainingAmount());
                st1.setString(9, co.getPaymentMethod());
                st1.setString(10, co.getNotes());
                st1.executeUpdate();
            }

            // 2. Update Booking
            try (PreparedStatement st2 = con.prepareStatement(updateBooking)) {
                st2.setInt(1, co.getBookingId());
                st2.executeUpdate();
            }

            // 3. Update Room
            try (PreparedStatement st3 = con.prepareStatement(updateRoom)) {
                st3.setInt(1, co.getBookingId());
                st3.executeUpdate();
            }

            // 4. Handle Invoice
            int invoiceId = -1;
            String checkInvoice = "SELECT invoice_id FROM dbo.Invoice WHERE booking_id = ?";
            try (PreparedStatement stCheck = con.prepareStatement(checkInvoice)) {
                stCheck.setInt(1, co.getBookingId());
                try (ResultSet rs = stCheck.executeQuery()) {
                    if (rs.next()) {
                        invoiceId = rs.getInt("invoice_id");
                    }
                }
            }

            if (invoiceId == -1) {
                // Create Invoice
                String insertInvoice = "INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at) VALUES (?, (SELECT customer_name FROM dbo.Booking WHERE booking_id = ?), ?, N'Paid', SYSDATETIME())";
                try (PreparedStatement stInv = con.prepareStatement(insertInvoice, Statement.RETURN_GENERATED_KEYS)) {
                    stInv.setInt(1, co.getBookingId());
                    stInv.setInt(2, co.getBookingId());
                    stInv.setString(3, co.getRoomNumber());
                    stInv.executeUpdate();
                    try (ResultSet rs = stInv.getGeneratedKeys()) {
                        if (rs.next()) {
                            invoiceId = rs.getInt(1);
                        }
                    }
                }

                // Insert InvoiceItem for Room
                String insertRoomItem = "INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) VALUES (?, N'Room', N'Tiền phòng', 1, ?, ?)";
                try (PreparedStatement stItem = con.prepareStatement(insertRoomItem)) {
                    stItem.setInt(1, invoiceId);
                    stItem.setDouble(2, co.getRoomCharge());
                    stItem.setDouble(3, co.getRoomCharge());
                    stItem.executeUpdate();
                }
            } else {
                // Update Invoice
                try (PreparedStatement st4 = con.prepareStatement(updateInvoice)) {
                    st4.setInt(1, co.getBookingId());
                    st4.executeUpdate();
                }
            }

            // 5. Insert Payment if customer pays the remaining amount now
            if (co.getRemainingAmount() > 0) {
                // sepay_tx_id is required. Since this is a manual checkout payment, we generate
                // a random negative ID
                long fakeTxId = -1L * Math.abs(java.util.UUID.randomUUID().getMostSignificantBits());
                String insertPayment = "INSERT INTO dbo.Payment (invoice_id, booking_id, sepay_tx_id, amount, gateway, content, transaction_date, created_at) VALUES (?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
                try (PreparedStatement stPay = con.prepareStatement(insertPayment)) {
                    if (invoiceId != -1) {
                        stPay.setInt(1, invoiceId);
                    } else {
                        stPay.setNull(1, java.sql.Types.INTEGER);
                    }
                    stPay.setInt(2, co.getBookingId());
                    stPay.setLong(3, fakeTxId);
                    stPay.setDouble(4, co.getRemainingAmount());
                    stPay.setString(5, co.getPaymentMethod());
                    stPay.setString(6, "THANH TOAN TAI QUAY - BOOKING " + co.getBookingId());
                    stPay.executeUpdate();
                }
            }

            con.commit(); // Commit transaction
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }
}
