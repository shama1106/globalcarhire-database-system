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