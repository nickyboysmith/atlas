
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 26/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP042_20.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailToEmail' 
				AND object_id = OBJECT_ID('ScheduledEmailTo'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailToEmail] ON [dbo].[ScheduledEmailTo];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailToEmail] ON [dbo].[ScheduledEmailTo]
		(
			[Email] ASC
		) INCLUDE ([ScheduledEmailId]) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDateCreated' 
				AND object_id = OBJECT_ID('Client'))
		BEGIN
		   DROP INDEX [IX_ClientDateCreated] ON [dbo].[Client];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDateCreated] ON [dbo].[Client]
		(
			[DateCreated] ASC
		) INCLUDE ([DisplayName]) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientClientIdCourseId' 
				AND object_id = OBJECT_ID('CourseClient'))
		BEGIN
		   DROP INDEX [IX_CourseClientClientIdCourseId] ON [dbo].[CourseClient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientClientIdCourseId] ON [dbo].[CourseClient]
		(
			[ClientId], [CourseId] ASC
		) INCLUDE ([LastPaymentMadeDate], [TotalPaymentMade]) WITH (ONLINE = ON) ;
		/************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

