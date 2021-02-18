/*
 * SCRIPT: Alter OrganisationSystemConfiguration
 * Author: Dan Hough
 * Created: 24/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP042_16.01_AlterTableOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter OrganisationSystemConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
		ADD SMSEnabled BIT NOT NULL DEFAULT 'False';

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
