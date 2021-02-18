/*
 * SCRIPT: Alter PeriodicalSPJob
 * Author: Dan Hough
 * Created: 10/11/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP045_17.03_AlterTableArchivedEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter ArchivedEmail';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ArchivedEmail
		ADD [Subject] VARCHAR(320) NULL
			, DateScheduledEmailStateUpdated DATETIME;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
