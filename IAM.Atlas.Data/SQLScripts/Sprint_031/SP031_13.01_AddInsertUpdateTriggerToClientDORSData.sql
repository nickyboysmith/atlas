/*
	SCRIPT: Add Insert and Update Trigger To ClientDORSData
	Author: Robert Newnham
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_13.01_AddInsertUpdateTriggerToClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert and Update Trigger To ClientDORSData';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientDORSData_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientDORSData_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_ClientDORSData_InsertUpdate ON dbo.ClientDORSData AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientDORSData', 'TRG_ClientDORSData_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			UPDATE COBS
			SET COBS.DORSSchemeId = I.DORSSchemeId
			FROM INSERTED I
			INNER JOIN ClientOnlineBookingState COBS ON COBS.ClientId = I.ClientId
			WHERE I.DataValidatedAgainstDORS = 'True'
			AND COBS.DORSSchemeId IS NULL;

		END --END PROCESS
	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_13.01_AddInsertUpdateTriggerToClientDORSData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	