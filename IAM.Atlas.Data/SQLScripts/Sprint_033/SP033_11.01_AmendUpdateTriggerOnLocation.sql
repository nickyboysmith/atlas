/*
	SCRIPT: Amend Update and Insert trigger on table Location
	Author: Robert Newnham
	Created: 08/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_11.01_AmendUpdateTriggerOnLocation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update and Insert trigger on table Location';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Location_UpdateInsert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Location_UpdateInsert;
	END
GO
	CREATE TRIGGER TRG_Location_UpdateInsert ON dbo.Location AFTER UPDATE, INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Location', 'TRG_Location_Update', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------

			UPDATE L
				SET L.DateUpdated = GETDATE()
				, L.PostCode = UPPER(ISNULL(L.PostCode,''))
			FROM INSERTED I
			INNER JOIN [Location] L ON I.Id = L.Id;
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_11.01_AmendUpdateTriggerOnLocation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO