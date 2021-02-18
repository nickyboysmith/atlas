/*
 * SCRIPT: Insert Missing Table Data EmailServiceEmailsSent 
 * Author: Robert Newnham
 * Created: 17/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP024_32.09_InsertMissingTableDataEmailServiceEmailsSent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Insert Missing Table Data EmailServiceEmailsSent';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/* Record Emails Sent Against a Service */
		INSERT INTO [dbo].[EmailServiceEmailsSent] (ScheduledEmailId, DateSent, EmailServiceId)
		SELECT SE.[Id] AS ScheduledEmailId
			, SE.[DateScheduledEmailStateUpdated] AS DateSent
			, SE.[EmailProcessedEmailServiceId] AS EmailServiceId
		FROM ScheduledEmail SE
		LEFT JOIN [dbo].[EmailServiceEmailsSent] ESES ON ESES.[ScheduledEmailId] = SE.[Id]
		WHERE SE.[ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
											FROM [dbo].[ScheduledEmailState] SES
											WHERE SES.[Name] = 'Sent')
		AND ESES.Id IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
