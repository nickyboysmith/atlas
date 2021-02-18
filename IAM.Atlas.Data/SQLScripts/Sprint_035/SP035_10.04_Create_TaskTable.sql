/*
	SCRIPT: Create Task Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.04_Create_TaskTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Task Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'Task'
		
		/*
		 *	Create Task Table
		 */
		IF OBJECT_ID('dbo.Task', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Task;
		END

		CREATE TABLE Task(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TaskCategoryId INT NOT NULL
			, [Title] VARCHAR(100) NOT NULL
			, PriorityNumber INT
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CreatedByUserId INT NOT NULL
			, DeadlineDate DATETIME
			, TaskClosed BIT NOT NULL DEFAULT 'False'
			, ClosedByUserId INT
			, DateClosed DATETIME
			, CONSTRAINT FK_Task_TaskCategory FOREIGN KEY (TaskCategoryId) REFERENCES TaskCategory(Id)
			, CONSTRAINT FK_Task_User_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_Task_User_ClosedByUserId FOREIGN KEY (ClosedByUserId) REFERENCES [User](Id)
			, INDEX IX_TaskTaskCategoryId NONCLUSTERED (TaskCategoryId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;