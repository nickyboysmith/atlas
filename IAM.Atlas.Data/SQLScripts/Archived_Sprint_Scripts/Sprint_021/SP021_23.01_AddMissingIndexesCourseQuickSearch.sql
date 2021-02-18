
/*
 * SCRIPT: Add Missing Indexes to table CourseQuickSearch.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_23.01_AddMissingIndexesCourseQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseQuickSearch';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseQuickSearchCourseId' 
				AND object_id = OBJECT_ID('CourseQuickSearch'))
		BEGIN
		   DROP INDEX [IX_CourseQuickSearchCourseId] ON [dbo].[CourseQuickSearch];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseQuickSearchCourseId] ON [dbo].[CourseQuickSearch]
		(
			[CourseId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

