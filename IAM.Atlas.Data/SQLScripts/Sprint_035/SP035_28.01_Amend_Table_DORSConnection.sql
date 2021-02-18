/*
 * SCRIPT: Amend Table DORSConnection, add column DateLastConnectionFailure.
 * Author: Paul Tuck
 * Created: 31/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_28.01_Amend_Table_DORSConnection.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table DORSConnection, add column DateLastConnectionFailure.';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		ALTER TABLE [dbo].DORSConnection
		ADD DateLastConnectionFailure DateTime NULL;

		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;