/*
	SCRIPT: Create TaskCategoryForOrganisation Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.03_Create_TaskCategoryForOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskCategoryForOrganisation Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskCategoryForOrganisation'
		
		/*
		 *	Create TaskCategoryForOrganisation Table
		 */
		IF OBJECT_ID('dbo.TaskCategoryForOrganisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskCategoryForOrganisation;
		END

		CREATE TABLE TaskCategoryForOrganisation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TaskCategoryId INT NOT NULL
			, OrganisationId INT NOT NULL
			, CONSTRAINT FK_TaskCategoryForOrganisation_TaskCategory FOREIGN KEY (TaskCategoryId) REFERENCES TaskCategory(Id)
			, CONSTRAINT FK_TaskCategoryForOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, INDEX IX_TaskCategoryForOrganisationOrganisationId NONCLUSTERED (OrganisationId)
			, INDEX UX_TaskCategoryForOrganisationTaskCategoryId UNIQUE NONCLUSTERED (TaskCategoryId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;