-- Script SQL tạo 1 phòng/đơn đặt phòng đã Check-Out hoàn tất để test chức năng mới.
-- Chạy script này trong SQL Server Management Studio (SSMS) hoặc công cụ quản lý Database của bạn.

USE HotelManagementDB;
GO

-- 1. Tìm thông tin Account, Room sẵn có để liên kết tự động
DECLARE @CustomerId INT, @CustomerName NVARCHAR(100), @CustomerEmail NVARCHAR(100), @CustomerPhone NVARCHAR(20);
SELECT TOP 1 
    @CustomerId = account_id, 
    @CustomerName = full_name, 
    @CustomerEmail = email,
    @CustomerPhone = phone
FROM dbo.Account 
WHERE email = N'customer@hotel.com';

DECLARE @ReceptionistId INT;
SELECT TOP 1 @ReceptionistId = account_id 
FROM dbo.Account 
WHERE email = N'receptionist@hotel.com';

DECLARE @RoomId INT, @RoomNumber NVARCHAR(50), @RoomTypeId INT;
SELECT TOP 1 
    @RoomId = room_id, 
    @RoomNumber = room_number, 
    @RoomTypeId = type_id
FROM dbo.Room 
WHERE is_deleted = 0;

-- 2. Thêm đơn Booking với trạng thái CheckedOut (đã trả phòng)
INSERT INTO dbo.Booking (
    account_id, customer_name, phone, email, 
    room_type_id, room_quantity, 
    check_in_date, check_out_date, 
    total_amount, status, note, created_at
)
VALUES (
    @CustomerId, @CustomerName, @CustomerPhone, @CustomerEmail,
    @RoomTypeId, 1,
    DATEADD(day, -3, CAST(GETDATE() AS DATE)), -- Check-in 3 ngày trước
    DATEADD(day, -1, CAST(GETDATE() AS DATE)), -- Check-out hôm qua
    1500000.00, N'CheckedOut', N'Đơn mẫu đã check out để làm chức năng mới', DATEADD(day, -3, GETDATE())
);

DECLARE @NewBookingId INT = SCOPE_IDENTITY();

-- 3. Phân phòng (RoomAssignment)
INSERT INTO dbo.RoomAssignment (booking_id, room_id, assigned_by, assigned_at, note)
VALUES (@NewBookingId, @RoomId, @ReceptionistId, DATEADD(day, -3, GETDATE()), N'Phân phòng lúc check-in');

-- 4. Thêm thông tin CheckIn
INSERT INTO dbo.CheckIn (booking_id, receptionist_id, checked_in_at, notes)
VALUES (@NewBookingId, @ReceptionistId, DATEADD(day, -3, GETDATE()), N'Khách đã check-in');

-- 5. Thêm thông tin CheckOut
INSERT INTO dbo.CheckOut (
    booking_id, receptionist_id, 
    room_charge, service_charge, extra_charge, 
    total_amount, amount_paid, remaining_amount, 
    payment_method, checked_out_at, notes
)
VALUES (
    @NewBookingId, @ReceptionistId,
    1500000.00, 0.00, 0.00,
    1500000.00, 1500000.00, 0.00,
    N'Tiền mặt', DATEADD(day, -1, GETDATE()), N'Đã check-out và thanh toán đầy đủ'
);

-- 6. Tạo Hóa đơn (Invoice) trạng thái Paid (đã thanh toán)
INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
VALUES (@NewBookingId, @CustomerName, @RoomNumber, N'Paid', DATEADD(day, -1, GETDATE()));

DECLARE @NewInvoiceId INT = SCOPE_IDENTITY();

-- 7. Thêm chi tiết hóa đơn (InvoiceItem)
INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
VALUES (
    @NewInvoiceId, N'Room', 
    N'Tiền phòng ' + @RoomNumber + N' (2 đêm)', 
    2, 750000.00, 1500000.00
);

-- 8. Ghi nhận giao dịch Payment thành công (có sepay_tx_id bắt buộc và không có payment_method)
INSERT INTO dbo.Payment (booking_id, invoice_id, sepay_tx_id, amount, gateway, reference_code, transaction_date, content)
VALUES (
    @NewBookingId, @NewInvoiceId, 
    2000000000 + @NewBookingId, -- sepay_tx_id duy nhất
    1500000.00, N'Quầy lễ tân', 
    N'REF' + CAST(@NewBookingId AS NVARCHAR), 
    DATEADD(day, -1, GETDATE()), 
    N'Thanh toán hóa đơn phòng ' + @RoomNumber
);

-- Kết quả trả về
SELECT 
    @NewBookingId AS [Mã Booking Vừa Tạo], 
    @NewInvoiceId AS [Mã Hóa Đơn Vừa Tạo], 
    @RoomNumber AS [Số Phòng Được Gán],
    N'CheckedOut' AS [Trạng Thái];
