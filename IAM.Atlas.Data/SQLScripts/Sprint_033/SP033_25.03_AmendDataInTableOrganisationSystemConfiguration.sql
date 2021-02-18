/*
 * SCRIPT: Alter Data in Table OrganisationSystemConfiguration
 * Author: Robert Newnham
 * Created: 15/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP033_25.03_AmendDataInTableOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Data in Table OrganisationSystemConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		UPDATE OSC
		SET OSC.FromName = O.[Name]
		, OSC.FromEmail = SC.AtlasSystemFromEmail
		FROM [dbo].[OrganisationSystemConfiguration] OSC
		INNER JOIN [dbo].[Organisation] O ON O.Id = OSC.OrganisationId
		INNER JOIN [dbo].[SystemControl] SC ON SC.Id = 1
		WHERE OSC.FromEmail IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
