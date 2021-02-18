/*
	SCRIPT: Add insert trigger to the CancelledCourse table to delete from the CourseQuickSearch
	Author: Nick Smith
	Created: 07/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_48.01_AddInsertTriggerToCancelledCourseToDeleteCourseQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the CancelledCourse table. Delete rows from CourseQuickSearch';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT];
		END
GO
		CREATE TRIGGER TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT ON CancelledCourse FOR INSERT
AS

		DELETE cqs
			FROM CourseQuickSearch cqs
			INNER JOIN inserted i on cqs.CourseId = i.CourseId

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_48.01_AddInsertTriggerToCancelledCourseToDeleteCourseQuickSearch.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO