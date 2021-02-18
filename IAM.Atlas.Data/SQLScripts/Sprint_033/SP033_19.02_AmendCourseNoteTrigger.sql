/*
	SCRIPT: Amend CourseNote Trigger
	Author: Robert Newnham
	Created: 14/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_19.02_AmendCourseNoteTrigger.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend CourseNote Trigger';

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
				SET CN.[DateCreated] = ISNULL(CN.[DateCreated], GETDATE())
				, CN.Removed = ISNULL(CN.Removed, 'False')
			FROM INSERTED I
			INNER JOIN CourseNote CN ON I.Id = CN.Id
			WHERE I.DateCreated IS NULL
			OR CN.Removed IS NULL;
			
		END --END PROCESS
		
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_19.02_AmendCourseNoteTrigger.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO