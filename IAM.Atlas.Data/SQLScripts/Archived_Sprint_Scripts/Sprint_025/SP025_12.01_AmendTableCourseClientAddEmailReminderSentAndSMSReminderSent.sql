/*
 * SCRIPT: Alter Table CourseClient add EmailReminderSent and SMSReminderSent Bit Fields 
 * Author: Nick Smith
 * Created: 02/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP025_12.01_AmendTableCourseClientAddEmailReminderSentAndSMSReminderSent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Bit Fields EmailReminderSent and SMSReminderSent to CourseClient Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.CourseClient
		ADD EmailReminderSent BIT DEFAULT 0
		, SMSReminderSent BIT DEFAULT 0
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

