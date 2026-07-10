/* ============================================================
   SEPAY PAYMENT - Bảng ghi nhận giao dịch thanh toán online
   Chạy script này trên DB hiện có (hoặc chạy lại hotel_management.sql
   bản mới — cả hai đều idempotent).

   - Mỗi dòng = 1 giao dịch tiền vào do SePay webhook báo về, đã khớp
     được với một hóa đơn (nội dung CK "HD{invoice_id}") HOẶC một khoản
     tiền cọc đặt phòng (nội dung CK "COC{booking_id}").
   - sepay_tx_id UNIQUE để chống ghi trùng khi SePay gửi lại webhook.
   ============================================================ */
USE HotelManagementDB;
GO

IF OBJECT_ID(N'dbo.Payment', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Payment (
        payment_id INT IDENTITY(1,1) PRIMARY KEY,
        invoice_id INT NULL,                  -- thanh toán hóa đơn (HD...)
        booking_id INT NULL,                  -- tiền cọc đặt phòng (COC...)
        sepay_tx_id BIGINT NOT NULL,          -- ID giao dịch phía SePay
        amount DECIMAL(18,2) NOT NULL,        -- số tiền khách chuyển
        gateway NVARCHAR(100) NULL,           -- ngân hàng (BIDV, MBBank...)
        reference_code NVARCHAR(100) NULL,    -- mã tham chiếu của ngân hàng
        content NVARCHAR(500) NULL,           -- nội dung chuyển khoản gốc
        transaction_date DATETIME2 NULL,      -- thời điểm giao dịch tại ngân hàng
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_Payment_Invoice FOREIGN KEY (invoice_id) REFERENCES dbo.Invoice(invoice_id),
        CONSTRAINT FK_Payment_Booking FOREIGN KEY (booking_id) REFERENCES dbo.Booking(booking_id),
        CONSTRAINT UQ_Payment_SepayTx UNIQUE (sepay_tx_id),
        CONSTRAINT CK_Payment_Amount CHECK (amount > 0),
        CONSTRAINT CK_Payment_Target CHECK (invoice_id IS NOT NULL OR booking_id IS NOT NULL)
    );
END
GO

/* Nâng cấp bảng Payment cũ (tạo trước khi có thanh toán cọc):
   invoice_id NOT NULL -> NULL, thêm cột booking_id.
   Dùng EXEC() vì cột booking_id chưa tồn tại lúc SQL Server biên dịch batch —
   tham chiếu trực tiếp sẽ báo "Invalid column name". */
IF COL_LENGTH(N'dbo.Payment', N'booking_id') IS NULL
BEGIN
    EXEC(N'ALTER TABLE dbo.Payment ALTER COLUMN invoice_id INT NULL');
    EXEC(N'ALTER TABLE dbo.Payment ADD booking_id INT NULL');
    EXEC(N'ALTER TABLE dbo.Payment ADD CONSTRAINT FK_Payment_Booking
        FOREIGN KEY (booking_id) REFERENCES dbo.Booking(booking_id)');
    EXEC(N'ALTER TABLE dbo.Payment ADD CONSTRAINT CK_Payment_Target
        CHECK (invoice_id IS NOT NULL OR booking_id IS NOT NULL)');
END
GO
