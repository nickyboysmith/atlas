

/*
	SCRIPT: Add delete trigger to the CourseTrainer table
	Author: Dan Murray
	Created: 12/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_13.01_AddDeleteTriggerToCourseTrainerTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseTrainer_DELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseTrainer_DELETE];
		END
GO
		CREATE TRIGGER TRG_CourseTrainer_DELETE ON CourseTrainer FOR DELETE
AS
	DECLARE @CourseId int;
	DECLARE @DateCreated DATETIME;
	DECLARE @CreatedByUserId INT;
	DECLARE @Item VARCHAR(40);
	DECLARE @NewValue VARCHAR(100);
	DECLARE @OldValue VARCHAR(100);

	SELECT @CourseId        = d.CourseId FROM deleted d;
	SELECT @DateCreated 	= GETDATE();
	SELECT @CreatedByUserId = d.CreatedByUserId FROM deleted d;
	SELECT @Item 			= 'Course Trainer Deleted';
	SELECT @OldValue		= 'Trainer:' + T.FirstName + ' ' + T.Surname FROM inserted i 
																		 JOIN Trainer T 
																		 ON i.TrainerId = T.Id;
	SELECT @NewValue     = NULL;

	INSERT INTO CourseLog
				(CourseId,
				DateCreated,
				CreatedByUserId,
				Item,
				NewValue,
				OldValue
				)
	VALUES		
				(
				@CourseId ,
				@DateCreated ,
				@CreatedByUserId ,
				@Item ,
				@NewValue ,
				@OldValue 
				)


/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP010_13.01_AddDeleteTriggerToCourseTrainerTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO