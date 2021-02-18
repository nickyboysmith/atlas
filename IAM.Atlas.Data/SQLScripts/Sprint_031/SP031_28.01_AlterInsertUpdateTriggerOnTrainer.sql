/*
	SCRIPT: Alter InsertUpdate Trigger on Trainer
	Author: Dan Hough
	Created: 09/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_28.01_AlterInsertUpdateTriggerOnTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Insert and Update Trigger on Trainer';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Trainer_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Trainer_InsertUpdate;
	END
GO


CREATE TRIGGER [dbo].[TRG_Trainer_InsertUpdate] ON [dbo].[Trainer]
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT id FROM inserted)
	BEGIN
		/*update*/
		IF EXISTS (SELECT * FROM Deleted)
		BEGIN
			INSERT INTO TrainerSetting (
				TrainerId
				,ProfileEditing
				,CourseTypeEditing
				)
			SELECT i.Id
				,ProfileEditing = 'True'
				,CourseTypeEditing = 'False'
			FROM inserted i
			INNER JOIN Trainer t
				ON t.id = i.Id
			WHERE NOT EXISTS (SELECT id FROM Trainer)
		END
		ELSE
			/*INSERT*/
		BEGIN
			IF NOT EXISTS (SELECT id FROM deleted)
				INSERT INTO TrainerSetting (
					TrainerId
					,ProfileEditing
					,CourseTypeEditing
					)
				SELECT i.Id
					,ProfileEditing = 'True'
					,CourseTypeEditing = 'False'
				FROM inserted i
				INNER JOIN Trainer t
					ON t.id = i.Id;

				EXEC dbo.uspEnsureTrainerLimitationAndSummaryDataSetup;
		END
	END
	ELSE
		/*Delete*/
	BEGIN
		PRINT 'DELETE'
	END
END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_28.01_AlterInsertUpdateTriggerOnTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	