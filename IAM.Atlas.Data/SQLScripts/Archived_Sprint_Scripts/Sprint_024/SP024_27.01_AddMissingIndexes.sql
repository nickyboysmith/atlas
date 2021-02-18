
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 11/08/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP024_27.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailScheduledEmailStateId' 
				AND object_id = OBJECT_ID('ScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailScheduledEmailStateId] ON [dbo].[ScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailScheduledEmailStateId] ON [dbo].[ScheduledEmail]
		(
			[ScheduledEmailStateId]  ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailEmailProcessedEmailServiceId' 
				AND object_id = OBJECT_ID('ScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailEmailProcessedEmailServiceId] ON [dbo].[ScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailEmailProcessedEmailServiceId] ON [dbo].[ScheduledEmail]
		(
			[EmailProcessedEmailServiceId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailAttachmentScheduledEmailId' 
				AND object_id = OBJECT_ID('ScheduledEmailAttachment'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailAttachmentScheduledEmailId] ON [dbo].[ScheduledEmailAttachment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailAttachmentScheduledEmailId] ON [dbo].[ScheduledEmailAttachment]
		(
			[ScheduledEmailId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailNoteScheduledEmailId' 
				AND object_id = OBJECT_ID('ScheduledEmailNote'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailNoteScheduledEmailId] ON [dbo].[ScheduledEmailNote];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailNoteScheduledEmailId] ON [dbo].[ScheduledEmailNote]
		(
			[ScheduledEmailId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailToScheduledEmailId' 
				AND object_id = OBJECT_ID('ScheduledEmailTo'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailToScheduledEmailId] ON [dbo].[ScheduledEmailTo];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailToScheduledEmailId] ON [dbo].[ScheduledEmailTo]
		(
			[ScheduledEmailId] ASC
		);
		/************************************************************************************/
		
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

