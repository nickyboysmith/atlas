/*
	SCRIPT: Create UserChangeLog Table
	Author: Robert Newnham
	Created: 09/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_21.01.CreateTableUserChangeLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create UserChangeLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'UserChangeLog'
		
		/*
		 *	Create UserChangeLog Table
		 */
		IF OBJECT_ID('dbo.UserChangeLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserChangeLog;
		END

		CREATE TABLE UserChangeLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId INT NOT NULL
			, ColumnName VARCHAR(100)
			, PreviousValue VARCHAR(400)
			, NewValue VARCHAR(400)
			, DateChanged DATETIME DEFAULT GETDATE()
			, ChangedByUserId INT
			, CONSTRAINT FK_UserChangeLog_User1 FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_UserChangeLog_User2 FOREIGN KEY (ChangedByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;