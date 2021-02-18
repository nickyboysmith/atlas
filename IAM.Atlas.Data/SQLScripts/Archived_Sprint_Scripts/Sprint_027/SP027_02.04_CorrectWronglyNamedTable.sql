/*
 * SCRIPT: Correct wrongly named Table, from ScheduledSMSStatus to ScheduledSMSState
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_02.04_CorrectWronglyNamedTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Correct wrongly named Table, from ScheduledSMSStatus to ScheduledSMSState';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		--Correct Table ScheduledSMS
		IF (OBJECT_ID('FK_ScheduledSMS_ScheduledSMSState', 'F') IS NULL)
		BEGIN
			ALTER TABLE [dbo].[ScheduledSMS] 
			ADD CONSTRAINT [FK_ScheduledSMS_ScheduledSMSState] FOREIGN KEY (ScheduledSMSStateId) REFERENCES ScheduledSMSState(Id);
		END
		---------------------------------------------------------------------------------------------------------------------------------
		
		--Correct Table ArchivedSMS
		IF (OBJECT_ID('FK_ArchivedSMS_ScheduledSMSState', 'F') IS NULL)
		BEGIN
			ALTER TABLE [dbo].[ArchivedSMS] 
			ADD CONSTRAINT [FK_ArchivedSMS_ScheduledSMSState] FOREIGN KEY (ScheduledSMSStateId) REFERENCES ScheduledSMSState(Id);
		END
		---------------------------------------------------------------------------------------------------------------------------------
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

