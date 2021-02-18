

/*
	SCRIPT: Update Table PhoneType
	Author: Robert Newnham
	Created: 06/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_07.01_UpdateTablePhoneType.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table PhoneType
		*/
		ALTER TABLE dbo.PhoneType
		DROP CONSTRAINT CHK_PhoneType;

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

