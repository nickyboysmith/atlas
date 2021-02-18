

/*
	SCRIPT: Add trigger to the Client table: populate quick search table entries
	Author: Dan Murray
	Created: 02/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_09.01_AddTriggerToClientTableForClientQuickSearch.sql';
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

	EXEC dbo.usp_RefreshSingleClientQuickSearchData @ClientId;
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP011_09.01_AddTriggerToClientTableForClientQuickSearch.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO