/*
	SCRIPT: Alter Send Attempts Column on ScheduledEmail Table from bit to int
	Author: Miles Stewart
	Created: 08/02/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_23.01_AlterSendAttemptsOnScheduledEmailTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Send Attempts Column on ScheduledEmail Table from bit to int';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/**
		 * Add send Atempts & default to 0
		 */
		ALTER TABLE dbo.ScheduledEmail
			ALTER COLUMN [SendAtempts] int;



		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;