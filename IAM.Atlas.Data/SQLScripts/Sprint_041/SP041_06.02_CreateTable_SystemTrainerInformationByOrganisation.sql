/*
	SCRIPT: Create SystemTrainerInformationByOrganisation Table
	Author: Nick Smith
	Created: 24/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_06.02_CreateTable_SystemTrainerInformationByOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemTrainerInformationByOrganisation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemTrainerInformationByOrganisation'
		
		/*
		 *	Create SystemTrainerInformationByOrganisation Table
		 */
		IF OBJECT_ID('dbo.SystemTrainerInformationByOrganisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemTrainerInformationByOrganisation;
		END

		CREATE TABLE SystemTrainerInformationByOrganisation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, AdminContactEmailAddress VARCHAR(320)
			, AdminContactPhoneNumber VARCHAR(40)
			, DisplayedMessage VARCHAR(100)
			, CONSTRAINT FK_SystemTrainerInformationByOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END