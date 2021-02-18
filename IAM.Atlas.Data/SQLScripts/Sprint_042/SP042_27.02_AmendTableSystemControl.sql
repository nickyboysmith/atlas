/*
 * SCRIPT: Change New Column to Table SystemControl
 * Author: Robert Newnham
 * Created: 28/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP042_27.02_AmendTableSystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Defaults on Table SystemControl';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[SystemControl]
		ADD EnableProcessMonitor BIT NOT NULL DEFAULT 'False';
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;