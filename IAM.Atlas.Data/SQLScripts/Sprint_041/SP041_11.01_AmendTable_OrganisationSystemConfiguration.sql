/*
 * SCRIPT: Add New Column to Table OrganisationSystemConfiguration
 * Author: Paul Tuck
 * Created: 27/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_11.01_AmendTable_OrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table OrganisationSystemConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
		ADD LoginEmailSendingEnabled BIT NULL
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;