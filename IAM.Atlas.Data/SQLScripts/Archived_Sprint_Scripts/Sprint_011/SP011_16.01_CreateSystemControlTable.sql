


/*
	SCRIPT: Create SystemControl
	Author: NickSmith
	Created: 14/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_16.01_CreateSystemControlTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'SystemControl'

		/*
			Create Table SystemControl
		*/
		IF OBJECT_ID('dbo.SystemControl', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemControl;
		END

		CREATE TABLE SystemControl(
		      Id int PRIMARY KEY NOT NULL
			, SystemAvailable bit NOT NULL
			, SystemStatus Varchar(200) 
			, SystemStatusColour Varchar(200)
			, SystemBlockedMessage Varchar(200)
			, MaxFailedLogins int NOT NULL
		);
		IF OBJECT_ID('dbo.SystemControl', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.SystemControl(Id, SystemAvailable, MaxFailedLogins)
			VALUES (1, 'True', 3)
		END
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

