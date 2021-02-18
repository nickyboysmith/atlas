/*
	SCRIPT: Create trigger TRG_SendSystemAdminsEmail_Insert
	Author: Robert Newnham
	Created: 21/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_02.03_CreateTriggerTRG_SendSystemAdminsEmail_Insert.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create trigger TRG_SendSystemAdminsEmail_Insert';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_SendSystemAdminsEmail_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_SendSystemAdminsEmail_Insert];
		END
	GO
	
	CREATE TRIGGER [dbo].[TRG_SendSystemAdminsEmail_Insert] ON [dbo].[SendSystemAdminsEmail] AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'SendSystemAdminsEmail', 'TRG_SendSystemAdminsEmail_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			DECLARE @requestedByUserId INT
				, @EmailSubject VARCHAR(100)
				, @EmailContent VARCHAR(4000)
				;
			SELECT @requestedByUserId=I.RequestedByUserId
				, @EmailSubject=I.SubjectText
				, @EmailContent=I.ContentText
			FROM INSERTED I;

			EXEC uspSendEmailContentToAllSystemAdmins @requestedByUserId, @EmailSubject, @EmailContent;
			
			UPDATE SSAE
			SET SSAE.EmailSent = 'True'
			, SSAE.DateTimeEmailSent = GETDATE()
			, SSAE.SentTo = 'System Administrators'
			FROM INSERTED I
			INNER JOIN SendSystemAdminsEmail SSAE ON SSAE.Id = I.Id;
			/**********************************************************************************************/


		END --END PROCESS
	END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP041_02.03_CreateTriggerTRG_SendSystemAdminsEmail_Insert.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO