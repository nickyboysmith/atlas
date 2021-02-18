/*
	SCRIPT: Remove Client Log Tables
	Author: Robert Newnham
	Created: 17/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_31.01_RemoveClientLogTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove Client Log Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ClientLog'
			EXEC dbo.uspDropTableContraints 'ClientLogType'

		/*
			Create Table ClientLog
		*/
		IF OBJECT_ID('dbo.ClientLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientLog;
		END
		
		/*
			Create Table ClientLogType
		*/
		IF OBJECT_ID('dbo.ClientLogType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientLogType;
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

