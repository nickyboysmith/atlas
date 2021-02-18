
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 22/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP042_11.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientScheduledEmailClientIdScheduledEmailId' 
				AND object_id = OBJECT_ID('ClientScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ClientScheduledEmailClientIdScheduledEmailId] ON [dbo].[ClientScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientScheduledEmailClientIdScheduledEmailId] ON [dbo].[ClientScheduledEmail]
		(
			[ClientId], [ScheduledEmailId] ASC
		) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientScheduledEmailScheduledEmailId' 
				AND object_id = OBJECT_ID('ClientScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ClientScheduledEmailScheduledEmailId] ON [dbo].[ClientScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientScheduledEmailScheduledEmailId] ON [dbo].[ClientScheduledEmail]
		(
			[ScheduledEmailId] ASC
		) WITH (ONLINE = ON) ;
		/************************************************************************************/
		


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

