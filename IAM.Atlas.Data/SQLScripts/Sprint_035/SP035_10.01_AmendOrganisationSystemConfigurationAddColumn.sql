/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration, Add Column
 * Author: Robert Newnham
 * Created: 19/03/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP035_10.01_AmendOrganisationSystemConfigurationAddColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Column to OrganisationSystemConfiguration Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration 
		ADD AllowTaskCreation BIT NOT NULL DEFAULT 'False';

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
