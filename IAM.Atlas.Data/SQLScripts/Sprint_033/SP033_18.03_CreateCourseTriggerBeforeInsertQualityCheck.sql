/*
	SCRIPT: Create Course Trigger Before Insert Quality Check
	Author: Robert Newnham
	Created: 13/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_18.03_CreateCourseTriggerBeforeInsertQualityCheck.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Course rigger Before Insert Quality Check';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Course_BeforeInsertCheck_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Course_BeforeInsertCheck_Insert;
	END
GO
	CREATE TRIGGER TRG_Course_BeforeInsertCheck_Insert ON dbo.Course AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_BeforeInsertCheck_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------

			UPDATE C
			SET C.Available = ISNULL(I.Available, 'False')
			, C.DateCreated = ISNULL(I.DateCreated, GETDATE())
			FROM INSERTED I
			INNER JOIN Course C ON C.Id = I.Id
			WHERE I.DateCreated IS NULL OR I.Available IS NULL
			;

		END --END PROCESS
		
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_18.03_CreateCourseTriggerBeforeInsertQualityCheck.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO