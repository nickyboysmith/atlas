/*
 * SCRIPT: Create LastRunLog Table
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_08.01_CreateTableLastRunLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create LastRunLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LastRunLog'
		
		/*
		 *	Create LastRunLog Table
		 */
		IF OBJECT_ID('dbo.LastRunLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LastRunLog;
		END
		
		CREATE TABLE LastRunLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ItemName VARCHAR(100)
			, ItemDescription VARCHAR(400)
			, DateLastRun DATETIME DEFAULT GETDATE()
			, DateCreated DATETIME DEFAULT GETDATE()
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

