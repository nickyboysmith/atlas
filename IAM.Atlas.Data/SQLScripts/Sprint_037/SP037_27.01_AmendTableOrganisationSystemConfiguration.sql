/*
 * SCRIPT: Add New Column to Table OrganisationSystemConfiguration
 * Author: Robert Newnham
 * Created: 15/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_27.01_AmendTableOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table OrganisationSystemConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
		ADD DefaultRegionId INT NULL
			, CONSTRAINT FK_OrganisationSystemConfiguration_Region FOREIGN KEY (DefaultRegionId) REFERENCES Region(Id)
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;