
/*
	SCRIPT: Amend view vwEmailsReadyToBeSent, return null for EmailServiceId, EmailServiceName if provider is disabled
	Author: Nick Smith
	Created: 29/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_05.01_Amend_vwEmailsReadyToBeSent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend view vwEmailsReadyToBeSent, return null for EmailServiceId, EmailServiceName if provider is disabled';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwEmailsReadyToBeSent', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwEmailsReadyToBeSent;
		END		
		GO

		/**
		 * Create vwEmailsReadyToBeSent
		 */
		CREATE VIEW [dbo].[vwEmailsReadyToBeSent] 
		AS 
			SELECT 
				O.Id AS OrganisationId
				, O.Name AS OrganisationName
				, CASE WHEN ES.[Disabled] = 1 THEN NULL ELSE ES.Id END AS EmailServiceId
                , CASE WHEN ES.[Disabled] = 1 THEN NULL ELSE ES.Name END AS EmailServiceName
				, SCET.ScheduledEmailId AS EmailId
				, SCET.Email AS EmailToAddress
				, concat('<', SCE.FromEmail, '> ', SCE.FromName) AS EmailReplyNameEmailCombo
				, SCE.Content AS EmailContent
				, SCE.[Subject] AS EmailSubject
				, SCET.CC AS EmailCCFlag
				, SCET.BCC AS EmailBCCFlag
				, EmailAttachmentPivot.EmailAttachment_1 AS EmailAttachmentPath1
				, EmailAttachmentPivot.EmailAttachment_2 AS EmailAttachmentPath2
				, EmailAttachmentPivot.EmailAttachment_3 AS EmailAttachmentPath3
				, SCE.SendAfter AS SendEmailAfter
			FROM ScheduledEmail SCE
			INNER JOIN ScheduledEmailTo SCET ON SCE.Id = SCET.ScheduledEmailId
			INNER JOIN ScheduledEmailState SEST ON SCE.ScheduledEmailStateId = SEST.Id
			INNER JOIN OrganisationScheduledEmail OSCE ON SCE.Id = OSCE.ScheduledEmailId
			INNER JOIN Organisation O ON OSCE.OrganisationId = O.Id
			LEFT JOIN OrganisationPrefferedEmailService OPES ON OSCE.OrganisationId = OPES.OrganisationId
			LEFT JOIN EmailService ES ON OPES.EmailServiceId = ES.Id
			LEFT JOIN (
						SELECT 
							ScheduledEmailId
							, EmailAttachment_1 
							, EmailAttachment_2
							, EmailAttachment_3
						FROM (SELECT 			 
								ScheduledEmailId
								, 'EmailAttachment_' + cast(RANK() OVER (PARTITION BY ScheduledEmailId ORDER BY Id, ScheduledEmailId)  as varchar(20)) Id
								, FilePath
							FROM ScheduledEmailAttachment
							) d
						PIVOT
						(
							max(FilePath)
							for Id in (EmailAttachment_1, EmailAttachment_2, EmailAttachment_3)
						) p
					) As EmailAttachmentPivot ON SCE.Id = EmailAttachmentPivot.ScheduledEmailId
			WHERE SEST.Id IN (SELECT DISTINCT Id FROM ScheduledEmailState WHERE NAME IN('Pending', 'Failed - Retrying'))
			AND SCET.Email IS NOT NULL
			AND SCET.Email <> ''
			AND SCET.Email NOT IN (SELECT DISTINCT Email
									FROM EmailsBlockedOutgoing EBO
									WHERE EBO.OrganisationId IS NULL
									OR EBO.OrganisationId = O.Id);


	GO

DECLARE @ScriptName VARCHAR(100) = 'SP024_05.01_Amend_vwEmailsReadyToBeSent.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO