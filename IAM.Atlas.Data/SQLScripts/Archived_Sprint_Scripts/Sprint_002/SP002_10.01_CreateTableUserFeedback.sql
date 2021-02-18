/*
	SCRIPT: Create User Feedback Tables
	Author: Paul Tuck
	Created: 11/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_10.01_CreateTableUserFeedback.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Used to record customer feedback';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'UserFeedback'

		/*
			Create Table UserPreviousId
		*/
		IF OBJECT_ID('dbo.UserFeedback', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserFeedback;
		END

		CREATE TABLE UserFeedback(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, CreationDate Datetime
			, IPAddress varchar(25)
			, CurrentUrl varchar(200)
			, PageIdentifier varchar(200)
			, UserAgent varchar(200)
			, OS varchar(100)
			, Title varchar(500) NOT NULL
			, Body varchar(1000) NOT NULL
			, ResponseRequired bit
			, Email varchar(200)
			, MessageSent bit
			, RepliedBy varchar(100)
			, RepliedDate Datetime
			, CONSTRAINT FK_UserId_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


