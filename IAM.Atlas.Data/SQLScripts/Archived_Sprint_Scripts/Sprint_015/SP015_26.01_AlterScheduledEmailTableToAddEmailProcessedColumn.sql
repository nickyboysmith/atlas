/*
	SCRIPT: Alter the ScheduledEmail Table to add a EmailProcessedEmailServiceId column
	Author: Miles Stewart
	Created: 09/02/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_26.01_AlterScheduledEmailTableToAddEmailProcessedColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter the ScheduledEmail Table to add a EmailProcessedEmailServiceId column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/**
		 * Add EmailProcessedEmailServiceId Column to the table
		 */
		ALTER TABLE dbo.ScheduledEmail
			ADD EmailProcessedEmailServiceId int,
			CONSTRAINT FK_ScheduledEmail_EmailService FOREIGN KEY (EmailProcessedEmailServiceId) REFERENCES [EmailService](Id);



		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;