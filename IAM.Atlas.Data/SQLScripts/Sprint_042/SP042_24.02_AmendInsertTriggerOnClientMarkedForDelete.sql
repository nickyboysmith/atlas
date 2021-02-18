/*
	SCRIPT: Amend Insert trigger on ClientMarkedForDelete
	Author: Robert Newnham
	Created: 27/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_24.02_AmendInsertTriggerOnClientMarkedForDelete.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger on ClientMarkedForDelete';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 


	IF OBJECT_ID('dbo.TRG_ClientMarkedForDelete_UPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ClientMarkedForDelete_UPDATE;
		END
	GO

	CREATE TRIGGER TRG_ClientMarkedForDelete_UPDATE ON dbo.ClientMarkedForDelete AFTER UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientMarkedForDelete', 'TRG_ClientMarkedForDelete_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			--Keep Record of Deletion Marking in the Cancelled Table
			INSERT INTO  dbo.ClientMarkedForDeleteCancelled (
							ClientId
							, RequestedByUserId
							, DateRequested
							, DeleteAfterDate
							, Note
							, CancelledByUserId
							, DateDeleteCancelled
							)				
			SELECT		 
						I.ClientId
						, I.RequestedByUserId
						, I.DateRequested
						, I.DeleteAfterDate
						, I.Note
						, I.CancelledByUserId
						, DateDeleteCancelled = GETDATE()
			FROM INSERTED I
			INNER JOIN DELETED D	ON I.id = D.id 
			WHERE I.CancelledByUserId IS NOT NULL 
			AND D.CancelledByUserId IS NULL;

			/*Delete row from ClientMarkedForDelete*/
			DELETE CMFD
			FROM INSERTED I
			INNER JOIN DELETED D						ON I.id = D.id 
			INNER JOIN dbo.ClientMarkedForDelete CMFD	ON CMFD.Id = I.Id
			WHERE I.CancelledByUserId IS NOT NULL 
			AND D.CancelledByUserId IS NULL;

		END --END PROCESS
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP042_24.02_AmendInsertTriggerOnClientMarkedForDelete.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO