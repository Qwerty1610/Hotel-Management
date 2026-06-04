/*
    HotelManagementDB - Service Management SQL (NO icon_key)
    Purpose:
    - Create database HotelManagementDB if missing
    - Keep/create login tables Role and Account for current project
    - Add HotelService table for Manager > Service Management
    - Remove icon_key usage because the group will not implement service icons

    SQL Server
*/

USE master;
GO

IF DB_ID(N'HotelManagementDB') IS NULL
BEGIN
    CREATE DATABASE HotelManagementDB;
END
GO

USE HotelManagementDB;
GO

/* ============================================================
   1. LOGIN TABLES - create only if missing
   ============================================================ */

IF OBJECT_ID(N'dbo.Role', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Role (
        role_id INT IDENTITY(1,1) PRIMARY KEY,
        role_name NVARCHAR(50) NOT NULL UNIQUE,
        description NVARCHAR(255) NULL
    );
END
GO

IF OBJECT_ID(N'dbo.Account', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Account (
        account_id INT IDENTITY(1,1) PRIMARY KEY,
        email NVARCHAR(100) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        full_name NVARCHAR(100) NOT NULL,
        role_id INT NOT NULL,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_Account_Role FOREIGN KEY (role_id) REFERENCES dbo.Role(role_id)
    );
END
GO

IF OBJECT_ID(N'dbo.PasswordReset', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordReset (
        id INT IDENTITY(1,1) PRIMARY KEY,
        email NVARCHAR(100) NOT NULL,
        token NVARCHAR(20) NOT NULL,
        expiry_time DATETIME2 NOT NULL,
        is_used BIT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END
GO


/* Add roles only if they are missing */
IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE role_name = N'Admin')
    INSERT INTO dbo.Role (role_name, description) VALUES (N'Admin', N'System administrator account');

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE role_name = N'Manager')
    INSERT INTO dbo.Role (role_name, description) VALUES (N'Manager', N'Hotel manager account');

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE role_name = N'Receptionist')
    INSERT INTO dbo.Role (role_name, description) VALUES (N'Receptionist', N'Receptionist/front desk account');

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE role_name = N'Housekeeping')
    INSERT INTO dbo.Role (role_name, description) VALUES (N'Housekeeping', N'Housekeeping staff account');

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE role_name = N'Customer')
    INSERT INTO dbo.Role (role_name, description) VALUES (N'Customer', N'Customer account');
GO

/*
    Test login accounts:
    admin@hotel.com         / admin123
    manager@hotel.com       / manager123
    receptionist@hotel.com  / receptionist123
    housekeeping@hotel.com  / housekeeping123
    customer@hotel.com      / customer123

    Passwords are BCrypt hashes because LoginController uses BCrypt.checkpw().
*/

IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'admin@hotel.com')
BEGIN
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active)
    VALUES (
        N'admin@hotel.com',
        N'$2a$10$vlNauaFagl8VNLAmR63Aw.vQhdP/IeCzFlSxSq8qVaTCO9.yWPV9y',
        N'Admin User',
        (SELECT role_id FROM dbo.Role WHERE role_name = N'Admin'),
        1
    );
END

IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'manager@hotel.com')
BEGIN
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active)
    VALUES (
        N'manager@hotel.com',
        N'$2a$10$uboMc8oQx3w6pJKL09IR/uUJkK0EtSLWkOI5rJ.f.vxB4gqwkpIMK',
        N'Hotel Manager',
        (SELECT role_id FROM dbo.Role WHERE role_name = N'Manager'),
        1
    );
END

IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'receptionist@hotel.com')
BEGIN
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active)
    VALUES (
        N'receptionist@hotel.com',
        N'$2a$10$Ipfqp4fFVKoRkHueD6lmsuDLjrxE.XC4u.GKU6.DMu1GTBEE2hbIC',
        N'Receptionist User',
        (SELECT role_id FROM dbo.Role WHERE role_name = N'Receptionist'),
        1
    );
END

IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'housekeeping@hotel.com')
BEGIN
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active)
    VALUES (
        N'housekeeping@hotel.com',
        N'$2a$10$1bFDXwvgUoDiLV6T08vFTO9S7DXcq4Wbh2Qv31D1BRAemXY3rvKl.',
        N'Housekeeping User',
        (SELECT role_id FROM dbo.Role WHERE role_name = N'Housekeeping'),
        1
    );
END

IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'customer@hotel.com')
BEGIN
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active)
    VALUES (
        N'customer@hotel.com',
        N'$2a$10$NKZuHMq4Tm0LJgtKBK401.FauytTSiIiR0h6BqGve1RFpZXzcjxeC',
        N'Customer User',
        (SELECT role_id FROM dbo.Role WHERE role_name = N'Customer'),
        1
    );
END
GO

/* Ensure Account has phone column required by application */
IF COL_LENGTH(N'dbo.Account', N'phone') IS NULL
BEGIN
    ALTER TABLE dbo.Account ADD phone NVARCHAR(20) NULL;
END
GO

