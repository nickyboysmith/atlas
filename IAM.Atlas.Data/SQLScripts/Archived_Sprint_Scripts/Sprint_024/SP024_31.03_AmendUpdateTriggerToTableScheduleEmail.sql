
/*
	SCRIPT: Amend Update trigger to the ScheduleEmail table
	Author: Robert Newnham
	Created: 17/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_31.03_AmendUpdateTriggerToTableScheduleEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update trigger to the ScheduleEmail table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[TRG_ScheduledEmail_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ScheduledEmail_UPDATE];
		END
	GO

	CREATE TRIGGER TRG_ScheduledEmail_UPDATE ON ScheduledEmail FOR UPDATE
	AS
	
		/* If an email has failed to Send 3 or more times then mark the email as a Send Failed */
		SELECT i.Id, Sum([SendAtempts]) AS TotalAttempts
		INTO #TooManyRetrys
		FROM inserted i
		WHERE i.[ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
											FROM [dbo].[ScheduledEmailState] SES
											WHERE SES.[Name] = 'Failed - Retrying')
		GROUP BY i.Id
		HAVING Sum([SendAtempts]) >= 3; /*Get All Emails which ahve failed 3 or more times.*/

		/*Set the emails to Failed Status. Stopping them from sending any more*/
		UPDATE SE
		SET [ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
										FROM [dbo].[ScheduledEmailState] SES
										WHERE SES.[Name] = 'Failed')
		FROM ScheduledEmail SE
		INNER JOIN #TooManyRetrys SE2 ON SE2.Id = SE.Id;
		/***************************************************************************************/
		
		/* Ensure that the DateUpdated is correct */
		UPDATE SE
		SET DateUpdated = GetDate()
		FROM ScheduledEmail SE
		INNER JOIN inserted i ON i.Id = SE.Id;
		/***************************************************************************************/

		/*Now Send message to Administrators*/
		DECLARE @OrgId int;
		DECLARE @ErrorMessage Varchar(100);
		DECLARE @ErrorMessageTitle Varchar(100);
		DECLARE @SupportUserId int;
		DECLARE @SupportUserEmail Varchar(320);
		DECLARE @atlasSystemUserId INT = dbo.udfGetSystemUserId();
		DECLARE @atlasSystemFromName VARCHAR(320) = dbo.udfGetSystemEmailFromName();
		DECLARE @atlasSystemFromEmail VARCHAR(320) = dbo.udfGetSystemEmailAddress();
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10)
		DECLARE @Tab VARCHAR(1) = CHAR(9);
		DECLARE @sendEmail BIT = 'True';
		DECLARE @sendInternalMessage BIT = 'True';		
		DECLARE @MessageCategoryId INT = [dbo].[udfGetMessageCategoryId]('ERROR');
		
		DECLARE errorCursor CURSOR FOR  
		SELECT DISTINCT 
			OSE.[OrganisationId]
			, 'Multiple Send Attempts. EmailId: "' + CAST(TMR.Id AS VARCHAR) + '";'
				+ ' To: ' + SETO.[Email] + '; '
				+ ' Org: ' + O.[Name] + ';' AS ErrorMessage
			, '*Multiple Send Email Attempts on Email*' AS ErrorMessageTitle
			, SSU.[UserId] AS SupportUserId
			, U.[Email] AS SupportUserEmail
		FROM #TooManyRetrys TMR
		INNER JOIN [dbo].[OrganisationScheduledEmail] OSE ON OSE.[ScheduledEmailId] = TMR.Id
		INNER JOIN [dbo].[Organisation] O ON O.Id = OSE.[OrganisationId]
		INNER JOIN [dbo].[ScheduledEmailTo] SETO ON SETO.[ScheduledEmailId] = TMR.Id
		INNER JOIN [dbo].[SystemSupportUser] SSU ON SSU.[OrganisationId] = OSE.[OrganisationId]
		INNER JOIN [dbo].[User] U ON U.[Id] = SSU.[UserId]
		WHERE U.[Email] IS NOT NULL
		AND dbo.udfIsEmailAddressValid(U.[Email]) = 'True'; --Only Send to the Support User if a Valid Email Address
		
		OPEN errorCursor   
		FETCH NEXT FROM errorCursor INTO @OrgId, @ErrorMessage, @ErrorMessageTitle, @SupportUserId, @SupportUserEmail;

		WHILE @@FETCH_STATUS = 0   
		BEGIN
			
			SELECT	@sendEmail = SendMessagesViaEmail, 
					@sendInternalMessage = sendmessagesviainternalmessaging 
			FROM [OrganisationSystemTaskMessaging]
			INNER JOIN [SystemTask] st ON SystemTaskId = st.Id
			WHERE organisationId = @OrgId AND st.Name = 'EMAIL_MultipleEmailSendFailure';

			IF (@sendEmail = 'True')
			BEGIN
				EXEC dbo.uspSendEmail @requestedByUserId = @atlasSystemUserId
									, @fromName = @atlasSystemFromName
									, @fromEmailAddresses = @atlasSystemFromEmail
									, @toEmailAddresses = @SupportUserEmail
									, @emailSubject = @ErrorMessageTitle
									, @emailContent = @ErrorMessage
									, @organisationId = @OrgId
			END
			
			IF (@sendInternalMessage = 'True')
			BEGIN
				EXEC dbo.uspSendInternalMessage 
									@MessageCategoryId = @MessageCategoryId
									, @MessageTitle = @ErrorMessageTitle
									, @MessageContent = @ErrorMessage
									, @SendToUserId = @SupportUserId
									, @CreatedByUserId = @atlasSystemUserId
									;
			END

			FETCH NEXT FROM errorCursor INTO @OrgId, @ErrorMessage, @ErrorMessageTitle, @SupportUserId, @SupportUserEmail;
		END   

		CLOSE errorCursor   
		DEALLOCATE errorCursor

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP024_31.03_AmendUpdateTriggerToTableScheduleEmail.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO