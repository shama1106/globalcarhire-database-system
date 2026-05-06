-- =============================================
-- Author: [Quynh Anh Nguyen 3473095; Shama Praveen c3470623; Leiming Guo c3471779  ]
-- Date: [28/6/2025]
-- Procedure: usp_CreatingBooking
-- Purpose: Book a vehicle for a customer
-- =============================================
----BOOKING PROCEDURE
DROP TYPE IF EXISTS TVP_PricedService;
DROP TYPE IF EXISTS TVP_Vehicle;
DROP TYPE IF EXISTS TVP_Driver;
DROP TYPE IF EXISTS TVP_ExtraService;

-- Table type for Priced Services
CREATE TYPE TVP_PricedService AS TABLE (
    PricedServiceID INT,
    ServiceStart DATE,
    ServiceEnd DATE
);

-- Table type for Vehicles
CREATE TYPE TVP_Vehicle AS TABLE (
    VehicleID INT
);

-- Table type for Drivers
CREATE TYPE TVP_Driver AS TABLE (
    Name VARCHAR(100),
    LicenseInfo VARCHAR(100),
    ContactNumber VARCHAR(20)
);

-- Table type for Extra Services
CREATE TYPE TVP_ExtraService AS TABLE (
    ExtraServiceID INT
);
GO
Drop procedure usp_CreatingBooking
GO
CREATE PROCEDURE usp_CreatingBooking
    @CustomerID INT,
    @HandledBy INT,
    @PaymentMethod VARCHAR(50),
    @Deposit DECIMAL(10,2),
    @BookingMethod VARCHAR(50),
    @PricedServices TVP_PricedService READONLY,
    @Vehicles TVP_Vehicle READONLY,
    @Drivers TVP_Driver READONLY,
    @ExtraServices TVP_ExtraService READONLY
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        ---------------------------------------------
        --Pre-Validations
        ---------------------------------------------

        -- Validate required tables
        IF NOT EXISTS (SELECT 1 FROM @PricedServices)
        BEGIN
            RAISERROR('At least one priced service must be provided.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM @Vehicles)
        BEGIN
            RAISERROR('At least one vehicle must be selected.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM @Drivers)
        BEGIN
            RAISERROR(' At least one driver must be provided.', 16, 1);
            RETURN;
        END

        -- Validate Customer exists
        IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerID = @CustomerID)
        BEGIN
            RAISERROR('Customer not found.', 16, 1);
            RETURN;
        END

        -- Validate Employee exists
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @HandledBy)
        BEGIN
            RAISERROR(' Employee (HandledBy) not found.', 16, 1);
            RETURN;
        END

        -- Validate all PricedServices exist
        IF EXISTS (
            SELECT ps.PricedServiceID
            FROM @PricedServices ps
            LEFT JOIN PricedService p ON ps.PricedServiceID = p.PricedServiceID
            WHERE p.PricedServiceID IS NULL
        )
        BEGIN
            RAISERROR('One or more priced service IDs are invalid.', 16, 1);
            RETURN;
        END

        -- Validate all Vehicles exist
        IF EXISTS (
            SELECT v.VehicleID
            FROM @Vehicles v
            LEFT JOIN Vehicle master ON v.VehicleID = master.VehicleID
            WHERE master.VehicleID IS NULL
        )
        BEGIN
            RAISERROR('One or more vehicle IDs are invalid.', 16, 1);
            RETURN;
        END

        ---------------------------------------------
        -- Step 1: Insert Booking
        ---------------------------------------------

        INSERT INTO Booking (BookingDate, CustomerID, BookingStatus, PaymentMethod, Deposit, HandledBy)
        VALUES (GETDATE(), @CustomerID, 'Confirmed', @PaymentMethod, @Deposit, @HandledBy);

        DECLARE @NewBookingID INT = SCOPE_IDENTITY();

        ---------------------------------------------
        -- Step 2: Validate and Insert Priced Services
        ---------------------------------------------

        IF EXISTS (
            SELECT 1
            FROM @PricedServices ps
            JOIN PricedService p ON ps.PricedServiceID = p.PricedServiceID
            WHERE ps.ServiceStart < p.StartDate OR ps.ServiceEnd > p.EndDate
        )
        BEGIN
            RAISERROR('One or more service dates are outside the valid pricing period.', 16, 1);
            RETURN;
        END

        INSERT INTO BookingService (BookingID, PricedServiceID, ServiceStart, ServiceEnd)
        SELECT @NewBookingID, PricedServiceID, ServiceStart, ServiceEnd
        FROM @PricedServices;

        ---------------------------------------------
        -- Step 3: Validate Vehicle Availability
        ---------------------------------------------

        IF EXISTS (
            SELECT 1
            FROM @Vehicles v
            JOIN BookingVehicle bv ON v.VehicleID = bv.VehicleID
            JOIN Booking b ON b.BookingID = bv.BookingID
            JOIN BookingService bs ON bs.BookingID = b.BookingID
            WHERE b.BookingStatus = 'Confirmed'
              AND EXISTS (
                  SELECT 1 FROM @PricedServices ps
                  WHERE ps.ServiceStart <= bs.ServiceEnd AND ps.ServiceEnd >= bs.ServiceStart
              )
        )
        BEGIN
            RAISERROR('One or more vehicles are already booked for the selected period.', 16, 1);
            RETURN;
        END

        ---------------------------------------------
        -- Step 4: Insert Vehicles, Drivers, Extras
        ---------------------------------------------

        INSERT INTO BookingVehicle (BookingID, VehicleID)
        SELECT @NewBookingID, VehicleID FROM @Vehicles;

        INSERT INTO Driver (BookingID, Name, LicenseInfo, ContactNumber)
        SELECT @NewBookingID, Name, LicenseInfo, ContactNumber FROM @Drivers;

        IF EXISTS (SELECT 1 FROM @ExtraServices)
        BEGIN
            INSERT INTO BookingExtraService (BookingID, ExtraServiceID)
            SELECT @NewBookingID, ExtraServiceID FROM @ExtraServices;
        END

        PRINT 'Booking created successfully. Booking ID: ' + CAST(@NewBookingID AS VARCHAR);
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;

