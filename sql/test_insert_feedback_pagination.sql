-- =====================================================================
-- Script: test_insert_feedback_pagination.sql
-- Muc dich: Them 10 Booking CheckedOut + 10 Feedback cho account
--           customer@hotel.com (Customer User) vao cac phong thuoc
--           RoomType "Phong Standard" - de test hien thi review.
-- Chay trong SSMS.
-- =====================================================================

USE HotelManagementDB;
GO

-- ─── BƯỚC 0: Lay thong tin can thiet ────────────────────────────────
DECLARE @CustomerId    INT,
        @CustomerName  NVARCHAR(100),
        @CustomerEmail NVARCHAR(100),
        @CustomerPhone NVARCHAR(20),
        @ReceptionistId INT,
        @RoomTypeId    INT;

-- Customer User
SELECT
    @CustomerId    = account_id,
    @CustomerName  = full_name,
    @CustomerEmail = email,
    @CustomerPhone = ISNULL(phone, N'0901234567')
FROM dbo.Account
WHERE email = N'customer@hotel.com';

-- Receptionist
SELECT TOP 1
    @ReceptionistId = account_id
FROM dbo.Account
WHERE email = N'receptionist@hotel.com';

-- RoomType co ten chua chu "Standard" (Phong Standard)
SELECT TOP 1
    @RoomTypeId = type_id
FROM dbo.RoomType
WHERE type_name LIKE N'%Standard%';

-- Kiem tra du lieu truoc khi chay
IF @CustomerId IS NULL
BEGIN
    RAISERROR(N'Khong tim thay customer@hotel.com. Chay hotel_management.sql truoc.', 16, 1);
    RETURN;
END
IF @ReceptionistId IS NULL
BEGIN
    RAISERROR(N'Khong tim thay receptionist@hotel.com. Chay hotel_management.sql truoc.', 16, 1);
    RETURN;
END
IF @RoomTypeId IS NULL
BEGIN
    RAISERROR(N'Khong tim thay RoomType chua chu "Standard". Kiem tra lai ten loai phong.', 16, 1);
    RETURN;
END

SELECT
    @CustomerId    AS [Customer ID],
    @CustomerName  AS [Ten KH],
    @ReceptionistId AS [Receptionist ID],
    @RoomTypeId    AS [Room Type ID (Standard)];

-- ─── BƯỚC 1: Lay danh sach phong thuoc Phong Standard ───────────────
DECLARE @Rooms TABLE (
    idx         INT IDENTITY(1,1),
    room_id     INT,
    room_number NVARCHAR(50),
    base_price  DECIMAL(18,2)
);

INSERT INTO @Rooms (room_id, room_number, base_price)
SELECT TOP 10
    r.room_id,
    r.room_number,
    rt.base_price
FROM dbo.Room r
JOIN dbo.RoomType rt ON r.type_id = rt.type_id
WHERE r.type_id = @RoomTypeId
ORDER BY r.room_id;

-- Neu loai phong nay co it hon 10 phong, moi phong se duoc dung nhieu lan
-- (moi booking ung voi 1 lan luu tru rieng biet - khong vi pham UNIQUE)

-- ─── BƯỚC 2: Tao 10 Booking + CheckIn + CheckOut + Invoice + Payment ─
DECLARE @i INT = 1;

-- Comment mau da dang cho 10 feedback
DECLARE @Comments TABLE (idx INT, comment NVARCHAR(500), rating TINYINT);
INSERT INTO @Comments VALUES
(1,  N'Phong sach, view dep, nhan vien than thien. Se quay lai!', 5),
(2,  N'Dich vu tot, phong rong. Sang qua hoi on nhung chap nhan duoc.', 4),
(3,  N'Rat thoai mai, giuong nem tot, dieu hoa mat. Xung dang 5 sao.', 5),
(4,  N'Phong dep va sach se. Ho boi rat thich. Chac chan goi lai.', 5),
(5,  N'Nhan vien nhiet tinh, check-in nhanh. Phong co day du tien nghi.', 4),
(6,  N'Vi tri thuan tien, gan trung tam, de di lai. Phong hop ly.', 4),
(7,  N'Khong gian yen tinh, phu hop nghi ngoi sau chuyen cong tac dai.', 5),
(8,  N'Phong nhu trong anh quang cao. Khuyen khich moi nguoi dat thu.', 4),
(9,  N'An tuong tot ve chat luong phong va su chuyen nghiep cua staff.', 5),
(10, N'Gia ca phu hop voi chat luong. Se gioi thieu cho ban be va dong nghiep.', 4),
(11, N'[TEST-EXTRA-11] Phong rat dep, toi da o nhieu khach san nhung day la tot nhat.', 3),
(12, N'[TEST-EXTRA-12] Dich vu an uong ngon, phong tiem nghi du tien ich. Hài long.', 5);

WHILE @i <= 12  -- 12 feedback de test TOP 10 cua DAO (2 cai bi cat)
BEGIN
    -- Lay phong theo thu tu, neu khong du 10 phong thi quay vong
    DECLARE @RoomId     INT,
            @RoomNumber NVARCHAR(50),
            @BasePrice  DECIMAL(18,2);

    -- Lay phong thu (@i mod so luong phong) + 1
    DECLARE @RoomCount INT = (SELECT COUNT(*) FROM @Rooms);
    DECLARE @RoomIdx   INT = ((@i - 1) % @RoomCount) + 1;

    SELECT
        @RoomId     = room_id,
        @RoomNumber = room_number,
        @BasePrice  = base_price
    FROM @Rooms
    WHERE idx = @RoomIdx;

    IF @RoomId IS NULL BREAK;

    -- Ngay luu tru: moi booking cach nhau 3 ngay, bat dau tu 35 ngay truoc
    DECLARE @CheckInDate  DATE          = DATEADD(DAY, -(@i * 3 + 5), CAST(GETDATE() AS DATE));
    DECLARE @CheckOutDate DATE          = DATEADD(DAY, 2, @CheckInDate);
    DECLARE @Nights       INT           = 2;
    DECLARE @RoomCharge   DECIMAL(18,2) = @BasePrice * @Nights;

    -- Lay rating va comment cho lan thu @i
    DECLARE @Rating  TINYINT        = (SELECT rating  FROM @Comments WHERE idx = @i);
    DECLARE @Comment NVARCHAR(500)  = (SELECT comment FROM @Comments WHERE idx = @i);

    -- ── 1. Booking ──────────────────────────────────────────────────
    INSERT INTO dbo.Booking (
        account_id, customer_name, phone, email,
        room_type_id, room_quantity,
        check_in_date, check_out_date,
        total_amount, status, note, created_at
    )
    VALUES (
        @CustomerId, @CustomerName, @CustomerPhone, @CustomerEmail,
        @RoomTypeId, 1,
        @CheckInDate, @CheckOutDate,
        @RoomCharge, N'CheckedOut',
        N'[TEST-FEEDBACK] Booking thu ' + CAST(@i AS NVARCHAR) + N' - Standard Room Review',
        CAST(@CheckInDate AS DATETIME2)
    );

    DECLARE @BookingId INT = SCOPE_IDENTITY();

    -- ── 2. RoomAssignment ────────────────────────────────────────────
    INSERT INTO dbo.RoomAssignment (booking_id, room_id, assigned_by, assigned_at, note)
    VALUES (@BookingId, @RoomId, @ReceptionistId,
            CAST(@CheckInDate AS DATETIME2), N'Phan phong test feedback');

    -- ── 3. CheckIn ──────────────────────────────────────────────────
    INSERT INTO dbo.CheckIn (booking_id, receptionist_id, checked_in_at, notes)
    VALUES (@BookingId, @ReceptionistId,
            CAST(@CheckInDate AS DATETIME2), N'Check-in test feedback');

    -- ── 4. CheckOut ─────────────────────────────────────────────────
    INSERT INTO dbo.CheckOut (
        booking_id, receptionist_id,
        room_charge, service_charge, extra_charge,
        total_amount, amount_paid, remaining_amount,
        payment_method, checked_out_at, notes
    )
    VALUES (
        @BookingId, @ReceptionistId,
        @RoomCharge, 0.00, 0.00,
        @RoomCharge, @RoomCharge, 0.00,
        N'Tien mat',
        CAST(@CheckOutDate AS DATETIME2),
        N'Thanh toan day du (test)'
    );

    -- ── 5. Invoice ──────────────────────────────────────────────────
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES (@BookingId, @CustomerName, @RoomNumber, N'Paid',
            CAST(@CheckOutDate AS DATETIME2));

    DECLARE @InvoiceId INT = SCOPE_IDENTITY();

    -- ── 6. InvoiceItem ──────────────────────────────────────────────
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    VALUES (
        @InvoiceId, N'Room',
        N'Tien phong ' + @RoomNumber + N' (' + CAST(@Nights AS NVARCHAR) + N' dem)',
        @Nights, @BasePrice, @RoomCharge
    );

    -- ── 7. Payment ──────────────────────────────────────────────────
    INSERT INTO dbo.Payment (
        booking_id, invoice_id, sepay_tx_id, amount,
        gateway, reference_code, transaction_date, content
    )
    VALUES (
        @BookingId, @InvoiceId,
        5000000000 + @BookingId,
        @RoomCharge,
        N'Quay le tan',
        N'FBTEST-STD-' + CAST(@BookingId AS NVARCHAR),
        CAST(@CheckOutDate AS DATETIME2),
        N'Thanh toan phong ' + @RoomNumber + N' (Standard test)'
    );

    -- ── 8. Feedback ─────────────────────────────────────────────────
    INSERT INTO dbo.Feedback (booking_id, room_id, account_id, rating, comment, created_at)
    VALUES (
        @BookingId,
        @RoomId,
        @CustomerId,
        @Rating,
        @Comment,
        DATEADD(HOUR, -@i, GETDATE())   -- moi feedback cach nhau 1 gio de sort dung
    );

    SET @i = @i + 1;
END

-- ─── BƯỚC 3: Kiem tra ket qua ────────────────────────────────────────
SELECT
    f.feedback_id   AS [Feedback ID],
    b.booking_id    AS [Booking ID],
    r.room_number   AS [So Phong],
    rt.type_name    AS [Loai Phong],
    f.rating        AS [Rating],
    LEFT(f.comment, 50) AS [Comment (50 ky tu)],
    f.created_at    AS [Thoi Gian]
FROM dbo.Feedback f
JOIN dbo.Booking b      ON f.booking_id = b.booking_id
JOIN dbo.Room r         ON f.room_id    = r.room_id
JOIN dbo.RoomType rt    ON r.type_id    = rt.type_id
WHERE b.note LIKE N'%[TEST-FEEDBACK]%'
ORDER BY f.created_at DESC;

-- Tong ket
SELECT
    COUNT(*)                AS [Tong so Feedback vua them],
    AVG(CAST(f.rating AS DECIMAL(3,1))) AS [Diem TB],
    @RoomTypeId             AS [Room Type ID de test],
    N'Mo trang: /rooms/detail?id=' + CAST(@RoomTypeId AS NVARCHAR) AS [URL path]
FROM dbo.Feedback f
JOIN dbo.Booking b ON f.booking_id = b.booking_id
WHERE b.note LIKE N'%[TEST-FEEDBACK]%';
GO
