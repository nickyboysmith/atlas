/*
	SCRIPT: Amend DELETE trigger to the AllTrainerDocument table
	Author: Robert Newnham
	Created: 25/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_20.06_AmendDeleteTriggerToAllTrainerDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend DELETE trigger to the AllTrainerDocument table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE];
	END
GO
	CREATE TRIGGER TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE ON AllTrainerDocument AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
			DELETE TD 
			FROM DELETED D
			INNER JOIN TrainerDocument TD		ON TD.DocumentId = D.DocumentId
												AND TD.OrganisationId = D.OrganisationId;
		END --END PROCESS
	END

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_20.06_AmendDeleteTriggerToAllTrainerDocument.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO