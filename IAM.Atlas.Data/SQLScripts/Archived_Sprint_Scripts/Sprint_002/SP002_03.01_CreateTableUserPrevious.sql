


/*
	SCRIPT: Create UserPrevious Table
	Author: Robert Newnham
	Created: 05/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_03.01_CreateTableUserPrevious.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'UserPreviousId'

		/*
			Create Table UserPreviousId
		*/
		IF OBJECT_ID('dbo.UserPreviousId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserPreviousId;
		END

		CREATE TABLE UserPreviousId(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, PreviousUserId int NOT NULL
			, CONSTRAINT FK_UserPreviousId_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

