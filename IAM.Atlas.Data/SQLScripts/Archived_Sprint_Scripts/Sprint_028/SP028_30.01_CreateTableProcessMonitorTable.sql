/*
 * SCRIPT: Create ProcessMonitor Table
 * Author: Robert Newnham
 * Created: 03/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_30.01_CreateTableProcessMonitorTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ProcessMonitor Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ProcessMonitor'
		
		/*
		 *	Create ProcessMonitor Table
		 */
		IF OBJECT_ID('dbo.ProcessMonitor', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ProcessMonitor;
		END
		
		CREATE TABLE ProcessMonitor(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Date] DATETIME DEFAULT GETDATE()
			, [ProcessName] VARCHAR(200)
			, [Identifier] INT
			, [Comments] VARCHAR(1000)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

