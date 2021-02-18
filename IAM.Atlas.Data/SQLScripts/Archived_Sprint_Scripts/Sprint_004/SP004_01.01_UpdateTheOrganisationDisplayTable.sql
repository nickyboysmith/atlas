/*
	SCRIPT: Update Table OrganisationDisplay
	Author: Miles Stewart
	Created: 05/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_01.01_UpdateTheOrganisationDisplayTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add an image file path to the OrganisationDisplay Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table OrganisationDisplay
		*/
		ALTER TABLE dbo.OrganisationDisplay
		ADD ImageFilePath Varchar(4000);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
