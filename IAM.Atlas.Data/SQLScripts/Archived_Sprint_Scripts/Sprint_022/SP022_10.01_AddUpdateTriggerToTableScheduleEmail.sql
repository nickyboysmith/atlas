
/*
	SCRIPT: Add Update trigger to the ScheduleEmail table
	Author: Robert Newnham
	Created: 27/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_10.01_AddUpdateTriggerToTableScheduleEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Update trigger to the ScheduleEmail table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[TRG_ScheduledEmail_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ScheduledEmail_UPDATE];
		END
	GO

	CREATE TRIGGER TRG_ScheduledEmail_UPDATE ON ScheduledEmail FOR UPDATE
	AS

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

		/*Now Send message to Administrators*/
		DECLARE @OrgId int;
		DECLARE @ErrorMessage Varchar(100);
		DECLARE @ErrorMessageTitle Varchar(100);
		DECLARE @SupportUserId int;
		DECLARE @SupportUserEmail Varchar(320);
		DECLARE @atlasSystemUserId int;
		DECLARE @atlasSystemFromName VARCHAR(320);
		DECLARE @atlasSystemFromEmail VARCHAR(320);

		SELECT @atlasSystemUserId = [AtlasSystemUserId]
		, @atlasSystemFromName = [AtlasSystemFromName]
		, @atlasSystemFromEmail = [AtlasSystemFromEmail]
		FROM [dbo].[SystemControl]
		WHERE Id = 1;

		DECLARE errorCursor CURSOR FOR  
		SELECT OSE.[OrganisationId]
		, 'Multiple Send Email Attempts on Email Id: "' + CAST(TMR.Id AS VARCHAR) + '";'
			+ ' To: ' + SETO.[Email] + '; '
			+ ' For Organisation: ' + O.[Name] + ';' AS ErrorMessage
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
		
		OPEN errorCursor   
		FETCH NEXT FROM errorCursor INTO @OrgId, @ErrorMessage, @ErrorMessageTitle, @SupportUserId, @SupportUserEmail;

		WHILE @@FETCH_STATUS = 0   
		BEGIN
			/*
				@requestedByUserId int
				, @fromName varchar(400) = null
				, @fromEmailAddresses varchar(400)
				, @toEmailAddresses varchar(400)
				, @ccEmailAddresses varchar(400) = null
				, @bccEmailAddresses varchar(400) = null
				, @emailSubject varchar(320)
				, @emailContent varchar(4000)
				, @asapFlag bit = false
				, @sendAfterDateTime DateTime = null
				, @emailServiceId int = null
				, @organisationId int = null
			*/
			EXEC dbo.uspSendEmail @requestedByUserId = @atlasSystemUserId
								, @fromName = @atlasSystemFromName
								, @fromEmailAddresses = @atlasSystemFromEmail
								, @toEmailAddresses = @SupportUserEmail
								, @emailSubject = @ErrorMessageTitle
								, @emailContent = @ErrorMessage
								, @organisationId = @OrgId

			FETCH NEXT FROM errorCursor INTO @OrgId, @ErrorMessage, @ErrorMessageTitle, @SupportUserId, @SupportUserEmail;
		END   

		CLOSE errorCursor   
		DEALLOCATE errorCursor

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP022_10.01_AddUpdateTriggerToTableScheduleEmail.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO