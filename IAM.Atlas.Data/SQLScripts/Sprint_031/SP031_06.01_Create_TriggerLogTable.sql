/*
	SCRIPT:  Create TriggerLog Table 
	Author: Robert Newnham
	Created: 28/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_06.01_Create_TriggerLogTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TriggerLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TriggerLog'
		EXEC dbo.uspDropTableContraints 'LogTrigger'
		
		/*
		 *	Create TriggerLog Table
		 */
		IF OBJECT_ID('dbo.LogTrigger', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LogTrigger;
		END
		IF OBJECT_ID('dbo.TriggerLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TriggerLog;
		END

		CREATE TABLE TriggerLog(
				Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
				, DateTimeRun DATETIME NOT NULL DEFAULT GETDATE()
				, TableName VARCHAR(1000) NOT NULL
				, TriggerName VARCHAR(1000) NOT NULL
				, InsertedTableRows INT NULL
				, DeletedTableRows INT NULL
				);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;