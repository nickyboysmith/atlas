/*
	SCRIPT: Create AdministrationMenuItemOrganisation Table
	Author: Dan Hough
	Created: 15/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_09.01_Create_AdministrationMenuItemOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the AdministrationMenuItemOrganisation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'AdministrationMenuItemOrganisation'
		
		/*
		 *	Create AdministrationMenuItemOrganisation Table
		 */
		IF OBJECT_ID('dbo.AdministrationMenuItemOrganisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AdministrationMenuItemOrganisation;
		END

		CREATE TABLE AdministrationMenuItemOrganisation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, AdminMenuItemId int NOT NULL
			, CONSTRAINT FK_AdministrationMenuItemOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_AdministrationMenuItemOrganisation_AdministrationMenuItem FOREIGN KEY (AdminMenuItemId) REFERENCES AdministrationMenuItem(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;