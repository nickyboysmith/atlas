/*
	SCRIPT: Alter Table EmailServiceEmailCount Table, add column EmailServiceId to table
	Author: Nick Smith
	Created: 04/02/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_17.01_AlterEmailServiceEmailsSentTableAddColumnEmailServiceId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table EmailServiceEmailsSent Table, add column EmailServiceId to table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.EmailServiceEmailsSent
			ADD EmailServiceId int
			, CONSTRAINT FK_EmailServiceEmailsSent_EmailService FOREIGN KEY (EmailServiceId) REFERENCES [EmailService](Id)
			
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
