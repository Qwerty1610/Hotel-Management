/* =====================================================================
   FIX: tiền cọc bị trừ HAI LẦN khỏi số tiền phải thanh toán
   Ngày: 23/07/2026 — QuyPQ

   Nguyên nhân: khi nhận cọc qua webhook SePay, handleDepositTransfer ghi
   giao dịch cọc kèm CẢ booking_id LẪN invoice_id. Hóa đơn vốn đã trừ cọc
   qua cột dẫn xuất deposit_amount (30% tiền phòng), nên phép
   SUM(amount) WHERE invoice_id = ? lại trừ cọc thêm lần nữa:
     - Trang QR hiển thị số cần trả bị hụt đúng bằng tiền cọc
     - Hóa đơn bị đánh dấu Paid khi khách còn nợ đúng phần cọc đó
     - Màn Check-out cộng "đã trả" gấp đôi tiền cọc

   Code đã sửa để giao dịch cọc CHỈ gắn booking_id. Script này dọn các
   bản ghi CŨ đã lỡ gắn invoice_id.

   Cách nhận diện: chỉ hai luồng ghi Payment mang cả hai khóa —
     (1) cọc qua webhook  -> content chứa mã COC do khách chuyển khoản
     (2) thanh toán tại quầy lúc trả phòng -> content 'THANH TOAN TAI QUAY - BOOKING x'
   Nhóm (2) phải giữ nguyên invoice_id vì đó là tiền trả cho hóa đơn thật.
   ===================================================================== */
USE HotelManagementDB;
GO

/* --- BƯỚC 1: xem trước các dòng sẽ bị sửa (chạy riêng, kiểm tra rồi mới UPDATE) --- */
SELECT payment_id, booking_id, invoice_id, amount, gateway, content, created_at
FROM dbo.Payment
WHERE booking_id IS NOT NULL
  AND invoice_id IS NOT NULL
  AND ISNULL(content, N'') NOT LIKE N'THANH TOAN TAI QUAY%'
ORDER BY created_at DESC;
GO

/* --- BƯỚC 2: gỡ invoice_id khỏi các giao dịch cọc cũ --- */
BEGIN TRANSACTION;

UPDATE dbo.Payment
SET invoice_id = NULL
WHERE booking_id IS NOT NULL
  AND invoice_id IS NOT NULL
  AND ISNULL(content, N'') NOT LIKE N'THANH TOAN TAI QUAY%';

PRINT N'Số giao dịch cọc đã gỡ invoice_id: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

-- Kiểm tra lại: sau khi chạy, mỗi giao dịch chỉ mang một khóa
-- (trừ thanh toán tại quầy). Nếu kết quả đúng như mong đợi -> COMMIT.
COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;  -- dùng dòng này thay COMMIT nếu muốn hủy
GO

/* --- BƯỚC 3: đối chiếu lại một hóa đơn cụ thể (thay 39 bằng id cần kiểm tra) ---
   Kỳ vọng: can_thanh_toan = tong_hoa_don − coc_30_phan_tram − da_hoan − da_tra_online
   và KHÔNG còn dòng cọc nào lọt vào da_tra_online.                                */
DECLARE @invoiceId INT = 39;

SELECT
    i.invoice_id,
    (SELECT ISNULL(SUM(amount),0) FROM dbo.InvoiceItem WHERE invoice_id = i.invoice_id) AS tong_hoa_don,
    (SELECT ISNULL(SUM(amount),0) * 0.3 FROM dbo.InvoiceItem
      WHERE invoice_id = i.invoice_id AND item_type = N'Room')                          AS coc_30_phan_tram,
    (SELECT ISNULL(SUM(amount),0) FROM dbo.Refund
      WHERE invoice_id = i.invoice_id AND status = N'Done')                             AS da_hoan,
    (SELECT ISNULL(SUM(amount),0) FROM dbo.Payment WHERE invoice_id = i.invoice_id)     AS da_tra_online,
    i.status
FROM dbo.Invoice i
WHERE i.invoice_id = @invoiceId;
GO
