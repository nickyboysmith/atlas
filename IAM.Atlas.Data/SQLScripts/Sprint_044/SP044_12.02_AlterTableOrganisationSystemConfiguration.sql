/*
 * SCRIPT: Alter OrganisationSelfConfiguration
 * Author: Dan Hough
 * Created: 21/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_12.02_AlterTableOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter OrganisationSelfConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
		ALTER COLUMN LoginEmailSendingEnabled BIT NOT NULL;

		ALTER TABLE [dbo].[OrganisationSystemConfiguration] 
		ADD  DEFAULT ('True') FOR [LoginEmailSendingEnabled];

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;