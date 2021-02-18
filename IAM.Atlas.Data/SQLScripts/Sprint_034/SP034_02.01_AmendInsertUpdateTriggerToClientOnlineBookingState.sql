/*
	SCRIPT: Amend Insert and Update Trigger To ClientOnlineBookingState
	Author: Robert Newnham
	Created: 23/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_02.01_AmendInsertUpdateTriggerToClientOnlineBookingState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert and Update Trigger To ClientOnlineBookingState';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientOnlineBookingState_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientOnlineBookingState_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_ClientOnlineBookingState_InsertUpdate ON dbo.ClientOnlineBookingState AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientOnlineBookingState', 'TRG_ClientOnlineBookingState_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			UPDATE COBS
			SET COBS.DORSSchemeId = CDD.DORSSchemeId
			FROM INSERTED I
			INNER JOIN ClientOnlineBookingState COBS ON COBS.ClientId = I.ClientId
			INNER JOIN ClientDORSData CDD ON CDD.ClientId = I.ClientId
			WHERE CDD.DataValidatedAgainstDORS = 'True'
			AND I.DORSSchemeId IS NULL
			AND COBS.DORSSchemeId IS NULL;
			
			/****************************************************************************************************************/

		END --END PROCESS
	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP034_02.01_AmendInsertUpdateTriggerToClientOnlineBookingState.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	