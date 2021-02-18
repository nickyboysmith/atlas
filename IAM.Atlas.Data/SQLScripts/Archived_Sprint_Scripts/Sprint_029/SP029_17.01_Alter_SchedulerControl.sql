/*
 * SCRIPT: Alter Table SchedulerControl 
 * Author: Dan Hough
 * Created: 18/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_17.01_Alter_SchedulerControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to SchedulerControl table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SchedulerControl
		ADD EmailArchiveDisabled BIT NOT NULL DEFAULT 'True'
		  , SMSArchiveDisabled BIT NOT NULL DEFAULT 'True'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
