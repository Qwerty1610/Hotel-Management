package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.RoomTypeDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRequestItem;
import com.mycompany.hotelmanagement.entity.Promotion;
import com.mycompany.hotelmanagement.entity.RoomInfo;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.entity.CustomerDetails;
import java.sql.Date;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Project: Hotel Management System
 * Class: BookingService
 *
 * Description:
 * Lớp dịch vụ (Service) xử lý logic nghiệp vụ đặt phòng. Xác thực ngày nhận/
 * trả phòng, sức chứa khách, tình trạng phòng trống và các yêu cầu đặc biệt.
 * Tính tổng tiền, áp dụng đặt cọc 30% và ủy quyền lưu trữ cho BookingDAO. Ném
 * ra mã ngoại lệ (MSGxx) khi xác thực thất bại.
 *
 * Related Use Cases:
 * - UC-11 Create Booking (Customer Online)
 * - UC-13 Create Walk-in Booking
 * 
 * Date: 17-06-2026
 * 
 * @author BinhHD, QuyPQ, MinhTDP
 * @version 1.3
 */

public class BookingService {

    private static final Logger LOGGER = Logger.getLogger(BookingService.class.getName());
    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomTypeDAO roomTypeRepository = new RoomTypeDAO();
    private final PromotionService promotionService = new PromotionService();

    /**
     * Creates a new booking with validation. Throws exception with message keys
     * (MSG17, MSG19, MSG20, MSG03, MSG55) if validation fails.
     */
    public boolean createBooking(Booking booking) throws Exception {
        try {
            // 1. Validate inputs
            if (booking == null) {
                throw new Exception("MSG55"); // Unexpected error
            }

            // 2. Validate dates (MSG17)
            Date checkIn = booking.getCheckInDate();
            Date checkOut = booking.getCheckOutDate();
            if (checkIn == null || checkOut == null || !checkIn.before(checkOut)) {
                throw new Exception("MSG17"); // Checkout must be after checkin
            }

            // 3. Validate Special Request length (MSG03)
            if (booking.getNote() != null && booking.getNote().length() > 500) {
                throw new Exception("MSG03"); // Special request too long (max 500)
            }

            long nights = booking.getNights();
            if (nights <= 0) {
                throw new Exception("MSG17");
            }

            // 4. Validate capacity and availability
            RoomTypeInfo rt = roomTypeRepository.getRoomTypeById(booking.getRoomTypeId());
            if (rt == null) {
                throw new Exception("MSG55");
            }

            // Attach room type name
            booking.setRoomTypeName(rt.getTypeName());

            int qty = booking.getRoomQuantity() > 0 ? booking.getRoomQuantity() : 1;

            // Check date-based overlapping availability (MSG19)
            int availableRooms = bookingDAO.checkRoomAvailability(booking.getRoomTypeId(), checkIn, checkOut, null);

            if (qty > availableRooms) {
                throw new Exception("MSG19"); // Rooms not available
            }

            // Calculate total price
            double totalAmount = rt.getBasePrice() * qty * nights;
            booking.setTotalAmount(totalAmount);
            booking.setStatus("Pending"); // Default initial status

            // 5. Call DAO to write Booking
            int bookingId = bookingDAO.createBooking(booking);
            if (bookingId <= 0) {
                throw new Exception("MSG55");
            }
            booking.setBookingId(bookingId);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in createBooking service call", e);
            if (e.getMessage() != null && e.getMessage().startsWith("MSG")) {
                throw e;
            }
            throw new Exception("MSG55", e);
        }
    }

