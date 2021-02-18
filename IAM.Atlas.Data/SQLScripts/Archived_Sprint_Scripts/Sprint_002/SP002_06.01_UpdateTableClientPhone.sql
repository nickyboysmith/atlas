

/*
	SCRIPT: Update Table ClientPhone
	Author: Robert Newnham
	Created: 06/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_06.01_UpdateTableClientPhone.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table ClientPhone
		*/
		ALTER TABLE dbo.ClientPhone
		ADD PhoneNumber Varchar(40) NOT NULL;

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

