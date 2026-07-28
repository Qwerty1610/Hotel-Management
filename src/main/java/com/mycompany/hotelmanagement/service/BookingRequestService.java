package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.BookingDAO;
import com.mycompany.hotelmanagement.dal.BookingRequestDAO;
import com.mycompany.hotelmanagement.dal.RoomTypeDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.BookingRequest;
import com.mycompany.hotelmanagement.entity.BookingRequestItem;
import com.mycompany.hotelmanagement.entity.RoomTypeInfo;
import com.mycompany.hotelmanagement.service.BookingService.GroupChangePlan;
import com.mycompany.hotelmanagement.service.BookingService.ItemChange;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Business logic for the two customer self-service booking requests:
 * <ul>
 *   <li>UC 2.3.9  Request Booking Change</li>
 *   <li>UC 2.3.14 Request Stay Extension</li>
 * </ul>
 * Each method validates per the use case and creates a Pending request that
 * Reception/Manager can later review. Validation returns short result codes
 * (MSGxx / NOT_ELIGIBLE) that the controller maps to user-facing messages.
 * <p>
 * <b>Đơn vị nghiệp vụ ở đây luôn là cả NHÓM đặt phòng</b> (dòng Booking cha +
 * các dòng con của một đơn nhiều loại phòng), không phải một dòng Booking đơn
 * lẻ. Khách gửi id nào thì cũng được quy về dòng cha, mọi kiểm tra tồn kho và
 * tính tiền đều làm trên tổng của cả nhóm, và thay đổi được áp cho mọi dòng
 * trong một transaction.
 *
 * @author QuyPQ
 * date: 12/07/2026
 * version: 2.0
 */
public class BookingRequestService {

    private static final Logger LOGGER = Logger.getLogger(BookingRequestService.class.getName());

    private final BookingRequestDAO requestDAO = new BookingRequestDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomTypeDAO roomTypeRepository = new RoomTypeDAO();
    private final BookingService bookingService = new BookingService();

    /** Outcome of a request operation: a result code plus any computed charge. */
    public static class Result {
        public final String code;
        /**
         * Chênh lệch tiền của yêu cầu: dương là khách phải trả thêm, âm là
         * khách được hoàn lại. Với yêu cầu gia hạn thì luôn dương.
         */
        public final double additionalCharge;

        /**
         * Khi thiếu phòng (MSG16): loại phòng nào thiếu, khách xin bao nhiêu và
         * thực tế còn bao nhiêu. Báo "hết phòng" chung chung thì khách không
         * biết phải sửa dòng nào.
         */
        public Integer shortRoomTypeId;
        public int requestedRooms;
        public int availableRooms;

        public Result(String code) { this(code, 0); }
        public Result(String code, double additionalCharge) {
            this.code = code;
            this.additionalCharge = additionalCharge;
        }

        static Result outOfRooms(int roomTypeId, int requested, int available) {
            Result r = new Result("MSG16");
            r.shortRoomTypeId = roomTypeId;
            r.requestedRooms = requested;
            r.availableRooms = available;
            return r;
        }

        public boolean isSuccess() { return code != null && code.startsWith("MSG2"); }
    }

    public List<BookingRequest> getRequestsByAccount(int accountId) {
        return requestDAO.getRequestsByAccount(accountId);
    }

    // =====================================================================
    // UC 2.4.5 Process Booking Change (Receptionist)
    // =====================================================================

    public List<BookingRequest> getRequestsForStaff(String statusFilter, String keyword, int offset, int limit) {
        return requestDAO.getRequestsForStaff(statusFilter, keyword, offset, limit);
    }

    public int countRequestsForStaff(String statusFilter, String keyword) {
        return requestDAO.countRequestsForStaff(statusFilter, keyword);
    }

    /**
     * Approves a pending request and applies it to the whole booking group:
     * <ul>
     *   <li>Change    — tạo một nhóm đơn MỚI (Pending) mang ngày/loại phòng/số
     *                   lượng khách yêu cầu, chuyển tiền cọc sang, rồi huỷ nhóm
     *                   cũ. Mã đơn của khách vì thế thay đổi.</li>
     *   <li>Extension — sửa tại chỗ: dời ngày trả phòng của mọi dòng đang lưu
     *                   trú, giữ nguyên mã đơn và phòng đang ở.</li>
     * </ul>
     * Điều kiện và tồn kho được kiểm tra LẠI tại thời điểm duyệt (dữ liệu có thể
     * đã đổi kể từ lúc khách gửi), sau đó toàn bộ thay đổi cùng việc chuyển
     * trạng thái yêu cầu được ghi trong một transaction.
     *
     * @return null on success, or an error code:
     *         notfound | not_pending | not_eligible | no_room | stale |
     *         invoice_locked | unknown
     */
    public String approveRequest(int requestId) {
        try {
            BookingRequest req = requestDAO.getRequestById(requestId);
            if (req == null) {
                return "notfound";
            }
            if (!"Pending".equalsIgnoreCase(req.getStatus())) {
                return "not_pending";
            }
            Booking root = resolveRoot(req.getBookingId());
            if (root == null) {
                return "notfound";
            }

            if (req.isChange()) {
                return approveChange(req, root);
            }
            if (req.isExtension()) {
                return approveExtension(req, root);
            }
            return "unknown";
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error approving request " + requestId, e);
            return "unknown";
        }
    }

    private String approveChange(BookingRequest req, Booking root) {
        String status = root.getStatus();
        boolean eligible = "Pending".equalsIgnoreCase(status) || "Confirmed".equalsIgnoreCase(status);
        if (!eligible || req.getNewCheckIn() == null || req.getNewCheckOut() == null) {
            return "not_eligible";
        }
        // Yêu cầu đã quá hạn: ngày nhận phòng mới nằm trong quá khứ
        if (req.getNewCheckIn().toLocalDate().isBefore(LocalDate.now())) {
            return "not_eligible";
        }

        List<ItemChange> items = toItemChanges(req);
        String stale = checkNotStale(req, root);
        if (stale != null) {
            return stale;
        }

        GroupChangePlan plan = bookingService.buildGroupChangePlan(
                root.getBookingId(), req.getNewCheckIn(), req.getNewCheckOut(), items);
        if (!plan.isValid()) {
            return "stale".equals(plan.error) ? "stale" : "not_eligible";
        }

        // Kiểm tra lại tồn kho theo tổng nhu cầu của cả nhóm. Nhóm cũ được loại
        // khỏi phép đếm (plan.groupBookingIds) — đúng cả với mô hình đơn thay
        // thế, vì nhóm cũ sẽ bị huỷ ngay trong cùng transaction.
        if (bookingService.findUnavailableRoomType(plan, req.getNewCheckIn(), req.getNewCheckOut()) != null) {
            return "no_room";
        }

        // Thay đổi đặt phòng KHÔNG sửa đơn tại chỗ: tạo một nhóm đơn mới mang
        // cấu hình khách yêu cầu rồi huỷ nhóm cũ, để mỗi lần thay đổi để lại
        // một bản ghi đơn riêng tra soát được.
        int newRootId = bookingService.applyChangeAsNewGroup(plan, req.getRequestId());
        if (newRootId > 0) {
            return null;
        }
        return newRootId == BookingDAO.CHANGE_ERR_INVOICE_LOCKED ? "invoice_locked" : "unknown";
    }

    private String approveExtension(BookingRequest req, Booking root) {
        if (!"CheckedIn".equalsIgnoreCase(root.getStatus())
                || req.getNewCheckOut() == null || root.getCheckOutDate() == null
                || !root.getCheckOutDate().before(req.getNewCheckOut())) {
            return "not_eligible";
        }

        Date currentCheckOut = root.getCheckOutDate();
        List<Booking> rows = groupRows(root);

        // Tồn kho cho các đêm gia hạn, theo tổng nhu cầu của cả nhóm
        GroupChangePlan plan = bookingService.buildGroupChangePlan(
                root.getBookingId(), null, req.getNewCheckOut(), new ArrayList<>());
        if (!plan.isValid()) {
            return "not_eligible";
        }
        if (bookingService.findUnavailableRoomType(plan, currentCheckOut, req.getNewCheckOut()) != null) {
            return "no_room";
        }
        // BR-41 — phòng vật lý đang ở đã bị đơn khác đặt cho các đêm gia hạn
        if (hasRoomConflictForExtension(rows, root.getBookingId(), currentCheckOut, req.getNewCheckOut())) {
            return "no_room";
        }

        // Gia hạn thì khách đang thực sự ở trong phòng: giữ nguyên xếp phòng.
        // Các đêm ở thêm vừa được kiểm tra là trống ngay phía trên; nếu kế hoạch
        // có phát hiện chồng lấn thì đó nằm ở phần đêm khách đã nhận phòng —
        // một bất thường dữ liệu, không phải lý do để đuổi khách khỏi phòng.
        plan.clearAssignmentIds.clear();

        return bookingService.applyGroupChangePlan(plan, req.getRequestId()) ? null : "unknown";
    }

    /**
     * Rejects a pending request. The booking itself is left untouched.
     *
     * @return null on success, or an error code: notfound | not_pending | unknown
     */
    public String rejectRequest(int requestId) {
        try {
            BookingRequest req = requestDAO.getRequestById(requestId);
            if (req == null) {
                return "notfound";
            }
            if (!"Pending".equalsIgnoreCase(req.getStatus())) {
                return "not_pending";
            }
            return requestDAO.updateStatus(requestId, "Rejected") ? null : "unknown";
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error rejecting request " + requestId, e);
            return "unknown";
        }
    }

    /**
     * UC 2.3.9 — create a booking-change request for a whole booking group.
     * Eligible only for the customer's own Pending/Confirmed booking before check-in.
     *
     * @param items thao tác trên từng dòng phòng của nhóm (Update / Add / Remove);
     *              rỗng nghĩa là chỉ đổi ngày, giữ nguyên cấu hình phòng
     */
    public Result requestBookingChange(int accountId, int bookingId, String newCheckInStr,
            String newCheckOutStr, List<ItemChange> items, String reason) {
        try {
            Booking root = resolveRoot(bookingId);
            if (root == null || root.getAccountId() == null || root.getAccountId() != accountId) {
                return new Result("MSG55");
            }

            // E1 — eligible status only (not CheckedIn / CheckedOut / Cancelled / Rejected)
            String status = root.getStatus();
            boolean eligible = "Pending".equalsIgnoreCase(status) || "Confirmed".equalsIgnoreCase(status);
            if (!eligible) {
                return new Result("NOT_ELIGIBLE");
            }
            // PRE-3 — change window still open (before the original check-in date)
            if (root.getCheckInDate() != null
                    && !LocalDate.now().isBefore(root.getCheckInDate().toLocalDate())) {
                return new Result("NOT_ELIGIBLE");
            }
            // Mỗi đơn chỉ được có một yêu cầu chờ duyệt tại một thời điểm
            if (requestDAO.hasPendingRequest(root.getBookingId())) {
                return new Result("PENDING_EXISTS");
            }

            // AF-1 — required fields
            if (isBlank(newCheckInStr) || isBlank(newCheckOutStr)) {
                return new Result("MSG02");
            }
            if (reason != null && reason.length() > 500) {
                return new Result("MSG03");
            }

            Date newCheckIn = parseDate(newCheckInStr);
            Date newCheckOut = parseDate(newCheckOutStr);
            if (newCheckIn == null || newCheckOut == null) {
                return new Result("MSG02");
            }

            // E2 — checkout must be after checkin; new check-in must not be in the past
            if (!newCheckIn.before(newCheckOut) || newCheckIn.toLocalDate().isBefore(LocalDate.now())) {
                return new Result("MSG17");
            }

            // Ảnh chụp ngày cũ trước khi dựng kế hoạch: buildGroupChangePlan nạp
            // lại đơn và ghi ngày mới lên bản sao của nó.
            Date oldCheckIn = root.getCheckInDate();
            Date oldCheckOut = root.getCheckOutDate();

            GroupChangePlan plan = bookingService.buildGroupChangePlan(
                    root.getBookingId(), newCheckIn, newCheckOut, items);
            if (!plan.isValid()) {
                return new Result(mapPlanError(plan.error));
            }
            if (isNoOp(plan, oldCheckIn, oldCheckOut, newCheckIn, newCheckOut)) {
                return new Result("NO_CHANGE");
            }

            // AF-2 — tồn kho cho lựa chọn mới. Cả nhóm được loại khỏi phép đếm
            // nên phải so với TỔNG nhu cầu của nhóm theo từng loại phòng: so
            // theo từng dòng sẽ bỏ sót phần phòng các dòng khác đang giữ.
            Integer shortType = bookingService.findUnavailableRoomType(plan, newCheckIn, newCheckOut);
            if (shortType != null) {
                return Result.outOfRooms(shortType,
                        plan.desiredByType.getOrDefault(shortType, 0),
                        bookingService.checkRoomAvailability(shortType, newCheckIn, newCheckOut,
                                plan.groupBookingIds));
            }

            BookingRequest r = new BookingRequest();
            r.setBookingId(root.getBookingId());
            r.setAccountId(accountId);
            r.setRequestType(BookingRequest.TYPE_CHANGE);
            r.setOldCheckIn(root.getCheckInDate());
            r.setOldCheckOut(root.getCheckOutDate());
            r.setNewCheckIn(newCheckIn);
            r.setNewCheckOut(newCheckOut);
            r.setReason(reason);
            r.setStatus("Pending");
            r.setAdditionalCharge(plan.getDelta());
            r.setItems(toRequestItems(plan, items));
            applyLegacySingleRoomFields(r, plan);

            int id = requestDAO.create(r);
            if (id <= 0) {
                return new Result("MSG55");
            }
            return new Result("MSG22", plan.getDelta());
        } catch (NumberFormatException e) {
            return new Result("MSG02");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in requestBookingChange", e);
            return new Result("MSG55");
        }
    }

    /**
     * UC 2.3.14 — create a stay-extension request (later check-out) for the whole
     * group. Eligible only for the customer's own CheckedIn booking.
     * <p>
     * Phụ phí tính trên MỌI dòng phòng của đơn: một đơn 2 Deluxe + 3 Suite ở
     * thêm 2 đêm phải trả tiền cho cả 5 phòng, không phải chỉ dòng cha.
     */
    public Result requestStayExtension(int accountId, int bookingId, String newCheckOutStr, String reason) {
        try {
            Booking root = resolveRoot(bookingId);
            if (root == null || root.getAccountId() == null || root.getAccountId() != accountId) {
                return new Result("MSG55");
            }

            // E1 — only an active (CheckedIn) stay can be extended
            if (!"CheckedIn".equalsIgnoreCase(root.getStatus())) {
                return new Result("NOT_ELIGIBLE");
            }
            if (requestDAO.hasPendingRequest(root.getBookingId())) {
                return new Result("PENDING_EXISTS");
            }

            // AF-2 — new date required
            if (isBlank(newCheckOutStr)) {
                return new Result("MSG02");
            }
            if (reason != null && reason.length() > 500) {
                return new Result("MSG03");
            }

            Date newCheckOut = parseDate(newCheckOutStr);
            Date currentCheckOut = root.getCheckOutDate();
            if (newCheckOut == null || currentCheckOut == null) {
                return new Result("MSG02");
            }

            // E2 — new check-out must be strictly later than the current check-out
            if (!currentCheckOut.before(newCheckOut)) {
                return new Result("MSG17");
            }

            List<Booking> rows = groupRows(root);

            // AF-1 — tồn kho cho các đêm ở thêm, theo tổng nhu cầu cả nhóm
            GroupChangePlan plan = bookingService.buildGroupChangePlan(
                    root.getBookingId(), null, newCheckOut, new ArrayList<>());
            if (!plan.isValid()) {
                return new Result(mapPlanError(plan.error));
            }
            if (bookingService.findUnavailableRoomType(plan, currentCheckOut, newCheckOut) != null) {
                return new Result("MSG16");
            }

            // E2 / BR-41 — phòng cụ thể khách đang ở đã bị đơn khác đặt cho các
            // đêm gia hạn (dù loại phòng vẫn còn phòng trống khác) -> chặn gửi.
            if (hasRoomConflictForExtension(rows, root.getBookingId(), currentCheckOut, newCheckOut)) {
                return new Result("ROOM_TAKEN");
            }

            double additionalCharge = calculateExtensionCharge(rows, currentCheckOut, newCheckOut);
            if (additionalCharge < 0) {
                return new Result("MSG55");
            }

            BookingRequest r = new BookingRequest();
            r.setBookingId(root.getBookingId());
            r.setAccountId(accountId);
            r.setRequestType(BookingRequest.TYPE_EXTENSION);
            r.setOldCheckIn(root.getCheckInDate());
            r.setOldCheckOut(currentCheckOut);
            r.setNewCheckOut(newCheckOut);
            r.setAdditionalCharge(additionalCharge);
            r.setReason(reason);
            r.setStatus("Pending");

            int id = requestDAO.create(r);
            if (id <= 0) {
                return new Result("MSG55");
            }
            return new Result("MSG23", additionalCharge);
        } catch (NumberFormatException e) {
            return new Result("MSG02");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in requestStayExtension", e);
            return new Result("MSG55");
        }
    }

    // =====================================================================
    // Helpers
    // =====================================================================

    /**
     * Quy một id đặt phòng bất kỳ về dòng cha của nhóm. Khách chỉ nhìn thấy mã
     * đơn (dòng cha), nhưng các liên kết cũ hoặc dữ liệu seed có thể trỏ vào
     * dòng con.
     */
    private Booking resolveRoot(int bookingId) {
        Booking b = bookingDAO.getBookingById(bookingId);
        if (b == null) {
            return null;
        }
        if (b.getGroupBookingId() == null) {
            return b;
        }
        return bookingDAO.getBookingById(b.getGroupBookingId());
    }

    /** Dòng cha cùng toàn bộ dòng con còn hiệu lực của nhóm. */
    private List<Booking> groupRows(Booking root) {
        List<Booking> rows = new ArrayList<>();
        rows.add(root);
        rows.addAll(bookingDAO.getChildBookings(root.getBookingId()));
        return rows;
    }

    /** Phụ phí gia hạn = tổng (giá loại phòng × số phòng) của cả nhóm × số đêm thêm. */
    private double calculateExtensionCharge(List<Booking> rows, Date currentCheckOut, Date newCheckOut) {
        long extraNights = (newCheckOut.getTime() - currentCheckOut.getTime()) / (1000L * 60 * 60 * 24);
        if (extraNights <= 0) {
            return -1;
        }
        double perNight = 0;
        for (Booking b : rows) {
            if (b.getRoomTypeId() == null) {
                return -1;
            }
            RoomTypeInfo rt = roomTypeRepository.getRoomTypeById(b.getRoomTypeId());
            if (rt == null) {
                return -1;
            }
            int qty = b.getRoomQuantity() > 0 ? b.getRoomQuantity() : 1;
            perNight += rt.getBasePrice() * qty;
        }
        return perNight * extraNights;
    }

    /**
     * BR-41 — kiểm tra xung đột PHÒNG VẬT LÝ khi gia hạn trên MỌI dòng của nhóm:
     * một trong các phòng đã gán (RoomAssignment) có bị booking khác (Pending /
     * Confirmed / CheckedIn) đặt trong khoảng [from, to) hay không. Kiểm tra
     * theo loại phòng không phát hiện được trường hợp lễ tân đã gán đúng căn
     * phòng khách đang ở cho một đơn khác ngay sau ngày trả hiện tại.
     */
    private boolean hasRoomConflictForExtension(List<Booking> rows, int rootBookingId, Date from, Date to) {
        List<Integer> roomIds = new ArrayList<>();
        for (Booking b : rows) {
            roomIds.addAll(bookingDAO.getAssignedRoomIds(b.getBookingId()));
        }
        if (roomIds.isEmpty()) {
            return false;
        }
        return !bookingDAO.getConflictingRooms(roomIds, from, to, rootBookingId).isEmpty();
    }

    /** Chuyển chi tiết yêu cầu đã lưu thành thao tác để dựng lại kế hoạch lúc duyệt. */
    private List<ItemChange> toItemChanges(BookingRequest req) {
        List<ItemChange> items = new ArrayList<>();
        for (BookingRequestItem i : req.getItems()) {
            items.add(ItemChange.of(i.getAction(), i.getTargetBookingId(),
                    i.getNewRoomTypeId(), i.getNewRoomQuantity()));
        }
        // Dữ liệu cũ (trước khi có bảng chi tiết) chỉ có một cặp loại/số lượng
        // áp cho dòng cha — vẫn duyệt được để không kẹt các yêu cầu đang chờ.
        if (items.isEmpty() && req.getNewRoomTypeId() != null && req.getNewRoomQuantity() != null) {
            items.add(ItemChange.of(BookingRequestItem.ACTION_UPDATE, req.getBookingId(),
                    req.getNewRoomTypeId(), req.getNewRoomQuantity()));
        }
        return items;
    }

    /**
     * Yêu cầu đã "ôi" chưa: đơn có bị sửa (bởi lễ tân hoặc luồng khác) kể từ lúc
     * khách gửi không. Nếu có, lễ tân đang nhìn thông tin so sánh không còn đúng
     * nên phải xem lại thay vì duyệt mù.
     */
    private String checkNotStale(BookingRequest req, Booking root) {
        Set<Integer> currentIds = new LinkedHashSet<>();
        for (Booking b : groupRows(root)) {
            currentIds.add(b.getBookingId());
        }
        for (BookingRequestItem i : req.getItems()) {
            if (i.isAdd()) {
                continue;
            }
            if (i.getTargetBookingId() == null || !currentIds.contains(i.getTargetBookingId())) {
                return "stale";
            }
            Booking target = bookingDAO.getBookingById(i.getTargetBookingId());
            if (target == null) {
                return "stale";
            }
            boolean typeChanged = i.getOldRoomTypeId() != null
                    && !i.getOldRoomTypeId().equals(target.getRoomTypeId());
            boolean qtyChanged = i.getOldRoomQuantity() != null
                    && i.getOldRoomQuantity() != target.getRoomQuantity();
            if (typeChanged || qtyChanged) {
                return "stale";
            }
        }
        return null;
    }

    /** Ảnh chụp thao tác để lưu kèm yêu cầu (kể cả các dòng khách không đụng tới). */
    private List<BookingRequestItem> toRequestItems(GroupChangePlan plan, List<ItemChange> items) {
        List<BookingRequestItem> result = new ArrayList<>();
        if (items == null) {
            return result;
        }
        for (ItemChange c : items) {
            if (c == null || c.action == null) {
                continue;
            }
            if (BookingRequestItem.ACTION_ADD.equalsIgnoreCase(c.action)) {
                result.add(BookingRequestItem.add(c.newRoomTypeId, c.newRoomQuantity));
                continue;
            }
            Booking before = bookingDAO.getBookingById(c.targetBookingId);
            Integer oldType = before != null ? before.getRoomTypeId() : null;
            Integer oldQty = before != null ? before.getRoomQuantity() : null;
            if (BookingRequestItem.ACTION_REMOVE.equalsIgnoreCase(c.action)) {
                result.add(BookingRequestItem.remove(c.targetBookingId, oldType, oldQty));
            } else {
                result.add(BookingRequestItem.update(c.targetBookingId, oldType, oldQty,
                        c.newRoomTypeId, c.newRoomQuantity));
            }
        }
        return result;
    }

    /**
     * Đơn chỉ có một loại phòng thì vẫn ghi vào hai cột cũ của bảng yêu cầu, để
     * các màn hình đang đọc {@code new_room_type_id / new_room_quantity} hiển
     * thị đúng mà không phải sửa.
     */
    private void applyLegacySingleRoomFields(BookingRequest r, GroupChangePlan plan) {
        if (plan.desiredByType.size() != 1) {
            return;
        }
        Map.Entry<Integer, Integer> only = plan.desiredByType.entrySet().iterator().next();
        r.setNewRoomTypeId(only.getKey());
        r.setNewRoomQuantity(only.getValue());
    }

    /** Yêu cầu không thay đổi gì so với hiện trạng thì không đáng để lễ tân duyệt. */
    private boolean isNoOp(GroupChangePlan plan, Date oldCheckIn, Date oldCheckOut,
            Date newCheckIn, Date newCheckOut) {
        boolean datesSame = newCheckIn.equals(oldCheckIn) && newCheckOut.equals(oldCheckOut);
        return datesSame && !plan.configChanged;
    }

    private String mapPlanError(String planError) {
        if (planError == null) {
            return "MSG55";
        }
        switch (planError) {
            case "empty":
                return "EMPTY_GROUP";
            case "stale":
                return "STALE";
            case "invalid_dates":
                return "MSG17";
            case "invalid_qty":
            case "invalid_type":
                return "MSG02";
            default:
                return "MSG55";
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private Date parseDate(String s) {
        try {
            return Date.valueOf(s.trim());
        } catch (Exception e) {
            return null;
        }
    }
}
