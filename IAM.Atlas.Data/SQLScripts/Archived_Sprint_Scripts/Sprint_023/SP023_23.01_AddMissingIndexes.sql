
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_23.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_LetterTemplateOrganisationId' 
				AND object_id = OBJECT_ID('LetterTemplate'))
		BEGIN
		   DROP INDEX [IX_LetterTemplateOrganisationId] ON [dbo].[LetterTemplate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_LetterTemplateOrganisationId] ON [dbo].[LetterTemplate]
		(
			[OrganisationId]  ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_LetterTemplateDocumentTemplateId' 
				AND object_id = OBJECT_ID('LetterTemplate'))
		BEGIN
		   DROP INDEX [IX_LetterTemplateDocumentTemplateId] ON [dbo].[LetterTemplate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_LetterTemplateDocumentTemplateId] ON [dbo].[LetterTemplate]
		(
			[DocumentTemplateId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_LetterTemplateUpdatedByUserId' 
				AND object_id = OBJECT_ID('LetterTemplate'))
		BEGIN
		   DROP INDEX [IX_LetterTemplateUpdatedByUserId] ON [dbo].[LetterTemplate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_LetterTemplateUpdatedByUserId] ON [dbo].[LetterTemplate]
		(
			[UpdatedByUserId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_LocationPostCode' 
				AND object_id = OBJECT_ID('Location'))
		BEGIN
		   DROP INDEX [IX_LocationPostCode] ON [dbo].[Location];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_LocationPostCode] ON [dbo].[Location]
		(
			[PostCode] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_LoginNumberLoginReference' 
				AND object_id = OBJECT_ID('LoginNumber'))
		BEGIN
		   DROP INDEX [IX_LoginNumberLoginReference] ON [dbo].[LoginNumber];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_LoginNumberLoginReference] ON [dbo].[LoginNumber]
		(
			[LoginReference] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_LoginSessionUserId' 
				AND object_id = OBJECT_ID('LoginSession'))
		BEGIN
		   DROP INDEX [IX_LoginSessionUserId] ON [dbo].[LoginSession];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_LoginSessionUserId] ON [dbo].[LoginSession]
		(
			[UserId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageAcknowledgementMessageId' 
				AND object_id = OBJECT_ID('MessageAcknowledgement'))
		BEGIN
		   DROP INDEX [IX_MessageAcknowledgementMessageId] ON [dbo].[MessageAcknowledgement];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageAcknowledgementMessageId] ON [dbo].[MessageAcknowledgement]
		(
			[MessageId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageAcknowledgementUserId' 
				AND object_id = OBJECT_ID('MessageAcknowledgement'))
		BEGIN
		   DROP INDEX [IX_MessageAcknowledgementUserId] ON [dbo].[MessageAcknowledgement];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageAcknowledgementUserId] ON [dbo].[MessageAcknowledgement]
		(
			[UserId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageAcknowledgementMessageIdUserId' 
				AND object_id = OBJECT_ID('MessageAcknowledgement'))
		BEGIN
		   DROP INDEX [IX_MessageAcknowledgementMessageIdUserId] ON [dbo].[MessageAcknowledgement];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageAcknowledgementMessageIdUserId] ON [dbo].[MessageAcknowledgement]
		(
			[MessageId], [UserId] ASC
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
				WHERE name='IX_MessageRecipientUserId' 
				AND object_id = OBJECT_ID('MessageRecipient'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientUserId] ON [dbo].[MessageRecipient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientUserId] ON [dbo].[MessageRecipient]
		(
			[UserId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientMessageIdUserId' 
				AND object_id = OBJECT_ID('MessageRecipient'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientMessageIdUserId] ON [dbo].[MessageRecipient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientMessageIdUserId] ON [dbo].[MessageRecipient]
		(
			[MessageId], [UserId] ASC
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
				WHERE name='IX_MessageRecipientExceptionUserId' 
				AND object_id = OBJECT_ID('MessageRecipientException'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientExceptionUserId] ON [dbo].[MessageRecipientException];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientExceptionUserId] ON [dbo].[MessageRecipientException]
		(
			[UserId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientExceptionMessageIdUserId' 
				AND object_id = OBJECT_ID('MessageRecipientException'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientExceptionMessageIdUserId] ON [dbo].[MessageRecipientException];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientExceptionMessageIdUserId] ON [dbo].[MessageRecipientException]
		(
			[MessageId], [UserId] ASC
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
				WHERE name='IX_MessageRecipientOrganisationMessageIdOrganisationId' 
				AND object_id = OBJECT_ID('MessageRecipientOrganisation'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientOrganisationMessageIdOrganisationId] ON [dbo].[MessageRecipientOrganisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientOrganisationMessageIdOrganisationId] ON [dbo].[MessageRecipientOrganisation]
		(
			[MessageId], [OrganisationId] ASC
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
				WHERE name='IX_MessageRecipientOrganisationExceptionMessageIdOrganisationId' 
				AND object_id = OBJECT_ID('MessageRecipientOrganisationException'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientOrganisationExceptionMessageIdOrganisationId] ON [dbo].[MessageRecipientOrganisationException];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientOrganisationExceptionMessageIdOrganisationId] ON [dbo].[MessageRecipientOrganisationException]
		(
			[MessageId], [OrganisationId] ASC
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
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationAdminUserUserId' 
				AND object_id = OBJECT_ID('OrganisationAdminUser'))
		BEGIN
		   DROP INDEX [IX_OrganisationAdminUserUserId] ON [dbo].[OrganisationAdminUser];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationAdminUserUserId] ON [dbo].[OrganisationAdminUser]
		(
			[UserId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationAdminUserOrganisationId' 
				AND object_id = OBJECT_ID('OrganisationAdminUser'))
		BEGIN
		   DROP INDEX [IX_OrganisationAdminUserOrganisationId] ON [dbo].[OrganisationAdminUser];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationAdminUserOrganisationId] ON [dbo].[OrganisationAdminUser]
		(
			[OrganisationId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationAdminUserOrganisationIdUserId' 
				AND object_id = OBJECT_ID('OrganisationAdminUser'))
		BEGIN
		   DROP INDEX [IX_OrganisationAdminUserOrganisationIdUserId] ON [dbo].[OrganisationAdminUser];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationAdminUserOrganisationIdUserId] ON [dbo].[OrganisationAdminUser]
		(
			[OrganisationId], [UserId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationScheduledEmailScheduledEmailId' 
				AND object_id = OBJECT_ID('OrganisationScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_OrganisationScheduledEmailScheduledEmailId] ON [dbo].[OrganisationScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationScheduledEmailScheduledEmailId] ON [dbo].[OrganisationScheduledEmail]
		(
			[ScheduledEmailId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationScheduledEmailOrganisationId' 
				AND object_id = OBJECT_ID('OrganisationScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_OrganisationScheduledEmailOrganisationId] ON [dbo].[OrganisationScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationScheduledEmailOrganisationId] ON [dbo].[OrganisationScheduledEmail]
		(
			[OrganisationId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationScheduledEmailScheduledEmailIdOrganisationId' 
				AND object_id = OBJECT_ID('OrganisationScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_OrganisationScheduledEmailScheduledEmailIdOrganisationId] ON [dbo].[OrganisationScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationScheduledEmailScheduledEmailIdOrganisationId] ON [dbo].[OrganisationScheduledEmail]
		(
			[ScheduledEmailId], [OrganisationId] ASC
		);
		/************************************************************************************/
				
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationUserUserId' 
				AND object_id = OBJECT_ID('OrganisationUser'))
		BEGIN
		   DROP INDEX [IX_OrganisationUserUserId] ON [dbo].[OrganisationUser];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationUserUserId] ON [dbo].[OrganisationUser]
		(
			[UserId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationUserOrganisationId' 
				AND object_id = OBJECT_ID('OrganisationUser'))
		BEGIN
		   DROP INDEX [IX_OrganisationUserOrganisationId] ON [dbo].[OrganisationUser];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationUserOrganisationId] ON [dbo].[OrganisationUser]
		(
			[OrganisationId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationUserOrganisationIdUserId' 
				AND object_id = OBJECT_ID('OrganisationUser'))
		BEGIN
		   DROP INDEX [IX_OrganisationUserOrganisationIdUserId] ON [dbo].[OrganisationUser];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationUserOrganisationIdUserId] ON [dbo].[OrganisationUser]
		(
			[OrganisationId], [UserId] ASC
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

