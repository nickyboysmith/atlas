

/*
	SCRIPT: FIX FOR Add delete trigger to the CourseDate table
	Author: Dan Murray, fixed by Robert Newnham
	Created: 11/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_07.03_FIXFOR_AddDeleteTriggerToCourseDateTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseDate_DELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseDate_DELETE];
		END
GO
		CREATE TRIGGER TRG_CourseDate_DELETE ON CourseDate FOR DELETE
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
	SELECT @Item 			= 'Course Date Deleted';
	SELECT @OldValue		= 'Course Date:' + CONVERT(VARCHAR(19), d.DateStart) FROM deleted d;
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

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP017_07.03_FIXFOR_AddDeleteTriggerToCourseDateTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO
