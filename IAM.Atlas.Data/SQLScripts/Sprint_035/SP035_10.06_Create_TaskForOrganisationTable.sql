/*
	SCRIPT: Create TaskForOrganisation Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.06_Create_TaskForOrganisationTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskForOrganisation Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskForOrganisation'
		
		/*
		 *	Create TaskForOrganisation Table
		 */
		IF OBJECT_ID('dbo.TaskForOrganisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskForOrganisation;
		END

		CREATE TABLE TaskForOrganisation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, TaskId INT NOT NULL
			, CONSTRAINT FK_TaskForOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_TaskForOrganisation_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, INDEX IX_TaskForOrganisationOrganisationId NONCLUSTERED (OrganisationId)
			, INDEX IX_TaskForOrganisationTaskId NONCLUSTERED (TaskId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;