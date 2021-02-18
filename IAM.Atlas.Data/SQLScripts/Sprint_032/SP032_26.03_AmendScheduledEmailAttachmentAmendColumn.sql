/*
 * SCRIPT: Alter Table ScheduledEmailAttachment
 * Author: Robert Newnham
 * Created: 29/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_26.03_AmendScheduledEmailAttachmentAmendColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend a Column on ScheduledEmailAttachment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ScheduledEmailAttachment 
		ALTER COLUMN FilePath VARCHAR(400);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
