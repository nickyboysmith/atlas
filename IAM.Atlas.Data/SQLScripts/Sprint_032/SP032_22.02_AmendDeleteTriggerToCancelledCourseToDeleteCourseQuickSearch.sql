/*
	SCRIPT: Amend Delete trigger to the CancelledCourse table to delete from the CourseQuickSearch
	Author: Robert Newnham
	Created: 29/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_22.02_AmendDeleteTriggerToCancelledCourseToDeleteCourseQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Delete trigger to the CancelledCourse table to Update the CourseQuickSearch';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_CancelledCourseToInsertCourseQuickSearch_DELETE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CancelledCourseToInsertCourseQuickSearch_DELETE];
	END
GO

	/*******************************************************************************************************************/
	CREATE TRIGGER TRG_CancelledCourseToInsertCourseQuickSearch_DELETE ON CancelledCourse FOR INSERT
	AS		
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN   
			DECLARE @CourseId INT;

			SELECT TOP 1 @CourseId = D.CourseId
			FROM DELETED D;

			EXEC dbo.usp_RefreshSingleCourseQuickSearchData @CourseId;
			
		END --END PROCESS

	END
	GO

	/*******************************************************************************************************************/

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_22.02_AmendDeleteTriggerToCancelledCourseToDeleteCourseQuickSearch.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO