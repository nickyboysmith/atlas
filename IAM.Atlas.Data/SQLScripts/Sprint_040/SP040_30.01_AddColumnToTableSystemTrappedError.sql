/*
	SCRIPT: Amend Column To Table SystemTrappedError
	Author: Robert Newnham
	Created: 12/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_30.01_AddColumnToTableSystemTrappedError.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Column To Table SystemTrappedError';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemTrappedError 
		ALTER COLUMN [Message] VARCHAR(8000) NOT NULL
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END