/*
 * SCRIPT: Alter Table SystemControl
 * Author: Robert Newnham
 * Created: 29/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_24.01_AmendSystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to SystemControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl 
		ADD
			NonAtlasAreaInfo VARCHAR(1000) NULL
			, NonAtlasAreaLinkTitle VARCHAR(100) NULL
			, NonAtlasAreaLink VARCHAR(200) NULL
			, SystemInactivityIdle INT NULL

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
