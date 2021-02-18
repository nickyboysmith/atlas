/*
	SCRIPT: Amend Stored procedure uspUpdateTrainerVenueDistance
	Author: Robert Newnham
	Created: 13/01/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_08.01_Amend_SP_uspUpdateTrainerVenueDistance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Stored procedure uspUpdateTrainerVenueDistance';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspUpdateTrainerVenueDistance', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspUpdateTrainerVenueDistance;
END		
GO
	/*
		Create uspUpdateTrainerVenueDistance
	*/

	CREATE PROCEDURE dbo.uspUpdateTrainerVenueDistance (@trainerId INT, @venueId INT)
	AS
	BEGIN
		DECLARE @trainerPostCode VARCHAR(20)
			  , @venuePostCode VARCHAR(20)
			  , @trainerEasting FLOAT
			  , @trainerNorthing FLOAT
			  , @venueEasting FLOAT
			  , @venueNorthing FLOAT
			  , @Distance FLOAT
			  , @trainerVenueId INT


		-- Checks to see if a row already exists which contains the trainerid and valueid. 
		--If not once is created.
		IF NOT EXISTS(SELECT TrainerId, VenueId FROM dbo.TrainerVenue WHERE (TrainerId = @trainerId) AND (VenueId = @venueId))
		BEGIN
			INSERT INTO dbo.TrainerVenue(TrainerId, VenueId, DateUpdated, UpdatedByUserId)
			VALUES(@trainerId, @venueId, GETDATE(), dbo.udfGetSystemUserId())
		END

		-- Captures the TrainerVenue.Id for use in updates later
		SELECT @trainerVenueId = id 
		FROM dbo.TrainerVenue 
		WHERE TrainerId = @TrainerId 
		AND VenueId = @VenueId;

		--Returns venue postcode, stripping out spaces
		SELECT @venuePostCode = REPLACE(L.PostCode, ' ', '')
		FROM dbo.VenueAddress VA 
		INNER JOIN dbo.[Location] L ON L.Id = VA.LocationId
		WHERE VA.VenueId = @venueId;

		--Returns trainer postcode, stripping out spaces
		SELECT TOP(1) @trainerPostCode = REPLACE(L.PostCode, ' ' , '')
		FROM dbo.TrainerLocation TL
		INNER JOIN dbo.[Location] L ON L.Id = TL.LocationId
		WHERE TL.TrainerId = @trainerId

		-- Retrieves Venue easting and northing using the postcode 
		-- (stripping out spaces) if @venuePostCode has been populated.
		--PRINT '@venuePostCode: ' + @venuePostCode
		IF(@venuePostCode IS NOT NULL)
		BEGIN
			SELECT @venueEasting = Easting, @venueNorthing = Northing
			FROM dbo.PostCodeInformation
			WHERE PostCodeNoSpaces = UPPER(@venuePostCode)
			--PRINT '@venueEasting: ' + CAST(@venueEasting AS VARCHAR)
			--PRINT '@venueNorthing: ' + CAST(@venueNorthing AS VARCHAR)
		END

		-- Retrieves Trainer easting and northing using the postcode 
		-- (stripping out spaces) if @trainerPostCode has been populated.
		--PRINT '@trainerPostCode: ' + @trainerPostCode
		IF (@trainerPostCode IS NOT NULL)
		BEGIN
			SELECT @trainerEasting = Easting, @trainerNorthing = Northing
			FROM dbo.PostCodeInformation
			WHERE PostCodeNoSpaces = UPPER(@trainerPostCode)
			--PRINT '@trainerEasting: ' + CAST(@trainerEasting AS VARCHAR)
			--PRINT '@trainerNorthing: ' + CAST(@trainerNorthing AS VARCHAR)
		END

		IF(@trainerEasting IS NOT NULL AND @trainerNorthing IS NOT NULL AND @venueEasting IS NOT NULL AND @venueNorthing IS NOT NULL)
		BEGIN
			-- Calculates the distance if all info has been successfully collected
			SELECT @Distance = SQRT(POWER(@venueEasting - @trainerEasting, 2) + POWER(@trainerNorthing - @venueNorthing, 2)) / 1609.3
		END
		ELSE
		BEGIN
			-- Sets @distance to -1 if some/all of the information hasn't been found
			SET @distance = -1
		END

		-- Once all the data has been retrieved, update TrainerValue with the distance
		UPDATE dbo.TrainerVenue
		SET DistanceHomeToVenueInMiles = @distance, DateUpdated = GETDATE()
		WHERE Id = @trainerVenueId
		--PRINT '@distance: ' + CAST(@distance AS VARCHAR)

	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP032_08.01_Amend_SP_uspUpdateTrainerVenueDistance.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO