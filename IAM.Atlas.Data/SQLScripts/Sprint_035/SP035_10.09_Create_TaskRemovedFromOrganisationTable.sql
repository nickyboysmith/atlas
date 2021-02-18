/*
	SCRIPT: Create TaskRemovedFromOrganisation Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.09_Create_TaskRemovedFromOrganisationTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskRemovedFromOrganisation Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskRemovedFromOrganisation'
		
		/*
		 *	Create TaskRemovedFromOrganisation Table
		 */
		IF OBJECT_ID('dbo.TaskRemovedFromOrganisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskRemovedFromOrganisation;
		END

		CREATE TABLE TaskRemovedFromOrganisation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TaskId INT NOT NULL
			, OrganisationId INT NOT NULL
			, RemovedByUserId INT NOT NULL
			, DateRemoved DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_TaskRemovedFromOrganisation_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, CONSTRAINT FK_TaskRemovedFromOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_TaskRemovedFromOrganisation_User_RemovedByUserId FOREIGN KEY (RemovedByUserId) REFERENCES [User](Id)
			, INDEX IX_TaskRemovedFromOrganisationTaskId NONCLUSTERED (TaskId)
			, INDEX IX_TaskRemovedFromOrganisationOrganisationId NONCLUSTERED (OrganisationId)
			, INDEX IX_TaskRemovedFromOrganisationRemovedByUserId NONCLUSTERED (RemovedByUserId)
			, INDEX UX_TaskCompletedForUserTaskIdOrganisationId UNIQUE NONCLUSTERED (TaskId, OrganisationId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;