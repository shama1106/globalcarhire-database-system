
-- Drop existing tables if they exist (in correct order to handle foreign keys)
DROP TABLE IF EXISTS Invoice, ReturnDetails, BookingExtraService, ExtraService, Driver,
    BookingVehicle, BookingService, Booking, PricedService, PackageService, RegularService,
    Service, Vehicle, VehicleCategory, Employee, Branch, Customer, LoyaltyTier;

-- ===========================
-- LoyaltyTier Table
-- ===========================
CREATE TABLE LoyaltyTier (
    TierID INT PRIMARY KEY,
    TierName VARCHAR(20) NOT NULL,
    DiscountRate DECIMAL(5,2) NOT NULL
);

-- ===========================
-- Customer Table
-- ===========================
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    DriverLicenseNo VARCHAR(30) NOT NULL UNIQUE,
    Country VARCHAR(50),
    TierID INT NULL,
    FOREIGN KEY (TierID) REFERENCES LoyaltyTier(TierID)
);

-- ===========================
-- Branch Table
-- ===========================
CREATE TABLE Branch (
    BranchID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Location VARCHAR(200) NOT NULL,
    OperationalStatus VARCHAR(20) CHECK (OperationalStatus IN ('Active', 'Inactive', 'Closed'))
);

-- ===========================
-- Employee Table
-- ===========================
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    Position VARCHAR(20) CHECK (Position IN ('Manager', 'Associate')),
    BranchID INT NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- ===========================
-- VehicleCategory Table
-- ===========================
CREATE TABLE VehicleCategory (
    CategoryID INT PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    Description TEXT,
    DailyRateMultiplier FLOAT NOT NULL DEFAULT 1.0
);

-- ===========================
-- Vehicle Table
-- ===========================
CREATE TABLE Vehicle (
    VehicleID INT PRIMARY KEY,
    Make VARCHAR(50) NOT NULL,
    Model VARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    Color VARCHAR(30),
    LicensePlateNumber VARCHAR(20) NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Active', 'Inactive', 'Decommissioned')),
    FuelType VARCHAR(10) CHECK (FuelType IN ('Diesel', 'Petrol', 'Electric')),
    TransmissionType VARCHAR(10) CHECK (TransmissionType IN ('Manual', 'Automatic')),
    BaseRate DECIMAL(10,2) NOT NULL,
    BranchID INT NOT NULL,
    CategoryID INT NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    FOREIGN KEY (CategoryID) REFERENCES VehicleCategory(CategoryID)
);

-- ===========================
-- Service Table
-- ===========================
CREATE TABLE Service (
    ServiceID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Status VARCHAR(20) CHECK (Status IN ('Available', 'Unavailable')),
    Type VARCHAR(20) CHECK (Type IN ('Regular', 'Package'))
);

-- ===========================
-- RegularService Table
-- ===========================
CREATE TABLE RegularService (
    ServiceID INT PRIMARY KEY,
    BasePrice DECIMAL(10,2),
    Currency VARCHAR(10),
    Restrictions TEXT,
    FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID)
);

-- ===========================
-- PackageService Table
-- ===========================
CREATE TABLE PackageService (
    ServiceID INT PRIMARY KEY,
    BasePrice DECIMAL(10,2),
    Currency VARCHAR(10),
    ValidStart DATE,
    ValidEnd DATE,
    Inclusions TEXT,
    Exclusions TEXT,
    GracePeriod INT,
    FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID)
);

-- ===========================
-- PricedService Table
-- ===========================
CREATE TABLE PricedService (
    PricedServiceID INT PRIMARY KEY,
    ServiceID INT,
    BranchID INT,
    Price DECIMAL(10,2),
    StartDate DATE,
    EndDate DATE,
    ApproverID INT,
    FOREIGN KEY (ServiceID) REFERENCES Service(ServiceID),
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    FOREIGN KEY (ApproverID) REFERENCES Employee(EmployeeID)
);

