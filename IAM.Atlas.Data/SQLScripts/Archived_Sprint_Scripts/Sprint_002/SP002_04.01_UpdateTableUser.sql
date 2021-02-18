


/*
	SCRIPT: Update Table User
	Author: Robert Newnham
	Created: 05/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_04.01_UpdateTableUser.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table User
		*/
		ALTER TABLE dbo.[User]
		ALTER COLUMN LoginId Varchar(100);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

