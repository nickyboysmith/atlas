/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration 
 * Author: John Cocklin
 * Created: 26/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_21.02_AmendOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to OrganisationSelfConfiguration Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration ADD
			ShowClientDisplayName BIT NOT NULL CONSTRAINT DF_OrganisationSelfConfiguration_ShowClientDisplayName DEFAULT 'True'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
