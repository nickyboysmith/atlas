/*
	SCRIPT: Amend Update trigger on the LetterTemplateDocument table
	Author: Dan Hough
	Created: 15/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_13.01_AmendUpdateTriggerOnLetterTemplateDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update trigger on the LetterTemplateDocument table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_LetterTemplateDocument_Update]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_LetterTemplateDocument_Update;
		END
GO


CREATE TRIGGER [dbo].[TRG_LetterTemplateDocument_Update] ON [dbo].[LetterTemplateDocument] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'LetterTemplateDocument', 'TRG_LetterTemplateDocument_Update', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			INSERT INTO [dbo].[DocumentPrintQueue] (OrganisationId, DocumentId, QueueInfo, CreatedByUserId, DateCreated)
			SELECT 
				DO.[OrganisationId]			AS OrganisationId
				, I.DocumentId				AS DocumentId
				, (CASE WHEN C.Id IS NOT NULL
						THEN C.DisplayName
						ELSE '' END)		AS QueueInfo
				, I.RequestByUserId			AS CreatedByUserId
				, GETDATE()					AS DateCreated
			FROM INSERTED I
			INNER JOIN dbo.[Document] D					ON D.Id = I.DocumentId
			INNER JOIN dbo.[DocumentOwner] DO			ON DO.DocumentId = D.Id
			LEFT JOIN dbo.[Client] C					ON C.Id = I.IdKey
			LEFT JOIN dbo.[DocumentPrintQueue] DPQ		ON DPQ.OrganisationId = DO.[OrganisationId]
														AND DPQ.DocumentId = I.DocumentId
			WHERE I.RequestCompleted = 'True'
			AND I.DocumentId IS NOT NULL
			AND I.OnCreationSendDocumentToPrintQueue = 'True'
			;

		END --END PROCESS
	END
	

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_13.01_AmendUpdateTriggerOnLetterTemplateDocument.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO