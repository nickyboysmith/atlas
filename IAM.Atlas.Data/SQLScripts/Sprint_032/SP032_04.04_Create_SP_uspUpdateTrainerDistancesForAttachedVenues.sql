/*
	SCRIPT: Create Stored procedure uspUpdateTrainerDistancesForAttachedVenues
	Author: Robert Newnham
	Created: 12/01/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_04.04_Create_SP_uspUpdateTrainerDistancesForAttachedVenues.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspUpdateTrainerDistancesForAttachedVenues';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspUpdateTrainerDistancesForAttachedVenues', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspUpdateTrainerDistancesForAttachedVenues;
END		
GO
	/*
		Create uspUpdateTrainerDistancesForAttachedVenues
	*/

	CREATE PROCEDURE dbo.uspUpdateTrainerDistancesForAttachedVenues (@TrainerId INT)
	AS
	BEGIN
		DECLARE @VenueId INT;
		DECLARE @TrainerVenueId INT = 0;
		DECLARE @CNT INT = 0;

		DECLARE cur_TrainerVenues CURSOR
		FOR 
		SELECT DISTINCT
			TV.VenueId 
			, TV.Id AS TrainerVenueId
		FROM dbo.TrainerVenue TV		
		INNER JOIN dbo.TrainerLocation TL	ON TL.TrainerId = TV.TrainerId
											AND TL.MainLocation = 'True'
		INNER JOIN [Location] L				ON L.Id = TL.LocationId
											AND LEN(L.PostCode) > 0 --Trainer Must Have a Valid Post Code
		INNER JOIN PostCodeInformation PCI	ON PCI.PostCodeNoSpaces = REPLACE(L.PostCode, ' ','')  --Trainer Should Have a Valid Post Code
		INNER JOIN dbo.VenueAddress VA		ON VA.VenueId = TV.VenueId
		INNER JOIN [Location] L2			ON L2.Id = VA.LocationId
											AND LEN(L2.PostCode) > 0 --Venue Must Have a Valid Post Code
		INNER JOIN PostCodeInformation PCI2	ON PCI2.PostCodeNoSpaces = REPLACE(L2.PostCode, ' ','') --Venue Should Have a Valid Post Code
		WHERE TV.TrainerId = @TrainerId
		AND (L.DateUpdated >= TV.DateUpdated
				OR ISNULL(TV.DistanceHomeToVenueInMiles,0) <= 0);
			
		OPEN cur_TrainerVenues   
		FETCH NEXT FROM cur_TrainerVenues INTO @VenueId, @TrainerVenueId;

		WHILE @@FETCH_STATUS = 0   
		BEGIN IF (ISNULL(@VenueId,-1) > 0 AND ISNULL(@TrainerId,-1) > 0)
			BEGIN
				--SET @CNT = @CNT + 1;
				--PRINT 'CNT: ' +  CAST(@CNT AS VARCHAR) + 'T:' + CAST(@TrainerId AS VARCHAR) + ' - TV:' + CAST(@TrainerVenueId AS VARCHAR) + ' - V:' + CAST(@VenueId AS VARCHAR);
				EXEC uspUpdateTrainerVenueDistance @TrainerId, @VenueId; 
			END
			FETCH NEXT FROM cur_TrainerVenues INTO @VenueId, @TrainerVenueId;
		END

		CLOSE cur_TrainerVenues;
		DEALLOCATE cur_TrainerVenues;
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP032_04.04_Create_SP_uspUpdateTrainerDistancesForAttachedVenues.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO