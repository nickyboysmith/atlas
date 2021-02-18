/*
 * SCRIPT: Add Missing Index to table CourseSearch.
 * Author: Robert Newnham
 * Created: 03/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP017_01.01_AddMissingIndexCourseSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseSearch';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseQuickSearchOrgIdSearchContent' 
				AND object_id = OBJECT_ID('CourseQuickSearch'))
		BEGIN
		   DROP INDEX [IX_CourseQuickSearchOrgIdSearchContent] ON [dbo].[CourseQuickSearch];
		END


		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseQuickSearchOrgIdSearchContent] ON [dbo].[CourseQuickSearch]
		(
			[OrganisationId], [SearchContent] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

