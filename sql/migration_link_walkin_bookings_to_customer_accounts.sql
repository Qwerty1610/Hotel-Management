/* ============================================================
   SQL Migration: Link Existing Walk-in Bookings to Customer Accounts
   
   Purpose:
   Backfill existing bookings where account_id is NULL by matching
   their email against existing active Customer accounts in the database.

   Execution:
   Run manually in SQL Server Management Studio (SSMS) or sqlcmd
   against the HotelManagementDB database.
   ============================================================ */

USE HotelManagementDB;
GO

-- 1. Preview bookings that will be updated
SELECT 
    b.booking_id,
    b.customer_name,
    b.email,
    b.status,
    a.account_id AS matched_account_id,
    a.full_name AS matched_account_name,
    r.role_name
FROM dbo.Booking b
JOIN dbo.Account a ON LOWER(RTRIM(LTRIM(b.email))) = LOWER(RTRIM(LTRIM(a.email)))
JOIN dbo.Role r ON a.role_id = r.role_id
WHERE b.account_id IS NULL
  AND b.email IS NOT NULL
  AND RTRIM(LTRIM(b.email)) <> ''
  AND a.is_active = 1
  AND LOWER(r.role_name) = 'customer';
GO

-- 2. Execute Update Migration
UPDATE b
SET b.account_id = a.account_id
FROM dbo.Booking b
JOIN dbo.Account a ON LOWER(RTRIM(LTRIM(b.email))) = LOWER(RTRIM(LTRIM(a.email)))
JOIN dbo.Role r ON a.role_id = r.role_id
WHERE b.account_id IS NULL
  AND b.email IS NOT NULL
  AND RTRIM(LTRIM(b.email)) <> ''
  AND a.is_active = 1
  AND LOWER(r.role_name) = 'customer';
GO

PRINT 'Migration completed successfully: Existing walk-in bookings linked to Customer accounts.';
GO
