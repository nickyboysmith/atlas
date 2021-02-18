/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration
 * Author: Nick Smith
 * Created: 27/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_37.01_Amend_OrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add AllowSMSCourseRemindersToBeSent, AllowEmailCourseRemindersToBeSent, DaysBeforeSMSCourseReminder, DaysBeforeEmailCourseReminder Columns to OrganisationSelfConfiguration Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
			ADD AllowSMSCourseRemindersToBeSent BIT DEFAULT 0,
				AllowEmailCourseRemindersToBeSent BIT DEFAULT 0,
				DaysBeforeSMSCourseReminder INT,
				DaysBeforeEmailCourseReminder INT

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