/* Create Customer table used by registration flow if missing */
IF OBJECT_ID(N'dbo.Customer', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customer (
        customer_id INT IDENTITY(1,1) PRIMARY KEY,
        account_id INT NOT NULL UNIQUE,
        loyalty_points INT NOT NULL DEFAULT 0,
        membership_level NVARCHAR(50) NOT NULL DEFAULT N'Standard',
        CONSTRAINT FK_Customer_Account FOREIGN KEY (account_id) REFERENCES dbo.Account(account_id)
    );
END
GO

/* Seed Customer rows for existing seeded accounts if missing */
IF NOT EXISTS (SELECT 1 FROM dbo.Customer WHERE account_id = (SELECT account_id FROM dbo.Account WHERE email = N'customer@hotel.com'))
BEGIN
    INSERT INTO dbo.Customer (account_id, loyalty_points, membership_level)
    VALUES ((SELECT account_id FROM dbo.Account WHERE email = N'customer@hotel.com'), 0, N'Standard');
END
GO

/* ============================================================
   2. SERVICE MANAGEMENT TABLE - NO icon_key
   ============================================================ */

/*
    HotelService: main table for Manager > Service Management.
    Fields match the simplified UI:
    - service_name: Ten dich vu
    - description: Mo ta dich vu
    - price: Don gia
    - unit: Don vi tinh
    - is_active: Trang thai bat/tat

    icon_key is intentionally removed.
*/
IF OBJECT_ID(N'dbo.HotelService', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.HotelService (
        service_id INT IDENTITY(1,1) PRIMARY KEY,
        service_name NVARCHAR(150) NOT NULL,
        description NVARCHAR(500) NULL,
        price DECIMAL(18,2) NOT NULL DEFAULT 0,
        unit NVARCHAR(50) NOT NULL,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NULL,
        CONSTRAINT CK_HotelService_Price CHECK (price >= 0)
    );
END
GO

/* If an old HotelService table already has icon_key from a previous script, remove it. */
IF COL_LENGTH(N'dbo.HotelService', N'icon_key') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HotelService DROP COLUMN icon_key;
END
GO

/* Make sure required columns exist if the table was created manually before. */
IF COL_LENGTH(N'dbo.HotelService', N'service_name') IS NULL
    ALTER TABLE dbo.HotelService ADD service_name NVARCHAR(150) NULL;
GO

IF COL_LENGTH(N'dbo.HotelService', N'description') IS NULL
    ALTER TABLE dbo.HotelService ADD description NVARCHAR(500) NULL;
GO

IF COL_LENGTH(N'dbo.HotelService', N'price') IS NULL
    ALTER TABLE dbo.HotelService ADD price DECIMAL(18,2) NOT NULL CONSTRAINT DF_HotelService_Price DEFAULT 0;
GO

IF COL_LENGTH(N'dbo.HotelService', N'unit') IS NULL
    ALTER TABLE dbo.HotelService ADD unit NVARCHAR(50) NOT NULL CONSTRAINT DF_HotelService_Unit DEFAULT N'/lượt';
GO

IF COL_LENGTH(N'dbo.HotelService', N'is_active') IS NULL
    ALTER TABLE dbo.HotelService ADD is_active BIT NOT NULL CONSTRAINT DF_HotelService_IsActive DEFAULT 1;
GO

IF COL_LENGTH(N'dbo.HotelService', N'created_at') IS NULL
    ALTER TABLE dbo.HotelService ADD created_at DATETIME2 NOT NULL CONSTRAINT DF_HotelService_CreatedAt DEFAULT SYSDATETIME();
GO

IF COL_LENGTH(N'dbo.HotelService', N'updated_at') IS NULL
    ALTER TABLE dbo.HotelService ADD updated_at DATETIME2 NULL;
GO

/* Optional: prevent duplicate service names */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_HotelService_ServiceName'
      AND object_id = OBJECT_ID(N'dbo.HotelService')
)
BEGIN
    CREATE UNIQUE INDEX UX_HotelService_ServiceName
    ON dbo.HotelService(service_name);
END
GO

/* Seed sample services for testing */
IF NOT EXISTS (SELECT 1 FROM dbo.HotelService WHERE service_name = N'Bữa sáng Buffet')
BEGIN
    INSERT INTO dbo.HotelService (service_name, description, price, unit, is_active)
    VALUES (N'Bữa sáng Buffet', N'Buffet sáng tại nhà hàng khách sạn, phục vụ từ 06:30 đến 09:30.', 150000, N'/khách', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.HotelService WHERE service_name = N'Giặt ủi quần áo')
BEGIN
    INSERT INTO dbo.HotelService (service_name, description, price, unit, is_active)
    VALUES (N'Giặt ủi quần áo', N'Dịch vụ giặt ủi quần áo cho khách lưu trú trong khách sạn.', 50000, N'/kg', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.HotelService WHERE service_name = N'Đưa đón sân bay')
BEGIN
    INSERT INTO dbo.HotelService (service_name, description, price, unit, is_active)
    VALUES (N'Đưa đón sân bay', N'Dịch vụ xe đưa đón khách từ sân bay về khách sạn hoặc ngược lại.', 350000, N'/chuyến', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.HotelService WHERE service_name = N'Spa thư giãn')
BEGIN
    INSERT INTO dbo.HotelService (service_name, description, price, unit, is_active)
    VALUES (N'Spa thư giãn', N'Dịch vụ massage và chăm sóc sức khỏe cơ bản cho khách.', 300000, N'/lượt', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.HotelService WHERE service_name = N'Phòng Gym')
BEGIN
    INSERT INTO dbo.HotelService (service_name, description, price, unit, is_active)
    VALUES (N'Phòng Gym', N'Sử dụng khu vực tập gym trong khách sạn.', 80000, N'/ngày', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.HotelService WHERE service_name = N'Hồ bơi')
BEGIN
    INSERT INTO dbo.HotelService (service_name, description, price, unit, is_active)
    VALUES (N'Hồ bơi', N'Sử dụng khu vực hồ bơi của khách sạn.', 100000, N'/ngày', 1);
END
GO

/* ============================================================
   3. USEFUL TEST QUERIES
   ============================================================ */

/* List services for Manager page */
SELECT
    service_id,
    service_name,
    description,
    price,
    unit,
    is_active,
    created_at,
    updated_at
FROM dbo.HotelService
ORDER BY service_id;
GO

/* List accounts for login test */
SELECT
    a.account_id,
    a.email,
    a.full_name,
    r.role_name,
    a.is_active,
    a.created_at
FROM dbo.Account a
JOIN dbo.Role r ON a.role_id = r.role_id
ORDER BY a.account_id;
GO

/* ============================================================
   3. ROOM TYPE AND ROOM TABLES
   ============================================================ */

IF OBJECT_ID(N'dbo.RoomType', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoomType (
        type_id INT IDENTITY(1,1) PRIMARY KEY,
        type_name NVARCHAR(100) NOT NULL UNIQUE,
        base_price DECIMAL(18,2) NOT NULL DEFAULT 0,
        price_per_hour DECIMAL(18,2) NOT NULL DEFAULT 0,
        deposit_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
        capacity INT NOT NULL DEFAULT 2,
        description NVARCHAR(500) NULL,
        area NVARCHAR(50) NULL,
        bed_type NVARCHAR(100) NULL
    );
END
GO

IF OBJECT_ID(N'dbo.RoomImage', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoomImage (
        image_id INT IDENTITY(1,1) PRIMARY KEY,
        type_id INT NOT NULL,
        image_url NVARCHAR(MAX) NOT NULL,
        CONSTRAINT FK_RoomImage_RoomType FOREIGN KEY (type_id) REFERENCES dbo.RoomType(type_id) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.Amenity', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Amenity (
        amenity_id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL UNIQUE,
        icon_url NVARCHAR(100) NULL
    );
END
GO

IF OBJECT_ID(N'dbo.RoomType_Amenity', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoomType_Amenity (
        type_id INT NOT NULL,
        amenity_id INT NOT NULL,
        PRIMARY KEY (type_id, amenity_id),
        CONSTRAINT FK_RTA_RoomType FOREIGN KEY (type_id) REFERENCES dbo.RoomType(type_id) ON DELETE CASCADE,
        CONSTRAINT FK_RTA_Amenity FOREIGN KEY (amenity_id) REFERENCES dbo.Amenity(amenity_id) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.Room', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Room (
        room_id INT IDENTITY(1,1) PRIMARY KEY,
        room_number NVARCHAR(50) NOT NULL UNIQUE,
        type_id INT NOT NULL,
        status NVARCHAR(50) NOT NULL DEFAULT N'Available',
        floor NVARCHAR(50) NOT NULL DEFAULT N'Tầng 1',
        CONSTRAINT FK_Room_RoomType FOREIGN KEY (type_id) REFERENCES dbo.RoomType(type_id) ON DELETE CASCADE
    );
END
GO

/* If floor column is missing in Room table (due to old table version), add it */
IF COL_LENGTH(N'dbo.Room', N'floor') IS NULL
BEGIN
    ALTER TABLE dbo.Room ADD floor NVARCHAR(50) NOT NULL DEFAULT N'Tầng 1';
END
GO

/* Seed Amenities */
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'Wifi miễn phí')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'Wifi miễn phí', N'fa-wifi');
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'Điều hòa')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'Điều hòa', N'fa-snowflake');
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'Tivi')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'Tivi', N'fa-tv');
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'Tivi HD')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'Tivi HD', N'fa-tv');
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'View thành phố')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'View thành phố', N'fa-city');
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'Mini bar')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'Mini bar', N'fa-glass');
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'Bồn tắm')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'Bồn tắm', N'fa-bath');
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'Ban công')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'Ban công', N'fa-door-open');
IF NOT EXISTS (SELECT 1 FROM dbo.Amenity WHERE name = N'Máy pha cà phê')
    INSERT INTO dbo.Amenity (name, icon_url) VALUES (N'Máy pha cà phê', N'fa-mug-hot');
GO

/* Seed RoomTypes */
IF NOT EXISTS (SELECT 1 FROM dbo.RoomType WHERE type_name = N'Phòng Standard')
BEGIN
    INSERT INTO dbo.RoomType (type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type)
    VALUES (N'Phòng Standard', 750000, 100000, 10, 2, N'Phòng tiêu chuẩn phù hợp cho khách đi công tác hoặc nghỉ ngắn ngày.', N'25 m²', N'1 Giường Queen');
END

IF NOT EXISTS (SELECT 1 FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe')
BEGIN
    INSERT INTO dbo.RoomType (type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type)
    VALUES (N'Phòng Deluxe', 1200000, 180000, 10, 2, N'Phòng rộng rãi, nội thất hiện đại, có view thành phố cực kỳ lung linh.', N'45 m²', N'1 Giường đôi lớn');
END

IF NOT EXISTS (SELECT 1 FROM dbo.RoomType WHERE type_name = N'Phòng Family')
BEGIN
    INSERT INTO dbo.RoomType (type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type)
    VALUES (N'Phòng Family', 1800000, 250000, 10, 4, N'Phòng gia đình với không gian lớn, phù hợp nhóm bạn hoặc gia đình nhỏ.', N'60 m²', N'2 Giường đôi');
END

IF NOT EXISTS (SELECT 1 FROM dbo.RoomType WHERE type_name = N'Phòng Suite')
BEGIN
    INSERT INTO dbo.RoomType (type_name, base_price, price_per_hour, deposit_percent, capacity, description, area, bed_type)
    VALUES (N'Phòng Suite', 2800000, 400000, 20, 3, N'Phòng cao cấp có khu tiếp khách riêng, bồn tắm và ban công.', N'75 m²', N'1 Giường King');
END
GO

/* Seed RoomImages */
IF NOT EXISTS (SELECT 1 FROM dbo.RoomImage WHERE type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard'))
BEGIN
    INSERT INTO dbo.RoomImage (type_id, image_url) VALUES 
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard'), N'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80');
END

IF NOT EXISTS (SELECT 1 FROM dbo.RoomImage WHERE type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'))
BEGIN
    INSERT INTO dbo.RoomImage (type_id, image_url) VALUES 
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), N'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80');
END

IF NOT EXISTS (SELECT 1 FROM dbo.RoomImage WHERE type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'))
BEGIN
    INSERT INTO dbo.RoomImage (type_id, image_url) VALUES 
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'), N'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80');
END

IF NOT EXISTS (SELECT 1 FROM dbo.RoomImage WHERE type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'))
BEGIN
    INSERT INTO dbo.RoomImage (type_id, image_url) VALUES 
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), N'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80');
END
GO

/* Seed RoomType_Amenity mapping */
-- Standard Amenities
IF NOT EXISTS (SELECT 1 FROM dbo.RoomType_Amenity WHERE type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard'))
BEGIN
    INSERT INTO dbo.RoomType_Amenity (type_id, amenity_id) VALUES
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Wifi miễn phí')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Điều hòa')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Tivi'));
END

-- Deluxe Amenities
IF NOT EXISTS (SELECT 1 FROM dbo.RoomType_Amenity WHERE type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'))
BEGIN
    INSERT INTO dbo.RoomType_Amenity (type_id, amenity_id) VALUES
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Wifi miễn phí')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Điều hòa')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Tivi')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'View thành phố')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Mini bar'));
END

-- Family Amenities
IF NOT EXISTS (SELECT 1 FROM dbo.RoomType_Amenity WHERE type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'))
BEGIN
    INSERT INTO dbo.RoomType_Amenity (type_id, amenity_id) VALUES
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Wifi miễn phí')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Điều hòa')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Tivi')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Mini bar'));
END

-- Suite Amenities
IF NOT EXISTS (SELECT 1 FROM dbo.RoomType_Amenity WHERE type_id = (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'))
BEGIN
    INSERT INTO dbo.RoomType_Amenity (type_id, amenity_id) VALUES
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Wifi miễn phí')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Điều hòa')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Tivi')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Bồn tắm')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'View thành phố')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Mini bar')),
    ((SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), (SELECT amenity_id FROM dbo.Amenity WHERE name = N'Ban công'));
END
GO

/* Seed Rooms
   Lưu ý: KHÔNG xóa phòng trước khi chèn. Các phòng được tham chiếu bởi
   CustomerRequest (FK_CustomerRequest_Room) nên DELETE sẽ lỗi khóa ngoại khi
   chạy lại; ngoài ra room_id là IDENTITY, xóa-chèn-lại sẽ làm đổi id và hỏng
   mọi tham chiếu. Các IF NOT EXISTS bên dưới đã đảm bảo idempotent. */
