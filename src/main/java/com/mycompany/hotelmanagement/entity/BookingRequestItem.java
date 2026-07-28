package com.mycompany.hotelmanagement.entity;

import java.io.Serializable;

/**
 * Một thao tác trên MỘT dòng phòng của yêu cầu thay đổi đặt phòng
 * (UC 2.3.9). Đơn đặt phòng nhiều loại phòng gồm 1 dòng Booking cha và N dòng
 * con, nên một yêu cầu thay đổi phải mô tả được nhiều thao tác cùng lúc:
 * <ul>
 *   <li>{@code Update} — đổi loại phòng / số lượng của dòng {@code targetBookingId}</li>
 *   <li>{@code Add}    — thêm một loại phòng mới vào nhóm ({@code targetBookingId} null)</li>
 *   <li>{@code Remove} — bỏ dòng {@code targetBookingId} khỏi nhóm</li>
 * </ul>
 * Các trường {@code old*} là ảnh chụp lúc gửi yêu cầu: lễ tân dùng để đối chiếu,
 * còn hệ thống dùng để phát hiện đơn đã bị sửa bởi luồng khác trước khi duyệt.
 *
 * @author QuyPQ
 */
public class BookingRequestItem implements Serializable {

    public static final String ACTION_UPDATE = "Update";
    public static final String ACTION_ADD = "Add";
    public static final String ACTION_REMOVE = "Remove";

    private int itemId;
    private int requestId;
    private Integer targetBookingId;
    private String action;
    private Integer oldRoomTypeId;
    private Integer oldRoomQuantity;
    private Integer newRoomTypeId;
    private Integer newRoomQuantity;

    // Display-only (joined)
    private String oldRoomTypeName;
    private String newRoomTypeName;

    public BookingRequestItem() {
    }

    public static BookingRequestItem update(int targetBookingId, Integer oldTypeId, Integer oldQty,
            int newTypeId, int newQty) {
        BookingRequestItem i = new BookingRequestItem();
        i.action = ACTION_UPDATE;
        i.targetBookingId = targetBookingId;
        i.oldRoomTypeId = oldTypeId;
        i.oldRoomQuantity = oldQty;
        i.newRoomTypeId = newTypeId;
        i.newRoomQuantity = newQty;
        return i;
    }

    public static BookingRequestItem add(int newTypeId, int newQty) {
        BookingRequestItem i = new BookingRequestItem();
        i.action = ACTION_ADD;
        i.newRoomTypeId = newTypeId;
        i.newRoomQuantity = newQty;
        return i;
    }

    public static BookingRequestItem remove(int targetBookingId, Integer oldTypeId, Integer oldQty) {
        BookingRequestItem i = new BookingRequestItem();
        i.action = ACTION_REMOVE;
        i.targetBookingId = targetBookingId;
        i.oldRoomTypeId = oldTypeId;
        i.oldRoomQuantity = oldQty;
        return i;
    }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public Integer getTargetBookingId() { return targetBookingId; }
    public void setTargetBookingId(Integer targetBookingId) { this.targetBookingId = targetBookingId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public Integer getOldRoomTypeId() { return oldRoomTypeId; }
    public void setOldRoomTypeId(Integer oldRoomTypeId) { this.oldRoomTypeId = oldRoomTypeId; }

    public Integer getOldRoomQuantity() { return oldRoomQuantity; }
    public void setOldRoomQuantity(Integer oldRoomQuantity) { this.oldRoomQuantity = oldRoomQuantity; }

    public Integer getNewRoomTypeId() { return newRoomTypeId; }
    public void setNewRoomTypeId(Integer newRoomTypeId) { this.newRoomTypeId = newRoomTypeId; }

    public Integer getNewRoomQuantity() { return newRoomQuantity; }
    public void setNewRoomQuantity(Integer newRoomQuantity) { this.newRoomQuantity = newRoomQuantity; }

    public String getOldRoomTypeName() { return oldRoomTypeName; }
    public void setOldRoomTypeName(String oldRoomTypeName) { this.oldRoomTypeName = oldRoomTypeName; }

    public String getNewRoomTypeName() { return newRoomTypeName; }
    public void setNewRoomTypeName(String newRoomTypeName) { this.newRoomTypeName = newRoomTypeName; }

    public boolean isAdd() { return ACTION_ADD.equalsIgnoreCase(action); }
    public boolean isRemove() { return ACTION_REMOVE.equalsIgnoreCase(action); }
    public boolean isUpdate() { return ACTION_UPDATE.equalsIgnoreCase(action); }

    /**
     * Dòng được gửi kèm nhưng khách không đổi gì trên nó. Yêu cầu vẫn lưu lại
     * để lúc duyệt áp đúng cấu hình khách đã thấy và để phát hiện đơn bị sửa
     * ngoài luồng, nhưng khi hiển thị thì không cần làm rối mắt.
     */
    public boolean isUnchanged() {
        return isUpdate()
                && oldRoomTypeId != null && oldRoomTypeId.equals(newRoomTypeId)
                && oldRoomQuantity != null && oldRoomQuantity.equals(newRoomQuantity);
    }
}
