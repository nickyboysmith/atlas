
/*
	SCRIPT: Amend Insert trigger to the EmailServiceSendingFailure table
	Author: Robert Newnham
	Created: 08/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_04.01_AmendInsertTriggerToTableEmailServiceSendingFailure.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to the EmailServiceSendingFailure table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[TRG_EmailServiceSendingFailure_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_EmailServiceSendingFailure_INSERT];
		END
	GO

	CREATE TRIGGER TRG_EmailServiceSendingFailure_INSERT ON EmailServiceSendingFailure FOR INSERT
	AS	
		DECLARE @EmailId int;
		DECLARE @EmailServiceId int;
		DECLARE @InvalidEmail bit;
		DECLARE @NoCredits bit;
		SET @InvalidEmail = 'False';
		SET @NoCredits = 'False';
		SELECT @EmailId = CAST(
								SUBSTRING([FailureInfo]
										, CHARINDEX('Email Id: ', [FailureInfo]) + 10
										, (CHARINDEX(CHAR(13), [FailureInfo], CHARINDEX('Email Id: ', [FailureInfo]) + 10))
											- (CHARINDEX('Email Id: ', [FailureInfo]) + 10)
										) 
								AS INT)
			, @InvalidEmail = (CASE WHEN [FailureInfo] LIKE '%Invalid email address%' THEN 'True' ELSE 'False' END)
			, @NoCredits = (CASE WHEN [FailureInfo] LIKE '%Insufficient credits remaining%' THEN 'True' ELSE 'False' END)
			, @EmailServiceId = EmailServiceId
		FROM inserted
		WHERE [FailureInfo] LIKE '%Email Id: %';
		
		UPDATE [dbo].[ScheduledEmail]
		SET [ScheduledEmailStateId] = 4
		, [DateScheduledEmailStateUpdated] = Getdate()
		WHERE [Id] = @EmailId AND [ScheduledEmailStateId] <> 4;

		INSERT INTO EmailsBlockedOutgoing (Email)
		SELECT DISTINCT Email
		FROM [dbo].[ScheduledEmailTo] SETO
		WHERE SETO.[ScheduledEmailId] = @EmailId
		AND @InvalidEmail = 'True'
		AND Email NOT IN (SELECT Email FROM EmailsBlockedOutgoing WHERE OrganisationId IS NULL);

		UPDATE [dbo].[EmailService]
		SET [Disabled] = 'True'
		WHERE Id = @EmailServiceId AND @NoCredits = 'True';

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP023_04.01_AmendInsertTriggerToTableEmailServiceSendingFailure.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO