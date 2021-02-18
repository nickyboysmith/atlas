/*
	SCRIPT: Amend Update and Insert trigger on Trainer
	Author: Dan Hough
	Created: 09/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_15.01_AmendInsertUpdateTriggerOnTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update and Insert trigger on Trainer';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Trainer_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Trainer_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_Trainer_InsertUpdate ON dbo.Trainer AFTER UPDATE, INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Trainer', 'TRG_Trainer_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @trainerId INT
					, @firstName VARCHAR(320)
					, @surname VARCHAR(320)
					, @capitalisedFirstName VARCHAR(320)
					, @capitalisedSurname VARCHAR(320);

			SELECT @firstName = FirstName
					, @surname = Surname
					, @capitalisedFirstName = LEFT(UPPER(@firstName), 1)+RIGHT(@firstName, LEN(@firstName)-1)
					, @capitalisedSurname = LEFT(UPPER(@surname), 1)+RIGHT(@surname, LEN(@surname)-1)
					, @trainerId = I.Id
			FROM Inserted i;

			--Updates Trainer Name if the cases don't match
			-- Latin1_General_CS_AS is case sensitive.
			IF(@firstName != @capitalisedFirstName COLLATE Latin1_General_CS_AS
				OR @surname != @capitalisedSurname COLLATE Latin1_General_CS_AS)
			BEGIN
				UPDATE dbo.Trainer
				SET FirstName = @capitalisedFirstName
					, Surname = @capitalisedSurname
				WHERE Id = @trainerId;
			END

			IF NOT EXISTS(SELECT * FROM dbo.TrainerSetting WHERE TrainerId = @trainerId)
			BEGIN
				INSERT INTO TrainerSetting (TrainerId, ProfileEditing, CourseTypeEditing)
				VALUES (@trainerId, 'True', 'False')
			END

			EXEC dbo.uspEnsureTrainerLimitationAndSummaryDataSetup;

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_15.01_AmendInsertUpdateTriggerOnTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO