/*
	SCRIPT: Create OnlineBookingLog Table
	Author: Dan Hough
	Created: 20/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_15.01_Create_OnlineBookingLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OnlineBookingLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OnlineBookingLog'
		
		/*
		 *	Create OnlineBookingLog Table
		 */
		IF OBJECT_ID('dbo.OnlineBookingLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OnlineBookingLog;
		END

		CREATE TABLE OnlineBookingLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, LicenceNumber VARCHAR(40)
			, DateTimeEntered DATETIME NOT NULL DEFAULT GETDATE()
			, Browser VARCHAR(200)
			, OperatingSystem VARCHAR(200)
			, IPAddress VARCHAR(40)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;