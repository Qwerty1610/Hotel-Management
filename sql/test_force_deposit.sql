-- ================================================================
-- TEST SCRIPT - HotelManagementDB
-- Dung de test tinh nang Receptionist:
--   1. Force coc -> Nut "Xac nhan duyet" duoc mo khoa
--   2. Them service/surcharge -> Xem chi tiet hoa don checkout
-- ================================================================

USE HotelManagementDB;
GO

-- ================================================================
-- BUOC 0: Xem booking Pending nao chua duoc coc
-- ================================================================
SELECT
    b.booking_id,
    b.customer_name,
    b.status,
    b.total_amount,
    ROUND(b.total_amount * 0.3, 0)          AS deposit_required,
    ISNULL(SUM(p.amount), 0)                AS total_paid,
    CASE
        WHEN ISNULL(SUM(p.amount), 0) >= ROUND(b.total_amount * 0.3, 0)
        THEN '>> DA COC - Nut se duoc mo'
        ELSE '!! CHUA COC - Nut van bi khoa'
    END                                     AS deposit_status
FROM dbo.Booking b
LEFT JOIN dbo.Payment p ON p.booking_id = b.booking_id
WHERE b.status IN ('Pending', 'Confirmed')
GROUP BY b.booking_id, b.customer_name, b.status, b.total_amount
ORDER BY b.booking_id DESC;
GO

-- ================================================================
-- BUOC 1: FORCE COC cho mot booking
-- >>> SUA SO DUOI: doi 99 thanh booking_id ban muon test <<<
-- ================================================================
DECLARE @BID   INT            = 99;   -- << DOI SO NAY
DECLARE @DEP   DECIMAL(18,2);
DECLARE @TXID  BIGINT;

SELECT @DEP = ROUND(total_amount * 0.3, 0)
FROM   dbo.Booking WHERE booking_id = @BID;

-- Sinh fake SePay TX ID (am de khong trung voi tx that)
SET @TXID = -1 * ABS(CAST(CAST(NEWID() AS VARBINARY(8)) AS BIGINT));

INSERT INTO dbo.Payment (booking_id, invoice_id, sepay_tx_id, amount,
                          gateway, reference_code, content, created_at)
VALUES (@BID, NULL, @TXID, @DEP,
        N'Manual/Test',
        N'TEST-COC-' + CAST(@BID AS NVARCHAR),
        N'COC' + CAST(@BID AS NVARCHAR) + N' - Force deposit test',
        SYSDATETIME());

PRINT N'[OK] Da them coc ' + CAST(@DEP AS NVARCHAR) + N' VND cho Booking #' + CAST(@BID AS NVARCHAR);
PRINT N'     -> Reload trang /receptionist/booking/process?bookingId=' + CAST(@BID AS NVARCHAR);
GO

-- ================================================================
-- BUOC 1.5 (Tuy chon): TAO HOA DON PENDING DE TEST KHACH HANG THANH TOAN 70% CON LAI
-- Vi mac dinh he thong chi tao hoa don luc Check-out, nen neu muon test
-- tinh nang "Hoa don cho thanh toan" o phia Khach hang, chay doan nay:
-- >>> SUA SO DUOI: doi 99 thanh booking_id cua ban <<<
-- ================================================================
/*
DECLARE @BID_INV INT = 99;   -- << DOI SO NAY
DECLARE @TOTAL   DECIMAL(18,2);
DECLARE @NEW_INV INT;

SELECT @TOTAL = total_amount FROM dbo.Booking WHERE booking_id = @BID_INV;

-- Kiem tra xem da co hoa don chua
IF NOT EXISTS (SELECT 1 FROM dbo.Invoice WHERE booking_id = @BID_INV)
BEGIN
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES (@BID_INV, (SELECT customer_name FROM dbo.Booking WHERE booking_id = @BID_INV), NULL, N'Pending', SYSDATETIME());
    
    SET @NEW_INV = SCOPE_IDENTITY();
    
    -- Them item Tien phong
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    VALUES (@NEW_INV, N'Room', N'Tiền phòng', 1, @TOTAL, @TOTAL);
    
    PRINT N'[OK] Da tao Hoa don (Pending) cho Booking #' + CAST(@BID_INV AS NVARCHAR);
    PRINT N'     -> Vao trang Khach hang -> Hoa don cho thanh toan se thay hoa don nay (chi hien thi so tien 70% con lai do da tru coc).';
END
ELSE
BEGIN
    PRINT N'[!] Booking #' + CAST(@BID_INV AS NVARCHAR) + N' da co hoa don roi.';
END
*/
GO

