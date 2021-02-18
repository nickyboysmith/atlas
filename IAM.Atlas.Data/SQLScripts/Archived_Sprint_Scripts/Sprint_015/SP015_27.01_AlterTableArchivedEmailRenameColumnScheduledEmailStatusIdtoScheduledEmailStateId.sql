/*
	SCRIPT: Alter Table ArchivedEmail, rename column ScheduledEmailStatusId to ScheduledEmailStateId
	Author: Nick Smith
	Created: 09/02/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_27.01_AlterTableArchivedEmailRenameColumnsAddDropConstraints.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table ArchivedEmail, rename column ScheduledEmailStatusId to ScheduledEmailStateId Add and Drop Constraints';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.ArchivedEmailTo
			DROP CONSTRAINT [FK_ArchivedEmailTo_ArchivedEmail]
			
		ALTER TABLE dbo.ArchivedEmailNote
			DROP CONSTRAINT [FK_ArchivedEmailNote_ArchivedEmail]
			
		ALTER TABLE dbo.ArchivedEmailAttachment
			DROP CONSTRAINT [FK_ArchivedEmailAttachment_ArchivedEmail]

		ALTER TABLE dbo.ArchivedEmail
			DROP CONSTRAINT [UNC_ArchivedEmail_ScheduledEmail]

		EXEC sp_RENAME 'ArchivedEmail.ScheduledEmailStatusId' , 'ScheduledEmailStateId', 'COLUMN'

		ALTER TABLE dbo.ArchivedEmail
			ADD CONSTRAINT FK_ArchivedEmail_ScheduledEmailState FOREIGN KEY (ScheduledEmailStateId) REFERENCES [ScheduledEmailState](Id)
			
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
