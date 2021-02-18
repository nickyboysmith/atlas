/*
	SCRIPT: Amend Insert trigger to the AllTrainerDocument table
	Author: Robert Newnham
	Created: 25/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_20.05_AmendInsertTriggerToAllTrainerDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to the AllTrainerDocument table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT];
	END
GO
	CREATE TRIGGER TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT ON AllTrainerDocument AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
			INSERT INTO [dbo].[TrainerDocument]
				([OrganisationId]
			   , [TrainerId]
			   , [DocumentId])
			SELECT
				I.OrganisationId
			   , TOrg.TrainerId
			   , I.DocumentId 
			FROM INSERTED I
			INNER JOIN TrainerOrganisation TOrg		ON TOrg.OrganisationId = I.OrganisationId
			LEFT JOIN [dbo].[TrainerDocument] TD	ON TD.OrganisationId = I.OrganisationId
													AND TD.DocumentId = I.DocumentId
			WHERE TD.Id IS NULL -- Not Already There
		END --END PROCESS
	END

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_20.05_AmendInsertTriggerToAllTrainerDocument.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO