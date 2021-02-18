/*
	SCRIPT: Change Email Data Structure - Alter tables EmailService and ScheduledEmail Create Table EmailServiceSendingFailure
	Author: Miles Stewart
	Created: 29/01/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_14.01_ChangeEmailDataStructure.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Email Data Structure - Alter tables EmailService and ScheduledEmail Create Table EmailServiceSendingFailure';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/**
		 * Add Exclusive to Email service
		 * Default to False
		 */
		ALTER TABLE dbo.EmailService
			ADD [Exclusive] bit DEFAULT 0;

		/**
		 * Add send Atempts & default to 0
		 */
		ALTER TABLE dbo.ScheduledEmail
			ADD [SendAtempts] int DEFAULT 0;

		/**
		 * Drop constraints if they exist
		 */
		 EXEC dbo.uspDropTableContraints 'EmailServiceSendingFailure'
				
		/*
		 *	Create EmailServiceSendingFailure Table
		 */
		IF OBJECT_ID('dbo.EmailServiceSendingFailure', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.EmailServiceSendingFailure;
		END

		CREATE TABLE EmailServiceSendingFailure(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, EmailServiceId int
			, DateFailed DATETIME DEFAULT GETDATE()
			, FailureInfo varchar(400)
			, CONSTRAINT FK_EmailServiceSendingFailure_EmailService FOREIGN KEY (EmailServiceId) REFERENCES [EmailService](Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;