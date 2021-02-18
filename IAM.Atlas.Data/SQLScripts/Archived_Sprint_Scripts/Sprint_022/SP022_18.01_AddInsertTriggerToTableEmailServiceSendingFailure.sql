
/*
	SCRIPT: Add Insert trigger to the EmailServiceSendingFailure table
	Author: Robert Newnham
	Created: 30/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_18.01_AddInsertTriggerToTableEmailServiceSendingFailure.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert trigger to the EmailServiceSendingFailure table';

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
		SELECT @EmailId = CAST(
								SUBSTRING([FailureInfo]
										, CHARINDEX('Email Id: ', [FailureInfo]) + 10
										, (CHARINDEX(CHAR(13), [FailureInfo], CHARINDEX('Email Id: ', [FailureInfo]) + 10))
											- (CHARINDEX('Email Id: ', [FailureInfo]) + 10)
										) 
								AS INT)
		FROM inserted
		WHERE [FailureInfo] LIKE '%Email Id: %';
		
		UPDATE [dbo].[ScheduledEmail]
		SET [ScheduledEmailStateId] = 4
		, [DateScheduledEmailStateUpdated] = Getdate()
		WHERE [Id] = @EmailId AND [ScheduledEmailStateId] <> 4;

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP022_18.01_AddInsertTriggerToTableEmailServiceSendingFailure.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO