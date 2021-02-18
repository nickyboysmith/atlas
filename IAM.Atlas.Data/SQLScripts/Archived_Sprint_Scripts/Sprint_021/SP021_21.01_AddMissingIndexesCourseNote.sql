
/*
 * SCRIPT: Add Missing Indexes to table CourseNote.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_21.01_AddMissingIndexesCourseNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseNote';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseNoteCourseId' 
				AND object_id = OBJECT_ID('CourseNote'))
		BEGIN
		   DROP INDEX [IX_CourseNoteCourseId] ON [dbo].[CourseNote];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseNoteCourseId] ON [dbo].[CourseNote]
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

