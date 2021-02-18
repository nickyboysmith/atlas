/*
	SCRIPT:  Update User and System Control Tables
	Author:  Nick Smith
	Created: 10/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_02.01_UpdateUserAndSystemControlTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add a new columns to User and System Control Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update User Table
		*/
		ALTER TABLE dbo.[User] 
		ADD PasswordChangeRequired bit NOT NULL DEFAULT 0
		, PasswordLastChanged DateTime 
		, PasswordNeverExpires bit NOT NULL DEFAULT 0
		, SecretQuestion varchar(200) 
		, SecretAnswer varchar(200) 
		, LoginStateId bit NOT NULL DEFAULT 0
		
		/*
			Update System Control
		*/
		ALTER TABLE dbo.[SystemControl] 
		ADD SystemInactivityTimeout int NOT NULL DEFAULT 300
			
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;