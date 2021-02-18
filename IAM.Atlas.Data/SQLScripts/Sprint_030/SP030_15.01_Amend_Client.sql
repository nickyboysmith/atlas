/*
 * SCRIPT: Make multiple columns on Client not null
 * Author: Dan Hough
 * Created: 13/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_15.01_Amend_Client.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Make multiple columns on Client not null';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		--EmailCourseReminders
		UPDATE dbo.Client
		SET EmailCourseReminders = 'False'
		WHERE EmailCourseReminders IS NULL;

		ALTER TABLE dbo.Client
		ALTER COLUMN EmailCourseReminders BIT NOT NULL;

		--SMSCourseReminders
		UPDATE dbo.Client
		SET SMSCourseReminders = 'False'
		WHERE SMSCourseReminders IS NULL;

		ALTER TABLE dbo.Client
		ALTER COLUMN SMSCourseReminders BIT NOT NULL;

		--EmailedConfirmed
		UPDATE dbo.Client
		SET EmailedConfirmed = 'False'
		WHERE EmailedConfirmed IS NULL;

		ALTER TABLE dbo.Client
		ALTER COLUMN EmailedConfirmed BIT NOT NULL;

		--SMSConfirmed
		UPDATE dbo.Client
		SET SMSConfirmed = 'False'
		WHERE SMSConfirmed IS NULL;

		ALTER TABLE dbo.Client
		ALTER COLUMN SMSConfirmed BIT NOT NULL;

		--SelfRegistration
		UPDATE dbo.Client
		SET SelfRegistration = 'False'
		WHERE SelfRegistration IS NULL;

		ALTER TABLE dbo.Client
		ALTER COLUMN SelfRegistration BIT NOT NULL;

		--DateUpdated 
		UPDATE dbo.Client
		SET DateUpdated = GETDATE()
		WHERE DateUpdated IS NULL;

		ALTER TABLE dbo.Client
		ALTER COLUMN DateUpdated DATETIME NOT NULL;

		IF OBJECT_ID('DF_Client_DateUpdated', 'D') IS NULL
		BEGIN
			ALTER TABLE dbo.Client
			ADD CONSTRAINT DF_Client_DateUpdated DEFAULT GETDATE() FOR DateUpdated;
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
