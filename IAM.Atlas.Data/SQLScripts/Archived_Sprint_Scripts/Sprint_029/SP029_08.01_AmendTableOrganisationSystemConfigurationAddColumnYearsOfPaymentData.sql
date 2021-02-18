/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration, Add new column YearsOfPaymentData
 * Author: Nick Smith
 * Created: 16/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_08.01_AmendTableOrganisationSystemConfigurationAddColumnYearsOfPaymentData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSystemConfiguration, Add new column YearsOfPaymentData';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
			ADD YearsOfPaymentData FLOAT NOT NULL DEFAULT 3
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
