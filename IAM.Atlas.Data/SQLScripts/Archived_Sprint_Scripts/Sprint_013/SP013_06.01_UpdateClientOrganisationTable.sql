/*
	SCRIPT:  Alter ClientOrganisation Table
	Author:  Nick Smith
	Created: 14/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_06.01_UpdateClientOrganisationTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add a new column to ClientOrganisation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update User Table
		*/
		ALTER TABLE dbo.[ClientOrganisation] 
		ADD DateAdded DateTime NOT NULL DEFAULT GetDate();
		
			
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;