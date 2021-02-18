

/*
	SCRIPT: Add delete trigger to the Course table
	Author: Dan Murray
	Created: 12/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_10.01_AddDeleteTriggerToCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_Course_DELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_Course_DELETE];
		END
GO
		CREATE TRIGGER TRG_Course_DELETE ON Course FOR DELETE
AS
	DECLARE @CourseId int;
	DECLARE @DateCreated DATETIME;
	DECLARE @CreatedByUserId INT;
	DECLARE @Item VARCHAR(40);
	DECLARE @NewValue VARCHAR(100);
	DECLARE @OldValue VARCHAR(100);

	SELECT @CourseId        = d.Id FROM deleted d;
	SELECT @DateCreated 	= GETDATE();
	SELECT @CreatedByUserId = d.CreatedByUserId FROM deleted d;
	SELECT @Item 			= 'Course Deleted';
	SELECT @NewValue 		= 'Course Type:' + CT.Title FROM deleted d
													    JOIN CourseType CT
														ON d.CourseTypeId = CT.Id;
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
DECLARE @ScriptName VARCHAR(100) = 'SP010_10.01_AddDeleteTriggerToCourseTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO
		