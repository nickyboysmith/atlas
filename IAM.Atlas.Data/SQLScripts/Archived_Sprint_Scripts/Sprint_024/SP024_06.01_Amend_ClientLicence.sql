/*
 * SCRIPT: Alter Table ClientLicence
 * Author: Dan Murray
 * Created: 01/08/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP024_06.01_Amend_ClientLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column UKLicence to ClientLicence table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		ALTER TABLE dbo.ClientLicence
			ADD UKLicence BIT DEFAULT (1);
			
			 
		/*** END OF SCRIPT ***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;