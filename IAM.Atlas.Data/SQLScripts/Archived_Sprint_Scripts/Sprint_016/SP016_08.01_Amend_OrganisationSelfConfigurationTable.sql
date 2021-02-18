/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration, Add ClientApplicationDescription and ClientWelcomeMessage columns.
 * Author: Paul Tuck
 * Created: 23/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP016_08.01_Amend_OrganisationSelfConfigurationTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSelfConfiguration, Add ClientApplicationDescription and ClientWelcomeMessage columns';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD
			ClientApplicationDescription  varchar(200) NULL 
			, ClientWelcomeMessage  varchar(200) NULL 
		
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

