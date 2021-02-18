
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 17/08/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP024_32.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationScheduledEmailOrganisationIdScheduledEmailId' 
				AND object_id = OBJECT_ID('OrganisationScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_OrganisationScheduledEmailOrganisationIdScheduledEmailId] ON [dbo].[OrganisationScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationScheduledEmailOrganisationIdScheduledEmailId] ON [dbo].[OrganisationScheduledEmail]
		(
			[OrganisationId] ASC
			, [ScheduledEmailId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageAllUsersDisabledIdMessageCategoryId' 
				AND object_id = OBJECT_ID('Message'))
		BEGIN
		   DROP INDEX [IX_MessageAllUsersDisabledIdMessageCategoryId] ON [dbo].[Message];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageAllUsersDisabledIdMessageCategoryId] ON [dbo].[Message]
		(
			[AllUsers] ASC
			, [Disabled] ASC
			, [Id] ASC
			, [MessageCategoryId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageMessageCategoryId' 
				AND object_id = OBJECT_ID('Message'))
		BEGIN
		   DROP INDEX [IX_MessageMessageCategoryId] ON [dbo].[Message];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageMessageCategoryId] ON [dbo].[Message]
		(
			[MessageCategoryId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientMessageId' 
				AND object_id = OBJECT_ID('MessageRecipient'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientMessageId] ON [dbo].[MessageRecipient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientMessageId] ON [dbo].[MessageRecipient]
		(
			[MessageId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientExceptionMessageId' 
				AND object_id = OBJECT_ID('MessageRecipientException'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientExceptionMessageId] ON [dbo].[MessageRecipientException];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientExceptionMessageId] ON [dbo].[MessageRecipientException]
		(
			[MessageId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientOrganisationMessageId' 
				AND object_id = OBJECT_ID('MessageRecipientOrganisation'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientOrganisationMessageId] ON [dbo].[MessageRecipientOrganisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientOrganisationMessageId] ON [dbo].[MessageRecipientOrganisation]
		(
			[MessageId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientOrganisationOrganisationId' 
				AND object_id = OBJECT_ID('MessageRecipientOrganisation'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientOrganisationOrganisationId] ON [dbo].[MessageRecipientOrganisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientOrganisationOrganisationId] ON [dbo].[MessageRecipientOrganisation]
		(
			[OrganisationId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientOrganisationOrganisationIdMessageId' 
				AND object_id = OBJECT_ID('MessageRecipientOrganisation'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientOrganisationOrganisationIdMessageId] ON [dbo].[MessageRecipientOrganisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientOrganisationOrganisationIdMessageId] ON [dbo].[MessageRecipientOrganisation]
		(
			[OrganisationId] ASC
			, [MessageId] ASC
		);
		/************************************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientOrganisationExceptionMessageId' 
				AND object_id = OBJECT_ID('MessageRecipientOrganisationException'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientOrganisationExceptionMessageId] ON [dbo].[MessageRecipientOrganisationException];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientOrganisationExceptionMessageId] ON [dbo].[MessageRecipientOrganisationException]
		(
			[MessageId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientOrganisationExceptionOrganisationId' 
				AND object_id = OBJECT_ID('MessageRecipientOrganisationException'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientOrganisationExceptionOrganisationId] ON [dbo].[MessageRecipientOrganisationException];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientOrganisationExceptionOrganisationId] ON [dbo].[MessageRecipientOrganisationException]
		(
			[OrganisationId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientOrganisationExceptionOrganisationIdMessageId' 
				AND object_id = OBJECT_ID('MessageRecipientOrganisationException'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientOrganisationExceptionOrganisationIdMessageId] ON [dbo].[MessageRecipientOrganisationException];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientOrganisationExceptionOrganisationIdMessageId] ON [dbo].[MessageRecipientOrganisationException]
		(
			[OrganisationId] ASC
			, [MessageId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageScheduleMessageId' 
				AND object_id = OBJECT_ID('MessageSchedule'))
		BEGIN
		   DROP INDEX [IX_MessageScheduleMessageId] ON [dbo].[MessageSchedule];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageScheduleMessageId] ON [dbo].[MessageSchedule]
		(
			[MessageId] ASC
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

