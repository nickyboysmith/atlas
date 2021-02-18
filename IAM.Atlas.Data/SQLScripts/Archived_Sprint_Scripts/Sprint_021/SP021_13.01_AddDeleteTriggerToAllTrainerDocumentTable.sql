

/*
	SCRIPT: Add delete trigger to the AllTrainerDocument table
	Author: Nick Smith
	Created: 02/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_13.01_AddDeleteTriggerToAllTrainerDocumentTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add delete trigger to the AllTrainerDocument table. Delete from TrainerDocument for that Organisation and Document.';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE];
		END
GO
		CREATE TRIGGER TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE ON AllTrainerDocument FOR DELETE
AS
	
	DELETE td 
	FROM TrainerDocument td
    INNER JOIN Deleted d on d.OrganisationId = td.OrganisationId
		AND d.DocumentId = td.DocumentId

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_13.01_AddDeleteTriggerToAllTrainerDocumentTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

