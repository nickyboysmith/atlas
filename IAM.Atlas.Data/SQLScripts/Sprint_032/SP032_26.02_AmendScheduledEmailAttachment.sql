/*
 * SCRIPT: Alter Table ScheduledEmailAttachment
 * Author: Robert Newnham
 * Created: 29/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_26.02_AmendScheduledEmailAttachment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to ScheduledEmailAttachment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.ScheduledEmailAttachment 
		ADD
			DocumentId INT NULL
			, CONSTRAINT FK_ScheduledEmailAttachment_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
