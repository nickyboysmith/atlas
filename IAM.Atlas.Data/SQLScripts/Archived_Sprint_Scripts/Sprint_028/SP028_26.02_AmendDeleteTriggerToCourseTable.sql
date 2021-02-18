

/*
	SCRIPT: Amend delete trigger to the Course table
	Author: Dan Murray, fixed by Robert Newnham
	Created: 31/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_26.02_AmendDeleteTriggerToCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_Course_DELETE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_Course_DELETE];
	END
GO
		CREATE TRIGGER TRG_Course_DELETE ON Course AFTER DELETE
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
				D.Id												AS CourseId
				, GETDATE()											AS DateCreated
				, D.CreatedByUserId									AS CreatedByUserId
				, 'Course Deleted'									AS Item
				, NULL												AS NewValue
				, 'Course Type:' + CT.Title							AS OldValue
			FROM DELETED D
			INNER JOIN CourseType CT ON CT.Id = D.CourseTypeId
			WHERE D.Id IS NOT NULL;
		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_26.02_AmendDeleteTriggerToCourseTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO
		