-- =====================================================================
-- Script: insert_mock_checkout_10.sql
-- Muc dich: Them 10 booking CheckedOut hoan chinh cho account
--           customer@hotel.com de test chuc nang Feedback (UC-35).
-- Moi booking bao gom day du: Booking - RoomAssignment - CheckIn
--                              - CheckOut - Invoice - InvoiceItem - Payment
-- Chay trong SSMS hoac cong cu quan ly DB.
-- =====================================================================

USE HotelManagementDB;
GO

-- Bien dung chung
DECLARE @CustomerId   INT,
        @CustomerName NVARCHAR(100),
        @CustomerEmail NVARCHAR(100),
        @CustomerPhone NVARCHAR(20),
        @ReceptionistId INT;

SELECT
    @CustomerId    = account_id,
    @CustomerName  = full_name,
    @CustomerEmail = email,
    @CustomerPhone = ISNULL(phone, N'0901234567')
FROM dbo.Account
WHERE email = N'customer@hotel.com';

SELECT TOP 1 @ReceptionistId = account_id
FROM dbo.Account
WHERE email = N'receptionist@hotel.com';

IF @CustomerId IS NULL
BEGIN
    RAISERROR(N'Khong tim thay account customer@hotel.com. Hay chay hotel_management.sql truoc.', 16, 1);
    RETURN;
END

IF @ReceptionistId IS NULL
BEGIN
    RAISERROR(N'Khong tim thay account receptionist@hotel.com. Hay chay hotel_management.sql truoc.', 16, 1);
    RETURN;
END

-- Bang tam: danh sach phong (lay 10 phong khac nhau, is_deleted = 0)
DECLARE @Rooms TABLE (
    idx         INT IDENTITY(1,1),
    room_id     INT,
    room_number NVARCHAR(50),
    type_id     INT,
    base_price  DECIMAL(18,2)
);

INSERT INTO @Rooms (room_id, room_number, type_id, base_price)
SELECT TOP 10
    r.room_id,
    r.room_number,
    r.type_id,
    rt.base_price
FROM dbo.Room r
JOIN dbo.RoomType rt ON r.type_id = rt.type_id
WHERE r.is_deleted = 0
ORDER BY r.room_id;

-- Vong lap them 10 booking
DECLARE @i INT = 1;

WHILE @i <= 10
BEGIN
    DECLARE @RoomId     INT,
            @RoomNumber NVARCHAR(50),
            @TypeId     INT,
            @BasePrice  DECIMAL(18,2);

    SELECT
        @RoomId     = room_id,
        @RoomNumber = room_number,
        @TypeId     = type_id,
        @BasePrice  = base_price
    FROM @Rooms
    WHERE idx = @i;

    IF @RoomId IS NULL BREAK;

    -- Ngay luu tru: booking i check-in (i*3 + 5) ngay truoc, o 2 dem
    DECLARE @CheckInDate  DATE          = DATEADD(day, -(@i * 3 + 5), CAST(GETDATE() AS DATE));
    DECLARE @CheckOutDate DATE          = DATEADD(day, 2, @CheckInDate);
    DECLARE @Nights       INT           = 2;
    DECLARE @RoomCharge   DECIMAL(18,2) = @BasePrice * @Nights;
    DECLARE @Note NVARCHAR(200)         = N'Mock checkout #' + CAST(@i AS NVARCHAR) + N' - test feedback';

    -- 1. Booking
    INSERT INTO dbo.Booking (
        account_id, customer_name, phone, email,
        room_type_id, room_quantity,
        check_in_date, check_out_date,
        total_amount, status, note, created_at
    )
    VALUES (
        @CustomerId, @CustomerName, @CustomerPhone, @CustomerEmail,
        @TypeId, 1,
        @CheckInDate, @CheckOutDate,
        @RoomCharge, N'CheckedOut', @Note,
        CAST(@CheckInDate AS DATETIME2)
    );

    DECLARE @BookingId INT = SCOPE_IDENTITY();

    -- 2. RoomAssignment
    INSERT INTO dbo.RoomAssignment (booking_id, room_id, assigned_by, assigned_at, note)
    VALUES (@BookingId, @RoomId, @ReceptionistId,
            CAST(@CheckInDate AS DATETIME2), N'Phan phong mock checkout');

    -- 3. CheckIn
    INSERT INTO dbo.CheckIn (booking_id, receptionist_id, checked_in_at, notes)
    VALUES (@BookingId, @ReceptionistId,
            CAST(@CheckInDate AS DATETIME2), N'Khach check-in (mock)');

    -- 4. CheckOut
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
        N'Thanh toan day du (mock)'
    );

    -- 5. Invoice
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES (@BookingId, @CustomerName, @RoomNumber, N'Paid',
            CAST(@CheckOutDate AS DATETIME2));

    DECLARE @InvoiceId INT = SCOPE_IDENTITY();

    -- 6. InvoiceItem
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    VALUES (
        @InvoiceId, N'Room',
        N'Tien phong ' + @RoomNumber + N' (' + CAST(@Nights AS NVARCHAR) + N' dem)',
        @Nights, @BasePrice, @RoomCharge
    );

    -- 7. Payment (sepay_tx_id bat dau tu 3 ty de tranh trung voi script cu)
    INSERT INTO dbo.Payment (
        booking_id, invoice_id, sepay_tx_id, amount,
        gateway, reference_code, transaction_date, content
    )
    VALUES (
        @BookingId, @InvoiceId,
        3000000000 + @BookingId,
        @RoomCharge,
        N'Quay le tan',
        N'MOCKREF' + CAST(@BookingId AS NVARCHAR),
        CAST(@CheckOutDate AS DATETIME2),
        N'Thanh toan phong ' + @RoomNumber + N' (mock feedback test)'
    );

    SET @i = @i + 1;
END

-- Ket qua
SELECT
    b.booking_id                AS [Ma Booking],
    b.customer_name             AS [Ten Khach],
    r.room_number               AS [So Phong],
    rt.type_name                AS [Loai Phong],
    b.check_in_date             AS [Check-In],
    b.check_out_date            AS [Check-Out],
    b.total_amount              AS [Tong Tien],
    b.status                    AS [Trang Thai],
    N'San sang test Feedback'   AS [Ghi Chu]
FROM dbo.Booking b
JOIN dbo.RoomAssignment ra ON ra.booking_id = b.booking_id
JOIN dbo.Room r            ON r.room_id     = ra.room_id
JOIN dbo.RoomType rt       ON rt.type_id    = r.type_id
WHERE b.account_id = @CustomerId
  AND b.status     = N'CheckedOut'
  AND b.note LIKE  N'Mock checkout%'
ORDER BY b.booking_id DESC;
GO
