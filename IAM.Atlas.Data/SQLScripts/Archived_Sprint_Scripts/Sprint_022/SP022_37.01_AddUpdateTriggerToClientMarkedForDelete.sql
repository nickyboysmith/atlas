/*
	SCRIPT: Add update trigger to ClientMarkedForDelete
	Author: Dan Hough
	Created: 05/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_37.01_AddUpdateTriggerToClientMarkedForDelete.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update trigger to ClientMarkedForDelete';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ClientMarkedForDelete_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ClientMarkedForDelete_UPDATE];
		END
GO
		CREATE TRIGGER TRG_ClientMarkedForDelete_UPDATE ON ClientMarkedForDelete AFTER UPDATE
AS

BEGIN
		/*Insert a row in to ClientMarkedForDeleteCancelled when CancelledByUserId is updated from empty to having a UserId*/
		IF EXISTS (SELECT id FROM inserted)
			BEGIN
				/*update*/
				IF EXISTS (SELECT * FROM Deleted)
				BEGIN
					INSERT INTO  dbo.ClientMarkedForDeleteCancelled
									 (ClientId
									, RequestedByUserId
									, DateRequested
									, DeleteAfterDate
									, Note
									, CancelledByUserId
									, DateDeleteCancelled)
				
					SELECT		 i.ClientId
							   , i.RequestedByUserId
							   , i.DateRequested
							   , i.DeleteAfterDate
							   , i.Note
							   , i.CancelledByUserId
							   , DateDeleteCancelled = GETDATE()
					FROM		Inserted i 
					INNER JOIN Deleted d
					ON i.id = d.id AND (i.CancelledByUserId IS NOT NULL AND
											d.CancelledByUserId IS NULL)
				END
			END

		/*Delete row from ClientMarkedForDelete*/

		DELETE FROM dbo.ClientMarkedForDelete
		WHERE ClientMarkedForDelete.Id = (Select id from inserted)

END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP022_37.01_AddUpdateTriggerToClientMarkedForDelete.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO