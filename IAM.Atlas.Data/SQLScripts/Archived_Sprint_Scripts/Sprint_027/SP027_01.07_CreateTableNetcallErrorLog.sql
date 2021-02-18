/*
 * SCRIPT: Create NetcallErrorLog Table
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_01.07_CreateTableNetcallErrorLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create NetcallErrorLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'NetcallErrorLog'
		
		/*
		 *	Create NetcallErrorLog Table
		 */
		IF OBJECT_ID('dbo.NetcallErrorLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.NetcallErrorLog;
		END
		
		CREATE TABLE NetcallErrorLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Request VARCHAR(4000)
			, ErrorMessage  VARCHAR(4000)
			, WarningMessageSentToSupport BIT DEFAULT 'False'
			, DateWarningMessageSent DATETIME
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

