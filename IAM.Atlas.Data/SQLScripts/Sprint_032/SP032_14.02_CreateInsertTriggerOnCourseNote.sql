/*
	SCRIPT: New Insert trigger on table CourseNote
	Author: Robert Newnham
	Created: 18/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_14.02_CreateInsertTriggerOnCourseNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'New Update and Insert trigger on table Location';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseNote_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseNote_Insert;
	END
GO
	CREATE TRIGGER TRG_CourseNote_Insert ON dbo.CourseNote AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseNote', 'TRG_CourseNote_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------

			UPDATE CN
				SET CN.[DateCreated] = GETDATE()
				, CN.Removed = ISNULL(CN.Removed, 'False')
			FROM CourseNote CN
			INNER JOIN INSERTED I ON I.Id = CN.Id;
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_14.02_CreateInsertTriggerOnCourseNote.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO