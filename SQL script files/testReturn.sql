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

