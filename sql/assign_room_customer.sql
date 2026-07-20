-- SQL Script to assign Room 101 to Customer User's CheckedIn booking (ID 38)
-- and update existing booking service requests to display the assigned room.

USE HotelManagementDB;
GO

-- 1. Check if the booking (ID 38) has room assignment, if not, assign Room 101 (room_id = 1)
IF NOT EXISTS (SELECT 1 FROM dbo.RoomAssignment WHERE booking_id = 38)
BEGIN
    INSERT INTO dbo.RoomAssignment (booking_id, room_id, assigned_by, assigned_at, note)
    VALUES (
        38, 
        1, 
        (SELECT account_id FROM dbo.Account WHERE email = N'receptionist@hotel.com'), 
        SYSDATETIME(), 
        N'Assigned Room 101 to CheckedIn Booking 38 (Customer User)'
    );
    PRINT 'Room 101 successfully assigned to Booking 38.';
END
ELSE
BEGIN
    PRINT 'Room assignment for Booking 38 already exists.';
END
GO

-- 2. Update existing BookingServiceRequest rows for booking 38 to link to Room 101 (room_id = 1)
UPDATE dbo.BookingServiceRequest
SET room_id = 1
WHERE booking_id = 38 AND room_id IS NULL;

PRINT 'Updated existing Booking Service Requests for Booking 38.';
GO
