/*
	SCRIPT: Create TransactionLog Table
	Author: Paul Tuck
	Created: 17/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_41.01_CreateTable_TransactionLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TransactionLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TransactionLog'
		
		/*
		 *	Create TransactionLog Table
		 */
		IF OBJECT_ID('dbo.TransactionLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TransactionLog;
		END

		CREATE TABLE TransactionLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Field1 VARCHAR(8000) NULL
			, Field2 VARCHAR(8000) NULL
			, Field3 VARCHAR(8000) NULL
			, Field4 VARCHAR(8000) NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, DateModified DATETIME NULL
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END