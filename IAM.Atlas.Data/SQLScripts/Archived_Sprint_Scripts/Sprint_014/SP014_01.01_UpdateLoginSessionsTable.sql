/*
	SCRIPT:  Update Login Sessions Table
	Author:  Miles Stewart
	Created: 31/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_01.01_UpdateLoginSessionsTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update the login sessions table change IssuedOn & ExpiredOn to DATETIME';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update DataView Table
		*/
		ALTER TABLE dbo.[LoginSessions] 
			ALTER COLUMN IssuedOn DATETIME null;
		
		ALTER TABLE dbo.[LoginSessions] 
			ALTER COLUMN ExpiresOn DATETIME null;
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;