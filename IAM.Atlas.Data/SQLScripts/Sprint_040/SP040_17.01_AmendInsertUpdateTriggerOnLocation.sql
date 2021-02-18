/*
	SCRIPT: Amend Insert Update trigger on Location
	Author: Dan Hough
	Created: 04/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_17.01_AmendInsertUpdateTriggerOnLocation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert Update Trigger on Location';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_Location_UpdateInsert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER TRG_Location_UpdateInsert;
	END

	GO

	CREATE TRIGGER TRG_Location_UpdateInsert ON dbo.[Location] AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Location', 'TRG_Location_UpdateInsert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			UPDATE L
			SET L.DateUpdated = GETDATE()
				, L.PostCode = UPPER(ISNULL(L.PostCode,''))
				, L.[Address] = REPLACE(L.[Address], CHAR(13) + CHAR(10), CHAR(10))
			FROM INSERTED I
			INNER JOIN [Location] L ON I.Id = L.Id;
		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_17.01_AmendInsertUpdateTriggerOnLocation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