IF NOT EXISTS (SELECT 1 FROM dbo.Room WHERE room_number = N'101')
    INSERT INTO dbo.Room (room_number, type_id, status, floor) VALUES (N'101', (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard'), N'Available', N'Tầng 1');
IF NOT EXISTS (SELECT 1 FROM dbo.Room WHERE room_number = N'102')
    INSERT INTO dbo.Room (room_number, type_id, status, floor) VALUES (N'102', (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Standard'), N'Available', N'Tầng 1');
IF NOT EXISTS (SELECT 1 FROM dbo.Room WHERE room_number = N'201')
    INSERT INTO dbo.Room (room_number, type_id, status, floor) VALUES (N'201', (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), N'Available', N'Tầng 2');
IF NOT EXISTS (SELECT 1 FROM dbo.Room WHERE room_number = N'202')
    INSERT INTO dbo.Room (room_number, type_id, status, floor) VALUES (N'202', (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), N'Available', N'Tầng 2');
IF NOT EXISTS (SELECT 1 FROM dbo.Room WHERE room_number = N'204')
    INSERT INTO dbo.Room (room_number, type_id, status, floor) VALUES (N'204', (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Deluxe'), N'Occupied', N'Tầng 2');
IF NOT EXISTS (SELECT 1 FROM dbo.Room WHERE room_number = N'301')
    INSERT INTO dbo.Room (room_number, type_id, status, floor) VALUES (N'301', (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'), N'Available', N'Tầng 3');
IF NOT EXISTS (SELECT 1 FROM dbo.Room WHERE room_number = N'305')
    INSERT INTO dbo.Room (room_number, type_id, status, floor) VALUES (N'305', (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Family'), N'Cleaning', N'Tầng 3');
IF NOT EXISTS (SELECT 1 FROM dbo.Room WHERE room_number = N'401')
    INSERT INTO dbo.Room (room_number, type_id, status, floor) VALUES (N'401', (SELECT type_id FROM dbo.RoomType WHERE type_name = N'Phòng Suite'), N'Maintenance', N'Tầng 4');
GO

/* Fix existing rows that still have 'Tầng VIP' */
UPDATE dbo.Room SET floor = N'Tầng 4' WHERE floor = N'Tầng VIP';
GO

/* ============================================================
   4. BOOKING TABLE 
   ============================================================ */

IF OBJECT_ID(N'dbo.Booking', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Booking (
        booking_id INT IDENTITY(1,1) PRIMARY KEY,
        account_id INT NULL,
        customer_name NVARCHAR(100) NOT NULL,
        room_type_id INT NULL,
        room_quantity INT NOT NULL DEFAULT 1,
        check_in_date DATE NOT NULL,
        check_out_date DATE NOT NULL,
        total_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
        status NVARCHAR(50) NOT NULL DEFAULT N'Pending',
        note NVARCHAR(500) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NULL,
        CONSTRAINT FK_Booking_Account FOREIGN KEY (account_id) REFERENCES dbo.Account(account_id),
        CONSTRAINT FK_Booking_RoomType FOREIGN KEY (room_type_id) REFERENCES dbo.RoomType(type_id)
    );
END
GO

/* Seed Mock Data cho Booking 
*/

-- 1. Trạng thái PENDING (Chờ xử lý)
IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Nguyễn Văn A' AND check_in_date = '2026-06-05')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note)
    VALUES (NULL, N'Nguyễn Văn A', 1, 1, '2026-06-05', '2026-06-07', 1500000, N'Pending', N'Khách dặn lấy phòng tầng cao, view đẹp.');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Trần Thị B' AND check_in_date = '2026-06-10')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note)
    VALUES (NULL, N'Trần Thị B', 2, 2, '2026-06-10', '2026-06-12', 4800000, N'Pending', N'Đoàn khách VIP.');
END
GO

-- 2. Trạng thái CONFIRMED (Đã xác nhận)
IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Customer User' AND check_in_date = '2026-06-15')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note)
    VALUES (5, N'Customer User', 3, 1, '2026-06-15', '2026-06-18', 5400000, N'Confirmed', N'Đã đặt cọc 50% qua VNPay.');
END
GO

-- 3. Trạng thái REJECTED (Từ chối)
IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Lê Văn C' AND check_in_date = '2026-05-20')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note)
    VALUES (NULL, N'Lê Văn C', 4, 1, '2026-05-20', '2026-05-22', 5600000, N'Rejected', N'Đã hết phòng Suite trong khoảng thời gian này.');
END
GO

-- 4. Trạng thái CANCELLED (Đã huỷ)
IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Phạm Thị D' AND check_in_date = '2026-05-25')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note)
    VALUES (NULL, N'Phạm Thị D', 1, 1, '2026-05-25', '2026-05-27', 1500000, N'Cancelled', N'Khách hàng chủ động gọi điện báo huỷ.');
END
GO

-- 5. Trạng thái CHECKED IN (Đã nhận phòng)
IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Ngô Thị F' AND check_in_date = '2026-05-30')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note)
    VALUES (NULL, N'Ngô Thị F', 1, 2, '2026-05-30', '2026-06-02', 3000000, N'CheckedIn', N'Khách đang lưu trú.');
END
GO

-- 6. Trạng thái CHECKED OUT (Đã trả phòng)
IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE customer_name = N'Hoàng Văn E' AND check_in_date = '2026-05-28')
BEGIN
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note)
    VALUES (NULL, N'Hoàng Văn E', 2, 1, '2026-05-28', '2026-05-30', 2400000, N'CheckedOut', N'Đã hoàn tất thanh toán.');
END
GO

/* ============================================================
   5. CUSTOMER REQUESTS & STAFF WORK TRACKING (Manager)
   ============================================================ */

/* 5.1 Thêm cột trạng thái làm việc cho nhân viên (Account).
   Giá trị: Active / OnBreak / Offline. Mặc định Offline. */
IF COL_LENGTH(N'dbo.Account', N'work_status') IS NULL
    ALTER TABLE dbo.Account ADD work_status NVARCHAR(30) NOT NULL CONSTRAINT DF_Account_WorkStatus DEFAULT N'Offline';
GO

/* 5.2 Bảng yêu cầu của khách hàng.
   - room_id        : phòng phát sinh yêu cầu
   - title          : nội dung yêu cầu (vd: Thêm khăn tắm)
   - priority       : Low / Medium / High / Urgent
   - status         : Pending / InProgress / Completed / Cancelled
   - assigned_staff_id : nhân viên Housekeeping được giao (NULL = chưa gán)
   - created_at     : thời gian yêu cầu (dùng để sắp xếp mặc định)
   - completed_at   : thời điểm hoàn thành (dùng đếm công việc theo ngày/tháng) */
IF OBJECT_ID(N'dbo.CustomerRequest', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CustomerRequest (
        request_id INT IDENTITY(1,1) PRIMARY KEY,
        room_id INT NULL,
        title NVARCHAR(200) NOT NULL,
        description NVARCHAR(500) NULL,
        priority NVARCHAR(20) NOT NULL DEFAULT N'Medium',
        status NVARCHAR(20) NOT NULL DEFAULT N'Pending',
        assigned_staff_id INT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NULL,
        completed_at DATETIME2 NULL,
        CONSTRAINT FK_CustomerRequest_Room FOREIGN KEY (room_id) REFERENCES dbo.Room(room_id),
        CONSTRAINT FK_CustomerRequest_Staff FOREIGN KEY (assigned_staff_id) REFERENCES dbo.Account(account_id),
        CONSTRAINT CK_CustomerRequest_Priority CHECK (priority IN (N'Low', N'Medium', N'High', N'Urgent')),
        CONSTRAINT CK_CustomerRequest_Status CHECK (status IN (N'Pending', N'InProgress', N'Completed', N'Cancelled'))
    );
END
GO

/* 5.3 Seed thêm nhân viên Housekeeping (mật khẩu: housekeeping123) với trạng thái đa dạng */
IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'hk1@hotel.com')
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active, work_status)
    VALUES (N'hk1@hotel.com', N'$2a$10$1bFDXwvgUoDiLV6T08vFTO9S7DXcq4Wbh2Qv31D1BRAemXY3rvKl.', N'Trần Thị Lan',
            (SELECT role_id FROM dbo.Role WHERE role_name = N'Housekeeping'), 1, N'Active');

IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'hk2@hotel.com')
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active, work_status)
    VALUES (N'hk2@hotel.com', N'$2a$10$1bFDXwvgUoDiLV6T08vFTO9S7DXcq4Wbh2Qv31D1BRAemXY3rvKl.', N'Nguyễn Văn Hùng',
            (SELECT role_id FROM dbo.Role WHERE role_name = N'Housekeeping'), 1, N'OnBreak');

IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'hk3@hotel.com')
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active, work_status)
    VALUES (N'hk3@hotel.com', N'$2a$10$1bFDXwvgUoDiLV6T08vFTO9S7DXcq4Wbh2Qv31D1BRAemXY3rvKl.', N'Lê Thị Mai',
            (SELECT role_id FROM dbo.Role WHERE role_name = N'Housekeeping'), 1, N'Active');

IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = N'hk4@hotel.com')
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active, work_status)
    VALUES (N'hk4@hotel.com', N'$2a$10$1bFDXwvgUoDiLV6T08vFTO9S7DXcq4Wbh2Qv31D1BRAemXY3rvKl.', N'Phạm Văn Nam',
            (SELECT role_id FROM dbo.Role WHERE role_name = N'Housekeeping'), 1, N'Offline');
GO

/* Đảm bảo tài khoản housekeeping gốc cũng ở trạng thái Active để demo */
UPDATE dbo.Account SET work_status = N'Active'
WHERE email = N'housekeeping@hotel.com' AND work_status = N'Offline';
GO

/* 5.4 Seed yêu cầu khách hàng mẫu (chỉ thêm nếu bảng đang rỗng) */
IF NOT EXISTS (SELECT 1 FROM dbo.CustomerRequest)
BEGIN
    INSERT INTO dbo.CustomerRequest (room_id, title, description, priority, status, assigned_staff_id, created_at, completed_at)
    VALUES
    -- Đang chờ xử lý (chưa gán)
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'204'), N'Yêu cầu thêm khăn tắm',
        N'Khách yêu cầu thêm 2 khăn tắm lớn.', N'Medium', N'Pending', NULL,
        DATEADD(MINUTE, -25, SYSDATETIME()), NULL),
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'301'), N'Điều hòa không mát',
        N'Khách phản ánh điều hòa chạy nhưng không mát.', N'High', N'Pending', NULL,
        DATEADD(MINUTE, -50, SYSDATETIME()), NULL),
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'101'), N'Nước nóng yếu',
        N'Vòi sen ra nước nóng rất yếu vào buổi sáng.', N'Urgent', N'Pending', NULL,
        DATEADD(HOUR, -2, SYSDATETIME()), NULL),
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'202'), N'Yêu cầu dọn phòng sớm',
        N'Khách muốn được dọn phòng trước 11h.', N'Low', N'Pending', NULL,
        DATEADD(HOUR, -3, SYSDATETIME()), NULL),
    -- Đang thực hiện (đã gán)
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'102'), N'Thay ga giường',
        N'Khách yêu cầu thay ga và vỏ gối mới.', N'Medium', N'InProgress',
        (SELECT account_id FROM dbo.Account WHERE email = N'hk1@hotel.com'),
        DATEADD(HOUR, -4, SYSDATETIME()), NULL),
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'305'), N'Bổ sung nước uống',
        N'Bổ sung 4 chai nước suối trong minibar.', N'Low', N'InProgress',
        (SELECT account_id FROM dbo.Account WHERE email = N'hk3@hotel.com'),
        DATEADD(HOUR, -5, SYSDATETIME()), NULL),
    -- Đã hoàn thành hôm nay (đếm theo ngày)
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'201'), N'Vệ sinh nhà tắm',
        N'Khách yêu cầu vệ sinh lại nhà tắm.', N'Medium', N'Completed',
        (SELECT account_id FROM dbo.Account WHERE email = N'hk1@hotel.com'),
        DATEADD(HOUR, -8, SYSDATETIME()), DATEADD(HOUR, -6, SYSDATETIME())),
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'401'), N'Thay bóng đèn',
        N'Bóng đèn phòng ngủ bị cháy.', N'High', N'Completed',
        (SELECT account_id FROM dbo.Account WHERE email = N'hk3@hotel.com'),
        DATEADD(HOUR, -10, SYSDATETIME()), DATEADD(HOUR, -9, SYSDATETIME())),
    -- Đã hoàn thành trước đó trong tháng (đếm theo tháng)
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'101'), N'Giặt nhanh quần áo',
        N'Khách gửi giặt nhanh 1 bộ vest.', N'Medium', N'Completed',
        (SELECT account_id FROM dbo.Account WHERE email = N'hk1@hotel.com'),
        DATEADD(DAY, -6, SYSDATETIME()), DATEADD(DAY, -6, SYSDATETIME())),
    -- Đã huỷ
    ((SELECT room_id FROM dbo.Room WHERE room_number = N'202'), N'Đặt thêm giường phụ',
        N'Khách đổi ý, không cần giường phụ nữa.', N'Low', N'Cancelled', NULL,
        DATEADD(DAY, -1, SYSDATETIME()), NULL);
