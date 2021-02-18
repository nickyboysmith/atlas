/*
	SCRIPT: Amend insert trigger on Venue
	Author: Dan Hough
	Created: 27/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_23.01_AmendInsertTriggerOnVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger on Venue';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 
IF OBJECT_ID('dbo.TRG_VenueToInsertInToTrainerVenue_Insert', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_VenueToInsertInToTrainerVenue_Insert;
END

GO

CREATE TRIGGER TRG_VenueToInsertInToTrainerVenue_Insert ON dbo.Venue AFTER INSERT
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN                 
		EXEC uspLogTriggerRunning 'Venue', 'TRG_VenueToInsertInToTrainerVenue_Insert', @insertedRows, @deletedRows;
		-------------------------------------------------------------------------------------------
	
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
			INNER JOIN dbo.TrainerOrganisation tro ON v.OrganisationId = tro.OrganisationId
			WHERE v.Id = @venueId;

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
					EXEC dbo.uspUpdateTrainerVenueDistance @trainerId, @VenueId;
				END

				SET @counter = @counter + 1;
			END

			DROP TABLE #Venue;
		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_23.01_AmendInsertTriggerOnVenue.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

