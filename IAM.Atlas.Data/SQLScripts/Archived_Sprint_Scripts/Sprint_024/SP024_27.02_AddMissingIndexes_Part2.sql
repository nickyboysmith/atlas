
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 12/08/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP024_27.02_AddMissingIndexes_Part2.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_EmailAddress' 
				AND object_id = OBJECT_ID('Email'))
		BEGIN
		   DROP INDEX [IX_EmailAddress] ON [dbo].[Email];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_EmailAddress] ON [dbo].[Email]
		(
			[Address]  ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_EmailsBlockedOutgoingOrganisationId' 
				AND object_id = OBJECT_ID('EmailsBlockedOutgoing'))
		BEGIN
		   DROP INDEX [IX_EmailsBlockedOutgoingOrganisationId] ON [dbo].[EmailsBlockedOutgoing];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_EmailsBlockedOutgoingOrganisationId] ON [dbo].[EmailsBlockedOutgoing]
		(
			[OrganisationId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_EmailsBlockedOutgoingEmail' 
				AND object_id = OBJECT_ID('EmailsBlockedOutgoing'))
		BEGIN
		   DROP INDEX [IX_EmailsBlockedOutgoingEmail] ON [dbo].[EmailsBlockedOutgoing];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_EmailsBlockedOutgoingEmail] ON [dbo].[EmailsBlockedOutgoing]
		(
			[Email] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_EmailServiceCredentialEmailServiceId' 
				AND object_id = OBJECT_ID('EmailServiceCredential'))
		BEGIN
		   DROP INDEX [IX_EmailServiceCredentialEmailServiceId] ON [dbo].[EmailServiceCredential];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_EmailServiceCredentialEmailServiceId] ON [dbo].[EmailServiceCredential]
		(
			[EmailServiceId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_EmailServiceEmailCountEmailServiceId' 
				AND object_id = OBJECT_ID('EmailServiceEmailCount'))
		BEGIN
		   DROP INDEX [IX_EmailServiceEmailCountEmailServiceId] ON [dbo].[EmailServiceEmailCount];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_EmailServiceEmailCountEmailServiceId] ON [dbo].[EmailServiceEmailCount]
		(
			[EmailServiceId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_EmailServiceEmailsSentEmailServiceId' 
				AND object_id = OBJECT_ID('EmailServiceEmailsSent'))
		BEGIN
		   DROP INDEX [IX_EmailServiceEmailsSentEmailServiceId] ON [dbo].[EmailServiceEmailsSent];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_EmailServiceEmailsSentEmailServiceId] ON [dbo].[EmailServiceEmailsSent]
		(
			[EmailServiceId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_EmailServiceEmailsSentScheduledEmailId' 
				AND object_id = OBJECT_ID('EmailServiceEmailsSent'))
		BEGIN
		   DROP INDEX [IX_EmailServiceEmailsSentScheduledEmailId] ON [dbo].[EmailServiceEmailsSent];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_EmailServiceEmailsSentScheduledEmailId] ON [dbo].[EmailServiceEmailsSent]
		(
			[ScheduledEmailId] ASC
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

