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