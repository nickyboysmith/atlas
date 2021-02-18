/*
	SCRIPT: Amend Trigger To Client INSERT/Update/Delete Table
	Author: Robert Newnham
	Created: 28/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_07.02_AmendTriggerToClient_InsertUpdateDeleteTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Trigger To Client Table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.TRG_Client_ClientQuickSearchINSERTUPDATEDELETE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_Client_ClientQuickSearchINSERTUPDATEDELETE];
	END
GO

	CREATE TRIGGER TRG_Client_ClientQuickSearchINSERTUPDATEDELETE ON Client AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
		
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Client', 'TRG_Client_ClientQuickSearchINSERTUPDATEDELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			DECLARE @ClientId int;
			DECLARE @InsertId int;
			DECLARE @DeleteId int;
	
			SELECT @InsertId = i.Id FROM inserted i;
			SELECT @DeleteId = d.Id FROM deleted d;
	
			SELECT @ClientId = COALESCE(@InsertId, @DeleteId);	

			EXEC dbo.uspRefreshClientQuickSearchData @ClientId;
		END --END PROCESS
	END
	GO
	/***END OF SCRIPT***/
	
DECLARE @ScriptName VARCHAR(100) = 'SP031_07.02_AmendTriggerToClient_InsertUpdateDeleteTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO