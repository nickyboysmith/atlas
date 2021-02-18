/*
 * SCRIPT: Alter Tables ArchivedSMS, ArchivedSMSNote, ArchivedSMSToList - Remove ForeignKey ScheduledSMSId
 * Author: Nick Smith
 * Created: 06/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP025_18.01_AlterTablesArchivedSMSArchivedSMSNoteArchivedSMSToListRemoveForeignKeyScheduledSMSId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove ForeignKey ScheduledSMSId from ArchivedSMS, ArchivedSMSNote, ArchivedSMSToList Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		--ArchivedSMS
		IF (OBJECT_ID('FK_ArchivedSMS_ScheduledSMS', 'F') IS NOT NULL)
		BEGIN
			ALTER TABLE ArchivedSMS DROP CONSTRAINT FK_ArchivedSMS_ScheduledSMS
		END

		--ArchivedSMSNote
		IF (OBJECT_ID('FK_ArchivedSMSNote_ScheduledSMS', 'F') IS NOT NULL)
		BEGIN
			ALTER TABLE ArchivedSMSNote DROP CONSTRAINT FK_ArchivedSMSNote_ScheduledSMS
		END

		--ArchivedSMSToList
		IF (OBJECT_ID('FK_ArchivedSMSToList_ScheduledSMS', 'F') IS NOT NULL)
		BEGIN
			ALTER TABLE ArchivedSMSToList DROP CONSTRAINT FK_ArchivedSMSToList_ScheduledSMS
		END

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

