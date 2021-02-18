/*
	SCRIPT: Amend Update and Insert trigger on ClientOrganisation
	Author: John Cocklin
	Created: 10/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_16.04_CreateInsertTriggerOnClientOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert trigger on Client Organisation';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientOrganisation_INSERT', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientOrganisation_INSERT;
	END
GO
	CREATE TRIGGER [dbo].[TRG_ClientOrganisation_INSERT] ON [dbo].[ClientOrganisation] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'ClientOrganisation', 'TRG_ClientOrganisation_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @userId INT
					, @clientId INT
					, @firstName VARCHAR(320)
					, @surname VARCHAR(320)
					, @capitalisedFirstName VARCHAR(320)
					, @capitalisedSurname VARCHAR(320);

			SELECT @userId = c.UserId
					, @clientId = i.ClientId 
					, @firstName = c.FirstName
					, @surname = c.Surname
					, @capitalisedFirstName = LEFT(UPPER(c.FirstName), 1)+RIGHT(c.FirstName, LEN(c.FirstName)-1)
					, @capitalisedSurname = LEFT(UPPER(c.Surname), 1)+RIGHT(c.Surname, LEN(c.Surname)-1)
			FROM inserted i
			INNER JOIN Client c ON c.Id = i.ClientId;

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
DECLARE @ScriptName VARCHAR(100) = 'SP033_16.04_CreateInsertTriggerOnClientOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO