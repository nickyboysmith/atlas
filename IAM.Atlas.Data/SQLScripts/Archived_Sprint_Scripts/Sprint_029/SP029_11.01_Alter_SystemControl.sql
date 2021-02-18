/*
 * SCRIPT: Alter Table SystemControl 
 * Author: Dan Hough
 * Created: 17/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_11.01_Alter_SystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to SystemControl table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl
		ADD SystemName VARCHAR(100)
			, DatabaseVersionPart1 INT NOT NULL DEFAULT 1
			, DatabaseVersionPart2 INT NOT NULL DEFAULT DATEPART(YEAR, GETDATE())
			, DatabaseVersionPart3 INT NOT NULL DEFAULT 1
			, DatabaseVersionPart4 FLOAT NOT NULL DEFAULT 1
			, ApplicationVersionPart1 INT NOT NULL DEFAULT 1
			, ApplicationVersionPart2 INT NOT NULL DEFAULT DATEPART(YEAR, GETDATE())
			, ApplicationVersionPart3 INT NOT NULL DEFAULT 1
			, ApplicationVersionPart4 FLOAT NOT NULL DEFAULT 1
			, DateOfLastApplicationReleaseStarted DATETIME
			, DateOfLastDatabaseUpdate DATETIME
			, DateOfLastApplicationReleaseCompleted DATETIME;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