-- ================================================================
-- BUOC 2 (tuy chon): Them dich vu / phu phi vao hoa don CheckedIn
-- de xem chi tiet trong trang Checkout
-- >>> SUA SO DUOI: doi 99 thanh booking_id da CheckedIn <<<
-- ================================================================
/*
DECLARE @BID2 INT = 99;   -- << DOI SO NAY (booking da CheckedIn)
DECLARE @INV  INT;
SELECT @INV = invoice_id FROM dbo.Invoice WHERE booking_id = @BID2;

IF @INV IS NULL
BEGIN
    PRINT N'[!] Booking #' + CAST(@BID2 AS NVARCHAR) + N' chua co Invoice. Hay check lai.';
END
ELSE
BEGIN
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    VALUES
        (@INV, 'Service',   N'Nuoc suoi Dasani 500ml',       3,  15000,   45000),
        (@INV, 'Service',   N'Giat la quan ao (1 bo)',        2,  80000,  160000),
        (@INV, 'Service',   N'Minibar - Bia Heineken',        4,  35000,  140000),
        (@INV, 'Surcharge', N'Phu phi tra phong tre (2h)',    1, 200000,  200000),
        (@INV, 'Surcharge', N'Phu phi hu hong: Remote TV',   1, 350000,  350000);

    PRINT N'[OK] Da them 5 dong dich vu / phu phi cho Invoice #' + CAST(@INV AS NVARCHAR);
    PRINT N'     -> Mo trang /receptionist/checkout?bookingId=' + CAST(@BID2 AS NVARCHAR);
END
*/
GO

-- ================================================================
-- BUOC 3: FORCE THANH TOAN HOA DON cho mot booking
-- >>> SUA SO DUOI: doi 99 thanh booking_id ban muon test <<<
-- ================================================================
/*
DECLARE @BID_PAY INT = 99;   -- << DOI SO NAY
DECLARE @INV_ID INT;
DECLARE @TOTAL_INV DECIMAL(18,2);
DECLARE @PAID_DEP DECIMAL(18,2);
DECLARE @REMAINING DECIMAL(18,2);
DECLARE @TXID_PAY BIGINT;

SELECT @INV_ID = invoice_id FROM dbo.Invoice WHERE booking_id = @BID_PAY AND status = N'Pending';

IF @INV_ID IS NULL
BEGIN
    PRINT N'[!] Booking #' + CAST(@BID_PAY AS NVARCHAR) + N' chua co hoa don Pending hoac khong ton tai. Hay tao hoa don truoc (BUOC 1.5).';
END
ELSE
BEGIN
    -- Tinh toan so tien con lai can thanh toan
    SELECT @TOTAL_INV = ISNULL(SUM(amount), 0) FROM dbo.InvoiceItem WHERE invoice_id = @INV_ID;
    SELECT @PAID_DEP = ISNULL(SUM(amount), 0) FROM dbo.Payment WHERE booking_id = @BID_PAY AND invoice_id IS NULL;
    SET @REMAINING = @TOTAL_INV - @PAID_DEP;

    IF @REMAINING <= 0
    BEGIN
        PRINT N'[!] Hoa don nay da duoc thanh toan du hoac khong con no.';
    END
    ELSE
    BEGIN
        -- Sinh fake SePay TX ID (am de khong trung voi tx that)
        SET @TXID_PAY = -1 * ABS(CAST(CAST(NEWID() AS VARBINARY(8)) AS BIGINT));

        INSERT INTO dbo.Payment (booking_id, invoice_id, sepay_tx_id, amount,
                                  gateway, reference_code, content, created_at)
        VALUES (@BID_PAY, @INV_ID, @TXID_PAY, @REMAINING,
                N'Manual/Test',
                N'TEST-PAY-' + CAST(@INV_ID AS NVARCHAR),
                N'PAY' + CAST(@INV_ID AS NVARCHAR) + N' - Force invoice payment test',
                SYSDATETIME());
                
        -- Cap nhat trang thai hoa don (neu can thiet)
        UPDATE dbo.Invoice SET status = N'Paid' WHERE invoice_id = @INV_ID;

        PRINT N'[OK] Da thanh toan ' + CAST(@REMAINING AS NVARCHAR) + N' VND cho Hoa don #' + CAST(@INV_ID AS NVARCHAR) + N' cua Booking #' + CAST(@BID_PAY AS NVARCHAR);
        PRINT N'     -> Reload trang "Thanh toan" hoac "Hoa don cho thanh toan" de kiem tra.';
    END
END
*/
GO

-- ================================================================
-- CLEANUP: Xoa du lieu test khi xong
-- >>> SUA SO DUOI: doi 99 thanh booking_id da dung de test <<<
-- ================================================================
/*
DECLARE @BID3 INT = 99;   -- << DOI SO NAY
DELETE FROM dbo.Payment
WHERE booking_id = @BID3 AND gateway = N'Manual/Test';

DELETE FROM dbo.InvoiceItem
WHERE invoice_id IN (SELECT invoice_id FROM dbo.Invoice WHERE booking_id = @BID3)
  AND description LIKE '%(Test)%' OR description LIKE N'Nuoc suoi Dasani%'
     OR description LIKE N'Giat la%' OR description LIKE N'Minibar%'
     OR description LIKE N'Phu phi tra phong%' OR description LIKE N'Phu phi hu hong%';

PRINT N'[OK] Da xoa du lieu test cho Booking #' + CAST(@BID3 AS NVARCHAR);
*/
GO
