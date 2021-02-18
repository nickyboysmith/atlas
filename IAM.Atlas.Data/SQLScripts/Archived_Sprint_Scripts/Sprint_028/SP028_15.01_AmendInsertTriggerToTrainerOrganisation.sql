/*
	SCRIPT: Amend insert trigger on the TrainerOrganisation table
	Author: Dan Hough
	Created: 21/10/2016

	Added one line - selecting Id in to @Id
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_15.01_AmendInsertTriggerToTrainerOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to TrainerOrganisation table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_TrainerOrganisation_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_TrainerOrganisation_Insert];
		END
GO
		CREATE TRIGGER TRG_TrainerOrganisation_Insert ON dbo.TrainerOrganisation AFTER INSERT
AS

BEGIN

	DECLARE @Id INT
		  , @rowCount INT
		  , @counter INT = 1
		  , @venueId INT
		  , @trainerId INT;

	SELECT @Id = i.Id FROM Inserted i

	-- Inserts the appropriate Trainer and Venue Id's in to a temporary table
	-- that will be looped through later.
	SELECT tro.TrainerId
	 , tro.OrganisationId
	 , v.Id as VenueId
	INTO #TrainerVenue
	FROM TrainerOrganisation tro
	INNER JOIN dbo.Venue v ON tro.OrganisationId = v.OrganisationId
	INNER JOIN dbo.VenueAddress va ON va.VenueId = v.Id
	INNER JOIN dbo.[Location] l ON l.Id = va.LocationId
	INNER JOIN dbo.TrainerLocation tl ON tro.TrainerId = tl.TrainerId
	INNER JOIN dbo.[Location] trainerloc ON trainerloc.Id = tl.LocationId
	WHERE tro.Id = @Id;

	-- Gets the row count of the table for use in the loop later
	SELECT @rowCount = @@ROWCOUNT;

	-- Adds an Id to the temp table which will be used for the loop
	ALTER TABLE #TrainerVenue
	ADD Id INT IDENTITY(1,1) PRIMARY KEY;

	WHILE @counter <= @rowCount
	BEGIN
		SELECT @venueId = VenueId, @trainerId = TrainerId FROM #TrainerVenue WHERE Id = @counter;

		-- Checks to see if there's already an entry on TrainerVenue for the venue and trainer
		-- If there is then it skips it, if there isn't it inserts in to TrainerVenue then calls
		-- The stored procedure to calculate distance
		IF NOT EXISTS(SELECT TOP(1) TrainerId, VenueId FROM dbo.TrainerVenue WHERE TrainerId = @TrainerId AND VenueId = @VenueId)
		BEGIN
			INSERT INTO dbo.TrainerVenue(trainerId, VenueId, DateUpdated, UpdatedByUserId)
			VALUES(@trainerId, @venueId, GETDATE(), dbo.udfGetSystemUserId());
			EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;
		END

		SET @counter = @counter + 1;
	END

	DROP TABLE #TrainerVenue;

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_15.01_AmendInsertTriggerToTrainerOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	