/*
	SCRIPT: Amend trigger TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE
	Author: Robert Newnham
	Created: 12/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_28.03_AmendTriggersForClientQuickSearch_ClientOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.[TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE];
		END
	GO

	CREATE TRIGGER TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE ON ClientOrganisation FOR INSERT, UPDATE, DELETE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientOrganisation', 'TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @ClientId int;
			DECLARE @InsertId int;
			DECLARE @DeleteId int;
	
			SELECT @InsertId = i.ClientId FROM inserted i;
			SELECT @DeleteId = d.ClientId FROM deleted d;
	
			SELECT @ClientId = COALESCE(@InsertId, @DeleteId);	

			IF (@ClientId IS NOT NULL)
			BEGIN
				EXEC dbo.uspRefreshClientQuickSearchData @ClientId;
			END

		END --END PROCESS
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_28.03_AmendTriggersForClientQuickSearch_ClientOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO