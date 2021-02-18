/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration, Add new column AllowManualEditingOfClientDORSData
 * Author: Nick Smith
 * Created: 14/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_02.01_AmendTableOrganisationSystemConfigurationAddColumnAllowManualEditingOfClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSystemConfiguration, Add new column AllowManualEditingOfClientDORSData';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
			ADD AllowManualEditingOfClientDORSData  BIT NOT NULL DEFAULT 'False'
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
