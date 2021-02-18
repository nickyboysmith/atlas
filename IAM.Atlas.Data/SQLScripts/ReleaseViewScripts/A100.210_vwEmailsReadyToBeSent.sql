
		-- Data View of Emails ready to be sent
		

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
			SELECT TOP (dbo.udfGetMaxNumberEmailsToProcessAtOnce())
							O.Id AS OrganisationId
							, O.Name AS OrganisationName
							, (CASE WHEN ES.[Disabled] = 'True' THEN NULL ELSE ES.Id END) AS EmailServiceId
							, (CASE WHEN ES.[Disabled] = 'True' THEN NULL ELSE ES.Name END) AS EmailServiceName
							, SCET.ScheduledEmailId AS EmailId
							, SCET.Email AS EmailToAddress
							, concat('<', SCE.FromEmail, '> ', SCE.FromName) AS EmailReplyNameEmailCombo
							, SCE.FromEmail AS EmailFromEmail
							, SCE.FromName AS EmailFromName
							, SCE.Content AS EmailContent
							, SCE.[Subject] AS EmailSubject
							, SCET.CC AS EmailCCFlag
							, SCET.BCC AS EmailBCCFlag
							, EmailAttachmentPivot.EmailAttachment_1 AS EmailAttachmentPath1
							, EmailAttachmentPivot.EmailAttachment_2 AS EmailAttachmentPath2
							, EmailAttachmentPivot.EmailAttachment_3 AS EmailAttachmentPath3
							, EmailAttachmentPivot.EmailAttachment_4 AS EmailAttachmentPath4
							, EmailAttachmentPivot.EmailAttachment_5 AS EmailAttachmentPath5
							, EmailAttachmentPivot.EmailAttachment_6 AS EmailAttachmentPath6
							, EmailAttachmentPivot.EmailAttachment_7 AS EmailAttachmentPath7
							, EmailAttachmentPivot.EmailAttachment_8 AS EmailAttachmentPath8
							, EmailAttachmentPivot.EmailAttachment_9 AS EmailAttachmentPath9
							, SCE.SendAfter AS SendEmailAfter
							, SCE.DateCreated AS DateEmailCreated
							, SCE.SendAtempts AS EmailSendAttempts
						FROM ScheduledEmail SCE
						INNER JOIN ScheduledEmailTo SCET ON SCE.Id = SCET.ScheduledEmailId
						INNER JOIN ScheduledEmailState SEST ON SCE.ScheduledEmailStateId = SEST.Id
						LEFT JOIN OrganisationScheduledEmail OSCE ON SCE.Id = OSCE.ScheduledEmailId
						LEFT JOIN Organisation O ON OSCE.OrganisationId = O.Id
						LEFT JOIN OrganisationPrefferedEmailService OPES ON OSCE.OrganisationId = OPES.OrganisationId
						LEFT JOIN EmailService ES ON OPES.EmailServiceId = ES.Id
						LEFT JOIN (
									SELECT 
										ScheduledEmailId
										, EmailAttachment_1 
										, EmailAttachment_2
										, EmailAttachment_3
										, EmailAttachment_4
										, EmailAttachment_5
										, EmailAttachment_6
										, EmailAttachment_7
										, EmailAttachment_8
										, EmailAttachment_9
									FROM (SELECT 			 
											ScheduledEmailId
											, 'EmailAttachment_' + cast(RANK() OVER (PARTITION BY ScheduledEmailId ORDER BY Id, ScheduledEmailId)  as varchar(20)) Id
											, FilePath
										FROM ScheduledEmailAttachment
										) d
									PIVOT
									(
										max(FilePath)
										for Id in (EmailAttachment_1, EmailAttachment_2, EmailAttachment_3, EmailAttachment_4, EmailAttachment_5, EmailAttachment_6, EmailAttachment_7, EmailAttachment_8, EmailAttachment_9)
									) p
								) As EmailAttachmentPivot ON SCE.Id = EmailAttachmentPivot.ScheduledEmailId
						WHERE dbo.udfIsEmailScheduleDisabled() = 'False'
						AND SEST.Id IN (SELECT DISTINCT Id FROM ScheduledEmailState WHERE NAME IN('Pending', 'Failed - Retrying'))
						AND SCET.Email IS NOT NULL
						AND SCET.Email <> ''
						AND SCE.[Disabled] = 'False'
						AND SCET.Email NOT IN (SELECT DISTINCT Email
												FROM EmailsBlockedOutgoing EBO
												WHERE EBO.OrganisationId IS NULL
												OR EBO.OrganisationId = O.Id);


	GO
