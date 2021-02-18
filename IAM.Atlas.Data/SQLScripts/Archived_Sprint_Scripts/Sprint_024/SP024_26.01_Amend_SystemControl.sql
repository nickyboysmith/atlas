/*
 * SCRIPT: Alter Table SystemControl 
 * Author: Robert Newnham
 * Created: 11/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP024_26.01_Amend_SystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Email Processing Control Columns to SystemControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl
			ADD MaxNumberEmailsToProcessAtOnce INT
			, MaxNumberEmailsToProcessPerDay INT

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
