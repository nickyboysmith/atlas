/*
	SCRIPT: Add LicencePhotoCardExpiryDate column to the TrainerLicence table
	Author: Miles Stewart
	Created: 02/10/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP009_07.01_ExtendTableTrainerLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add an extra column to the TrainerLicence Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/**
		 * Update Table TrainerLicence
		 */
		ALTER TABLE dbo.TrainerLicence	
		ADD LicencePhotoCardExpiryDate DateTime
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

