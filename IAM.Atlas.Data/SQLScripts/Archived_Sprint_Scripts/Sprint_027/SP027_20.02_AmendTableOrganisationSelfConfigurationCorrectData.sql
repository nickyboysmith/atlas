/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration, Add new column ShowTrainerCosts, ensure data correct
 * Author: Robert Newnham
 * Created: 09/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_20.02_AmendTableOrganisationSelfConfigurationCorrectData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSelfConfiguration, Add new column ShowTrainerCosts, ensure data correct';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.OrganisationSelfConfiguration
		SET ShowTrainerCosts = 'False'
		WHERE ShowTrainerCosts IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
