/*
	SCRIPT: Create TaskActionPriorityForOrganisation Table 
	Author: Paul Tuck
	Created: 22/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_15.01_Create_Table_TaskActionPriorityForOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskActionPriorityForOrganisation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskActionPriorityForOrganisation'
		
		/*
		 *	Create TaskActionPriorityForOrganisation Table
		 */
		IF OBJECT_ID('dbo.TaskActionPriorityForOrganisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskActionPriorityForOrganisation;
		END

		CREATE TABLE TaskActionPriorityForOrganisation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, TaskActionId INT NOT NULL
			, PriorityNumber INT Default 2 NOT NULL
			, AssignToOrganisation BIT Not Null Default 'False'
			, AssignToOrganisationAdminstrators BIT Not Null Default 'False'
			, AssignToOrganisationSupportGroup BIT Not Null Default 'False'
			, AssignToAtlasSystemAdministrators BIT Not Null Default 'False'
			, AssignToAtlasSystemSupportGroup BIT Not Null Default 'False'
			, CONSTRAINT FK_TaskActionPriorityForOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_TaskActionPriorityForOrganisation_TaskAction FOREIGN KEY (TaskActionId) REFERENCES TaskAction(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;