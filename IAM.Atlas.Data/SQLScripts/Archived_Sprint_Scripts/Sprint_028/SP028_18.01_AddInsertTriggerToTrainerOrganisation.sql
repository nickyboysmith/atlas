/*
	SCRIPT: Add insert trigger on the Venue table
	Author: Dan Hough
	Created: 24/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_18.01_AddInsertTriggerToTrainerOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to Venue table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_VenueToInsertInToTrainerVenue_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_VenueToInsertInToTrainerVenue_Insert];
		END
GO
		CREATE TRIGGER TRG_VenueToInsertInToTrainerVenue_Insert ON dbo.Venue AFTER INSERT
AS

BEGIN

	DECLARE  @rowCount INT
			, @counter INT = 1
			, @venueId INT
			, @trainerId INT;

		SELECT @venueId = i.Id FROM Inserted i;

		-- Inserts the appropriate Trainer and Venue Id's in to a temporary table
		-- that will be looped through later.
		SELECT v.Id as VenueId, tro.TrainerId
		INTO #Venue
		FROM dbo.Venue v
		INNER JOIN dbo.Organisation o ON v.OrganisationId = o.Id
		INNER JOIN dbo.VenueAddress va ON v.Id = va.VenueId
		INNER JOIN dbo.TrainerOrganisation tro ON v.OrganisationId = tro.OrganisationId
		WHERE v.Id = @venueId

		-- Gets the row count of the table for use in the loop later
		SELECT @rowCount = @@ROWCOUNT;

		-- Adds an Id to the temp table which will be used for the loop
		ALTER TABLE #Venue
		ADD Id INT IDENTITY(1,1) PRIMARY KEY;

		WHILE @counter <= @rowCount
		BEGIN
			SELECT @venueId = VenueId, @trainerId = TrainerId FROM #Venue WHERE Id = @counter;

			-- Checks to see if there's already an entry on TrainerVenue for the venue and trainer
			-- If there is then it skips it, if there isn't it inserts in to TrainerVenue then calls
			-- the stored procedure to calculate distance
			IF NOT EXISTS(SELECT TOP(1) TrainerId, VenueId FROM dbo.TrainerVenue WHERE TrainerId = @TrainerId AND VenueId = @VenueId)
			BEGIN
				INSERT INTO dbo.TrainerVenue(trainerId, VenueId, DateUpdated, UpdatedByUserId)
				VALUES(@trainerId, @venueId, GETDATE(), dbo.udfGetSystemUserId());
				EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;
			END
			SET @counter = @counter + 1;
		END

		DROP TABLE #Venue;

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_18.01_AddInsertTriggerToTrainerOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	