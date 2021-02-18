

/*
	SCRIPT: Add delete trigger to the CourseSchedule table
	Author: Dan Murray
	Created: 12/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_12.01_AddDeleteTriggerToCourseScheduleTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseSchedule_DELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseSchedule_DELETE];
		END
GO
		CREATE TRIGGER TRG_CourseSchedule_DELETE ON CourseSchedule FOR DELETE
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
	SELECT @Item 			= 'Course Times Deleted';
	SELECT @OldValue		= 'Course Start Time:' + CONVERT(VARCHAR(19), d.StartTime) + '; Course End Time:' + CONVERT(VARCHAR(19), d.EndTime) FROM deleted d;
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
DECLARE @ScriptName VARCHAR(100) = 'SP010_12.01_AddDeleteTriggerToCourseScheduleTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO