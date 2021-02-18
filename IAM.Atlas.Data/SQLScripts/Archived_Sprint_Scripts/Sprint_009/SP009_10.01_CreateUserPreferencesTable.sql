/*
	SCRIPT: Create User Preferences Table
	Author: Miles Stewart
	Created: 07/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_10.01_CreateUserPreferencesTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the user preferences table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'UserPreferences'

		/*
			Create Table UserPreferences
		*/
		IF OBJECT_ID('dbo.UserPreferences', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserPreferences;
		END

		CREATE TABLE UserPreferences(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int
			, AlignPreference varchar(10)
			, CONSTRAINT FK_UserPreferences_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;