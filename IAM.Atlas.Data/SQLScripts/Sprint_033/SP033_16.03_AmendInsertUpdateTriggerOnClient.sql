/*
	SCRIPT: Amend Update trigger on Client
	Author: John Cocklin
	Created: 10/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_16.03_AmendInsertUpdateTriggerOnClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update trigger on Client: Remove Insert';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Client_INSERTUPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Client_INSERTUPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_Client_INSERTUPDATE] ON [dbo].[Client] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Client', 'TRG_Client_INSERTUPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @userId INT
					, @clientId INT
					, @firstName VARCHAR(320)
					, @surname VARCHAR(320)
					, @capitalisedFirstName VARCHAR(320)
					, @capitalisedSurname VARCHAR(320);

			SELECT @userId = i.UserId
					, @clientId = i.Id 
			FROM inserted i;

			SELECT @firstName = FirstName
					, @surname = Surname
					, @capitalisedFirstName = LEFT(UPPER(@firstName), 1) + RIGHT(@firstName, LEN(@firstName)-1)
					, @capitalisedSurname = LEFT(UPPER(@surname), 1) + RIGHT(@surname, LEN(@surname)-1)
			FROM dbo.Client
			WHERE Id = @clientId;

			--Updates Client if the cases don't match
			-- Latin1_General_CS_AS is case sensitive.
			IF(@firstName != @capitalisedFirstName COLLATE Latin1_General_CS_AS
				OR @surname != @capitalisedSurname COLLATE Latin1_General_CS_AS)
			BEGIN
				UPDATE dbo.Client
				SET FirstName = @capitalisedFirstName
					, Surname = @capitalisedSurname
				WHERE Id = @clientId;
			END

			EXEC dbo.[uspCheckUser] @userId = @UserId, @clientId = @ClientId;

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_16.03_AmendInsertUpdateTriggerOnClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO