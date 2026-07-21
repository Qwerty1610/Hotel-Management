package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.config.ConfigUtil;
import com.mycompany.hotelmanagement.dal.InvoiceDAO;
import com.mycompany.hotelmanagement.dal.PaymentDAO;
import com.mycompany.hotelmanagement.entity.Booking;
import com.mycompany.hotelmanagement.entity.Invoice;
import com.mycompany.hotelmanagement.entity.Payment;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * PaymentService
 * Nghiệp vụ thanh toán online qua SePay cho Customer:
 * - Make Online Payment: sinh mã VietQR (qr.sepay.vn) cho hóa đơn Pending,
 *   nhận webhook tiền vào từ SePay, khớp nội dung chuyển khoản HD{invoiceId},
 *   ghi nhận giao dịch và tất toán hóa đơn khi đủ tiền.
 * - View Payment History: danh sách giao dịch đã thanh toán của khách.
 *
 * Số tiền phải trả = Tổng hóa đơn − Tiền cọc (30% tiền phòng, coi như đã trả
 * khi đặt) − Đã hoàn − Đã thanh toán online trước đó.
 *
 * Date: 08/7/2026
 * @author Pham Quoc Quy
 * version: 1.0
 */
public class PaymentService {

    /** Kết quả xử lý một webhook tiền vào (để log / trả lời SePay). */
    public enum WebhookResult {
        MATCHED_PAID,        // khớp hóa đơn, đủ tiền -> Paid
        MATCHED_PARTIAL,     // khớp hóa đơn, chưa đủ tiền
        MATCHED_DEPOSIT,     // khớp tiền cọc đặt phòng, đã ghi nhận
        DUPLICATE,           // giao dịch đã xử lý trước đó
        NO_INVOICE_CODE,     // nội dung CK không chứa mã hóa đơn / mã đặt phòng
        INVOICE_NOT_PAYABLE, // hóa đơn / đặt phòng không tồn tại hoặc không hợp lệ
        ERROR
    }

    /** Tỷ lệ tiền cọc trên tổng tiền phòng (đồng bộ với deposit_amount 30% của InvoiceDAO). */
    public static final double DEPOSIT_RATE = 0.3;

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    /**
     * Một đặt phòng đang chờ thanh toán cọc (dòng hiển thị trên trang Thanh toán).
     * Gói Booking kèm số tiền cọc phải trả và số đã chuyển.
     */
    public static class DepositItem {
        private final Booking booking;
        private final double depositAmount;
        private final double paidAmount;

        public DepositItem(Booking booking, double depositAmount, double paidAmount) {
            this.booking = booking;
            this.depositAmount = depositAmount;
            this.paidAmount = paidAmount;
        }

        public Booking getBooking()       { return booking; }
        public double getDepositAmount()  { return depositAmount; }
        public double getPaidAmount()     { return paidAmount; }
        public double getRemainingAmount() {
            double r = depositAmount - paidAmount;
            return r > 0 ? r : 0;
        }
        /** Đã chuyển đủ cọc — chờ lễ tân xác nhận. */
        public boolean isFullyPaid()      { return getRemainingAmount() <= 0.01; }
    }

    /* ---------- Cấu hình SePay ---------- */

    public String getBankAccount()   { return ConfigUtil.get("sepay.bank.account", ""); }
    public String getBankCode()      { return ConfigUtil.get("sepay.bank.code", ""); }
    public String getAccountHolder() { return ConfigUtil.get("sepay.account.holder", ""); }
    public String getPrefix()        { return ConfigUtil.get("sepay.payment.prefix", "HD"); }
    public String getDepositPrefix() { return ConfigUtil.get("sepay.deposit.prefix", "COC"); }
    public String getWebhookApiKey() { return ConfigUtil.get("sepay.webhook.apikey", ""); }

    /** Nội dung chuyển khoản định danh hóa đơn, vd "HD123". */
    public String buildTransferContent(int invoiceId) {
        return getPrefix() + invoiceId;
    }

    /** Nội dung chuyển khoản định danh tiền cọc đặt phòng, vd "COC45". */
    public String buildDepositTransferContent(int bookingId) {
        return getDepositPrefix() + bookingId;
    }

