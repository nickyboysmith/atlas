/*
	SCRIPT: Add update, insert trigger to Trainer table
	Author: Dan Hough
	Created: 31/03/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP018_17.01_AddUpdateInsertTriggerToTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update, insert trigger to Trainer table';

EXEC dbo.uspScriptStarted @ScriptName
	,@ScriptComments;/*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_Trainer_InsertUpdate]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.[TRG_Trainer_InsertUpdate];
END
GO

CREATE TRIGGER TRG_Trainer_InsertUpdate ON Trainer
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
					ON t.id = i.Id
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
DECLARE @ScriptName VARCHAR(100) = 'SP018_17.01_AddUpdateInsertTriggerToTrainer.sql';

EXEC dbo.uspScriptCompleted @ScriptName;/*LOG SCRIPT COMPLETED*/
GO


