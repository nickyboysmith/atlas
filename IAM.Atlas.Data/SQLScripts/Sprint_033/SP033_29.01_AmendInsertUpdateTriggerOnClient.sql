/*
	SCRIPT: Amend Update trigger on Client
	Author: Robert Newnham
	Created: 17/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_29.01_AmendInsertUpdateTriggerOnClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update trigger on Client: Remove Insert';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Client_INSERTUPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Client_INSERTUPDATE;
	END
GO
IF OBJECT_ID('dbo.TRG_Client_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Client_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_Client_UPDATE] ON [dbo].[Client] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Client', 'TRG_Client_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @userId INT
					, @clientId INT;

			SELECT @userId = i.UserId
					, @clientId = i.Id 
			FROM inserted i;

			EXEC uspClientEnsureUppercaseStart @ClientId;

			EXEC dbo.[uspCheckUser] @userId = @UserId, @clientId = @ClientId;

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_29.01_AmendInsertUpdateTriggerOnClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO