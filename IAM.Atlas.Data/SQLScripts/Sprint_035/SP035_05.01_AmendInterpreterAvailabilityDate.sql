/*
	SCRIPT: Amend Table InterpreterAvailabilityDate, Alter Column from DateTime to Date
	Author: Robert Newnham
	Created: 17/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_05.01_AmendInterpreterAvailabilityDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table InterpreterAvailabilityDate, Alter Column from DateTime to Date';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.InterpreterAvailabilityDate 
		ALTER COLUMN [Date] DATE NOT NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END