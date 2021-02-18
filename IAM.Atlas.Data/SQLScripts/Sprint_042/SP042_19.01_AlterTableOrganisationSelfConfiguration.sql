/*
 * SCRIPT: Alter OrganisationSelfConfiguration
 * Author: Dan Hough
 * Created: 25/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP042_19.01_AlterTableOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter OrganisationSelfConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD SMSDisplayName VARCHAR(11)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
