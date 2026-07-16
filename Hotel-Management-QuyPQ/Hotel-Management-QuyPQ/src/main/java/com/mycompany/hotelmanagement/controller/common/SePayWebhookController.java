package com.mycompany.hotelmanagement.controller.common;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;
import com.mycompany.hotelmanagement.service.PaymentService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Webhook nhận thông báo TIỀN VÀO từ SePay (https://my.sepay.vn).
 *
 * Cấu hình phía SePay: Tích hợp Webhooks -> URL trỏ tới
 *   https://{domain}/{context}/api/sepay-webhook
 * kiểu chứng thực API Key -> SePay gửi header "Authorization: Apikey {key}",
 * key phải trùng sepay.webhook.apikey trong config.properties.
 *
 * Payload mẫu SePay gửi:
 * {
 *   "id": 92704, "gateway": "MBBank", "transactionDate": "2026-07-08 14:02:37",
 *   "accountNumber": "0123456789", "content": "HD123 chuyen tien",
 *   "transferType": "in", "transferAmount": 1500000, "referenceCode": "FT2231...",
 *   "code": null, "subAccount": null, "accumulated": 0, "description": ""
 * }
 *
 * Luôn trả HTTP 200 với giao dịch không khớp (sai nội dung, hóa đơn đã đóng...)
 * để SePay không retry vô ích; chỉ trả 401 khi sai API Key và 500 khi lỗi hệ thống.
 *
 * Date: 08/7/2026
 * @author Pham Quoc Quy
 * version: 1.0
 */
@WebServlet(name = "SePayWebhookController", urlPatterns = { "/api/sepay-webhook" })
public class SePayWebhookController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SePayWebhookController.class.getName());
    private static final DateTimeFormatter SEPAY_DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // 1. Chứng thực API Key: "Authorization: Apikey {key}"
        String configuredKey = paymentService.getWebhookApiKey();
        String auth = request.getHeader("Authorization");
        if (configuredKey == null || configuredKey.isBlank()
                || auth == null || !auth.equals("Apikey " + configuredKey)) {
            LOGGER.warning("SePay webhook: sai hoặc thiếu API Key");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false, \"message\": \"unauthorized\"}");
            return;
        }

        // 2. Đọc payload JSON
        JsonObject tx;
        try {
            tx = JsonParser.parseReader(request.getReader()).getAsJsonObject();
        } catch (JsonSyntaxException | IllegalStateException e) {
            LOGGER.log(Level.WARNING, "SePay webhook: payload không phải JSON hợp lệ", e);
            response.getWriter().write("{\"success\": true, \"message\": \"invalid_payload_ignored\"}");
            return;
        }

        try {
            // 3. Chỉ xử lý giao dịch tiền vào
            String transferType = getString(tx, "transferType");
            if (!"in".equalsIgnoreCase(transferType)) {
                response.getWriter().write("{\"success\": true, \"message\": \"ignored_not_incoming\"}");
                return;
            }

            long sepayTxId = tx.get("id").getAsLong();
            double amount = tx.get("transferAmount").getAsDouble();
            String content = getString(tx, "content");
            String gateway = getString(tx, "gateway");
            String referenceCode = getString(tx, "referenceCode");
            Timestamp txDate = parseDate(getString(tx, "transactionDate"));

            // 4. Khớp hóa đơn + ghi nhận + tất toán
            PaymentService.WebhookResult result =
                    paymentService.handleIncomingTransfer(sepayTxId, content, amount, gateway, referenceCode, txDate);

            LOGGER.info("SePay webhook: tx=" + sepayTxId + " amount=" + amount
                    + " content=\"" + content + "\" -> " + result);

            if (result == PaymentService.WebhookResult.ERROR) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\": false, \"message\": \"internal_error\"}");
                return;
            }
            response.getWriter().write("{\"success\": true, \"message\": \"" + result.name().toLowerCase() + "\"}");
        } catch (RuntimeException e) {
            // Thiếu trường bắt buộc (id / transferAmount) hoặc sai kiểu dữ liệu
            LOGGER.log(Level.WARNING, "SePay webhook: payload thiếu trường bắt buộc", e);
            response.getWriter().write("{\"success\": true, \"message\": \"malformed_ignored\"}");
        }
    }

    /** Đọc chuỗi từ JSON, chịu được trường null hoặc không tồn tại. */
    private String getString(JsonObject obj, String key) {
        return (obj.has(key) && !obj.get(key).isJsonNull()) ? obj.get(key).getAsString() : null;
    }

    /** Parse "yyyy-MM-dd HH:mm:ss" của SePay, trả null nếu không đúng định dạng. */
    private Timestamp parseDate(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            return Timestamp.valueOf(LocalDateTime.parse(raw.trim(), SEPAY_DATE_FORMAT));
        } catch (Exception e) {
            return null;
        }
    }
}
