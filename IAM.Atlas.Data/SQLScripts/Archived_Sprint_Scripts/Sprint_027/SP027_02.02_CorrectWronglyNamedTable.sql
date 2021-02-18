/*
 * SCRIPT: Correct wrongly named Table, from ScheduledSMSStatus to ScheduledSMSState
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_02.02_CorrectWronglyNamedTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Correct wrongly named Table, from ScheduledSMSStatus to ScheduledSMSState';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		--Correct Table ScheduledSMS
		IF (OBJECT_ID('FK_ScheduledSMS_ScheduledSMSStatus', 'F') IS NOT NULL)
		BEGIN
			ALTER TABLE [dbo].[ScheduledSMS] 
			DROP CONSTRAINT [FK_ScheduledSMS_ScheduledSMSStatus];
		END
		IF EXISTS(SELECT *
				FROM sys.columns 
				WHERE Name      = N'ScheduledSMSStatusId'
				AND Object_ID = Object_ID(N'ScheduledSMS'))
		BEGIN
			-- Column Exists, Rename it
			EXEC sp_RENAME 'ScheduledSMS.ScheduledSMSStatusId' , 'ScheduledSMSStateId', 'COLUMN';
		END
		---------------------------------------------------------------------------------------------------------------------------------
		
		--Correct Table ArchivedSMS
		IF (OBJECT_ID('FK_ArchivedSMS_ScheduledSMSStatus', 'F') IS NOT NULL)
		BEGIN
			ALTER TABLE [dbo].[ArchivedSMS] 
			DROP CONSTRAINT [FK_ArchivedSMS_ScheduledSMSStatus];
		END
		IF EXISTS(SELECT *
				FROM sys.columns 
				WHERE Name      = N'ScheduledSMSStatusId'
				AND Object_ID = Object_ID(N'ArchivedSMS'))
		BEGIN
			-- Column Exists, Rename it
			EXEC sp_RENAME 'ArchivedSMS.ScheduledSMSStatusId' , 'ScheduledSMSStateId', 'COLUMN';
		END
		---------------------------------------------------------------------------------------------------------------------------------
		
		--Now Drop Table
		EXEC dbo.uspDropTableContraints 'ScheduledSMSStatus'
		/*
		 *	Create ScheduledSMSStatus Table
		 */
		IF OBJECT_ID('dbo.ScheduledSMSStatus', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ScheduledSMSStatus;
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

