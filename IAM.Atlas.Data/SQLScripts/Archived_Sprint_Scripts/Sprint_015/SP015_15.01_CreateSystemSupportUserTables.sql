/*
	SCRIPT: Create System Support User Tables
	Author: Nick Smith
	Created: 04/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_15.01_CreateSystemSupportUserTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the System Support User Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemSupportUser'
		
			/*
		 *	Create SystemSupportUser Table
		 */
		IF OBJECT_ID('dbo.SystemSupportUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemSupportUser;
		END

		CREATE TABLE SystemSupportUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, AddedByUserId int
			, DateAdded DATETIME DEFAULT GETDATE()
			, CONSTRAINT FK_SystemSupportUser_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;