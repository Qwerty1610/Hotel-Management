package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * A customer-initiated request against an existing booking. Covers two use
 * cases that share the same tracking table:
 * <ul>
 *   <li>{@code Change}    — UC 2.3.9 Request Booking Change</li>
 *   <li>{@code Extension} — UC 2.3.14 Request Stay Extension</li>
 * </ul>
 *
 * @author QuyPQ
 */
public class BookingRequest implements Serializable {

    public static final String TYPE_CHANGE = "Change";
    public static final String TYPE_EXTENSION = "Extension";

    private int requestId;
    private int bookingId;
    private int accountId;
    private String requestType;

    private Date oldCheckIn;
    private Date oldCheckOut;
    private Date newCheckIn;
    private Date newCheckOut;
    private Integer newRoomTypeId;
    private Integer newRoomQuantity;
    private Double additionalCharge;
    private String reason;
    private String status;
    private Timestamp createdAt;

    /**
     * Đơn được sinh ra khi yêu cầu thay đổi này được duyệt. Luồng thay đổi
     * không sửa đơn tại chỗ mà tạo đơn mới rồi huỷ đơn cũ, nên mã đơn của khách
     * thay đổi — cả khách lẫn lễ tân cần thấy "#cũ → #mới". Null với yêu cầu
     * gia hạn lưu trú (sửa tại chỗ) và với yêu cầu chưa được duyệt.
     */
    private Integer newBookingId;

    // Display-only fields (joined for the tracking list)
    private String newRoomTypeName;
    private String currentRoomTypeName;

    // Display-only fields for the staff processing list (UC 2.4.5 Process Booking Change)
    private String customerName;
    private String bookingStatus;

    /**
     * Các thao tác trên từng dòng phòng của nhóm (xem {@link BookingRequestItem}).
     * Yêu cầu Change luôn có ít nhất 1 item; yêu cầu Extension không dùng tới.
     */
    private List<BookingRequestItem> items = new ArrayList<>();

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }

    public String getRequestType() { return requestType; }
    public void setRequestType(String requestType) { this.requestType = requestType; }

    public Date getOldCheckIn() { return oldCheckIn; }
    public void setOldCheckIn(Date oldCheckIn) { this.oldCheckIn = oldCheckIn; }

    public Date getOldCheckOut() { return oldCheckOut; }
    public void setOldCheckOut(Date oldCheckOut) { this.oldCheckOut = oldCheckOut; }

    public Date getNewCheckIn() { return newCheckIn; }
    public void setNewCheckIn(Date newCheckIn) { this.newCheckIn = newCheckIn; }

    public Date getNewCheckOut() { return newCheckOut; }
    public void setNewCheckOut(Date newCheckOut) { this.newCheckOut = newCheckOut; }

    public Integer getNewRoomTypeId() { return newRoomTypeId; }
    public void setNewRoomTypeId(Integer newRoomTypeId) { this.newRoomTypeId = newRoomTypeId; }

    public Integer getNewRoomQuantity() { return newRoomQuantity; }
    public void setNewRoomQuantity(Integer newRoomQuantity) { this.newRoomQuantity = newRoomQuantity; }

    public Double getAdditionalCharge() { return additionalCharge; }
    public void setAdditionalCharge(Double additionalCharge) { this.additionalCharge = additionalCharge; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Integer getNewBookingId() { return newBookingId; }
    public void setNewBookingId(Integer newBookingId) { this.newBookingId = newBookingId; }

    public String getNewRoomTypeName() { return newRoomTypeName; }
    public void setNewRoomTypeName(String newRoomTypeName) { this.newRoomTypeName = newRoomTypeName; }

    public String getCurrentRoomTypeName() { return currentRoomTypeName; }
    public void setCurrentRoomTypeName(String currentRoomTypeName) { this.currentRoomTypeName = currentRoomTypeName; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(String bookingStatus) { this.bookingStatus = bookingStatus; }

    public List<BookingRequestItem> getItems() { return items; }
    public void setItems(List<BookingRequestItem> items) {
        this.items = items != null ? items : new ArrayList<>();
    }

    public boolean isExtension() { return TYPE_EXTENSION.equalsIgnoreCase(requestType); }
    public boolean isChange() { return TYPE_CHANGE.equalsIgnoreCase(requestType); }
}
