/*
	SCRIPT: Create Course Client Email Reminder Table
	Author: Nick Smith
	Created: 02/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_13.01_CreateTableCourseClientEmailReminder.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create table CourseClientEmailReminder';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'CourseClientEmailReminder'
			
		/*
			Drop tables in this order to avoid errors due to foreign key constraints
		*/
		IF OBJECT_ID('dbo.CourseClientEmailReminder', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClientEmailReminder;
		END

		/*
			Create Table CourseClientEmailReminder
		*/
		CREATE TABLE CourseClientEmailReminder(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, CourseId INT NOT NULL
			, DateSent Datetime NOT NULL
			, SentByUserId INT
			, ScheduledEmailId INT NOT NULL
			, CONSTRAINT FK_CourseClientEmailReminder_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseClientEmailReminder_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_CourseClientEmailReminder_User FOREIGN KEY (SentByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_CourseClientEmailReminder_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES [ScheduledEmail](Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


