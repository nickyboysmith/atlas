/*
	SCRIPT: Amend Insert trigger to the CancelledCourse table to delete from the CourseQuickSearch
	Author: Robert Newnham
	Created: 29/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_22.01_AmendInsertTriggerToCancelledCourseToDeleteCourseQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to the CancelledCourse table to delete from the CourseQuickSearch';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT];
	END
GO

	/*******************************************************************************************************************/
	CREATE TRIGGER TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT ON CancelledCourse FOR INSERT
	AS

		
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN   
			DELETE cqs
			FROM INSERTED I
			INNER JOIN CourseQuickSearch CQS ON CQS.CourseId = I.CourseId;

		END --END PROCESS

	END
	GO

	/*******************************************************************************************************************/

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_22.01_AmendInsertTriggerToCancelledCourseToDeleteCourseQuickSearch.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO