/*
 * SCRIPT: Alter Table DORSScheme 
 * Author: John Cocklin
 * Created: 12/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_01.03_AmendDORSScheme.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to DORSScheme Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DORSScheme ADD
			MinTheoryTrainers INT NOT NULL CONSTRAINT DF_DORSScheme_MinTheoryTrainers DEFAULT 1,
			MinPracticalTrainers INT NOT NULL CONSTRAINT DF_DORSScheme_MinPracticalTrainers DEFAULT 0,
			MaxTheoryTrainers INT NOT NULL CONSTRAINT DF_DORSScheme_MaxTheoryTrainers DEFAULT 2,
			MaxPracticalTrainers  INT NOT NULL CONSTRAINT DF_DORSScheme_MaxPracticalTrainers DEFAULT 0,
			MaxPlaces INT NOT NULL CONSTRAINT DF_DORSScheme_MaxPlaces DEFAULT 2

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
