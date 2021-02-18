/*
 * SCRIPT: Alter PeriodicalSPJob
 * Author: Dan Hough
 * Created: 01/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP043_02.01_AlterTablePeriodicalSPJob.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter PeriodicalSPJob';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.PeriodicalSPJob
		ADD RunOnlyOnDayNumber INT NULL
			, RunOnlyOnWeekends BIT NOT NULL DEFAULT 'False'
			, RunOnlyOnWeekdays BIT NOT NULL DEFAULT 'False'
			, RunOnOrAfterTime TIME NOT NULL DEFAULT '00:00:01'
			, RunOnOrBeforeTime TIME NOT NULL DEFAULT '23:59:59'
			, LastDateTimeStarted DATETIME NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
