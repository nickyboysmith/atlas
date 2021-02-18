
/*
 * SCRIPT: Alter Indexes to table CourseLog.
 * Author: Nick Smith
 * Created: 07/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_41.01_AlterIndexesCourseLogAddCourseIdAndCreatedByUserId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Indexes to table CourseLog, Add CourseId and CreatedByUserId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Combined Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseLogCourseIdCreatedByUserId' 
				AND object_id = OBJECT_ID('CourseLog'))
		BEGIN
		   DROP INDEX [IX_CourseLogCourseIdCreatedByUserId] ON [dbo].[CourseLog];
		END

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseLogCourseId' 
				AND object_id = OBJECT_ID('CourseLog'))
		BEGIN
		   DROP INDEX [IX_CourseLogCourseId] ON [dbo].[CourseLog];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseLogCourseId] ON [dbo].[CourseLog]
		(
			[CourseId]  ASC
		);

		/***************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseLogCreatedByUserId' 
				AND object_id = OBJECT_ID('CourseLog'))
		BEGIN
		   DROP INDEX [IX_CourseLogCreatedByUserId] ON [dbo].[CourseLog];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseLogCreatedByUserId] ON [dbo].[CourseLog]
		(
			[CreatedByUserId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

