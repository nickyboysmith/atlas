/*
	SCRIPT: Create TaskForUser Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.07_Create_TaskForUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskForUser Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskForUser'
		
		/*
		 *	Create TaskForUser Table
		 */
		IF OBJECT_ID('dbo.TaskForUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskForUser;
		END

		CREATE TABLE TaskForUser(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId INT NOT NULL
			, TaskId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, AssignedByUserId INT
			, CONSTRAINT FK_TaskForUser_User_UserId FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_TaskForUser_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, CONSTRAINT FK_TaskForUser_User_AssignedByUserId FOREIGN KEY (AssignedByUserId) REFERENCES [User](Id)
			, INDEX IX_TaskForUserUserId NONCLUSTERED (UserId)
			, INDEX IX_TaskForUserTaskId NONCLUSTERED (TaskId)
			, INDEX IX_TaskForUserAssignedByUserId NONCLUSTERED (AssignedByUserId)
			, INDEX UX_TaskForUserUserIdTaskId UNIQUE NONCLUSTERED (UserId, TaskId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;