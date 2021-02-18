/*
 * SCRIPT: Change Defaults on Table TrainerEmail
 * Author: Robert Newnham
 * Created: 23/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP031_01.02_AmendTableTrainerEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Defaults on Table TrainerEmail';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.TrainerEmail
		SET MainEmail = 'False'
		WHERE MainEmail IS NULL;

		ALTER TABLE dbo.TrainerEmail
		ALTER COLUMN MainEmail BIT NOT NULL;

		ALTER TABLE dbo.TrainerEmail 
		ADD DEFAULT 'False' for MainEmail;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;