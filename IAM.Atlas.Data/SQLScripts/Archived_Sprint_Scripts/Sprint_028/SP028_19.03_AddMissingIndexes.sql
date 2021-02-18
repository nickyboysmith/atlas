
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 24/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_19.03_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailDateCreated' 
				AND object_id = OBJECT_ID('ScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailDateCreated] ON [dbo].[ScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailDateCreated] ON [dbo].[ScheduledEmail]
		(
			[DateCreated] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailSendAfter' 
				AND object_id = OBJECT_ID('ScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailSendAfter] ON [dbo].[ScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailSendAfter] ON [dbo].[ScheduledEmail]
		(
			[SendAfter] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailSubject' 
				AND object_id = OBJECT_ID('ScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailSubject] ON [dbo].[ScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailSubject] ON [dbo].[ScheduledEmail]
		(
			[Subject] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageTitle' 
				AND object_id = OBJECT_ID('Message'))
		BEGIN
		   DROP INDEX [IX_MessageTitle] ON [dbo].[Message];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageTitle] ON [dbo].[Message]
		(
			[Title] ASC
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

