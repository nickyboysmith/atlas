

/*
	SCRIPT: FIX FOR Add insert trigger to the CourseTrainer table
	Author: Dan Murray, fixed by Robert Newnham
	Created: 11/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_07.05_FIXFOR_AddInsertTriggerToCourseTrainerTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseTrainer_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseTrainer_INSERT];
		END
GO
		CREATE TRIGGER TRG_CourseTrainer_INSERT ON CourseTrainer FOR INSERT
AS
	DECLARE @CourseId int;
	DECLARE @DateCreated DATETIME;
	DECLARE @CreatedByUserId INT;
	DECLARE @Item VARCHAR(40);
	DECLARE @NewValue VARCHAR(100);
	DECLARE @OldValue VARCHAR(100);

	SELECT @CourseId        = i.CourseId FROM inserted i;
	SELECT @DateCreated 	= GETDATE();
	SELECT @CreatedByUserId = i.CreatedByUserId FROM inserted i;
	SELECT @Item 			= 'New Course Trainer';
	SELECT @NewValue 		= 'Trainer:' + T.FirstName + ' ' + T.Surname FROM inserted i 
																		 JOIN Trainer T 
																		 ON i.TrainerId = T.Id;
	SELECT @OldValue        = NULL;

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
				);
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP017_07.05_FIXFOR_AddInsertTriggerToCourseTrainerTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO