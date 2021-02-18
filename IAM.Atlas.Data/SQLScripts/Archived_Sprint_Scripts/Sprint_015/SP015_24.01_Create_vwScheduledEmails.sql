/*
	SCRIPT: Alter the stored procedure to send an email
	Author: Paul Tuck
	Created: 08/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_24.01_Create_vwScheduledEmails.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to see scheduled emails';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwScheduledEmails', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.vwScheduledEmails;
END		
GO

/*
	Create vwScheduledEmails
*/
CREATE VIEW vwScheduledEmails AS

SELECT 

			O.Id												AS OrganisationId,
			O.Name												AS OrganisationName,
			ES.Name												AS EmailServiceName,
			SCE.DateCreated										AS EmailCreatedDate,
			ScheduledEmailState.Name							As EmailState,
			SCET.Email											AS EmailToAddress,
			concat('<', SCE.FromEmail, '> ', SCE.FromName)		AS EmailReplyNameEmailCombo,
			SCE.Content											AS EmailContent,
			SCET.CC												AS EmailCCFlag,
			SCET.BCC											AS EmailBCCFlag,
			EmailAttachmentPivot.EmailAttachment_1				AS EmailAttachmentPath1,
			EmailAttachmentPivot.EmailAttachment_2				AS EmailAttachmentPath2,
			EmailAttachmentPivot.EmailAttachment_3				AS EmailAttachmentPath3,
			SCE.[Disabled]										AS [Disabled],
			CASE
				WHEN ScheduledEmailState.Id = 2 -- Sent
					THEN
						DateScheduledEmailStateUpdated
				ELSE
					NULL
			END													AS EmailDateSent,
			CAST(CASE
				WHEN ASAP = 1
					THEN
						'ASAP'
					ELSE
						SendAfter
					END AS varchar(25))							AS EmailScheduledDate 

		 FROM ScheduledEmail SCE
				JOIN ScheduledEmailTo SCET ON SCE.Id = SCET.ScheduledEmailId
				JOIN OrganisationScheduledEmail OSCE ON SCE.Id = OSCE.ScheduledEmailId
				JOIN OrganisationPrefferedEmailService OPES ON OSCE.OrganisationId = OPES.OrganisationId
				JOIN Organisation O ON OSCE.OrganisationId = O.Id
				LEFT JOIN EmailService ES ON OPES.EmailServiceId = ES.Id
				INNER JOIN ScheduledEmailState ON ScheduledEmailState.Id = SCE.ScheduledEmailStateId
				LEFT JOIN (
					SELECT 
						ScheduledEmailId,
						EmailAttachment_1, 
						EmailAttachment_2, 
						EmailAttachment_3
					FROM
					(
						SELECT 			 
							 ScheduledEmailId,
							 'EmailAttachment_' + cast(RANK() OVER (PARTITION BY ScheduledEmailId ORDER BY Id, ScheduledEmailId)  as varchar(20)) Id, 
							 FilePath
						FROM
							ScheduledEmailAttachment
					) d
					PIVOT
					(
						max(FilePath)
						for Id in (EmailAttachment_1, EmailAttachment_2, EmailAttachment_3)
					) p
				) As EmailAttachmentPivot
			ON SCE.Id = EmailAttachmentPivot.ScheduledEmailId

GO

DECLARE @ScriptName VARCHAR(100) = 'SP015_24.01_Create_vwScheduledEmails.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
