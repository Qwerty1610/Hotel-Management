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
-- PHAN A0: MIGRATION AN TOAN CHO DB CU
-- Code check-in moi yeu cau cot anh CCCD + phu phi. Neu DB duoc tao
-- tu truoc khi cap nhat, bang CheckIn/CheckInCompanion se thieu cot
-- -> INSERT luc check-in FAIL. Chay block nay de bo sung (idempotent).
-- ================================================================
IF COL_LENGTH(N'dbo.CheckIn', N'image_url') IS NULL
    ALTER TABLE dbo.CheckIn ADD image_url NVARCHAR(500) NULL;
IF COL_LENGTH(N'dbo.CheckIn', N'extra_fee') IS NULL
    ALTER TABLE dbo.CheckIn ADD extra_fee DECIMAL(18,2) NULL;
IF COL_LENGTH(N'dbo.CheckInCompanion', N'age_range') IS NULL
    ALTER TABLE dbo.CheckInCompanion ADD age_range VARCHAR(20) NULL;
IF COL_LENGTH(N'dbo.CheckInCompanion', N'image_url') IS NULL
    ALTER TABLE dbo.CheckInCompanion ADD image_url NVARCHAR(500) NULL;
PRINT N'[OK] Schema CheckIn/CheckInCompanion da du cot anh CCCD, phu phi, do tuoi.';
GO

-- ================================================================
-- PHAN A: TAO BOOKING DEMO (CONFIRMED, DA XEP PHONG) + COC 30%
-- Swimlane moi da bo node "Assign room" -> viec duyet don + xep phong
-- coi nhu da xay ra tu truoc (thuoc UC Process Booking Request).
-- Ket qua: booking cua khach "Tran Van Demo" o trang thai Confirmed,
-- DA duoc gan phong cu the, da coc 30%, CHUA co hoa don
-- -> khi le tan Check-In, he thong se TAO INVOICE UNPAID dung nhu
-- node "Create invoice for customer with unpaid status" trong diagram.
-- ================================================================
DECLARE @AccId INT = (SELECT account_id FROM dbo.Account WHERE email = N'customer@hotel.com');
DECLARE @RecId INT = (SELECT account_id FROM dbo.Account WHERE email = N'receptionist@hotel.com');
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

    -- Chon 1 phong trong cua loai nay, khong dung lich voi booking khac
    DECLARE @RoomId INT, @RoomNo NVARCHAR(50);
    SELECT TOP 1 @RoomId = r.room_id, @RoomNo = r.room_number
    FROM dbo.Room r
    WHERE r.type_id = @TypeId AND r.is_deleted = 0 AND r.status = N'Available'
      AND NOT EXISTS (
            SELECT 1
            FROM dbo.RoomAssignment ra
            JOIN dbo.Booking b ON b.booking_id = ra.booking_id
            WHERE ra.room_id = r.room_id
              AND b.status IN (N'Confirmed', N'CheckedIn')
              AND b.check_in_date < @CheckOut
              AND b.check_out_date > @CheckIn)
    ORDER BY r.room_number;

    IF @RoomId IS NULL
    BEGIN
        PRINT N'[LOI] Loai phong da chon khong con phong trong hom nay.';
    END
    ELSE
    BEGIN
        INSERT INTO dbo.Booking
            (account_id, customer_name, phone, email,
             room_type_id, room_quantity, check_in_date, check_out_date,
             total_amount, status, note)
        VALUES
            (@AccId, N'Tran Van Demo', N'0901234567', N'customer@hotel.com',
             @TypeId, 1, @CheckIn, @CheckOut,
             @Total, N'Confirmed', N'[DEMO] Booking demo swimlane check-in/check-out');

        DECLARE @BID INT = SCOPE_IDENTITY();

        -- Gan phong san (thay cho buoc Assign room da bo khoi diagram)
        INSERT INTO dbo.RoomAssignment (booking_id, room_id, assigned_by, assigned_at, note)
        VALUES (@BID, @RoomId, @RecId, SYSDATETIME(), N'[DEMO] Xep phong khi duyet don');

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
        PRINT N'[OK] Booking #' + CAST(@BID AS NVARCHAR)
            + N' (Confirmed) - khach: Tran Van Demo - phong: ' + @RoomNo;
        PRINT N'[OK] Da coc ' + CAST(@DEP AS NVARCHAR) + N' VND (30%). Chua co hoa don.';
        PRINT N'>> Le tan mo tab Check-in: /HotelManagement/receptionist/dashboard?tab=checkin';
        PRINT N'=====================================================';

        SELECT @BID AS booking_id, N'Tran Van Demo' AS customer_name, @RoomNo AS room_number,
               @CheckIn AS check_in, @CheckOut AS check_out,
               @Total AS total_amount, @DEP AS deposit_paid;
    END
END
GO

-- ================================================================
-- PHAN B: QUERY SOI TRANG THAI HE THONG (chay lai sau MOI buoc demo)
-- Chung minh lane "System" hoat dong dung:
--   - TRUOC CHECK-IN: booking = Confirmed, phong da gan, CHUA co invoice
--   - Sau CHECK-IN  : booking = CheckedIn, phong = Occupied,
--                     invoice VUA DUOC TAO trang thai Pending (unpaid),
--                     co anh CCCD + companion
--   - Sau CHECKOUT  : booking = CheckedOut, invoice = Paid, phong = Cleaning
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

-- 5. Check-in: anh CCCD khach dai dien, phu phi + nguoi di kem
--    (image_url = link Cloudinary anh can cuoc da upload luc check-in)
SELECT ci.check_in_id, ci.checked_in_at,
       ci.image_url  AS customer_cccd_image,
       ci.extra_fee,
       ci.special_request, ci.notes,
       cc.full_name  AS companion_name,
       cc.age_range  AS companion_age_range,
       cc.image_url  AS companion_cccd_image
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
