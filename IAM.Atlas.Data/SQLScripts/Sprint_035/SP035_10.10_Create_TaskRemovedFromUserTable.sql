/*
	SCRIPT: Create TaskRemovedFromUser Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.10_Create_TaskRemovedFromUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskRemovedFromUser Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskRemovedFromUser'
		
		/*
		 *	Create TaskRemovedFromUser Table
		 */
		IF OBJECT_ID('dbo.TaskRemovedFromUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskRemovedFromUser;
		END

		CREATE TABLE TaskRemovedFromUser(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TaskId INT NOT NULL
			, UserId INT NOT NULL
			, RemovedByUserId INT NOT NULL
			, DateRemoved DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_TaskRemovedFromUser_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, CONSTRAINT FK_TaskRemovedFromUser_User_UserId FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_TaskRemovedFromUser_User_RemovedByUserId FOREIGN KEY (RemovedByUserId) REFERENCES [User](Id)
			, INDEX IX_TaskRemovedFromUserTaskId NONCLUSTERED (TaskId)
			, INDEX IX_TaskRemovedFromUserUserId NONCLUSTERED (UserId)
			, INDEX IX_TaskRemovedFromUserRemovedByUserId NONCLUSTERED (RemovedByUserId)
			, INDEX UX_TaskCompletedForUserTaskIdUserId UNIQUE NONCLUSTERED (TaskId, UserId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;