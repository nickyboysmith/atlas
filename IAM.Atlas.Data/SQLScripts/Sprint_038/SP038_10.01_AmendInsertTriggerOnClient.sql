/*
	SCRIPT: Amend Insert trigger on Client
	Author: Robert Newnham
	Created: 25/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_10.01_AmendInsertTriggerOnClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger on Client';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Client_INSERT', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Client_INSERT;
	END
GO
	CREATE TRIGGER [dbo].[TRG_Client_INSERT] ON [dbo].[Client] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Client', 'TRG_Client_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			DECLARE @clientId INT;

			SELECT @clientId = I.Id
			FROM INSERTED I
			
			--Ensure Entry on ClientView Table
			UPDATE CV
			SET CV.DateTimeViewed = GETDATE()
			FROM INSERTED I
			INNER JOIN [dbo].[ClientView] CV ON CV.ClientId = I.Id
											AND CV.ViewedByUserId = I.CreatedByUserId
			;

			INSERT INTO [dbo].[ClientView] (ClientId, ViewedByUserId, DateTimeViewed)
			SELECT I.Id AS ClientId, I.CreatedByUserId AS ViewedByUserId, GETDATE() AS DateTimeViewed
			FROM INSERTED I
			LEFT JOIN [dbo].[ClientView] CV ON CV.ClientId = I.Id
											AND CV.ViewedByUserId = I.CreatedByUserId
			WHERE CV.Id IS NULL;
			--------------------------------------------------------------------------------------------------

			EXEC uspClientEnsureUppercaseStart @ClientId;
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP038_10.01_AmendInsertTriggerOnClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO