
/*
 * SCRIPT: Add Missing Indexes to table CourseLog.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_20.01_AddMissingIndexesCourseLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseLog';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseLogCourseIdCreatedByUserId' 
				AND object_id = OBJECT_ID('CourseLog'))
		BEGIN
		   DROP INDEX [IX_CourseLogCourseIdCreatedByUserId] ON [dbo].[CourseLog];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseLogCourseIdCreatedByUserId] ON [dbo].[CourseLog]
		(
			[CourseId], [CreatedByUserId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

