/*
	SCRIPT: Add update trigger on the Venue table
	Author: Dan Hough
	Created: 21/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_09.01_AddUpdateTriggerToVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update trigger to Venue table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_VenueToUpdateTrainerVenueDistance_Update', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_VenueToUpdateDistance_Update];
		END
GO
		CREATE TRIGGER TRG_VenueToUpdateDistance_Update ON dbo.Venue AFTER UPDATE
AS

BEGIN
	DECLARE @trainerId INT
		  , @venueId INT
		  , @trainerVenueCount INT
		  , @counter INT = 1;

	SELECT @venueId = i.id FROM Inserted i;
	
	-- Retrieves a count of rows which matches the trainer id. This will be used for the loop.
	SELECT @trainerVenueCount = COUNT(Id)
	FROM dbo.TrainerVenue
	WHERE VenueId = @VenueId;

	--Loops through the rows executing the stored proc for each row 
	IF (@trainerVenueCount > 0)
	BEGIN
		WHILE (@counter <= @trainerVenueCount)
		BEGIN
			SELECT TOP(1) @trainerId = TrainerId
			FROM dbo.TrainerVenue
			WHERE VenueId = @venueId;

			EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;

			SET @counter = @counter + 1;
		END
	END

END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_09.01_AddUpdateTriggerToVenue.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO