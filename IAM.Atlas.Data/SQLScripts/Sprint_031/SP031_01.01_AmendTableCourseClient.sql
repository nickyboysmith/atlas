/*
 * SCRIPT: Change Defaults on Table CourseClient
 * Author: Robert Newnham
 * Created: 23/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP031_01.01_AmendTableCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Defaults on Table CourseClient';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.CourseClient
		SET EmailReminderSent = 'False'
		WHERE EmailReminderSent IS NULL;

		ALTER TABLE dbo.CourseClient
		ALTER COLUMN EmailReminderSent BIT NOT NULL;
		
		UPDATE dbo.CourseClient
		SET SMSReminderSent = 'False'
		WHERE SMSReminderSent IS NULL;

		ALTER TABLE dbo.CourseClient
		ALTER COLUMN SMSReminderSent BIT NOT NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;