    /**
     * Cancels a booking by customer request.
     */
    public boolean cancelBookingByCustomer(int bookingId, int accountId) throws Exception {
        try {
            Booking b = bookingDAO.getBookingById(bookingId);
            if (b == null) {
                throw new Exception("MSG55");
            }

            // Validate data ownership
            if (b.getAccountId() == null || b.getAccountId() != accountId) {
                throw new Exception("MSG55");
            }

            // Validate status allows cancellation
            String status = b.getStatus();
            if ("CheckedIn".equalsIgnoreCase(status) || "CheckedOut".equalsIgnoreCase(status)
                    || "Rejected".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status)) {
                throw new Exception("MSG55");
            }

            boolean success = bookingDAO.cancelBooking(bookingId, "Huỷ bởi khách hàng");
            if (!success) {
                throw new Exception("MSG55");
            }
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in cancelBookingByCustomer: id=" + bookingId, e);
            if (e.getMessage() != null && e.getMessage().startsWith("MSG")) {
                throw e;
            }
            throw new Exception("MSG55", e);
        }
    }

    public List<Booking> getBookingsByAccount(int accountId, String statusFilter, String keyword) {
        return bookingDAO.getBookingsByAccount(accountId, statusFilter, keyword);
    }

    public Booking getBookingById(int bookingId) {
        return bookingDAO.getBookingById(bookingId);
    }

    public List<Booking> getChildBookings(int parentBookingId) {
        return bookingDAO.getChildBookings(parentBookingId);
    }

    public String getAssignedRoomsForBookingSelf(int bookingId) {
        return bookingDAO.getAssignedRoomsForBookingSelf(bookingId);
    }

    // getBookingRooms removed in simplification
    /**
     * Delegates updateBookingDetails to DAO.
     */
    public boolean updateBookingDetails(Booking booking) {
        return bookingDAO.updateBookingDetails(booking);
    }

    /**
     * Delegates updateBookingStatus to DAO.
     */
    public boolean updateBookingStatus(int bookingId, String newStatus, String note) {
        return bookingDAO.updateBookingStatus(bookingId, newStatus, note);
    }

    /**
     * Delegates cancelBooking to DAO.
     */
    public boolean cancelBooking(int bookingId, String reason) {
        return bookingDAO.cancelBooking(bookingId, reason);
    }

    /**
     * Returns all rooms in the hotel with their type name and current status.
     */
    public List<RoomInfo> getAllRooms(Date checkIn, Date checkOut) {
        return bookingDAO.getAllRooms(checkIn, checkOut);
    }

    /**
     * Returns rooms filtered by room type ID.
     */
    public List<RoomInfo> getRoomsByTypeId(int typeId, Date checkIn, Date checkOut) {
        return bookingDAO.getRoomsByTypeId(typeId, checkIn, checkOut);
    }

    /**
     * Returns rooms already assigned to a specific booking via RoomAssignment.
     */
    public List<RoomInfo> getAssignedRoomsForBooking(int bookingId, Date checkIn, Date checkOut) {
        return bookingDAO.getAssignedRoomsForBooking(bookingId, checkIn, checkOut);
    }

    /**
     * Assigns (or replaces) rooms to a booking in the RoomAssignment table.
     */
    public boolean assignRoomsToBooking(int bookingId, List<Integer> roomIds) {
        return bookingDAO.assignRoomsToBooking(bookingId, roomIds);
    }

    /**
     * Returns customer account details (full name, email, phone) by accountId.
     */
    public CustomerDetails getCustomerDetailsByAccountId(int accountId) {
        return bookingDAO.getCustomerDetailsByAccountId(accountId);
    }

    /**
     * Checks available rooms of a specific type for a date range.
     */
    public int checkRoomAvailability(int roomTypeId, Date checkIn, Date checkOut) {
        return bookingDAO.checkRoomAvailability(roomTypeId, checkIn, checkOut);
    }

    /**
     * Checks if specific rooms conflict with other overlapping assignments.
     */
    public List<Integer> getConflictingRooms(List<Integer> roomIds, Date checkIn, Date checkOut, int excludeBookingId) {
        return bookingDAO.getConflictingRooms(roomIds, checkIn, checkOut, excludeBookingId);
    }



    public double calculateGroupTotalAmount(int parentBookingId) {
        Booking parent = bookingDAO.getBookingById(parentBookingId);
        if (parent == null) {
            return 0;
        }
        long nights = parent.getNights();
        double total = 0;

        RoomTypeInfo parentType = roomTypeRepository.getRoomTypeById(parent.getRoomTypeId());
        if (parentType != null) {
            total += parentType.getBasePrice() * parent.getRoomQuantity();
        }

        List<Booking> children = bookingDAO.getChildBookings(parentBookingId);
        for (Booking child : children) {
            RoomTypeInfo type = roomTypeRepository.getRoomTypeById(child.getRoomTypeId());
            if (type != null) {
                total += type.getBasePrice() * child.getRoomQuantity();
            }
        }
        return total * nights;
    }

    /** Tính subtotal thuần (chưa trừ khuyến mãi) = basePrice x số lượng x số đêm. */
    private double calculateSubtotal(Booking booking) {
        if (booking == null || booking.getRoomTypeId() == null) {
            return 0;
        }
        RoomTypeInfo roomType = roomTypeRepository.getRoomTypeById(booking.getRoomTypeId());
        if (roomType == null) {
            return 0;
        }
        return roomType.getBasePrice()
                * booking.getRoomQuantity()
                * booking.getNights();
    }

    /**
     * Tổng tiền của MỘT booking (đã trừ khuyến mãi nếu có promotion_id).
     * Dùng cho các booking đứng riêng lẻ (không thuộc nhóm) hoặc khi chỉ cần
     * ước tính nhanh; với nhóm booking cha/con, ưu tiên dùng
     * {@link #recalculateGroupAmounts(Booking, List)} để tính đúng theo tổng
     * cả nhóm rồi rải xuống từng booking.
     */
    public double calculateBookingAmount(Booking booking) {
        double subtotal = calculateSubtotal(booking);
        if (booking == null || booking.getPromotionId() == null) {
            return subtotal;
        }
        Promotion promo = promotionService.getPromotionById(booking.getPromotionId());
        if (promo == null) {
            return subtotal;
        }
        double discount = promotionService.calculateDiscountAmount(promo, subtotal);
        return Math.max(0, subtotal - discount);
    }

    /**
     * Tính lại total_amount cho cả nhóm booking (cha + các con) mỗi khi
     * ngày/loại phòng/số lượng thay đổi, GIỮ NGUYÊN mã khuyến mãi đã áp
     * (nếu có) trên booking cha — không bao giờ làm mã giảm giá "biến mất"
     * dù subtotal đổi thế nào. Set totalAmount lên các object truyền vào
     * (in-memory) — người gọi tự lưu DB sau đó.
     */
    public void recalculateGroupAmounts(Booking parent, List<Booking> children) {
        if (parent == null) {
            return;
        }
        if (children == null) {
            children = new ArrayList<>();
        }

        double parentSubtotal = calculateSubtotal(parent);
        List<Double> childSubtotals = new ArrayList<>();
        for (Booking child : children) {
            childSubtotals.add(calculateSubtotal(child));
        }

        Integer promotionId = parent.getPromotionId();
        if (promotionId == null) {
            parent.setTotalAmount(parentSubtotal);
            for (int i = 0; i < children.size(); i++) {
                children.get(i).setTotalAmount(childSubtotals.get(i));
            }
            return;
        }

        Promotion promo = promotionService.getPromotionById(promotionId);
        if (promo == null) {
            parent.setTotalAmount(parentSubtotal);
            for (int i = 0; i < children.size(); i++) {
                children.get(i).setTotalAmount(childSubtotals.get(i));
            }
            return;
        }

        double groupSubtotal = parentSubtotal;
        for (double s : childSubtotals) {
            groupSubtotal += s;
        }
        double totalDiscount = promotionService.calculateDiscountAmount(promo, groupSubtotal);

        double remainingDiscount = totalDiscount;
        remainingDiscount = cascadeOne(parent, parentSubtotal, remainingDiscount);
        for (int i = 0; i < children.size(); i++) {
            remainingDiscount = cascadeOne(children.get(i), childSubtotals.get(i), remainingDiscount);
        }
    }

    /** Trừ (một phần của) discount vào 1 booking, trả về phần discount còn dư. */
    private double cascadeOne(Booking booking, double subtotal, double remainingDiscount) {
        if (remainingDiscount <= 0) {
            booking.setTotalAmount(subtotal);
            return 0;
        }
        if (subtotal >= remainingDiscount) {
            booking.setTotalAmount(subtotal - remainingDiscount);
            return 0;
        }
        booking.setTotalAmount(0);
        return remainingDiscount - subtotal;
    }

    /**
     * Phân bổ số tiền giảm giá vào booking cha (và các booking con nếu có),
     * đồng thời GHI NHỚ promotion_id lên booking cha để lần sau đổi ngày/loại
     * phòng có thể tính lại discount này (xem calculateBookingAmount /
     * recalculateGroupAmounts) thay vì làm mã giảm giá biến mất.
     */
    public void applyDiscountToGroup(int parentBookingId, double totalDiscount, int promotionId, String promoCode) {
        Booking parent = bookingDAO.getBookingById(parentBookingId);
        if (parent == null)
            return;
        List<Booking> children = bookingDAO.getChildBookings(parentBookingId);

        double remainingDiscount = totalDiscount;
        String noteAppend = "[Áp dụng mã: " + promoCode + " - Giảm: " + Math.round(totalDiscount) + " VND]";

        // Trừ ở booking cha trước
        double parentAmount = parent.getTotalAmount();
        if (parentAmount >= remainingDiscount) {
            bookingDAO.updateBookingTotalAmountAndNote(parentBookingId, parentAmount - remainingDiscount, noteAppend);
            remainingDiscount = 0;
        } else {
            bookingDAO.updateBookingTotalAmountAndNote(parentBookingId, 0, noteAppend);
            remainingDiscount -= parentAmount;
        }

        // Nếu còn dư, trừ tiếp ở booking con
        for (Booking child : children) {
            if (remainingDiscount <= 0)
                break;
            double childAmount = child.getTotalAmount();
            if (childAmount >= remainingDiscount) {
                bookingDAO.updateBookingTotalAmountAndNote(child.getBookingId(), childAmount - remainingDiscount,
                        noteAppend);
                remainingDiscount = 0;
            } else {
                bookingDAO.updateBookingTotalAmountAndNote(child.getBookingId(), 0, noteAppend);
                remainingDiscount -= childAmount;
            }
        }

        bookingDAO.updateBookingPromotion(parentBookingId, promotionId);
    }

    // =====================================================================
    // Thay đổi cả nhóm đặt phòng (dùng chung cho UC 2.3.9 và UC 2.4.5)
    // =====================================================================

    /** Một thao tác trên một dòng phòng của nhóm. Xem {@link BookingRequestItem}. */
    public static class ItemChange {
        public String action;
        public Integer targetBookingId;
        public Integer newRoomTypeId;
        public Integer newRoomQuantity;

        public static ItemChange of(String action, Integer targetBookingId,
                Integer newRoomTypeId, Integer newRoomQuantity) {
            ItemChange c = new ItemChange();
            c.action = action;
            c.targetBookingId = targetBookingId;
            c.newRoomTypeId = newRoomTypeId;
            c.newRoomQuantity = newRoomQuantity;
            return c;
        }
    }

    /**
     * Kết quả dựng sẵn của một thay đổi trên cả nhóm: trạng thái các dòng sau
     * thay đổi, nhu cầu phòng gộp theo loại, và chênh lệch tiền. Chỉ tính toán
     * trong bộ nhớ — chưa ghi gì xuống CSDL — nên dùng được cả để xem trước lúc
     * khách gửi yêu cầu lẫn để áp dụng lúc lễ tân duyệt.
     */
    public static class GroupChangePlan {
        /** null nếu hợp lệ; ngược lại là mã lỗi: notfound | stale | empty | invalid_qty | invalid_type */
        public String error;
        public Booking root;
        /** Dòng cha (đã cập nhật) đứng đầu, sau đó là các dòng con còn lại. */
        public List<Booking> updates = new ArrayList<>();
        public List<Booking> inserts = new ArrayList<>();
        public List<Integer> cancelIds = new ArrayList<>();
        public List<Integer> clearAssignmentIds = new ArrayList<>();
        /** Tổng số phòng cần có theo từng loại SAU thay đổi, gộp cả nhóm. */
        public Map<Integer, Integer> desiredByType = new LinkedHashMap<>();
        /** Toàn bộ dòng hiện có của nhóm — tập cần loại khỏi phép đếm phòng trống. */
        public Set<Integer> groupBookingIds = new LinkedHashSet<>();
        /** Có dòng nào đổi loại phòng / số lượng, hoặc có dòng được thêm / bỏ. */
        public boolean configChanged;
        public double oldTotal;
        public double newTotal;

        public boolean isValid() { return error == null; }
        public double getDelta() { return newTotal - oldTotal; }
    }

    /**
     * Dựng kế hoạch thay đổi cho cả nhóm đặt phòng gốc {@code rootBookingId}.
     * <p>
     * Ngày mới (nếu truyền) áp cho MỌI dòng trong nhóm — ngày nhận/trả phòng là
     * thuộc tính của cả đơn, không của từng dòng. Các thao tác loại phòng được
     * áp theo từng dòng. Tổng tiền được tính lại qua
     * {@link #recalculateGroupAmounts(Booking, List)} nên mã khuyến mãi đã áp
     * vẫn được giữ và chỉ bị trừ một lần trên toàn nhóm.
     *
     * @param newCheckIn  ngày nhận phòng mới, null = giữ nguyên
     * @param newCheckOut ngày trả phòng mới, null = giữ nguyên
     * @param items       thao tác trên từng dòng, có thể rỗng (chỉ đổi ngày)
     */
    public GroupChangePlan buildGroupChangePlan(int rootBookingId, Date newCheckIn, Date newCheckOut,
            List<ItemChange> items) {

        GroupChangePlan plan = new GroupChangePlan();

        Booking root = bookingDAO.getBookingById(rootBookingId);
        if (root == null || root.getGroupBookingId() != null) {
            plan.error = "notfound";
            return plan;
        }
        plan.root = root;

        List<Booking> children = bookingDAO.getChildBookings(rootBookingId);
        List<Booking> rows = new ArrayList<>();
        rows.add(root);
        rows.addAll(children);

        Map<Integer, Booking> byId = new LinkedHashMap<>();
        Map<Integer, int[]> originalConfig = new HashMap<>();
        for (Booking b : rows) {
            byId.put(b.getBookingId(), b);
            plan.groupBookingIds.add(b.getBookingId());
            plan.oldTotal += b.getTotalAmount();
            originalConfig.put(b.getBookingId(),
                    new int[] { b.getRoomTypeId() != null ? b.getRoomTypeId() : -1, b.getRoomQuantity() });
        }

        Set<Integer> removedIds = new LinkedHashSet<>();
        List<ItemChange> additions = new ArrayList<>();

        if (items != null) {
            for (ItemChange item : items) {
                if (item == null || item.action == null) {
                    continue;
                }
                if (BookingRequestItem.ACTION_ADD.equalsIgnoreCase(item.action)) {
                    additions.add(item);
                    continue;
                }
                if (item.targetBookingId == null || !byId.containsKey(item.targetBookingId)) {
                    // Dòng đích không còn thuộc nhóm: đơn đã bị sửa sau khi khách gửi
                    plan.error = "stale";
                    return plan;
                }
                if (BookingRequestItem.ACTION_REMOVE.equalsIgnoreCase(item.action)) {
                    removedIds.add(item.targetBookingId);
                } else {
                    Booking target = byId.get(item.targetBookingId);
                    if (item.newRoomTypeId == null || item.newRoomQuantity == null) {
                        plan.error = "invalid_type";
                        return plan;
                    }
                    if (item.newRoomQuantity <= 0 || item.newRoomQuantity > 100) {
                        plan.error = "invalid_qty";
                        return plan;
                    }
                    target.setRoomTypeId(item.newRoomTypeId);
                    target.setRoomQuantity(item.newRoomQuantity);
                }
            }
        }

        // Không cho bỏ hết phòng: đó là huỷ đơn, thuộc luồng khác.
        if (removedIds.size() >= rows.size() && additions.isEmpty()) {
            plan.error = "empty";
            return plan;
        }

        // Dòng cha là điểm neo của cả nhóm (các dòng con trỏ về nó), nên không
        // thể xoá. Khi khách bỏ đúng loại phòng của dòng cha, ta chuyển cấu hình
        // của một dòng còn sống lên dòng cha rồi bỏ dòng đó thay thế — tập loại
        // phòng khách nhận được là như nhau.
        if (removedIds.contains(root.getBookingId())) {
            Booking donor = null;
            for (Booking b : children) {
                if (!removedIds.contains(b.getBookingId())) {
                    donor = b;
                    break;
                }
            }
            if (donor != null) {
                root.setRoomTypeId(donor.getRoomTypeId());
                root.setRoomQuantity(donor.getRoomQuantity());
                removedIds.remove(root.getBookingId());
                removedIds.add(donor.getBookingId());
            } else if (!additions.isEmpty()) {
                ItemChange first = additions.remove(0);
                if (first.newRoomTypeId == null || first.newRoomQuantity == null
                        || first.newRoomQuantity <= 0 || first.newRoomQuantity > 100) {
                    plan.error = "invalid_qty";
                    return plan;
                }
                root.setRoomTypeId(first.newRoomTypeId);
                root.setRoomQuantity(first.newRoomQuantity);
                removedIds.remove(root.getBookingId());
            } else {
                plan.error = "empty";
                return plan;
            }
        }

        // Ngày mới áp cho toàn bộ nhóm
        List<Booking> surviving = new ArrayList<>();
        for (Booking b : rows) {
            if (removedIds.contains(b.getBookingId())) {
                plan.cancelIds.add(b.getBookingId());
                plan.clearAssignmentIds.add(b.getBookingId());
                continue;
            }
            if (newCheckIn != null) {
                b.setCheckInDate(newCheckIn);
            }
            if (newCheckOut != null) {
                b.setCheckOutDate(newCheckOut);
            }
            if (b.getCheckInDate() == null || b.getCheckOutDate() == null
                    || !b.getCheckInDate().before(b.getCheckOutDate())) {
                plan.error = "invalid_dates";
                return plan;
            }
            surviving.add(b);
        }

        for (ItemChange item : additions) {
            if (item.newRoomTypeId == null || item.newRoomQuantity == null
                    || item.newRoomQuantity <= 0 || item.newRoomQuantity > 100) {
                plan.error = "invalid_qty";
                return plan;
            }
            Booking added = new Booking();
            added.setAccountId(root.getAccountId());
            added.setCustomerName(root.getCustomerName());
            added.setPhone(root.getPhone());
            added.setEmail(root.getEmail());
            added.setNote(root.getNote());
            added.setStatus(root.getStatus());
            added.setGroupBookingId(root.getBookingId());
            added.setRoomTypeId(item.newRoomTypeId);
            added.setRoomQuantity(item.newRoomQuantity);
            added.setCheckInDate(newCheckIn != null ? newCheckIn : root.getCheckInDate());
            added.setCheckOutDate(newCheckOut != null ? newCheckOut : root.getCheckOutDate());
            plan.inserts.add(added);
        }

        // Nhu cầu phòng gộp theo loại: phải so với tồn kho theo TỔNG cả nhóm,
        // vì cả nhóm đã bị loại khỏi phép đếm phòng trống.
        List<Booking> allAfter = new ArrayList<>(surviving);
        allAfter.addAll(plan.inserts);
        for (Booking b : allAfter) {
            if (b.getRoomTypeId() == null) {
                plan.error = "invalid_type";
                return plan;
            }
            if (roomTypeRepository.getRoomTypeById(b.getRoomTypeId()) == null) {
                plan.error = "invalid_type";
                return plan;
            }
            plan.desiredByType.merge(b.getRoomTypeId(), b.getRoomQuantity(), Integer::sum);
        }

        // Tính lại tiền cho cả nhóm (giữ nguyên khuyến mãi đã áp trên dòng cha)
        List<Booking> nonRoot = new ArrayList<>(allAfter);
        nonRoot.remove(root);
        recalculateGroupAmounts(root, nonRoot);
        for (Booking b : allAfter) {
            plan.newTotal += b.getTotalAmount();
        }

        plan.updates.addAll(surviving);

        // Xếp phòng: chỉ gỡ những dòng thực sự không còn phù hợp. Dòng giữ
        // nguyên loại/số lượng mà phòng đang xếp không đụng đơn khác trong
        // khoảng ngày mới thì giữ nguyên phòng, khỏi bắt lễ tân xếp lại cả nhóm.
        plan.configChanged = !plan.inserts.isEmpty() || !plan.cancelIds.isEmpty();

        for (Booking b : surviving) {
            int[] before = originalConfig.get(b.getBookingId());
            boolean rowChanged = before == null
                    || before[0] != (b.getRoomTypeId() != null ? b.getRoomTypeId() : -1)
                    || before[1] != b.getRoomQuantity();
            if (rowChanged) {
                plan.configChanged = true;
            }

            List<Integer> assigned = bookingDAO.getAssignedRoomIds(b.getBookingId());
            if (assigned.isEmpty()) {
                continue;
            }
            if (rowChanged) {
                plan.clearAssignmentIds.add(b.getBookingId());
                continue;
            }
            List<Integer> conflicts = bookingDAO.getConflictingRooms(
                    assigned, b.getCheckInDate(), b.getCheckOutDate(), root.getBookingId());
            if (!conflicts.isEmpty()) {
                plan.clearAssignmentIds.add(b.getBookingId());
            }
        }

        return plan;
    }

    /**
     * Kiểm tra tồn kho cho một kế hoạch thay đổi: với từng loại phòng, tổng nhu
     * cầu của cả nhóm phải nằm trong số phòng trống của khoảng ngày mới (đã loại
     * chính các dòng của nhóm này khỏi phép đếm).
     *
     * @return null nếu đủ phòng, ngược lại là id loại phòng thiếu phòng
     */
    public Integer findUnavailableRoomType(GroupChangePlan plan, Date checkIn, Date checkOut) {
        if (plan == null || !plan.isValid()) {
            return null;
        }
        for (Map.Entry<Integer, Integer> e : plan.desiredByType.entrySet()) {
            int available = bookingDAO.checkRoomAvailability(
                    e.getKey(), checkIn, checkOut, plan.groupBookingIds);
            if (e.getValue() > available) {
                return e.getKey();
            }
        }
        return null;
    }

    /**
     * Bản thiết kế của NHÓM ĐƠN MỚI, dựng từ một {@link GroupChangePlan}. Mọi
     * Booking ở đây đều là bản sao chưa có id — không dính gì tới các dòng của
     * đơn cũ, nên đơn cũ vẫn nguyên vẹn nếu transaction thất bại.
     */
    public static class NewGroupDraft {
        public Booking root;
        public List<Booking> children = new ArrayList<>();
        /** null nếu hợp lệ. */
        public String error;
    }

    /**
     * Chuyển một kế hoạch thay đổi thành bản thiết kế nhóm đơn mới.
     * <p>
     * {@code plan.updates.get(0)} luôn là dòng cha: {@link #buildGroupChangePlan}
     * đưa {@code root} vào đầu danh sách dòng rồi mới duyệt tuần tự để dựng
     * {@code surviving}, và khối "donor" đảm bảo dòng cha không bao giờ bị bỏ.
     * {@code plan.cancelIds} / {@code plan.clearAssignmentIds} bị bỏ qua vì cả
     * nhóm cũ sẽ bị huỷ trọn gói kèm gỡ xếp phòng.
     */
    public NewGroupDraft toNewGroupDraft(GroupChangePlan plan, int requestId) {
        NewGroupDraft draft = new NewGroupDraft();
        if (plan == null || !plan.isValid() || plan.updates.isEmpty()) {
            draft.error = "invalid_plan";
            return draft;
        }

        Booking oldRoot = plan.root;
        Booking planRoot = plan.updates.get(0);

        draft.root = copyAsNewRow(planRoot, oldRoot);
        draft.root.setGroupBookingId(null);
        draft.root.setNote(truncateNote(appendLine(oldRoot.getNote(),
                "Tạo từ yêu cầu thay đổi #" + requestId + " (thay cho đơn #"
                        + oldRoot.getBookingId() + ").")));

        for (int i = 1; i < plan.updates.size(); i++) {
            draft.children.add(copyAsNewRow(plan.updates.get(i), oldRoot));
        }
        for (Booking added : plan.inserts) {
            draft.children.add(copyAsNewRow(added, oldRoot));
        }

        List<Booking> all = new ArrayList<>();
        all.add(draft.root);
        all.addAll(draft.children);
        for (Booking b : all) {
            if (b.getRoomTypeId() == null || b.getCheckInDate() == null || b.getCheckOutDate() == null
                    || !b.getCheckInDate().before(b.getCheckOutDate())) {
                draft.error = "invalid_dates";
                return draft;
            }
        }
        return draft;
    }

    /**
     * Sao chép một dòng đã tính toán thành dòng Booking mới ở trạng thái Pending.
     * Các setter của {@link Booking} ném {@link IllegalArgumentException} khi giá
     * trị ngoài miền cho phép; kế hoạch đã chặn từ trước qua {@code invalid_qty}
     * / {@code invalid_dates}, nhưng vẫn ép biên ở đây để một bản ghi bẩn không
     * làm vỡ cả lượt duyệt bằng RuntimeException.
     */
    private Booking copyAsNewRow(Booking src, Booking oldRoot) {
        Booking c = new Booking();
        c.setAccountId(src.getAccountId() != null ? src.getAccountId() : oldRoot.getAccountId());

        String name = firstNonBlank(src.getCustomerName(), oldRoot.getCustomerName(), "Khách hàng");
        c.setCustomerName(name.length() > 100 ? name.substring(0, 100) : name);

        c.setPhone(src.getPhone() != null ? src.getPhone() : oldRoot.getPhone());
        c.setEmail(src.getEmail() != null ? src.getEmail() : oldRoot.getEmail());
        c.setRoomTypeId(src.getRoomTypeId());
        c.setRoomQuantity(Math.max(1, Math.min(100, src.getRoomQuantity())));
        c.setCheckInDate(src.getCheckInDate());
        c.setCheckOutDate(src.getCheckOutDate());
        c.setTotalAmount(Math.max(0, src.getTotalAmount()));
        // Đơn thay thế luôn quay về đầu quy trình: nó chưa được xếp phòng nên
        // phải đi qua màn hình xử lý đặt phòng của lễ tân một lần nữa.
        c.setStatus("Pending");
        c.setNote(truncateNote(src.getNote()));
        // Cố tình không sao chép groupBookingId: nó còn trỏ vào nhóm cũ, và
        // applyChangeAsNewBooking mới là chỗ quyết định dòng nào là cha.
        return c;
    }

    private String firstNonBlank(String... values) {
        for (String v : values) {
            if (v != null && !v.trim().isEmpty()) {
                return v.trim();
            }
        }
        return "Khách hàng";
    }

    private String appendLine(String base, String line) {
        if (base == null || base.trim().isEmpty()) {
            return line;
        }
        return base.trim() + System.lineSeparator() + line;
    }

    /**
     * Cột {@code note} là NVARCHAR(500) và một đơn có thể bị đổi nhiều lần nên
     * ghi chú tích tụ; tràn sẽ ném SQLException và làm rollback cả lượt duyệt.
     */
    private String truncateNote(String note) {
        if (note == null) {
            return null;
        }
        return note.length() > 500 ? note.substring(0, 500) : note;
    }

    /**
     * Duyệt một yêu cầu thay đổi theo mô hình đơn thay thế: tạo nhóm đơn mới
     * (Pending) mang cấu hình đích, chuyển tiền cọc và hoá đơn sang, rồi huỷ
     * nhóm cũ — tất cả trong một transaction.
     *
     * @return booking_id của đơn mới, {@link BookingDAO#CHANGE_ERR_INVOICE_LOCKED}
     *         nếu hoá đơn đang hoàn tiền, hoặc -1 nếu thất bại
     */
    public int applyChangeAsNewGroup(GroupChangePlan plan, int requestId) {
        if (plan == null || !plan.isValid()) {
            return -1;
        }
        NewGroupDraft draft = toNewGroupDraft(plan, requestId);
        if (draft.error != null) {
            LOGGER.log(Level.WARNING, "Cannot build replacement group for request {0}: {1}",
                    new Object[] { requestId, draft.error });
            return -1;
        }
        return bookingDAO.applyChangeAsNewBooking(
                draft.root,
                draft.children,
                plan.root.getBookingId(),
                plan.root.getPromotionId(),
                requestId,
                "Đã thay bằng đơn mới theo yêu cầu thay đổi #" + requestId + ".");
    }

    /**
     * Ghi kế hoạch xuống CSDL trong một transaction, đồng thời chuyển yêu cầu
     * sang Approved nếu {@code requestId > 0}.
     * <p>
     * Chỉ còn phục vụ luồng <b>gia hạn lưu trú</b> (khách đang ở trong phòng nên
     * phải sửa tại chỗ) và lễ tân sửa đơn trực tiếp. Luồng thay đổi đặt phòng
     * dùng {@link #applyChangeAsNewGroup}.
     */
    public boolean applyGroupChangePlan(GroupChangePlan plan, int requestId) {
        if (plan == null || !plan.isValid()) {
            return false;
        }
        return bookingDAO.applyGroupChange(plan.updates, plan.inserts,
                plan.cancelIds, plan.clearAssignmentIds, requestId);
    }

    /** Id các phòng vật lý đang xếp cho một dòng booking. */
    public List<Integer> getAssignedRoomIds(int bookingId) {
        return bookingDAO.getAssignedRoomIds(bookingId);
    }

    /**
     * Số phòng trống của một loại phòng, loại {@code excludeBookingIds} khỏi
     * phép đếm. Xem {@link BookingDAO#checkRoomAvailability(int, Date, Date, java.util.Collection)}.
     */
    public int checkRoomAvailability(int roomTypeId, Date checkIn, Date checkOut,
            java.util.Collection<Integer> excludeBookingIds) {
        return bookingDAO.checkRoomAvailability(roomTypeId, checkIn, checkOut, excludeBookingIds);
    }
}
