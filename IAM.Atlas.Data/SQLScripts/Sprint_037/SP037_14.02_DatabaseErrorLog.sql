/*
 * SCRIPT: Create Table DatabaseErrorLog 
 * Author: Robert Newnham
 * Created: 05/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_14.02_DatabaseErrorLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DatabaseErrorLog';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DatabaseErrorLog'
		
		/*
		 *	Create DashboardMeterData_Client Table
		 */
		IF OBJECT_ID('dbo.DatabaseErrorLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DatabaseErrorLog;
		END
		
		CREATE TABLE DatabaseErrorLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateAndTimeRecorded DateTime NOT NULL DEFAULT GETDATE()
			, ProcedureName VARCHAR(200) NULL
			, ErrorNumber INT NULL
			, ErrorSeverity INT NULL
			, ErrorState INT NULL
			, ErrorProcedure VARCHAR(140)
			, ErrorLine INT 
			, ErrorMessage VARCHAR(4000)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;