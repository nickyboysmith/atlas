/*
	SCRIPT: Update Table UserLogins
	Author: Daniel Murray
	Created: 15/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_01.02_UpdateTableUserLogins.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table UserLogins
		*/
		ALTER TABLE dbo.[UserLogin]
		ALTER COLUMN LoginId Varchar(50);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
