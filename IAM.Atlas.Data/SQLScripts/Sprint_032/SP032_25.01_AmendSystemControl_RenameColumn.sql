/*
 * SCRIPT: Alter Table SystemControl, Rename Column
 * Author: Robert Newnham
 * Created: 29/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_25.01_AmendSystemControl_RenameColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Column on SystemControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		-- ClientDORSData
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'SystemInactivityIdle' 
						and Object_ID = Object_ID(N'SystemControl')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.SystemControl.SystemInactivityIdle', N'SystemInactivityWarning', 'COLUMN' 
		END
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
