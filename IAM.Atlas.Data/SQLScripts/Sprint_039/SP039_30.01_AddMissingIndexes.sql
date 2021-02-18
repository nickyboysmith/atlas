
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 28/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP039_30.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSClientCourseIdClientId' 
				AND object_id = OBJECT_ID('CourseDORSClient'))
		BEGIN
		   DROP INDEX [IX_CourseDORSClientCourseIdClientId] ON [dbo].[CourseDORSClient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSClientCourseIdClientId] ON [dbo].[CourseDORSClient]
		(
			[CourseId], [ClientId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSClientCourseId' 
				AND object_id = OBJECT_ID('CourseDORSClient'))
		BEGIN
		   DROP INDEX [IX_CourseDORSClientCourseId] ON [dbo].[CourseDORSClient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSClientCourseId] ON [dbo].[CourseDORSClient]
		(
			[CourseId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSClientClientId' 
				AND object_id = OBJECT_ID('CourseDORSClient'))
		BEGIN
		   DROP INDEX [IX_CourseDORSClientClientId] ON [dbo].[CourseDORSClient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSClientClientId] ON [dbo].[CourseDORSClient]
		(
			[ClientId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSClientCourseIdClientIdIsMysteryShopper' 
				AND object_id = OBJECT_ID('CourseDORSClient'))
		BEGIN
		   DROP INDEX [IX_CourseDORSClientCourseIdClientIdIsMysteryShopper] ON [dbo].[CourseDORSClient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSClientCourseIdClientIdIsMysteryShopper] ON [dbo].[CourseDORSClient]
		(
			[CourseId], [ClientId], [IsMysteryShopper] ASC
		) ;
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

