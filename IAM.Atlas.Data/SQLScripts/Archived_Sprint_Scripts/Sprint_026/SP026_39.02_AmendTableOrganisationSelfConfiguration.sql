/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration, Add new column ShowLicencePhotocardDetails, ensure data correct
 * Author: Robert Newnham
 * Created: 27/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_39.02_AmendTableOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSelfConfiguration, Add new column ShowLicencePhotocardDetails, ensure data correct';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.OrganisationSelfConfiguration
		SET ShowLicencePhotocardDetails = 'False'
		WHERE ShowLicencePhotocardDetails IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
