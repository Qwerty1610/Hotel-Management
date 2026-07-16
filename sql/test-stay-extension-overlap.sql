/* ============================================================================
   TEST DATA — Request Stay Extension (UC 2.3.14)
   Kịch bản: khách đang lưu trú (CheckedIn) muốn gia hạn ngày trả phòng,
   nhưng những đêm muốn ở thêm ĐÃ CÓ KHÁCH KHÁC ĐẶT → hệ thống phải báo
   MSG16 ("Không còn phòng trống phù hợp...").

   An toàn để chạy nhiều lần (idempotent). Chạy trên Database HotelManagementDB.

   Bối cảnh tồn kho (theo seed gốc):
     - Phòng Standard: 2 phòng (101, 102)  -> dùng cho kịch bản THẤT BẠI
     - Phòng Deluxe : 3 phòng (201, 202, 204) -> dùng cho kịch bản THÀNH CÔNG
   ============================================================================ */
USE HotelManagementDB;
GO

DECLARE @cust       INT = (SELECT account_id FROM dbo.Account WHERE email = N'customer@hotel.com');
DECLARE @standard   INT = (SELECT type_id    FROM dbo.RoomType WHERE type_name = N'Phòng Standard');
DECLARE @deluxe     INT = (SELECT type_id    FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe');

/* ----------------------------------------------------------------------------
   1) BOOKING CỦA KHÁCH (chủ thể test) — đang lưu trú phòng STANDARD
      22/06 -> 25/06. Đây là booking sẽ được dùng để bấm "Gia hạn lưu trú".
      (Có thể đã tồn tại nếu bạn đã chạy mục 12 của hotel_management.sql.)
   ---------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM dbo.Booking
               WHERE account_id = @cust AND room_type_id = @standard
                 AND check_in_date = '2026-06-22' AND check_out_date = '2026-06-25')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity,
                             check_in_date, check_out_date, total_amount, status, note)
    VALUES (@cust, N'Customer User', @standard, 1,
            '2026-06-22', '2026-06-25', 2250000, N'CheckedIn',
            N'[TEST] Đang lưu trú phòng Standard - dùng để test gia hạn THẤT BẠI');
END
GO

/* ----------------------------------------------------------------------------
   2) HAI BOOKING CỦA KHÁCH KHÁC chiếm CẢ 2 phòng Standard trong các đêm
      25/06 và 26/06 (chính là khoảng khách muốn ở thêm).
        - Booking A: 24/06 -> 28/06  (phủ 25, 26, 27)
        - Booking B: 25/06 -> 27/06  (phủ 25, 26)
      => Ngày 25 và 26 đều có 2 phòng bị chiếm = tổng số phòng Standard (2)
      => available = 0  => gia hạn vào các ngày này sẽ bị từ chối (MSG16).
   ---------------------------------------------------------------------------- */
DECLARE @standard2 INT = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard');

IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Phạm Văn E (test)' AND check_in_date = '2026-06-24')
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity,
                             check_in_date, check_out_date, total_amount, status, note)
    VALUES (NULL, N'Phạm Văn E (test)', @standard2, 1,
            '2026-06-24', '2026-06-28', 3000000, N'Confirmed',
            N'[TEST] Giữ 1 phòng Standard 24-28/06');

IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Hoàng Thị F (test)' AND check_in_date = '2026-06-25')
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity,
                             check_in_date, check_out_date, total_amount, status, note)
    VALUES (NULL, N'Hoàng Thị F (test)', @standard2, 1,
            '2026-06-25', '2026-06-27', 1500000, N'Confirmed',
            N'[TEST] Giữ 1 phòng Standard 25-27/06');
GO

/* ----------------------------------------------------------------------------
   3) BOOKING ĐỐI CHỨNG (THÀNH CÔNG) — khách đang lưu trú phòng DELUXE
      22/06 -> 25/06. Deluxe còn 3 phòng và KHÔNG có ai đặt các đêm 25, 26
      => gia hạn sang 27/06 sẽ THÀNH CÔNG (phụ phí = 1.200.000 x 1 x 2 = 2.400.000).
   ---------------------------------------------------------------------------- */
DECLARE @cust3   INT = (SELECT account_id FROM dbo.Account  WHERE email = N'customer@hotel.com');
DECLARE @deluxe3 INT = (SELECT type_id    FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe');

IF NOT EXISTS (SELECT 1 FROM dbo.Booking
               WHERE account_id = @cust3 AND room_type_id = @deluxe3
                 AND check_in_date = '2026-06-22' AND check_out_date = '2026-06-25')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity,
                             check_in_date, check_out_date, total_amount, status, note)
    VALUES (@cust3, N'Customer User', @deluxe3, 1,
            '2026-06-22', '2026-06-25', 3600000, N'CheckedIn',
            N'[TEST] Đang lưu trú phòng Deluxe - dùng để test gia hạn THÀNH CÔNG');
END
GO

/* ----------------------------------------------------------------------------
   4) KIỂM TRA NHANH — số phòng Standard bị chiếm trong khoảng 25/06–27/06.
      Kỳ vọng: mỗi đêm (25, 26) có 2 phòng bị đặt = hết phòng Standard.
   ---------------------------------------------------------------------------- */
SELECT booking_id, customer_name, status, check_in_date, check_out_date, room_quantity
FROM dbo.Booking
WHERE room_type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard')
  AND status IN (N'Pending', N'Confirmed', N'CheckedIn')
  AND check_in_date < '2026-06-27'   -- overlap với khoảng [25/06, 27/06)
  AND check_out_date > '2026-06-25'
ORDER BY check_in_date;
GO
