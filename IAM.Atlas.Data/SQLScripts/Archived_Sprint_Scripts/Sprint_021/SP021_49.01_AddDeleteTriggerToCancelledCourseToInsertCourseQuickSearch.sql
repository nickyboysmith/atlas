/*
	SCRIPT: Add delete trigger to the CancelledCourse table to insert into the CourseQuickSearch table
	Author: Nick Smith
	Created: 07/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_49.01_AddDeleteTriggerToCancelledCourseToInsertCourseQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add delete trigger to the CancelledCourse table. Insert rows into CourseQuickSearch';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_CancelledCourseToInsertCourseQuickSearch_DELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CancelledCourseToInsertCourseQuickSearch_DELETE];
		END
GO
		CREATE TRIGGER TRG_CancelledCourseToInsertCourseQuickSearch_DELETE ON CancelledCourse FOR DELETE
AS

		DECLARE @CourseId INT;

		SELECT TOP 1 @CourseId = d.CourseId
		FROM deleted d;

		EXEC dbo.usp_RefreshSingleCourseQuickSearchData @CourseId;

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_49.01_AddDeleteTriggerToCancelledCourseToInsertCourseQuickSearch.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO