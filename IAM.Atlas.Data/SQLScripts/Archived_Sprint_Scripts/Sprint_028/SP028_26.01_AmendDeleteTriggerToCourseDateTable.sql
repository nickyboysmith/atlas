

/*
	SCRIPT: Amend delete trigger to the CourseDate table
	Author: Dan Murray, fixed by Robert Newnham
	Created: 31/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_26.01_AmendDeleteTriggerToCourseDateTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseDate_DELETE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseDate_DELETE];
	END
GO

		CREATE TRIGGER TRG_CourseDate_DELETE ON CourseDate AFTER DELETE
		AS
			INSERT INTO CourseLog
						(CourseId,
						DateCreated,
						CreatedByUserId,
						Item,
						NewValue,
						OldValue
						)
			SELECT 
				CourseId											AS CourseId
				, GETDATE()											AS DateCreated
				, CreatedByUserId									AS CreatedByUserId
				, 'Course Date Deleted'								AS Item
				, NULL												AS NewValue
				, 'Course Date:' + CONVERT(VARCHAR(19), DateStart)	AS OldValue
			FROM DELETED
			WHERE CourseId IS NOT NULL;

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_26.01_AmendDeleteTriggerToCourseDateTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO
