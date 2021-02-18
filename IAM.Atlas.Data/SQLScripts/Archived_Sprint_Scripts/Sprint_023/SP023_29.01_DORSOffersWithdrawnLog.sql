/*
 * SCRIPT: Create Table DORSOffersWithdrawnLog
 * Author: Nick Smith
 * Created: 23/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_29.01_DORSOffersWithdrawnLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DORSOffersWithdrawnLog';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSOffersWithdrawnLog'
		
		/*
		 *	Create DORSOffersWithdrawnLog Table
		 */
		IF OBJECT_ID('dbo.DORSOffersWithdrawnLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSOffersWithdrawnLog;
		END

		CREATE TABLE DORSOffersWithdrawnLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSConnectionId INT
			, DateCreated DATETIME
			, DORSAttendanceRef INT
			, LicenceNumber VARCHAR(40)
			, DORSSchemeId INT
			, OldAttendanceStatusId INT
			, AdministrationNotified BIT DEFAULT 0
			, CONSTRAINT FK_DORSOffersWithdrawnLog_DORSConnection FOREIGN KEY (DORSConnectionId) REFERENCES [DORSConnection](Id)

		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;