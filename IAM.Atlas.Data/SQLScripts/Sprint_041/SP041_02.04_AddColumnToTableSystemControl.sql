/*
	SCRIPT: Add Column To Table SystemControl
	Author: Robert Newnham
	Created: 21/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_02.04_AddColumnToTableSystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table SystemControl';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl 
		ADD MonitorForDuplicateClients BIT NOT NULL DEFAULT 'False'
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END