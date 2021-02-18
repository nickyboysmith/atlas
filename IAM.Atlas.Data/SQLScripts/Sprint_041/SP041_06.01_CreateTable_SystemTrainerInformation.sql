/*
	SCRIPT: Create SystemTrainerInformation Table
	Author: Nick Smith
	Created: 24/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_06.01_CreateTable_SystemTrainerInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemTrainerInformation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemTrainerInformation'
		
		/*
		 *	Create SystemTrainerInformation Table
		 */
		IF OBJECT_ID('dbo.SystemTrainerInformation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemTrainerInformation;
		END

		CREATE TABLE SystemTrainerInformation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, AdminContactEmailAddress VARCHAR(320)
			, AdminContactPhoneNumber VARCHAR(40)
			, DisplayedMessage VARCHAR(100)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END