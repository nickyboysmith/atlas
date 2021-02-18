/*
	SCRIPT: Create Course Client SMS Reminder Table
	Author: Nick Smith
	Created: 02/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_14.01_CreateTableCourseClientSMSReminder.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create table CourseClientSMSReminder';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'CourseClientSMSReminder'
			
		/*
			Drop tables in this order to avoid errors due to foreign key constraints
		*/
		IF OBJECT_ID('dbo.CourseClientSMSReminder', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClientSMSReminder;
		END

		/*
			Create Table CourseClientSMSReminder
		*/
		CREATE TABLE CourseClientSMSReminder(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, CourseId INT NOT NULL
			, DateSent Datetime NOT NULL
			, SentByUserId INT
			, ScheduledSMSId INT NOT NULL
			, CONSTRAINT FK_CourseClientSMSReminder_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_CourseClientSMSReminder_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseClientSMSReminder_User FOREIGN KEY (SentByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_CourseClientSMSReminder_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES [ScheduledSMS](Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


