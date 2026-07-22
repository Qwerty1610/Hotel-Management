-- ================================================================
-- DEMO PREP - Swimlane Check-In / Check-Out (QuyPQ)
-- DB: HotelManagementDB
--
-- PHAN A: Chay TRUOC demo -> tao booking online (Pending) + coc 30%
-- PHAN B: Query "soi" trang thai he thong sau moi buoc (chieu len man hinh)
-- PHAN C: (Tuy chon) Them dich vu vao hoa don sau khi Check-In
-- PHAN D: Cleanup sau demo
-- ================================================================

USE HotelManagementDB;
GO

-- ================================================================
-- PHAN A: TAO BOOKING DEMO (PENDING) + FORCE COC 30%
-- Ket qua: 1 booking cua khach "Tran Van Demo", nhan phong HOM NAY,
-- tra phong NGAY MAI, da chuyen coc 30% -> nut "Xac nhan duyet"
-- cua le tan duoc mo khoa.
-- ================================================================
DECLARE @AccId INT = (SELECT account_id FROM dbo.Account WHERE email = N'customer@hotel.com');
DECLARE @TypeId INT, @Price DECIMAL(18,2);

-- Chon loai phong dang co nhieu phong Available nhat
SELECT TOP 1
    @TypeId = rt.type_id,
    @Price  = rt.base_price
FROM dbo.RoomType rt
JOIN dbo.Room r ON r.type_id = rt.type_id
WHERE r.is_deleted = 0 AND r.status = N'Available'
GROUP BY rt.type_id, rt.base_price
ORDER BY COUNT(*) DESC;

IF @TypeId IS NULL
BEGIN
    PRINT N'[LOI] Khong con phong Available nao. Hay kiem tra bang Room truoc.';
END
ELSE
BEGIN
    DECLARE @CheckIn  DATE = CAST(GETDATE() AS DATE);
    DECLARE @CheckOut DATE = DATEADD(DAY, 1, @CheckIn);
    DECLARE @Total    DECIMAL(18,2) = @Price;   -- 1 phong x 1 dem

    INSERT INTO dbo.Booking
        (account_id, customer_name, phone, email,
         room_type_id, room_quantity, check_in_date, check_out_date,
         total_amount, status, note)
    VALUES
        (@AccId, N'Tran Van Demo', N'0901234567', N'customer@hotel.com',
         @TypeId, 1, @CheckIn, @CheckOut,
         @Total, N'Pending', N'[DEMO] Booking demo swimlane check-in/check-out');

    DECLARE @BID INT = SCOPE_IDENTITY();

    -- Force coc 30% (gia lap khach da chuyen khoan SePay)
    DECLARE @DEP  DECIMAL(18,2) = ROUND(@Total * 0.3, 0);
    DECLARE @TXID BIGINT = -1 * ABS(CAST(CAST(NEWID() AS VARBINARY(8)) AS BIGINT));

    INSERT INTO dbo.Payment
        (booking_id, invoice_id, sepay_tx_id, amount,
         gateway, reference_code, content, created_at)
    VALUES
        (@BID, NULL, @TXID, @DEP,
         N'Manual/Demo', N'DEMO-COC-' + CAST(@BID AS NVARCHAR),
         N'COC' + CAST(@BID AS NVARCHAR) + N' - dat coc demo', SYSDATETIME());

    PRINT N'=====================================================';
    PRINT N'[OK] Da tao Booking #' + CAST(@BID AS NVARCHAR)
        + N' (Pending) - khach: Tran Van Demo';
    PRINT N'[OK] Da coc ' + CAST(@DEP AS NVARCHAR) + N' VND (30%).';
    PRINT N'>> Le tan mo: /HotelManagement/receptionist/booking/process?bookingId=' + CAST(@BID AS NVARCHAR);
    PRINT N'=====================================================';

    SELECT @BID AS booking_id, N'Tran Van Demo' AS customer_name,
           @CheckIn AS check_in, @CheckOut AS check_out,
           @Total AS total_amount, @DEP AS deposit_paid;
END
GO

-- ================================================================
-- PHAN B: QUERY SOI TRANG THAI HE THONG (chay lai sau MOI buoc demo)
-- Chung minh lane "System" hoat dong dung:
--   - Sau CONFIRM : booking = Confirmed, invoice = Pending (unpaid)
--   - Sau CHECK-IN: booking = CheckedIn, phong = Occupied, co companion
--   - Sau CHECKOUT: booking = CheckedOut, invoice = Paid, phong = Cleaning
-- ================================================================
DECLARE @BID INT = (SELECT MAX(booking_id) FROM dbo.Booking WHERE note LIKE N'[[]DEMO]%');

-- 1. Trang thai booking
SELECT b.booking_id, b.customer_name, b.status AS booking_status,
       b.check_in_date, b.check_out_date, b.total_amount
FROM dbo.Booking b WHERE b.booking_id = @BID;

-- 2. Phong da gan + trang thai phong (cot status = gia tri luu trong DB,
--    display_status = trang thai hien tren So do phong)
SELECT r.room_number, r.status AS room_status_in_db,
       CASE WHEN b.status IN (N'Confirmed', N'CheckedIn') THEN N'Occupied'
            ELSE r.status END AS display_status
FROM dbo.RoomAssignment ra
JOIN dbo.Room r    ON r.room_id = ra.room_id
JOIN dbo.Booking b ON b.booking_id = ra.booking_id
WHERE ra.booking_id = @BID;

-- 3. Hoa don + chi tiet
SELECT i.invoice_id, i.status AS invoice_status, i.room_number, i.created_at
FROM dbo.Invoice i WHERE i.booking_id = @BID;

SELECT ii.item_type, ii.description, ii.quantity, ii.unit_price, ii.amount
FROM dbo.InvoiceItem ii
JOIN dbo.Invoice i ON i.invoice_id = ii.invoice_id
WHERE i.booking_id = @BID;

-- 4. Thanh toan (coc + tat toan)
SELECT p.amount, p.gateway, p.content, p.created_at
FROM dbo.Payment p WHERE p.booking_id = @BID;

-- 5. Check-in + nguoi di kem (companion)
SELECT ci.check_in_id, ci.checked_in_at, ci.special_request, ci.notes,
       cc.full_name AS companion_name
FROM dbo.CheckIn ci
LEFT JOIN dbo.CheckInCompanion cc ON cc.check_in_id = ci.check_in_id
WHERE ci.booking_id = @BID;
GO

-- ================================================================
-- PHAN C (TUY CHON): THEM DICH VU VAO HOA DON SAU KHI CHECK-IN
-- De buoc "Review final charges" luc checkout co dich vu de xem.
-- (Neu demo them dich vu bang UI /receptionist/add-booking-service
--  thi KHONG can chay phan nay.)
-- ================================================================
/*
DECLARE @BID INT = (SELECT MAX(booking_id) FROM dbo.Booking WHERE note LIKE N'[[]DEMO]%');
DECLARE @INV INT = (SELECT invoice_id FROM dbo.Invoice WHERE booking_id = @BID);

IF @INV IS NULL
    PRINT N'[!] Booking chua co Invoice - hay Confirm/Check-In tren UI truoc.';
ELSE
BEGIN
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    VALUES
        (@INV, N'Service', N'Nuoc suoi 500ml',        2, 15000,  30000),
        (@INV, N'Service', N'Giat la quan ao (1 bo)', 1, 80000,  80000);
    PRINT N'[OK] Da them 2 dich vu vao Invoice #' + CAST(@INV AS NVARCHAR);
END
*/
GO

-- ================================================================
-- PHAN D: CLEANUP SAU DEMO (xoa toan bo du lieu [DEMO])
-- Neu demo them nhanh Walk-In, sua @BID_WALKIN thanh booking id
-- cua don walk-in de xoa luon (0 = bo qua).
-- ================================================================
/*
DECLARE @BID_WALKIN INT = 0;   -- << booking id don walk-in (neu co)

DECLARE @Ids TABLE (id INT);
INSERT INTO @Ids
    SELECT booking_id FROM dbo.Booking WHERE note LIKE N'[[]DEMO]%'
    UNION SELECT @BID_WALKIN WHERE @BID_WALKIN > 0
    UNION SELECT booking_id FROM dbo.Booking WHERE group_booking_id IN
        (SELECT booking_id FROM dbo.Booking WHERE note LIKE N'[[]DEMO]%'
         UNION SELECT @BID_WALKIN WHERE @BID_WALKIN > 0);

-- Tra phong ve Available
UPDATE dbo.Room SET status = N'Available'
WHERE room_id IN (SELECT room_id FROM dbo.RoomAssignment WHERE booking_id IN (SELECT id FROM @Ids));

DELETE FROM dbo.CheckOut       WHERE booking_id IN (SELECT id FROM @Ids);
DELETE FROM dbo.Payment        WHERE booking_id IN (SELECT id FROM @Ids)
    OR invoice_id IN (SELECT invoice_id FROM dbo.Invoice WHERE booking_id IN (SELECT id FROM @Ids));
DELETE FROM dbo.InvoiceItem    WHERE invoice_id IN (SELECT invoice_id FROM dbo.Invoice WHERE booking_id IN (SELECT id FROM @Ids));
DELETE FROM dbo.Invoice        WHERE booking_id IN (SELECT id FROM @Ids);
DELETE FROM dbo.CheckInCompanion WHERE check_in_id IN (SELECT check_in_id FROM dbo.CheckIn WHERE booking_id IN (SELECT id FROM @Ids));
DELETE FROM dbo.CheckIn        WHERE booking_id IN (SELECT id FROM @Ids);
DELETE FROM dbo.BookingServiceRequest WHERE booking_id IN (SELECT id FROM @Ids);
DELETE FROM dbo.RoomAssignment WHERE booking_id IN (SELECT id FROM @Ids);
DELETE FROM dbo.Booking        WHERE group_booking_id IN (SELECT id FROM @Ids);
DELETE FROM dbo.Booking        WHERE booking_id IN (SELECT id FROM @Ids);

PRINT N'[OK] Da don sach du lieu demo.';
*/
GO
