

/*
	SCRIPT: Add insert trigger to the Course table
	Author: Dan Murray
	Created: 12/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_06.01_AddInsertTriggerToCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_Course_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_Course_INSERT];
		END
GO
		CREATE TRIGGER TRG_Course_INSERT ON Course FOR INSERT
AS
	DECLARE @CourseId int;
	DECLARE @DateCreated DATETIME;
	DECLARE @CreatedByUserId INT;
	DECLARE @Item VARCHAR(40);
	DECLARE @NewValue VARCHAR(100);
	DECLARE @OldValue VARCHAR(100);

	SELECT @CourseId        = i.Id FROM inserted i;
	SELECT @DateCreated 	= GETDATE();
	SELECT @CreatedByUserId = i.CreatedByUserId FROM inserted i;
	SELECT @Item 			= 'New Course';
	SELECT @NewValue 		= 'Course Type:' + CT.Title FROM inserted i
													    JOIN CourseType CT
														ON i.CourseTypeId = CT.Id;
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
DECLARE @ScriptName VARCHAR(100) = 'SP010_06.01_AddInsertTriggerToCourseTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO