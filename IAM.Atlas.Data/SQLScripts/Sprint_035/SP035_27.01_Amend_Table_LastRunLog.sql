/*
 * SCRIPT: Amend Table LastRunLog, add columns LastRunError and DateLastRunError.
 * Author: Paul Tuck
 * Created: 31/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_27.01_Amend_Table_LastRunLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table LastRunLog, add columns LastRunError and DateLastRunError.';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		ALTER TABLE [dbo].LastRunLog
		ADD DateLastRunError DateTime NULL, 
			LastRunError VARCHAR(2000) NULL;

		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;