END
GO

/* Test query: danh sách yêu cầu kèm phòng và nhân viên được giao */
SELECT cr.request_id, rm.room_number, cr.title, cr.priority, cr.status,
       acc.full_name AS staff_name, cr.created_at, cr.completed_at
FROM dbo.CustomerRequest cr
LEFT JOIN dbo.Room rm ON cr.room_id = rm.room_id
LEFT JOIN dbo.Account acc ON cr.assigned_staff_id = acc.account_id
ORDER BY cr.created_at DESC;
GO

/* ============================================================
   6. INVOICE MANAGEMENT (Manager)
   ============================================================ */

/* 6.1 Hóa đơn (header).
   - booking_id     : liên kết tới Booking (NULL nếu hóa đơn lẻ)
   - room_number    : số phòng (lưu kèm để hiển thị)
   - status         : Pending / Paid / Refunding / Refunded / Cancelled
   Tổng tiền hóa đơn = SUM(InvoiceItem.amount), tính khi truy vấn. */
IF OBJECT_ID(N'dbo.Invoice', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Invoice (
        invoice_id INT IDENTITY(1,1) PRIMARY KEY,
        booking_id INT NULL,
        customer_name NVARCHAR(100) NOT NULL,
        room_number NVARCHAR(50) NULL,
        status NVARCHAR(20) NOT NULL DEFAULT N'Pending',
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NULL,
        CONSTRAINT FK_Invoice_Booking FOREIGN KEY (booking_id) REFERENCES dbo.Booking(booking_id),
        CONSTRAINT CK_Invoice_Status CHECK (status IN (N'Pending', N'Paid', N'Refunding', N'Refunded', N'Cancelled'))
    );
END
GO

/* 6.2 Dòng chi tiết hóa đơn.
   - item_type : Room (tiền phòng) / Service (dịch vụ thêm) / Surcharge (phụ phí) */
IF OBJECT_ID(N'dbo.InvoiceItem', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.InvoiceItem (
        item_id INT IDENTITY(1,1) PRIMARY KEY,
        invoice_id INT NOT NULL,
        item_type NVARCHAR(20) NOT NULL,
        description NVARCHAR(200) NOT NULL,
        quantity INT NOT NULL DEFAULT 1,
        unit_price DECIMAL(18,2) NOT NULL DEFAULT 0,
        amount DECIMAL(18,2) NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_InvoiceItem_Invoice FOREIGN KEY (invoice_id) REFERENCES dbo.Invoice(invoice_id) ON DELETE CASCADE,
        CONSTRAINT CK_InvoiceItem_Type CHECK (item_type IN (N'Room', N'Service', N'Surcharge'))
    );
END
GO

/* 6.3 Bản ghi hoàn tiền (refund). */
IF OBJECT_ID(N'dbo.Refund', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Refund (
        refund_id INT IDENTITY(1,1) PRIMARY KEY,
        invoice_id INT NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        reason NVARCHAR(500) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT FK_Refund_Invoice FOREIGN KEY (invoice_id) REFERENCES dbo.Invoice(invoice_id) ON DELETE CASCADE,
        CONSTRAINT CK_Refund_Amount CHECK (amount > 0)
    );
END
GO

/* 6.4 Seed hóa đơn mẫu (chỉ chạy khi bảng rỗng). */
IF NOT EXISTS (SELECT 1 FROM dbo.Invoice)
BEGIN
    DECLARE @id INT;

    /* HĐ1 - Pending - Nguyễn Văn A - phòng 101 */
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES ((SELECT TOP 1 booking_id FROM dbo.Booking WHERE customer_name = N'Nguyễn Văn A'),
            N'Nguyễn Văn A', N'101', N'Pending', DATEADD(DAY, -2, SYSDATETIME()));
    SET @id = SCOPE_IDENTITY();
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) VALUES
        (@id, N'Room',    N'Phòng Standard (2 đêm)', 2, 750000, 1500000),
        (@id, N'Service', N'Bữa sáng Buffet',        2, 150000, 300000);

    /* HĐ2 - Pending - Trần Thị B - phòng 201 */
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES ((SELECT TOP 1 booking_id FROM dbo.Booking WHERE customer_name = N'Trần Thị B'),
            N'Trần Thị B', N'201', N'Pending', DATEADD(DAY, -1, SYSDATETIME()));
    SET @id = SCOPE_IDENTITY();
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) VALUES
        (@id, N'Room', N'Phòng Deluxe x2 (2 đêm)', 4, 1200000, 4800000);

    /* HĐ3 - Paid - Customer User - phòng 305 - có phụ phí */
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES ((SELECT TOP 1 booking_id FROM dbo.Booking WHERE customer_name = N'Customer User'),
            N'Customer User', N'305', N'Paid', DATEADD(DAY, -4, SYSDATETIME()));
    SET @id = SCOPE_IDENTITY();
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) VALUES
        (@id, N'Room',      N'Phòng Family (3 đêm)', 3, 1800000, 5400000),
        (@id, N'Service',   N'Đưa đón sân bay',      1, 350000,  350000),
        (@id, N'Surcharge', N'Trả phòng muộn (late check-out)', 1, 200000, 200000);

    /* HĐ4 - Paid - Ngô Thị F - phòng 102 */
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES ((SELECT TOP 1 booking_id FROM dbo.Booking WHERE customer_name = N'Ngô Thị F'),
            N'Ngô Thị F', N'102', N'Paid', DATEADD(DAY, -3, SYSDATETIME()));
    SET @id = SCOPE_IDENTITY();
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) VALUES
        (@id, N'Room',    N'Phòng Standard x2 (3 đêm)', 6, 500000, 3000000),
        (@id, N'Service', N'Giặt ủi quần áo',           5, 50000,  250000);

    /* HĐ5 - Refunding - Lê Văn C - phòng 401 (booking bị từ chối, phải hoàn cọc) */
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES ((SELECT TOP 1 booking_id FROM dbo.Booking WHERE customer_name = N'Lê Văn C'),
            N'Lê Văn C', N'401', N'Refunding', DATEADD(DAY, -5, SYSDATETIME()));
    SET @id = SCOPE_IDENTITY();
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) VALUES
        (@id, N'Room', N'Phòng Suite (2 đêm)', 2, 2800000, 5600000);

    /* HĐ6 - Refunding - Phạm Thị D - phòng 101 (khách huỷ, phải hoàn cọc) */
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES ((SELECT TOP 1 booking_id FROM dbo.Booking WHERE customer_name = N'Phạm Thị D'),
            N'Phạm Thị D', N'101', N'Refunding', DATEADD(DAY, -6, SYSDATETIME()));
    SET @id = SCOPE_IDENTITY();
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) VALUES
        (@id, N'Room', N'Phòng Standard (2 đêm)', 2, 750000, 1500000);

    /* HĐ7 - Refunded - Hoàng Văn E - phòng 202 (đã hoàn tiền một phần) */
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    VALUES ((SELECT TOP 1 booking_id FROM dbo.Booking WHERE customer_name = N'Hoàng Văn E'),
            N'Hoàng Văn E', N'202', N'Refunded', DATEADD(DAY, -7, SYSDATETIME()));
    SET @id = SCOPE_IDENTITY();
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount) VALUES
        (@id, N'Room',      N'Phòng Deluxe (2 đêm)', 2, 1200000, 2400000),
        (@id, N'Surcharge', N'Hư hỏng nội thất (vỡ ấm đun)', 1, 300000, 300000);
    INSERT INTO dbo.Refund (invoice_id, amount, reason, created_at)
    VALUES (@id, 500000, N'Hoàn phí dịch vụ khách không sử dụng.', DATEADD(DAY, -6, SYSDATETIME()));
