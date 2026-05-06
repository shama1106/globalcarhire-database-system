---Insert LoyaltyTier
INSERT INTO LoyaltyTier (TierID, TierName, DiscountRate)
VALUES (1, 'Silver', 5.00),
       (2, 'Gold', 10.00),
       (3, 'Platinum', 15.00);

---Insert Customer 
INSERT INTO Customer (CustomerID, FullName, Email, Phone, DriverLicenseNo, Country, TierID)
VALUES (1001, 'Jane Doe', 'jane@example.com', '0400000001', 'DL1001', 'Australia', 2),
       (1002, 'John Smith', 'john@example.com', '0400000002', 'DL1002', 'Australia', NULL);
---Insert Branch
INSERT INTO Branch (BranchID, Name, Location, OperationalStatus)
VALUES (1, 'Sydney Central', '123 George St, Sydney', 'Active'),
       (2, 'Melbourne Hub', '456 Collins St, Melbourne', 'Active');
---Insert Employee
INSERT INTO Employee (EmployeeID, Name, Email, Phone, Position, BranchID)
VALUES (2001, 'Alice Manager', 'alice@company.com', '0411000001', 'Manager', 1),
       (2002, 'Bob Associate', 'bob@company.com', '0411000002', 'Associate', 1);
---Insert VehicleCategory
INSERT INTO VehicleCategory (CategoryID, Name, Description, DailyRateMultiplier)
VALUES (1, 'Sedan', 'Standard 4-door car', 1.0),
       (2, 'SUV', 'Spacious SUV', 1.2);
---Insert Vehicle
INSERT INTO Vehicle (VehicleID, Make, Model, Year, Color, LicensePlateNumber, Status, FuelType, TransmissionType, BaseRate, BranchID, CategoryID)
VALUES (3001, 'Toyota', 'Corolla', 2022, 'White', 'ABC123', 'Active', 'Petrol', 'Automatic', 70.00, 1, 1),
       (3002, 'Mazda', 'CX-5', 2023, 'Blue', 'XYZ789', 'Active', 'Petrol', 'Automatic', 90.00, 1, 2),
      (3003, 'Hyundai', 'Elantra', 2021, 'Silver', 'HYN321', 'Active', 'Petrol', 'Automatic', 65.00, 1, 1),
      (3004, 'Kia', 'Sportage', 2022, 'Red', 'KIA654', 'Active', 'Petrol', 'Manual', 85.00, 2, 2),
      (3005, 'Tesla', 'Model 3', 2024, 'Black', 'TES999', 'Active', 'Electric', 'Automatic', 120.00, 2, 1);
---Insert Service
INSERT INTO Service (ServiceID, Name, Description, Status, Type)
VALUES (4001, 'Daily Rental', 'Standard daily rental', 'Available', 'Regular'),
       (4002, 'Weekend Package', '3-day weekend package', 'Available', 'Package');
---Insert RegularService
INSERT INTO RegularService (ServiceID, BasePrice, Currency, Restrictions)
VALUES (4001, 70.00, 'AUD', 'None');
---Insert PackageService
INSERT INTO PackageService (ServiceID, BasePrice, Currency, ValidStart, ValidEnd, Inclusions, Exclusions, GracePeriod)
VALUES (4002, 200.00, 'AUD', '2025-07-01', '2025-07-31', 'Unlimited km, Insurance', 'Fuel', 2);
---Insert PricedService
INSERT INTO PricedService (PricedServiceID, ServiceID, BranchID, Price, StartDate, EndDate, ApproverID)
VALUES (5001, 4001, 1, 70.00, '2025-07-01', '2025-07-31', 2001),
       (5002, 4002, 1, 200.00, '2025-07-01', '2025-07-31', 2001);
---Insert Booking
INSERT INTO Booking (BookingDate, CustomerID, BookingStatus, PaymentMethod, Deposit, HandledBy)
VALUES ('2025-07-01', 1001, 'Confirmed', 'Credit Card', 100.00, 2002);
---Insert BookingService
INSERT INTO BookingService (BookingID, PricedServiceID, ServiceStart, ServiceEnd)
VALUES (1, 5002, '2025-07-10', '2025-07-12');
---Insert BookingVehicle
INSERT INTO BookingVehicle (BookingID, VehicleID)
VALUES (1, 3002);
---Insert Driver
INSERT INTO Driver (BookingID, Name, LicenseInfo, ContactNumber)
VALUES (1, 'Jane Doe', 'DL1001', '0400000001');
---Insert ExtraService
INSERT INTO ExtraService (ExtraServiceID, Name, AdvertisedRate)
VALUES (6001, 'Child Seat', 10.00),
       (6002, 'GPS Navigator', 15.00),
       (6003, 'Additional Driver', 20.00),
       (6004, 'Insurance Upgrade', 25.00);
---Insert BookingExtraService
INSERT INTO BookingExtraService (BookingID, ExtraServiceID)
VALUES (1, 6002),
       (1, 6004);
---Insert ReturnDetails
INSERT INTO ReturnDetails (BookingID, PickupTime, DropOffTime, VehicleCondition, LatePenalty, DamagePenalty, FinalAmount, ProcessedBy, DiscountApprover)
VALUES ( 1, '2025-07-10 09:00', '2025-07-12 18:00', 'Good condition', 0.00, 0.00, 240.00, 2002, NULL);
---Insert Invoice
INSERT INTO Invoice ( BookingID, BaseCharge, ExtraCharge, LatePenalty, DamagePenalty, Discount, FinalAmount, PaymentMethod)
VALUES ( 1, 200.00, 40.00, 0.00, 0.00, 0.00, 240.00, 'Credit Card');