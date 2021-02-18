/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration, Add new column ShowNetcallFeatures
 * Author: Robert Newnham
 * Created: 30/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_01.01_AmendTableOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSystemConfiguration, Add new column ShowNetcallFeatures';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
			ADD ShowNetcallFeatures BIT DEFAULT 'False'
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
