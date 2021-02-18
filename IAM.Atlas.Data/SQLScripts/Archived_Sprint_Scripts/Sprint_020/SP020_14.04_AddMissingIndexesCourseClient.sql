
/*
 * SCRIPT: Add Missing Indexes to table CourseClient.
 * Author: Robert Newnham
 * Created: 08/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_14.04_AddMissingIndexesCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseClient';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientCourseId' 
				AND object_id = OBJECT_ID('CourseClient'))
		BEGIN
		   DROP INDEX [IX_CourseClientCourseId] ON [dbo].[CourseClient];
		END


		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientCourseId] ON [dbo].[CourseClient]
		(
			[CourseId] ASC
		);

		/********************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientClientId' 
				AND object_id = OBJECT_ID('CourseClient'))
		BEGIN
		   DROP INDEX [IX_CourseClientClientId] ON [dbo].[CourseClient];
		END


		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientClientId] ON [dbo].[CourseClient]
		(
			[ClientId] ASC
		);
		
		/********************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientCourseIdClientId' 
				AND object_id = OBJECT_ID('CourseClient'))
		BEGIN
		   DROP INDEX [IX_CourseClientCourseIdClientId] ON [dbo].[CourseClient];
		END


		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientCourseIdClientId] ON [dbo].[CourseClient]
		(
			[CourseId], [ClientId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

