
/*
 * SCRIPT: Add Missing Indexes to table CourseLanguage.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_19.01_AddMissingIndexesCourseLanguage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseLanguage';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseLanguageCourseId' 
				AND object_id = OBJECT_ID('CourseLanguage'))
		BEGIN
		   DROP INDEX [IX_CourseLanguageCourseId] ON [dbo].[CourseLanguage];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseLanguageCourseId] ON [dbo].[CourseLanguage]
		(
			[CourseId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

