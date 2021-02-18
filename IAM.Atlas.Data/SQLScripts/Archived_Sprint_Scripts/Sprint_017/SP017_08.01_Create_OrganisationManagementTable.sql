/*
	SCRIPT: Create OrganisationManagement Table
	Author: Dan Hough
	Created: 11/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_08.01_Create_OrganisationManagementTable';
DECLARE @ScriptComments VARCHAR(800) = 'Create the OrganisationManagement Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationManagement'
		
		/*
		 *	Create OrganisationManagement Table
		 */
		IF OBJECT_ID('dbo.OrganisationManagement', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationManagement;
		END

		CREATE TABLE OrganisationManagement(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, ManagingOrganisationId int NOT NULL
			, CONSTRAINT FK_OrganisationManagement_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationManagement_Organisation1 FOREIGN KEY (ManagingOrganisationId) REFERENCES Organisation(Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;