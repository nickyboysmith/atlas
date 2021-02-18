/*
	SCRIPT: Amend Insert trigger on ClientOrganisation
	Author: Robert Newnham
	Created: 17/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_29.03_AmendInsertTriggerOnClientOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger on Client Organisation';

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
					, @clientId INT;

			SELECT @userId = C.UserId
					, @clientId = i.Id 
			FROM inserted i
			INNER JOIN Client C ON C.Id = i.ClientId;

			EXEC uspClientEnsureUppercaseStart @ClientId;
			
			EXEC dbo.[uspCheckUser] @userId = @UserId, @clientId = @ClientId;

		END --END PROCESS

	END


	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_29.03_AmendInsertTriggerOnClientOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO