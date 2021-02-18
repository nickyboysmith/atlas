/*
	SCRIPT: Amend Trigger To Client INSERT/Update Table
	Author: Robert Newnham
	Created: 28/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_07.01_AmendTriggerToClient_InsertUpdateTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Trigger To Client Table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.TRG_Client_INSERTUPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_Client_INSERTUPDATE];
	END
GO

	CREATE TRIGGER TRG_Client_INSERTUPDATE ON Client AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
		
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Client', 'TRG_Client_INSERTUPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @UserId INT;
			DECLARE @ClientId INT;

			SELECT @UserId = i.UserId FROM inserted i;
			SELECT @ClientId = i.Id FROM inserted i;
			
			EXEC dbo.[uspCheckUser] @userId = @UserId, @clientId = @ClientId;
		END --END PROCESS
	END
	GO
	/***END OF SCRIPT***/
	
DECLARE @ScriptName VARCHAR(100) = 'SP031_07.01_AmendTriggerToClient_InsertUpdateTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO