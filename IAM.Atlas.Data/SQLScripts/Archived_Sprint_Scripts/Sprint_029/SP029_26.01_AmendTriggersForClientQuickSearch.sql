/*
	SCRIPT: Add trigger on the Client and ClientOrganisation table: populate quick search table entries
	Author: Robert Newnham
	Created: 23/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_26.01_AmendTriggersForClientQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.[TRG_Client_ClientQuickSearchINSERTUPDATEDELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_Client_ClientQuickSearchINSERTUPDATEDELETE];
		END
	GO

	CREATE TRIGGER TRG_Client_ClientQuickSearchINSERTUPDATEDELETE ON Client FOR INSERT, UPDATE, DELETE
	AS
		DECLARE @ClientId int;
		DECLARE @InsertId int;
		DECLARE @DeleteId int;
	
		SELECT @InsertId = i.Id FROM inserted i;
		SELECT @DeleteId = d.Id FROM deleted d;
	
		SELECT @ClientId = COALESCE(@InsertId, @DeleteId);	

		EXEC dbo.uspRefreshClientQuickSearchData @ClientId;
		GO
		
	IF OBJECT_ID('dbo.[TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE];
		END
	GO

	CREATE TRIGGER TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE ON ClientOrganisation FOR INSERT, UPDATE, DELETE
	AS
		DECLARE @ClientId int;
		DECLARE @InsertId int;
		DECLARE @DeleteId int;
	
		SELECT @InsertId = i.Id FROM inserted i;
		SELECT @DeleteId = d.Id FROM deleted d;
	
		SELECT @ClientId = COALESCE(@InsertId, @DeleteId);	

		EXEC dbo.uspRefreshClientQuickSearchData @ClientId;
		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_26.01_AmendTriggersForClientQuickSearch.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO