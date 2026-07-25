/* ============================================================================
   BACKFILL: Đưa phụ phí check-in (CheckIn.extra_fee) vào hóa đơn dưới dạng
             dòng InvoiceItem loại Surcharge.

   Bối cảnh:
     Trước đây phụ phí (ví dụ khách vượt số người tiêu chuẩn) chỉ được lưu ở
     cột CheckIn.extra_fee, KHÔNG ghi thành InvoiceItem. Do tổng hóa đơn được
     tính bằng SUM(InvoiceItem.amount) nên Manager không thấy khoản phụ phí này.
     Code check-in đã được sửa để ghi Surcharge cho các lần check-in MỚI; script
     này vá dữ liệu CŨ.

   Ánh xạ:
     - Invoice.booking_id trỏ tới "root booking" (group_booking_id nếu > 0,
       ngược lại là chính booking_id) — khớp logic createInvoiceForBooking.
     - CheckIn.booking_id là booking lẻ → cần quy về root để tìm đúng hóa đơn.
     - Với group booking, nhiều CheckIn (mỗi phòng) có thể cùng lưu extra_fee;
       ta chỉ lấy MỘT khoản phụ phí cho mỗi hóa đơn (MAX theo invoice) để không
       nhân đôi — khớp hành vi code mới (chỉ ghi 1 dòng Surcharge cho hóa đơn gốc).

   An toàn:
     - Chỉ xử lý CheckIn có extra_fee > 0.
     - Chỉ chèn khi hóa đơn CHƯA có dòng Surcharge trùng mô tả + số tiền
       (idempotent: chạy lại nhiều lần không cộng trùng).
     - Bọc trong transaction; in ra số dòng đã chèn để kiểm chứng.
   ============================================================================ */

SET NOCOUNT ON;
BEGIN TRAN;

;WITH ci AS (
    SELECT
        c.extra_fee,
        root_booking_id = CASE
            WHEN b.group_booking_id IS NOT NULL AND b.group_booking_id > 0
                THEN b.group_booking_id
            ELSE b.booking_id
        END
    FROM dbo.CheckIn c
    JOIN dbo.Booking b ON b.booking_id = c.booking_id
    WHERE c.extra_fee IS NOT NULL AND c.extra_fee > 0
),
target AS (
    -- Một khoản phụ phí cho mỗi hóa đơn (tránh nhân đôi khi group có nhiều CheckIn)
    SELECT
        i.invoice_id,
        extra_fee = MAX(ci.extra_fee),
        desc_text = N'Phụ phí vượt số người tiêu chuẩn'
    FROM ci
    JOIN dbo.Invoice i ON i.booking_id = ci.root_booking_id
    GROUP BY i.invoice_id
)
INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
SELECT t.invoice_id, N'Surcharge', t.desc_text, 1, t.extra_fee, t.extra_fee
FROM target t
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.InvoiceItem ii
    WHERE ii.invoice_id = t.invoice_id
      AND ii.item_type  = N'Surcharge'
      AND ii.description = t.desc_text
      AND ii.amount     = t.extra_fee
);

PRINT N'Số dòng Surcharge đã chèn (backfill): ' + CAST(@@ROWCOUNT AS NVARCHAR(20));

/* Đổi thành ROLLBACK để chạy thử (dry-run) trước khi commit thật. */
COMMIT TRAN;

/* --- Kiểm chứng: các phụ phí check-in và trạng thái đã có mặt trên hóa đơn chưa ---
SELECT
    c.check_in_id, c.booking_id, c.extra_fee,
    i.invoice_id,
    surcharge_on_invoice = (
        SELECT ISNULL(SUM(ii.amount),0)
        FROM dbo.InvoiceItem ii
        WHERE ii.invoice_id = i.invoice_id AND ii.item_type = N'Surcharge'
    )
FROM dbo.CheckIn c
JOIN dbo.Booking b ON b.booking_id = c.booking_id
JOIN dbo.Invoice i ON i.booking_id = CASE
        WHEN b.group_booking_id IS NOT NULL AND b.group_booking_id > 0
            THEN b.group_booking_id ELSE b.booking_id END
WHERE c.extra_fee > 0
ORDER BY c.check_in_id;
*/
