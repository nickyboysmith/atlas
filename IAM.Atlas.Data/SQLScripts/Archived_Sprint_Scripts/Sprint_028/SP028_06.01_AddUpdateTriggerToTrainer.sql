/*
	SCRIPT: Add update trigger on the Trainer table
	Author: Dan Hough
	Created: 21/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_06.01_AddUpdateTriggerToTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update trigger on the Trainer table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_TrainerToUpdateDistance_Update', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_TrainerToUpdateDistance_Update];
		END
GO
		CREATE TRIGGER TRG_TrainerToUpdateDistance_Update ON dbo.Trainer AFTER UPDATE
AS

BEGIN
	DECLARE @trainerId INT
		  , @venueId INT
		  , @trainerVenueCount INT
		  , @counter INT = 1;

	SELECT @trainerId = i.id FROM Inserted i
	
	-- Retrieves a count of rows which matches the trainer id. This will be used for the loop.
	SELECT @trainerVenueCount = COUNT(Id)
	FROM dbo.TrainerVenue
	WHERE TrainerId = @trainerId;

	--Loops through the rows executing the stored proc for each row 
	IF (@trainerVenueCount > 0)
	BEGIN
		WHILE (@counter <= @trainerVenueCount)
		BEGIN
			SELECT TOP(1) @venueId = VenueId
			FROM dbo.TrainerVenue
			WHERE TrainerId = @trainerId

			EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId

			SET @counter = @counter + 1;
		END
	END

END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_06.01_AddUpdateTriggerToTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO