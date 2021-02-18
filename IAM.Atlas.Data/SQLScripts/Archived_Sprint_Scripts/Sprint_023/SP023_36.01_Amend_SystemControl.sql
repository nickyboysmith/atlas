/*
 * SCRIPT: Alter Table SystemControl 
 * Author: Nick Smith
 * Created: 27/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_36.01_Amend_SystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add DefaultDORSConnectionId Column to SystemControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl
			ADD DefaultDORSConnectionId INT

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
