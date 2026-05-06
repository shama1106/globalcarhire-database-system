-- =============================================
-- Author: [Quynh Anh Nguyen 3473095; Shama Praveen c3470623; Leiming Guo c3471779  ]
-- Date: [28/6/2025]
-- Procedure: usp_ProcessReturn
-- Purpose: Customer return process
-- =============================================
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