END
GO

/* Test query: danh sách hóa đơn kèm tổng tiền và tổng đã hoàn */
SELECT i.invoice_id, i.customer_name, i.room_number, i.status, i.created_at,
       (SELECT ISNULL(SUM(amount),0) FROM dbo.InvoiceItem ii WHERE ii.invoice_id = i.invoice_id) AS total_amount,
       (SELECT ISNULL(SUM(amount),0) FROM dbo.Refund rf WHERE rf.invoice_id = i.invoice_id) AS refunded_amount
FROM dbo.Invoice i
ORDER BY i.created_at DESC;
GO

/* ============================================================
   7. SEED 30 KHÁCH HÀNG + BOOKING + HÓA ĐƠN TƯƠNG ỨNG
   Mỗi khách: 1 tài khoản (role Customer) + 1 hồ sơ Customer +
   1 booking + 1 hóa đơn (kèm dòng chi tiết / phụ phí / hoàn tiền).
   Ngày nhận phòng trải đều trong 2026-05-07 .. 2026-06-14 để biểu đồ
   Dashboard và trang Hóa đơn có nhiều dữ liệu.
   Mật khẩu mọi tài khoản: customer123
   Idempotent: chỉ chạy khi chưa có booking đánh dấu note = 'SEED30'.
   ============================================================ */
IF NOT EXISTS (SELECT 1 FROM dbo.Booking WHERE note = N'SEED30')
BEGIN
    DECLARE @seed TABLE (
        email NVARCHAR(100), full_name NVARCHAR(100), phone NVARCHAR(20),
        type_id INT, room_number NVARCHAR(50), qty INT,
        check_in DATE, check_out DATE,
        bstatus NVARCHAR(50), istatus NVARCHAR(20),
        bf BIT, air BIT,
        surcharge DECIMAL(18,2), surcharge_desc NVARCHAR(200),
        refund DECIMAL(18,2), refund_reason NVARCHAR(500),
        loyalty INT, membership NVARCHAR(50)
    );

    INSERT INTO @seed (email, full_name, phone, type_id, room_number, qty, check_in, check_out, bstatus, istatus, bf, air, surcharge, surcharge_desc, refund, refund_reason, loyalty, membership) VALUES
    (N'cust01@hotel.com', N'Trần Anh Khoa',    N'0901000001', 1, N'103', 1, '2026-05-07','2026-05-09', N'CheckedOut', N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                          120, N'Silver'),
    (N'cust02@hotel.com', N'Nguyễn Bảo Châu',  N'0901000002', 2, N'203', 1, '2026-05-07','2026-05-10', N'CheckedOut', N'Paid',      1,1, 0,      NULL,                                  0,      NULL,                                          300, N'Gold'),
    (N'cust03@hotel.com', N'Lê Gia Bảo',       N'0901000003', 3, N'302', 1, '2026-05-08','2026-05-11', N'CheckedOut', N'Paid',      0,0, 200000, N'Trả phòng muộn (late check-out)',     0,      NULL,                                           50, N'Standard'),
    (N'cust04@hotel.com', N'Phạm Thuỳ Dung',   N'0901000004', 1, N'104', 2, '2026-05-08','2026-05-09', N'CheckedOut', N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                           80, N'Standard'),
    (N'cust05@hotel.com', N'Hoàng Minh Tuấn',  N'0901000005', 4, N'402', 1, '2026-05-09','2026-05-12', N'CheckedOut', N'Paid',      0,1, 0,      NULL,                                  0,      NULL,                                          500, N'Gold'),
    (N'cust06@hotel.com', N'Vũ Khánh Linh',    N'0901000006', 2, N'205', 2, '2026-05-10','2026-05-13', N'CheckedOut', N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                          210, N'Silver'),
    (N'cust07@hotel.com', N'Đỗ Hải Nam',       N'0901000007', 1, N'106', 1, '2026-05-11','2026-05-12', N'CheckedOut', N'Paid',      0,0, 0,      NULL,                                  0,      NULL,                                           30, N'Standard'),
    (N'cust08@hotel.com', N'Bùi Thanh Hà',     N'0901000008', 3, N'303', 1, '2026-05-12','2026-05-15', N'CheckedOut', N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                          260, N'Silver'),
    (N'cust09@hotel.com', N'Đặng Quốc Việt',   N'0901000009', 2, N'206', 1, '2026-05-13','2026-05-16', N'CheckedOut', N'Paid',      0,1, 0,      NULL,                                  0,      NULL,                                           95, N'Standard'),
    (N'cust10@hotel.com', N'Mai Phương Thảo',  N'0901000010', 4, N'403', 1, '2026-05-14','2026-05-17', N'CheckedOut', N'Paid',      1,0, 300000, N'Hư hỏng nội thất (vỡ kính)',          0,      NULL,                                          600, N'Gold'),
    (N'cust11@hotel.com', N'Ngô Văn Sơn',      N'0901000011', 1, N'107', 1, '2026-05-15','2026-05-16', N'CheckedOut', N'Paid',      0,0, 0,      NULL,                                  0,      NULL,                                           40, N'Standard'),
    (N'cust12@hotel.com', N'Lý Thị Hồng',      N'0901000012', 3, N'304', 1, '2026-05-16','2026-05-19', N'CheckedOut', N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                          180, N'Silver'),
    (N'cust13@hotel.com', N'Trịnh Đức Anh',    N'0901000013', 2, N'207', 2, '2026-05-18','2026-05-21', N'CheckedOut', N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                          220, N'Silver'),
    (N'cust14@hotel.com', N'Cao Mỹ Linh',      N'0901000014', 4, N'404', 1, '2026-05-20','2026-05-23', N'CheckedOut', N'Paid',      0,1, 0,      NULL,                                  0,      NULL,                                          410, N'Gold'),
    (N'cust15@hotel.com', N'Phan Văn Đạt',     N'0901000015', 1, N'108', 1, '2026-05-21','2026-05-22', N'CheckedOut', N'Paid',      0,0, 0,      NULL,                                  0,      NULL,                                           25, N'Standard'),
    (N'cust16@hotel.com', N'Hồ Ngọc Mai',      N'0901000016', 3, N'306', 1, '2026-05-22','2026-05-25', N'CheckedOut', N'Paid',      1,0, 150000, N'Giặt ủi phát sinh',                   0,      NULL,                                          200, N'Silver'),
    (N'cust17@hotel.com', N'Dương Quốc Huy',   N'0901000017', 2, N'208', 1, '2026-05-25','2026-05-28', N'CheckedOut', N'Paid',      1,1, 0,      NULL,                                  0,      NULL,                                          130, N'Standard'),
    (N'cust18@hotel.com', N'Tô Thanh Tùng',    N'0901000018', 4, N'405', 1, '2026-05-26','2026-05-29', N'CheckedOut', N'Paid',      0,0, 0,      NULL,                                  0,      NULL,                                          350, N'Gold'),
    (N'cust19@hotel.com', N'Lưu Thị Cẩm',      N'0901000019', 3, N'307', 1, '2026-05-28','2026-05-31', N'CheckedOut', N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                          160, N'Silver'),
    (N'cust20@hotel.com', N'Hà Văn Phúc',      N'0901000020', 2, N'209', 2, '2026-05-29','2026-06-01', N'CheckedOut', N'Refunded',  1,0, 0,      NULL,                                  500000, N'Hoàn phí dịch vụ khách không sử dụng',        240, N'Silver'),
    (N'cust21@hotel.com', N'Quách Bảo Ngọc',   N'0901000021', 1, N'109', 1, '2026-06-03','2026-06-06', N'CheckedIn',  N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                           70, N'Standard'),
    (N'cust22@hotel.com', N'Vương Tuấn Kiệt',  N'0901000022', 2, N'210', 2, '2026-06-04','2026-06-07', N'CheckedIn',  N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                          150, N'Silver'),
    (N'cust23@hotel.com', N'Đoàn Thị Yến',     N'0901000023', 4, N'406', 1, '2026-06-04','2026-06-06', N'CheckedIn',  N'Paid',      0,1, 0,      NULL,                                  0,      NULL,                                          320, N'Gold'),
    (N'cust24@hotel.com', N'Lâm Chí Thành',    N'0901000024', 3, N'308', 1, '2026-06-05','2026-06-08', N'CheckedIn',  N'Paid',      1,0, 0,      NULL,                                  0,      NULL,                                          110, N'Standard'),
    (N'cust25@hotel.com', N'Trương Khải Minh', N'0901000025', 2, N'211', 1, '2026-06-08','2026-06-11', N'Confirmed',  N'Pending',   0,0, 0,      NULL,                                  0,      NULL,                                           60, N'Standard'),
    (N'cust26@hotel.com', N'Kiều Anh Thư',     N'0901000026', 3, N'309', 1, '2026-06-10','2026-06-13', N'Confirmed',  N'Pending',   0,0, 0,      NULL,                                  0,      NULL,                                           90, N'Standard'),
    (N'cust27@hotel.com', N'Tạ Quang Dũng',    N'0901000027', 4, N'407', 1, '2026-06-12','2026-06-15', N'Confirmed',  N'Pending',   0,0, 0,      NULL,                                  0,      NULL,                                          280, N'Silver'),
    (N'cust28@hotel.com', N'Phùng Mỹ Duyên',   N'0901000028', 1, N'110', 1, '2026-06-09','2026-06-11', N'Pending',    N'Pending',   0,0, 0,      NULL,                                  0,      NULL,                                           20, N'Standard'),
    (N'cust29@hotel.com', N'Châu Văn Lộc',     N'0901000029', 2, N'212', 1, '2026-06-14','2026-06-16', N'Rejected',   N'Refunding', 0,0, 0,      NULL,                                  0,      NULL,                                           45, N'Standard'),
    (N'cust30@hotel.com', N'Đinh Thị Bích',    N'0901000030', 3, N'310', 1, '2026-06-07','2026-06-09', N'Cancelled',  N'Cancelled', 0,0, 0,      NULL,                                  0,      NULL,                                           15, N'Standard');

    /* 1) Tài khoản khách hàng (role Customer) — mật khẩu: customer123 */
    INSERT INTO dbo.Account (email, password, full_name, role_id, is_active, phone)
    SELECT s.email,
           N'$2a$10$NKZuHMq4Tm0LJgtKBK401.FauytTSiIiR0h6BqGve1RFpZXzcjxeC',
           s.full_name,
           (SELECT role_id FROM dbo.Role WHERE role_name = N'Customer'),
           1, s.phone
    FROM @seed s
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Account a WHERE a.email = s.email);

    /* 2) Hồ sơ Customer */
    INSERT INTO dbo.Customer (account_id, loyalty_points, membership_level)
    SELECT a.account_id, s.loyalty, s.membership
    FROM @seed s
    JOIN dbo.Account a ON a.email = s.email
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Customer c WHERE c.account_id = a.account_id);

    /* 3) Booking — total_amount = giá nền × số đêm × số phòng (chỉ tiền phòng) */
    INSERT INTO dbo.Booking (account_id, customer_name, room_type_id, room_quantity, check_in_date, check_out_date, total_amount, status, note)
    SELECT a.account_id, s.full_name, s.type_id, s.qty, s.check_in, s.check_out,
           rt.base_price * DATEDIFF(DAY, s.check_in, s.check_out) * s.qty,
           s.bstatus, N'SEED30'
    FROM @seed s
    JOIN dbo.Account a ON a.email = s.email
    JOIN dbo.RoomType rt ON rt.type_id = s.type_id;

    /* 4) Hóa đơn — 1 hóa đơn / booking */
    INSERT INTO dbo.Invoice (booking_id, customer_name, room_number, status, created_at)
    SELECT b.booking_id, s.full_name, s.room_number, s.istatus, CAST(s.check_in AS DATETIME2)
    FROM @seed s
    JOIN dbo.Account a ON a.email = s.email
    JOIN dbo.Booking b ON b.account_id = a.account_id AND b.note = N'SEED30';

    /* 5a) Dòng tiền phòng */
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    SELECT inv.invoice_id, N'Room',
           CONCAT(rt.type_name, N' (', DATEDIFF(DAY, s.check_in, s.check_out), N' đêm',
                  CASE WHEN s.qty > 1 THEN CONCAT(N' x', s.qty, N' phòng') ELSE N'' END, N')'),
           DATEDIFF(DAY, s.check_in, s.check_out) * s.qty,
           rt.base_price,
           rt.base_price * DATEDIFF(DAY, s.check_in, s.check_out) * s.qty
    FROM @seed s
    JOIN dbo.Account a ON a.email = s.email
    JOIN dbo.Booking b ON b.account_id = a.account_id AND b.note = N'SEED30'
    JOIN dbo.Invoice inv ON inv.booking_id = b.booking_id
    JOIN dbo.RoomType rt ON rt.type_id = s.type_id;

    /* 5b) Dòng bữa sáng Buffet (nếu có) */
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    SELECT inv.invoice_id, N'Service', N'Bữa sáng Buffet',
           DATEDIFF(DAY, s.check_in, s.check_out) * s.qty, 150000,
           150000 * DATEDIFF(DAY, s.check_in, s.check_out) * s.qty
    FROM @seed s
    JOIN dbo.Account a ON a.email = s.email
    JOIN dbo.Booking b ON b.account_id = a.account_id AND b.note = N'SEED30'
    JOIN dbo.Invoice inv ON inv.booking_id = b.booking_id
    WHERE s.bf = 1;

    /* 5c) Dòng đưa đón sân bay (nếu có) */
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    SELECT inv.invoice_id, N'Service', N'Đưa đón sân bay', 1, 350000, 350000
    FROM @seed s
    JOIN dbo.Account a ON a.email = s.email
    JOIN dbo.Booking b ON b.account_id = a.account_id AND b.note = N'SEED30'
    JOIN dbo.Invoice inv ON inv.booking_id = b.booking_id
    WHERE s.air = 1;

    /* 5d) Dòng phụ phí (nếu có) */
    INSERT INTO dbo.InvoiceItem (invoice_id, item_type, description, quantity, unit_price, amount)
    SELECT inv.invoice_id, N'Surcharge', s.surcharge_desc, 1, s.surcharge, s.surcharge
    FROM @seed s
    JOIN dbo.Account a ON a.email = s.email
    JOIN dbo.Booking b ON b.account_id = a.account_id AND b.note = N'SEED30'
    JOIN dbo.Invoice inv ON inv.booking_id = b.booking_id
    WHERE s.surcharge > 0;

    /* 6) Hoàn tiền (nếu có) */
    INSERT INTO dbo.Refund (invoice_id, amount, reason, created_at)
    SELECT inv.invoice_id, s.refund, s.refund_reason, CAST(s.check_out AS DATETIME2)
    FROM @seed s
    JOIN dbo.Account a ON a.email = s.email
    JOIN dbo.Booking b ON b.account_id = a.account_id AND b.note = N'SEED30'
    JOIN dbo.Invoice inv ON inv.booking_id = b.booking_id
    WHERE s.refund > 0;
END
GO

/* Test query: tổng hợp dữ liệu vừa seed */
SELECT
    (SELECT COUNT(*) FROM dbo.Booking WHERE note = N'SEED30')                         AS seed_bookings,
    (SELECT COUNT(*) FROM dbo.Account a JOIN dbo.Role r ON a.role_id = r.role_id
        WHERE r.role_name = N'Customer' AND a.email LIKE N'cust%@hotel.com')          AS seed_customers,
    (SELECT COUNT(*) FROM dbo.Invoice i
        JOIN dbo.Booking b ON i.booking_id = b.booking_id WHERE b.note = N'SEED30')   AS seed_invoices;
GO