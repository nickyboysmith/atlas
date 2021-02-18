/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration Add Columns ArchiveSMSAfterDays, DeleteSMSAfterDays"
 * Author: Nick Smith
 * Created: 06/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP025_17.01_AlterTableOrganisationSystemConfigurationAddArchiveSMSAfterDaysDeleteSMSAfterDays.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Integer Fields ArchiveSMSAfterDays and DeleteSMSAfterDays to OrganisationSystemConfiguration Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
		ADD ArchiveSMSAfterDays INT
		, DeleteSMSAfterDays INT
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

