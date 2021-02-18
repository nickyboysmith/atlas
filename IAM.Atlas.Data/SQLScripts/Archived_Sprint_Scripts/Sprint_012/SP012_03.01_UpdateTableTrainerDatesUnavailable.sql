/*
	SCRIPT: Update Table TrainerDatesUnavailable
	Author: Paul Tuck
	Created: 09/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP012_03.01_UpdateTableTrainerDatesUnavailable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add a column to the TrainerDatesUnavailable Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Course
		*/
		ALTER TABLE dbo.TrainerDatesUnavailable
		ADD DateUpdated DATETIME NOT NULL DEFAULT (GETDATE());

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
