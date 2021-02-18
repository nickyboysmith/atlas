/*
	SCRIPT: Create TaskAction Table 
	Author: Paul Tuck
	Created: 22/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_14.01_Create_Table_TaskAction.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskAction Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskAction'
		
		/*
		 *	Create TaskAction Table
		 */
		IF OBJECT_ID('dbo.TaskAction', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskAction;
		END

		CREATE TABLE TaskAction(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name VARCHAR(400) NOT NULL UNIQUE
			, [Description] VARCHAR(400)
			, PriorityNumber INT NOT NULL DEFAULT 2
			, AssignToOrganisation BIT NOT NULL DEFAULT 'False'
			, AssignToOrganisationAdminstrators BIT NOT NULL DEFAULT 'False'
			, AssignToOrganisationSupportGroup BIT NOT NULL DEFAULT 'False'
			, AssignToAtlasSystemAdministrators BIT NOT NULL DEFAULT 'False'
			, AssignToAtlasSystemSupportGroup BIT NOT NULL DEFAULT 'False'
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;