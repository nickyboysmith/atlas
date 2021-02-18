/*
 * SCRIPT: Alter Table ScheduledSMS
 * Author: Dan Hough
 * Created: 29/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP022_14.01_Amend_ScheduledSMS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to ScheduledSMS table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		ALTER TABLE dbo.ScheduledSMS
			ADD DateExpires DATETIME NULL
		    , DateScheduledSMSStateUpdated DATETIME NULL
			, SendAttempts INT NULL
			, SMSProcessedSMSServiceId INT NULL
			, CONSTRAINT FK_ScheduledSMS_SMSService FOREIGN KEY (SMSProcessedSMSServiceId) REFERENCES SMSService(Id)

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;