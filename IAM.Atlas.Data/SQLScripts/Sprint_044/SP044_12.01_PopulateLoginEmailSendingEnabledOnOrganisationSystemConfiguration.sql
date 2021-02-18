/*
 * SCRIPT: Populate LoginEmailSendingEnabled on OrganisationSystemConfiguration
 * Author: Dan Hough
 * Created: 02/10/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_12.01_PopulateLoginEmailSendingEnabledOnOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Populate LoginEmailSendingEnabled on OrganisationSystemConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.OrganisationSystemConfiguration
		SET LoginEmailSendingEnabled = 'False'
		WHERE LoginEmailSendingEnabled IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;