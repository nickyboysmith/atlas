
/*
 * SCRIPT: Add Missing Indexes to table CourseTypeCategory.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_27.01_AddMissingIndexesCourseTypeCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseTypeCategory';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeCategoryCourseTypeId' 
				AND object_id = OBJECT_ID('CourseTypeCategory'))
		BEGIN
		   DROP INDEX [IX_CourseTypeCategoryCourseTypeId] ON [dbo].[CourseTypeCategory];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTypeCategoryCourseTypeId] ON [dbo].[CourseTypeCategory]
		(
			[CourseTypeId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
