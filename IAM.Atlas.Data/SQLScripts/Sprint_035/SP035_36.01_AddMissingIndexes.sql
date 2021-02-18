
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 02/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_36.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSCourseDataCourseDate' 
				AND object_id = OBJECT_ID('DORSCourseData'))
		BEGIN
		   DROP INDEX [IX_DORSCourseDataCourseDate] ON [dbo].[DORSCourseData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSCourseDataCourseDate] ON [dbo].[DORSCourseData]
		(
			[CourseDate] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSCourseDataDORSCourseIdentifier' 
				AND object_id = OBJECT_ID('DORSCourseData'))
		BEGIN
		   DROP INDEX [IX_DORSCourseDataDORSCourseIdentifier] ON [dbo].[DORSCourseData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSCourseDataDORSCourseIdentifier] ON [dbo].[DORSCourseData]
		(
			[DORSCourseIdentifier] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSCourseDataDORSForceContractIdentifier' 
				AND object_id = OBJECT_ID('DORSCourseData'))
		BEGIN
		   DROP INDEX [IX_DORSCourseDataDORSForceContractIdentifier] ON [dbo].[DORSCourseData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSCourseDataDORSForceContractIdentifier] ON [dbo].[DORSCourseData]
		(
			[DORSForceContractIdentifier] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSCourseDataDORSSiteIdentifier' 
				AND object_id = OBJECT_ID('DORSCourseData'))
		BEGIN
		   DROP INDEX [IX_DORSCourseDataDORSSiteIdentifier] ON [dbo].[DORSCourseData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSCourseDataDORSSiteIdentifier] ON [dbo].[DORSCourseData]
		(
			[DORSSiteIdentifier] ASC
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