    /**
     * URL ảnh VietQR nhúng theo mẫu SePay cung cấp (mục "Mã nhúng QR" trên
     * my.sepay.vn), chèn thẳng vào thẻ img. Có thêm amount + des để app
     * ngân hàng tự điền số tiền và nội dung chuyển khoản.
     * amount làm tròn về VND nguyên vì app ngân hàng không nhận số lẻ.
     */
    public String buildQrUrl(String transferContent, double amount) {
        StringBuilder url = new StringBuilder("https://vietqr.app/img")
                .append("?bank=").append(encode(getBankCode()))
                .append("&acc=").append(encode(getBankAccount()))
                .append("&template=compact&showinfo=true")
                .append("&amount=").append(Math.round(amount))
                .append("&des=").append(encode(transferContent));
        String holder = getAccountHolder();
        if (holder != null && !holder.isBlank()) {
            url.append("&holder=").append(encode(holder));
        }
        return url.toString();
    }

    /** Encode tham số URL; dùng %20 cho khoảng trắng theo đúng mẫu nhúng của SePay. */
    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8).replace("+", "%20");
    }

    /* ---------- Make Online Payment ---------- */

    /**
     * Lấy hóa đơn để thanh toán, ràng buộc: thuộc về khách đang đăng nhập
     * và đang ở trạng thái Pending (chưa thanh toán).
     *
     * @return Invoice hợp lệ hoặc null
     */
    public Invoice getPayableInvoice(int invoiceId, int accountId) {
        Invoice inv = invoiceDAO.getInvoiceForCustomer(invoiceId, accountId);
        if (inv == null || !"Pending".equals(inv.getStatus())) {
            return null;
        }
        return inv;
    }

    /**
     * Số tiền còn phải trả của hóa đơn (VND, không âm):
     * Thực thu (tổng − cọc − đã hoàn) trừ tiếp phần đã thanh toán online.
     */
    public double getRemainingAmount(Invoice inv) {
        double remaining = inv.getNetAmount() - paymentDAO.sumPaidForInvoice(inv.getInvoiceId());
        return remaining > 0 ? remaining : 0;
    }

    /** Hóa đơn của khách theo id (không ràng buộc trạng thái) — cho polling. */
    public Invoice getCustomerInvoice(int invoiceId, int accountId) {
        return invoiceDAO.getInvoiceForCustomer(invoiceId, accountId);
    }

    /** Danh sách hóa đơn chưa thanh toán của khách (để chọn hóa đơn cần trả). */
    public List<Invoice> getUnpaidInvoices(int accountId) {
        return invoiceDAO.getUnpaidInvoicesByAccount(accountId);
    }

    /* ---------- Tiền cọc đặt phòng (booking Pending) ---------- */

    /** Số tiền cọc phải trả của một đặt phòng = 30% tổng tiền phòng cả nhóm. */
    public double getDepositAmount(Booking b) {
        return Math.round(b.getOverallTotalAmount() * DEPOSIT_RATE);
    }

    /**
     * Danh sách đặt phòng đang chờ xác nhận (Pending) của khách, kèm tiền cọc
     * phải trả và số đã chuyển — cho mục "Đặt phòng chờ thanh toán cọc".
     */
    public List<DepositItem> getPendingDeposits(int accountId) {
        List<DepositItem> items = new ArrayList<>();
        for (Booking b : paymentDAO.getPendingBookingsByAccount(accountId)) {
            items.add(new DepositItem(b, getDepositAmount(b), paymentDAO.sumPaidForBooking(b.getBookingId())));
        }
        return items;
    }

    /**
     * Lấy đặt phòng để thanh toán cọc: thuộc về khách, đang Pending.
     * Trả về null nếu không hợp lệ.
     */
    public Booking getPayableDepositBooking(int bookingId, int accountId) {
        Booking b = paymentDAO.getBookingForCustomer(bookingId, accountId);
        if (b == null || !"Pending".equals(b.getStatus())) {
            return null;
        }
        return b;
    }

    /** Tiền cọc còn thiếu của một đặt phòng (không âm). */
    public double getDepositRemaining(Booking b) {
        double remaining = getDepositAmount(b) - paymentDAO.sumPaidForBooking(b.getBookingId());
        return remaining > 0 ? remaining : 0;
    }

    /** Đặt phòng của khách kèm số cọc đã trả — cho polling trạng thái. */
    public DepositItem getDepositStatus(int bookingId, int accountId) {
        Booking b = paymentDAO.getBookingForCustomer(bookingId, accountId);
        if (b == null) return null;
        return new DepositItem(b, getDepositAmount(b), paymentDAO.sumPaidForBooking(bookingId));
    }

    /* ---------- View Payment History ---------- */

    /** Lịch sử giao dịch thanh toán online của khách, mới nhất trước. */
    public List<Payment> getPaymentHistory(int accountId) {
        return paymentDAO.getPaymentsByAccount(accountId);
    }

    /* ---------- Xử lý webhook SePay ---------- */

    /**
     * Xử lý một giao dịch TIỀN VÀO do SePay báo về.
     * Tìm mã hóa đơn trong nội dung chuyển khoản; nếu khớp hóa đơn Pending
     * thì ghi nhận giao dịch (idempotent theo sepayTxId) và tất toán khi đủ tiền.
     *
     * @param sepayTxId     ID giao dịch phía SePay (trường "id" trong payload)
     * @param content       nội dung chuyển khoản
     * @param amount        số tiền vào (transferAmount)
     * @param gateway       ngân hàng phát sinh giao dịch
     * @param referenceCode mã tham chiếu của ngân hàng
     * @param txDate        thời điểm giao dịch (có thể null nếu parse lỗi)
     */
    public WebhookResult handleIncomingTransfer(long sepayTxId, String content, double amount,
                                                String gateway, String referenceCode, Timestamp txDate) {
        // 1. Tìm mã hóa đơn (HD...) hoặc mã tiền cọc (COC...) trong nội dung CK
        Integer invoiceId = extractCode(content, getPrefix());
        if (invoiceId == null) {
            Integer bookingId = extractCode(content, getDepositPrefix());
            if (bookingId != null) {
                return handleDepositTransfer(sepayTxId, bookingId, content, amount, gateway, referenceCode, txDate);
            }
            return WebhookResult.NO_INVOICE_CODE;
        }

        // 2. Hóa đơn phải tồn tại và đang chờ thanh toán
        Invoice inv = invoiceDAO.getInvoiceById(invoiceId);
        if (inv == null || !"Pending".equals(inv.getStatus())) {
            // Webhook gửi lại sau khi hóa đơn đã Paid -> báo trùng thay vì lỗi
            if (inv != null && paymentDAO.existsBySepayTxId(sepayTxId)) {
                return WebhookResult.DUPLICATE;
            }
            return WebhookResult.INVOICE_NOT_PAYABLE;
        }

        // 3. Ghi nhận + tất toán trong một transaction
        Payment p = new Payment();
        p.setInvoiceId(invoiceId);
        p.setSepayTxId(sepayTxId);
        p.setAmount(amount);
        p.setGateway(gateway);
        p.setReferenceCode(referenceCode);
        p.setContent(content);
        p.setTransactionDate(txDate);

        double due = inv.getNetAmount(); // tổng − cọc − đã hoàn
        PaymentDAO.SettleResult r = paymentDAO.recordPaymentAndSettle(p, due);
        switch (r) {
            case PAID:      return WebhookResult.MATCHED_PAID;
            case PARTIAL:   return WebhookResult.MATCHED_PARTIAL;
            case DUPLICATE: return WebhookResult.DUPLICATE;
            default:        return WebhookResult.ERROR;
        }
    }

    /**
     * Ghi nhận tiền cọc đặt phòng từ webhook. Không đổi trạng thái Booking —
     * lễ tân sẽ đối chiếu và xác nhận đặt phòng thủ công.
     */
    private WebhookResult handleDepositTransfer(long sepayTxId, int bookingId, String content, double amount,
                                                String gateway, String referenceCode, Timestamp txDate) {
        if (paymentDAO.getBookingIdIfExists(bookingId) == null) {
            return WebhookResult.INVOICE_NOT_PAYABLE;
        }
        int invoiceId = invoiceDAO.createInvoiceForBooking(bookingId);

        Payment p = new Payment();
        p.setBookingId(bookingId);
        if (invoiceId > 0) {
            p.setInvoiceId(invoiceId);
        }
        p.setSepayTxId(sepayTxId);
        p.setAmount(amount);
        p.setGateway(gateway);
        p.setReferenceCode(referenceCode);
        p.setContent(content);
        p.setTransactionDate(txDate);

        PaymentDAO.SettleResult r = paymentDAO.recordDepositPayment(p);
        switch (r) {
            case PAID:      return WebhookResult.MATCHED_DEPOSIT;
            case DUPLICATE: return WebhookResult.DUPLICATE;
            default:        return WebhookResult.ERROR;
        }
    }

    /**
     * Rút mã số theo tiền tố từ nội dung chuyển khoản,
     * vd prefix "HD": "MBVCB.123 HD45 chuyen tien" -> 45.
     * Không phân biệt hoa thường vì ngân hàng thường viết hoa toàn bộ nội dung.
     */
    public Integer extractCode(String content, String prefix) {
        if (content == null || content.isBlank()) return null;
        Pattern pattern = Pattern.compile(Pattern.quote(prefix) + "(\\d+)", Pattern.CASE_INSENSITIVE);
        Matcher m = pattern.matcher(content);
        if (m.find()) {
            try {
                return Integer.valueOf(m.group(1));
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }
}
