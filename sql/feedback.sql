USE HotelManagementDB;
GO

IF OBJECT_ID(N'dbo.Feedback', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Feedback (
        feedback_id INT IDENTITY(1,1) PRIMARY KEY,
        booking_id INT NOT NULL,
        room_id INT NOT NULL,
        account_id INT NOT NULL,
        rating TINYINT NOT NULL,
        comment NVARCHAR(1000) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NULL,

        CONSTRAINT FK_Feedback_Booking
            FOREIGN KEY (booking_id)
            REFERENCES dbo.Booking(booking_id),

        CONSTRAINT FK_Feedback_Room
            FOREIGN KEY (room_id)
            REFERENCES dbo.Room(room_id),

        CONSTRAINT FK_Feedback_Account
            FOREIGN KEY (account_id)
            REFERENCES dbo.Account(account_id),

        CONSTRAINT CK_Feedback_Rating
            CHECK (rating BETWEEN 1 AND 5),

        CONSTRAINT UQ_Feedback_Booking_Room
            UNIQUE (booking_id, room_id)
    );
END
GO
