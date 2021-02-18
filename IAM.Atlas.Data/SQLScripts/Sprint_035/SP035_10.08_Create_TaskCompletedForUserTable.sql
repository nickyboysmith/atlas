/*
	SCRIPT: Create TaskCompletedForUser Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.08_Create_TaskCompletedForUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskCompletedForUser Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskCompletedForUser'
		
		/*
		 *	Create TaskCompletedForUser Table
		 */
		IF OBJECT_ID('dbo.TaskCompletedForUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskCompletedForUser;
		END

		CREATE TABLE TaskCompletedForUser(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId INT NOT NULL
			, TaskId INT NOT NULL
			, CompletedByUserId INT NOT NULL
			, DateCompleted DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_TaskCompletedForUser_User_UserId FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_TaskCompletedForUser_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, CONSTRAINT FK_TaskCompletedForUser_User_CompletedByUserId FOREIGN KEY (CompletedByUserId) REFERENCES [User](Id)
			, INDEX IX_TaskCompletedForUserUserId NONCLUSTERED (UserId)
			, INDEX IX_TaskCompletedForUserTaskId NONCLUSTERED (TaskId)
			, INDEX IX_TaskCompletedForUserCompletedByUserId NONCLUSTERED (CompletedByUserId)
			, INDEX UX_TaskCompletedForUserUserIdTaskId UNIQUE NONCLUSTERED (UserId, TaskId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;