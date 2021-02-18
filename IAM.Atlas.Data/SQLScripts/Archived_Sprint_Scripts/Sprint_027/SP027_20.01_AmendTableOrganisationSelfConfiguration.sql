/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration, Add new column ShowTrainerCosts
 * Author: Robert Newnham
 * Created: 09/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_20.01_AmendTableOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSelfConfiguration, Add new column ShowTrainerCosts';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
			ADD ShowTrainerCosts BIT DEFAULT 'False'
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