-- ===========================
-- Booking Table
-- ===========================
CREATE TABLE Booking (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    BookingDate DATE,
    CustomerID INT,
    BookingStatus VARCHAR(20),
    PaymentMethod VARCHAR(50),
    Deposit DECIMAL(10,2),
    HandledBy INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (HandledBy) REFERENCES Employee(EmployeeID)
);

-- ===========================
-- BookingService Table
-- ===========================
CREATE TABLE BookingService (
    BookingID INT,
    PricedServiceID INT,
    ServiceStart DATE,
    ServiceEnd DATE,
    PRIMARY KEY (BookingID, PricedServiceID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (PricedServiceID) REFERENCES PricedService(PricedServiceID)
);

-- ===========================
-- BookingVehicle Table
-- ===========================
CREATE TABLE BookingVehicle (
    BookingID INT,
    VehicleID INT,
    PRIMARY KEY (BookingID, VehicleID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);

-- ===========================
-- Driver Table
-- ===========================
CREATE TABLE Driver (
    DriverID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT,
    Name VARCHAR(100),
    LicenseInfo VARCHAR(100),
    ContactNumber VARCHAR(20),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);

-- ===========================
-- ExtraService Table
-- ===========================
CREATE TABLE ExtraService (
    ExtraServiceID INT PRIMARY KEY,
    Name VARCHAR(100),
    AdvertisedRate DECIMAL(10,2)
);


-- ===========================
-- BookingExtraService Table
-- ===========================
CREATE TABLE BookingExtraService (
    BookingID INT,
    ExtraServiceID INT,
    PRIMARY KEY (BookingID, ExtraServiceID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (ExtraServiceID) REFERENCES ExtraService(ExtraServiceID)
);

-- ===========================
-- ReturnDetails Table
-- ===========================
CREATE TABLE ReturnDetails (
    ReturnID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT,
    PickupTime DATETIME,
    DropOffTime DATETIME,
    VehicleCondition TEXT,
    LatePenalty DECIMAL(10,2),
    DamagePenalty DECIMAL(10,2),
    FinalAmount DECIMAL(10,2),
    ProcessedBy INT,
    DiscountApprover INT,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (ProcessedBy) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (DiscountApprover) REFERENCES Employee(EmployeeID)
);

-- ===========================
-- Invoice Table
-- ===========================
CREATE TABLE Invoice (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT,
    BaseCharge DECIMAL(10,2),
    ExtraCharge DECIMAL(10,2),
    LatePenalty DECIMAL(10,2),
    DamagePenalty DECIMAL(10,2),
    Discount DECIMAL(10,2),
    FinalAmount DECIMAL(10,2),
    PaymentMethod VARCHAR(50),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);
--- Sample Data Entry

INSERT INTO LoyaltyTier (TierID, TierName, DiscountRate)
VALUES (1, 'Silver', 5.00),
       (2, 'Gold', 10.00),
       (3, 'Platinum', 15.00);
INSERT INTO Customer (CustomerID, FullName, Email, Phone, DriverLicenseNo, Country, TierID)
VALUES (1001, 'Jane Doe', 'jane@example.com', '0400000001', 'DL1001', 'Australia', 2),
       (1002, 'John Smith', 'john@example.com', '0400000002', 'DL1002', 'Australia', NULL);
INSERT INTO Branch (BranchID, Name, Location, OperationalStatus)
VALUES (1, 'Sydney Central', '123 George St, Sydney', 'Active'),
       (2, 'Melbourne Hub', '456 Collins St, Melbourne', 'Active');
INSERT INTO Employee (EmployeeID, Name, Email, Phone, Position, BranchID)
VALUES (2001, 'Alice Manager', 'alice@company.com', '0411000001', 'Manager', 1),
       (2002, 'Bob Associate', 'bob@company.com', '0411000002', 'Associate', 1);
INSERT INTO VehicleCategory (CategoryID, Name, Description, DailyRateMultiplier)
VALUES (1, 'Sedan', 'Standard 4-door car', 1.0),
       (2, 'SUV', 'Spacious SUV', 1.2);
INSERT INTO Vehicle (VehicleID, Make, Model, Year, Color, LicensePlateNumber, Status, FuelType, TransmissionType, BaseRate, BranchID, CategoryID)
VALUES (3001, 'Toyota', 'Corolla', 2022, 'White', 'ABC123', 'Active', 'Petrol', 'Automatic', 70.00, 1, 1),
       (3002, 'Mazda', 'CX-5', 2023, 'Blue', 'XYZ789', 'Active', 'Petrol', 'Automatic', 90.00, 1, 2),
      (3003, 'Hyundai', 'Elantra', 2021, 'Silver', 'HYN321', 'Active', 'Petrol', 'Automatic', 65.00, 1, 1),
      (3004, 'Kia', 'Sportage', 2022, 'Red', 'KIA654', 'Active', 'Petrol', 'Manual', 85.00, 2, 2),
      (3005, 'Tesla', 'Model 3', 2024, 'Black', 'TES999', 'Active', 'Electric', 'Automatic', 120.00, 2, 1);

INSERT INTO Service (ServiceID, Name, Description, Status, Type)
VALUES (4001, 'Daily Rental', 'Standard daily rental', 'Available', 'Regular'),
       (4002, 'Weekend Package', '3-day weekend package', 'Available', 'Package');

INSERT INTO RegularService (ServiceID, BasePrice, Currency, Restrictions)
VALUES (4001, 70.00, 'AUD', 'None');
INSERT INTO PackageService (ServiceID, BasePrice, Currency, ValidStart, ValidEnd, Inclusions, Exclusions, GracePeriod)
VALUES (4002, 200.00, 'AUD', '2025-07-01', '2025-07-31', 'Unlimited km, Insurance', 'Fuel', 2);
INSERT INTO PricedService (PricedServiceID, ServiceID, BranchID, Price, StartDate, EndDate, ApproverID)
VALUES (5001, 4001, 1, 70.00, '2025-07-01', '2025-07-31', 2001),
       (5002, 4002, 1, 200.00, '2025-07-01', '2025-07-31', 2001);
INSERT INTO Booking (BookingDate, CustomerID, BookingStatus, PaymentMethod, Deposit, HandledBy)
VALUES ('2025-07-01', 1001, 'Confirmed', 'Credit Card', 100.00, 2002);
INSERT INTO BookingService (BookingID, PricedServiceID, ServiceStart, ServiceEnd)
VALUES (1, 5002, '2025-07-10', '2025-07-12');
INSERT INTO BookingVehicle (BookingID, VehicleID)
VALUES (1, 3002);
INSERT INTO Driver (BookingID, Name, LicenseInfo, ContactNumber)
VALUES (1, 'Jane Doe', 'DL1001', '0400000001');
INSERT INTO ExtraService (ExtraServiceID, Name, AdvertisedRate)
VALUES (6001, 'Child Seat', 10.00),
       (6002, 'GPS Navigator', 15.00),
       (6003, 'Additional Driver', 20.00),
       (6004, 'Insurance Upgrade', 25.00);
INSERT INTO BookingExtraService (BookingID, ExtraServiceID)
VALUES (1, 6002),
       (1, 6004);
INSERT INTO ReturnDetails (BookingID, PickupTime, DropOffTime, VehicleCondition, LatePenalty, DamagePenalty, FinalAmount, ProcessedBy, DiscountApprover)
VALUES ( 1, '2025-07-10 09:00', '2025-07-12 18:00', 'Good condition', 0.00, 0.00, 240.00, 2002, NULL);
INSERT INTO Invoice ( BookingID, BaseCharge, ExtraCharge, LatePenalty, DamagePenalty, Discount, FinalAmount, PaymentMethod)
VALUES ( 1, 200.00, 40.00, 0.00, 0.00, 0.00, 240.00, 'Credit Card');

-- =============================================
-- Author: [Quynh Anh Nguyen 3473095; Shama Praveen c3470623; Leiming Guo c3471779  ]
-- Date: [28/6/2025]
-- Procedure: usp_CreateBooking
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


---Test Cases
---1.Booking Successfully

DECLARE @Services1 TVP_PricedService;
INSERT INTO @Services1 (PricedServiceID, ServiceStart, ServiceEnd)
VALUES (5001, '2025-07-15', '2025-07-16');
DECLARE @Vehicles1 TVP_Vehicle;
INSERT INTO @Vehicles1 (VehicleID)
VALUES (3003);
DECLARE @Drivers1 TVP_Driver;
INSERT INTO @Drivers1 (Name, LicenseInfo, ContactNumber)
VALUES ('John Smith', 'DL1002', '0400000002');
DECLARE @Extras1 TVP_ExtraService;
INSERT INTO @Extras1 (ExtraServiceID)
VALUES (6001);
EXEC usp_CreatingBooking
    @CustomerID = 1002,
    @HandledBy = 2002,
    @PaymentMethod = 'Credit Card',
    @Deposit = 100.00,
    @BookingMethod = 'App',
    @PricedServices = @Services1,
    @Vehicles = @Vehicles1,
    @Drivers = @Drivers1,
    @ExtraServices = @Extras1;

---Vehicle Already Booked (Overlapping Dates)
DECLARE @Services2 TVP_PricedService;
INSERT INTO @Services2 VALUES (5002, '2025-07-11', '2025-07-13'); -- Overlaps with existing booking
DECLARE @Vehicles2 TVP_Vehicle;
INSERT INTO @Vehicles2 VALUES (3002); -- Already booked for 10–12 July
DECLARE @Drivers2 TVP_Driver;
INSERT INTO @Drivers2 VALUES ('Jane Doe', 'DL1001', '0400000001');
DECLARE @Extras2 TVP_ExtraService;
INSERT INTO @Extras2 VALUES (6002);

EXEC usp_CreatingBooKing
    @CustomerID = 1001,
    @HandledBy = 2002,
    @PaymentMethod = 'Credit Card',
    @Deposit = 100.00,
    @BookingMethod = 'Website',
    @PricedServices = @Services2,
    @Vehicles = @Vehicles2,
    @Drivers = @Drivers2,
    @ExtraServices = @Extras2;

---2.Service Dates Outside Pricing Period
DECLARE @Services3 TVP_PricedService;
INSERT INTO @Services3 VALUES (5002, '2025-06-25', '2025-06-28'); -- Before valid start
DECLARE @Vehicles3 TVP_Vehicle;
INSERT INTO @Vehicles3 VALUES (3001);
DECLARE @Drivers3 TVP_Driver;
INSERT INTO @Drivers3 VALUES ('John Smith', 'DL1002', '0400000002');
DECLARE @Extras3 TVP_ExtraService;
INSERT INTO @Extras3 VALUES (6003);

EXEC usp_CreatingBooKing
    @CustomerID = 1002,
    @HandledBy = 2002,
    @PaymentMethod = 'Credit Card',
    @Deposit = 100.00,
    @BookingMethod = 'Phone',
    @PricedServices = @Services3,
    @Vehicles = @Vehicles3,
    @Drivers = @Drivers3,
    @ExtraServices = @Extras3;
----4. Invalid Customer ID
DECLARE @Services4 TVP_PricedService;
INSERT INTO @Services4 VALUES (5001, '2025-07-15', '2025-07-16');
DECLARE @Vehicles4 TVP_Vehicle;
INSERT INTO @Vehicles4 VALUES (3001);
DECLARE @Drivers4 TVP_Driver;
INSERT INTO @Drivers4 VALUES ('Ghost User', 'DL9999', '0400000999');
DECLARE @Extras4 TVP_ExtraService;
INSERT INTO @Extras4 VALUES (6001);

EXEC usp_CreatingBooKing
    @CustomerID = 9999, -- Does not exist
    @HandledBy = 2002,
    @PaymentMethod = 'Credit Card',
    @Deposit = 100.00,
    @BookingMethod = 'In Person',
    @PricedServices = @Services4,
    @Vehicles = @Vehicles4,
    @Drivers = @Drivers4,
    @ExtraServices = @Extras4;
GO
-----Return Procedure

DROP PROCEDURE IF EXISTS usp_ProcessReturn;
GO

CREATE PROCEDURE usp_ProcessReturn
    @BookingID INT,
    @PickupTime DATETIME,
    @DropOffTime DATETIME,
    @VehicleCondition VARCHAR(100),
    @LatePenalty DECIMAL(10,2),
    @DamagePenalty DECIMAL(10,2),
    @ProcessedBy INT,
    @DiscountApprover INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate booking
        IF NOT EXISTS (
            SELECT 1 FROM Booking
            WHERE BookingID = @BookingID AND BookingStatus = 'Confirmed'
        )
        BEGIN
            RAISERROR('Booking not found or not in a returnable state.', 16, 1);
            RETURN;
        END

        -- Validate employee
        IF NOT EXISTS (
            SELECT 1 FROM Employee WHERE EmployeeID = @ProcessedBy
        )
        BEGIN
            RAISERROR(' ProcessedBy employee not found.', 16, 1);
            RETURN;
        END

        -- Calculate base and extra charges
        DECLARE @BaseCharge DECIMAL(10,2) = (
            SELECT SUM(p.Price)
            FROM BookingService bs
            JOIN PricedService p ON bs.PricedServiceID = p.PricedServiceID
            WHERE bs.BookingID = @BookingID
        );

        DECLARE @ExtraCharge DECIMAL(10,2) = (
            SELECT ISNULL(SUM(e.AdvertisedRate), 0)
            FROM BookingExtraService bes
            JOIN ExtraService e ON bes.ExtraServiceID = e.ExtraServiceID
            WHERE bes.BookingID = @BookingID
        );

        -- Loyalty discount
        DECLARE @DiscountRate DECIMAL(5,2) = (
            SELECT ISNULL(t.DiscountRate, 0)
            FROM Booking b
            JOIN Customer c ON b.CustomerID = c.CustomerID
            LEFT JOIN LoyaltyTier t ON c.TierID = t.TierID
            WHERE b.BookingID = @BookingID
        );

        DECLARE @DiscountAmount DECIMAL(10,2) = ROUND(
            (@BaseCharge + @ExtraCharge) * @DiscountRate / 100, 2
        );

        -- Calculate final amount
        DECLARE @FinalAmount DECIMAL(10,2) = 
            (@BaseCharge + @ExtraCharge + @LatePenalty + @DamagePenalty) - @DiscountAmount;

        -- Insert return record
        INSERT INTO ReturnDetails (
            BookingID, PickupTime, DropOffTime, VehicleCondition,
            LatePenalty, DamagePenalty, FinalAmount,
            ProcessedBy, DiscountApprover
        )
        VALUES (
            @BookingID, @PickupTime, @DropOffTime, @VehicleCondition,
            @LatePenalty, @DamagePenalty, @FinalAmount,
            @ProcessedBy, @DiscountApprover
        );

        -- Insert invoice
        INSERT INTO Invoice (
            BookingID, BaseCharge, ExtraCharge, LatePenalty,
            DamagePenalty, Discount, FinalAmount, PaymentMethod
        )
        SELECT
            b.BookingID, @BaseCharge, @ExtraCharge, @LatePenalty,
            @DamagePenalty, @DiscountAmount, @FinalAmount, b.PaymentMethod
        FROM Booking b
        WHERE b.BookingID = @BookingID;

        -- Update booking status
        UPDATE Booking
        SET BookingStatus = 'Serviced'
        WHERE BookingID = @BookingID;

        -- Reactivate vehicle(s)
        UPDATE v
        SET v.Status = 'Active'
        FROM Vehicle v
        JOIN BookingVehicle bv ON v.VehicleID = bv.VehicleID
        WHERE bv.BookingID = @BookingID;

        -- Message output
        PRINT 'Return processed successfully. Final Amount: $' + CAST(@FinalAmount AS VARCHAR);

        IF @LatePenalty > 0 OR @DamagePenalty > 0
            PRINT ' Penalties applied: Late Fee = $' + CAST(@LatePenalty AS VARCHAR) + 
                  ', Damage Fee = $' + CAST(@DamagePenalty AS VARCHAR);

        IF @DiscountAmount > 0
            PRINT 'Loyalty discount applied: $' + CAST(@DiscountAmount AS VARCHAR);

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;

---Test Cases 


--1. Successful Return with Loyalty Discount, No Penalties
-- Reset booking status (for testing only)
UPDATE Booking
SET BookingStatus = 'Confirmed'
WHERE BookingID = 1;
EXEC usp_ProcessReturn
    @BookingID = 1,  -- Booking exists, belongs to Gold customer (TierID = 2, 10% discount)
    @PickupTime = '2025-07-10 09:00',
    @DropOffTime = '2025-07-12 18:00',
    @VehicleCondition = 'Excellent',
    @LatePenalty = 0.00,
    @DamagePenalty = 0.00,
    @ProcessedBy = 2002,
    @DiscountApprover = NULL;  -- Associate applying discount for loyal customer
--2.Return with Late and Damage Penalties, No Discount

INSERT INTO Booking (BookingDate, CustomerID, BookingStatus, PaymentMethod, Deposit, HandledBy)
VALUES ('2025-07-05', 1003, 'Confirmed', 'Credit Card', 100.00, 2002);
INSERT INTO BookingService (BookingID, PricedServiceID, ServiceStart, ServiceEnd)
VALUES (2, 5001, '2025-07-10', '2025-07-12');  -- Regular service
INSERT INTO BookingVehicle (BookingID, VehicleID)
VALUES (2, 3005);  -- Make sure this vehicle is available
INSERT INTO Driver (BookingID, Name, LicenseInfo, ContactNumber)
VALUES (2, 'Alex Carter', 'DL3001', '0400000005');
UPDATE Booking
SET BookingStatus = 'Confirmed'
WHERE BookingID = 2;
EXEC usp_ProcessReturn
    @BookingID = 2,
    @PickupTime = '2025-07-10 09:00',
    @DropOffTime = '2025-07-13 20:30',
    @VehicleCondition = 'Scratched rear bumper',
    @LatePenalty = 50.00,
    @DamagePenalty = 120.00,
    @ProcessedBy = 2002,
    @DiscountApprover = NULL;

---2. Invalid Booking ID

EXEC usp_ProcessReturn
    @BookingID = 999,  -- Doesn't exist
    @PickupTime = '2025-07-01 10:00',
    @DropOffTime = '2025-07-05 16:00',
    @VehicleCondition = 'Good',
    @LatePenalty = 0.00,
    @DamagePenalty = 0.00,
    @ProcessedBy = 2002,
    @DiscountApprover = NULL;

---3.ProcessedBy Employee Doesn't Exist
-- Reset booking status (for testing only)
UPDATE Booking
SET BookingStatus = 'Confirmed'
WHERE BookingID = 1;
EXEC usp_ProcessReturn
    @BookingID = 1,
    @PickupTime = '2025-07-10 09:00',
    @DropOffTime = '2025-07-12 18:00',
    @VehicleCondition = 'Normal wear',
    @LatePenalty = 0.00,
    @DamagePenalty = 0.00,
    @ProcessedBy = 9999,  -- Invalid employee
    @DiscountApprover = NULL;

