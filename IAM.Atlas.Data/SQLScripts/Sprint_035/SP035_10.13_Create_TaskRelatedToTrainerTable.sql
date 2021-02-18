/*
	SCRIPT: Create TaskRelatedToTrainer Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.13_Create_TaskRelatedToTrainerTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskRelatedToTrainer Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskRelatedToTrainer'
		
		/*
		 *	Create TaskRelatedToTrainer Table
		 */
		IF OBJECT_ID('dbo.TaskRelatedToTrainer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskRelatedToTrainer;
		END

		CREATE TABLE TaskRelatedToTrainer(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TaskId INT NOT NULL
			, TrainerId INT NOT NULL
			, CONSTRAINT FK_TaskRelatedToTrainer_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, CONSTRAINT FK_TaskRelatedToTrainer_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, INDEX IX_TaskRelatedToTrainerTaskId NONCLUSTERED (TaskId)
			, INDEX IX_TaskRelatedToTrainerTrainerId NONCLUSTERED (TrainerId)
			, INDEX UX_TaskCompletedForUserTaskIdTrainerId UNIQUE NONCLUSTERED (TaskId, TrainerId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;