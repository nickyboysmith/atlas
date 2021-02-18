/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration, Add new column ArchiveClientEmailsAfterDays
 * Author: Nick Smith
 * Created: 10/11/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP045_16.01_AmendTableOrganisationSystemConfigurationAddColumnArchiveClientEmailsAfterDays.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSystemConfiguration, Add new column ArchiveClientEmailsAfterDays';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
			ADD ArchiveClientEmailsAfterDays INT NOT NULL DEFAULT 200
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
