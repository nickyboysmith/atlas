
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 16/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_26.02_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSCourse' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseDORSCourse] ON [dbo].[Course];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSCourse] ON [dbo].[Course]
		(
			[DORSCourse] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSCourseDORSNotificationRequestedDORSNotified' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseDORSCourseDORSNotificationRequestedDORSNotified] ON [dbo].[Course];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSCourseDORSNotificationRequestedDORSNotified] ON [dbo].[Course]
		(
			[DORSCourse], [DORSNotificationRequested], [DORSNotified] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSCourseDORSNotified' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseDORSCourseDORSNotified] ON [dbo].[Course];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSCourseDORSNotified] ON [dbo].[Course]
		(
			[DORSCourse], [DORSNotified] ASC
		);
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

