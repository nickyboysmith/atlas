/*
 * SCRIPT: Alter Table SystemControl 
 * Author: Dan Hough
 * Created: 18/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_18.01_Alter_SystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to SystemControl table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl
		ADD ArchiveEmailsAfterDaysDefault INT NOT NULL DEFAULT 30
		  , ArchiveSMSsAfterDaysDefault INT NOT NULL DEFAULT 30
		  , DeleteEmailsAfterDaysDefault INT NOT NULL DEFAULT 90
		  , DeleteSMSsAfterDaysDefault INT NOT NULL DEFAULT 90

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
