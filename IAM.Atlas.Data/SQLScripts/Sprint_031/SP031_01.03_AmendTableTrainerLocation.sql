/*
 * SCRIPT: Change Defaults on Table TrainerLocation
 * Author: Robert Newnham
 * Created: 23/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP031_01.03_AmendTableTrainerLocation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Defaults on Table TrainerLocation';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.TrainerLocation
		SET MainLocation = 'False'
		WHERE MainLocation IS NULL;

		ALTER TABLE dbo.TrainerLocation
		ALTER COLUMN MainLocation BIT NOT NULL;

		ALTER TABLE dbo.TrainerLocation 
		ADD DEFAULT 'False' for MainLocation;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;