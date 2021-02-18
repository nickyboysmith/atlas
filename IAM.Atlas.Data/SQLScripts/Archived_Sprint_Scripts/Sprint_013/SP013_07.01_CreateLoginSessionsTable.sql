/*
	SCRIPT: Create Table LoginSessions
	Author: Miles Stewart
	Created: 15/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_07.01_CreateLoginSessionsTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the login session table to manage token based auth.';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 * Drop Constraints if they Exist
		 */
		EXEC dbo.uspDropTableContraints 'LoginSession'
		
		/*
		 * Drop tables in this order to avoid errors due to foreign key constraints
		 */
		IF OBJECT_ID('dbo.LoginSession', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LoginSession;
		END

		/*
		 *	Create Table LoginSession
		 */
		CREATE TABLE LoginSession(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, AuthToken VARCHAR(250) NOT NULL
			, IssuedOn int NOT NULL
			, ExpiresOn int NOT NULL
			, CONSTRAINT FK_LoginSession_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
