/*
	SCRIPT: Fix for the insert trigger
	Author: Miles Stewart
	Created: 10/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_06.01_FixInsertTriggerToCourseDateTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseDate_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseDate_INSERT];
		END
GO
		CREATE TRIGGER TRG_CourseDate_INSERT ON CourseDate FOR INSERT
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
	SELECT @Item 			= 'New Course Date';
	SELECT @NewValue 		= 'Course Date:' +  CAST(i.DateStart as VARCHAR) FROM inserted i;
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

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP017_06.01_FixInsertTriggerToCourseDateTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO