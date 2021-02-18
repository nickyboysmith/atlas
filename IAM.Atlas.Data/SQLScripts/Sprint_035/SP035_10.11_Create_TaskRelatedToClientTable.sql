/*
	SCRIPT: Create TaskRelatedToClient Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.11_Create_TaskRelatedToClientTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskRelatedToClient Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskRelatedToClient'
		
		/*
		 *	Create TaskRelatedToClient Table
		 */
		IF OBJECT_ID('dbo.TaskRelatedToClient', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskRelatedToClient;
		END

		CREATE TABLE TaskRelatedToClient(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TaskId INT NOT NULL
			, ClientId INT NOT NULL
			, CONSTRAINT FK_TaskRelatedToClient_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, CONSTRAINT FK_TaskRelatedToClient_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, INDEX IX_TaskRelatedToClientTaskId NONCLUSTERED (TaskId)
			, INDEX IX_TaskRelatedToClientClientId NONCLUSTERED (ClientId)
			, INDEX UX_TaskCompletedForUserTaskIdClientId UNIQUE NONCLUSTERED (TaskId, ClientId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;