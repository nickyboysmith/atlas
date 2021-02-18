
/*
 * SCRIPT: Add Missing Indexes to table CourseSchedule.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_24.01_AddMissingIndexesCourseSchedule.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseSchedule';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseScheduleCourseIdDate' 
				AND object_id = OBJECT_ID('CourseSchedule'))
		BEGIN
		   DROP INDEX [IX_CourseScheduleCourseIdDate] ON [dbo].[CourseSchedule];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseScheduleCourseIdDate] ON [dbo].[CourseSchedule]
		(
			[CourseId], [Date]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

