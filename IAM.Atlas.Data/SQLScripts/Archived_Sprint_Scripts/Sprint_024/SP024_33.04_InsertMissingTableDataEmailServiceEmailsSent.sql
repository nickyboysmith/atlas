/*
 * SCRIPT: Insert Missing Table Data EmailServiceEmailsSent ... Re-run
 * Author: Robert Newnham
 * Created: 17/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP024_33.04_InsertMissingTableDataEmailServiceEmailsSent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Insert Missing Table Data EmailServiceEmailsSent ... Re-run';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		DELETE [dbo].[EmailServiceEmailsSent];

		/* Record Emails Sent Against a Service */
		INSERT INTO [dbo].[EmailServiceEmailsSent] (ScheduledEmailId, DateSent, EmailServiceId, OrganisationId)
		SELECT SE.[Id] AS ScheduledEmailId
			, SE.[DateScheduledEmailStateUpdated] AS DateSent
			, SE.[EmailProcessedEmailServiceId] AS EmailServiceId
			, OSE.[OrganisationId] AS OrganisationId
		FROM ScheduledEmail SE
		LEFT JOIN [dbo].[OrganisationScheduledEmail] OSE ON OSE.[ScheduledEmailId] = SE.[Id]
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
