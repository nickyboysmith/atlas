

/*
	SCRIPT: Add insert trigger to the CourseSchedule table
	Author: Dan Murray
	Created: 12/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_08.01_AddInsertTriggerToCourseScheduleTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseSchedule_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseSchedule_INSERT];
		END
GO
		CREATE TRIGGER TRG_CourseSchedule_INSERT ON CourseSchedule FOR INSERT
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
	SELECT @Item 			= 'New Course Schedule';
	SELECT @NewValue 		= 'Course Start Time:' + CONVERT(VARCHAR(19),i.StartTime)  + '; Course End Time:' + CONVERT(VARCHAR(19),i.EndTime) FROM inserted i ;
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
				)


/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP010_08.01_AddInsertTriggerToCourseScheduleTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO