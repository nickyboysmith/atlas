/*
	SCRIPT: Add update trigger to DocumentMarkedForDelete
	Author: Nick Smith
	Created: 15/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_21.01_AddUpdateTriggerToDocumentMarkedForDelete.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update trigger to DocumentMarkedForDelete';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_DocumentMarkedForDelete_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_DocumentMarkedForDelete_UPDATE];
		END
GO
		CREATE TRIGGER TRG_DocumentMarkedForDelete_UPDATE ON DocumentMarkedForDelete AFTER UPDATE
AS

BEGIN
		/*Insert a row in to DocumentMarkedForDeleteCancelled when CancelledByUserId is updated from empty to having a UserId*/

		IF UPDATE(CancelledByUserId)
		BEGIN
			
				INSERT INTO  dbo.DocumentMarkedForDeleteCancelled
									(DocumentId
								, RequestedByUserId
								, DateRequested
								, DeleteAfterDate
								, Note
								, CancelledByUserId
								, DateDeleteCancelled)
				
				SELECT		 i.DocumentId
							, i.RequestedByUserId
							, i.DateRequested
							, i.DeleteAfterDate
							, i.Note
							, i.CancelledByUserId
							, DateDeleteCancelled = GETDATE()
				FROM		Inserted i 
				INNER JOIN Deleted d
				ON i.id = d.id 
				WHERE (i.CancelledByUserId IS NOT NULL AND
					   d.CancelledByUserId IS NULL)
				
				/*Delete row from DocumentMarkedForDelete*/
				DELETE dmd
				FROM dbo.DocumentMarkedForDelete dmd
				INNER JOIN Inserted i on dmd.Id = i.DocumentMarkedForDeleteId
				INNER JOIN Deleted d ON i.id = d.id 
				WHERE (i.CancelledByUserId IS NOT NULL AND
					   d.CancelledByUserId IS NULL)
		END
END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP023_21.01_AddUpdateTriggerToDocumentMarkedForDelete.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO