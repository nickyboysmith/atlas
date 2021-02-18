/*
	SCRIPT: Create Insert and Update Trigger on ClientPhone
	Author: Robert Newnham
	Created: 01/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_07.01_CreateInsertAndUpdateTriggerOnClientPhone.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert and Update Trigger on ClientPhone';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientPhone_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientPhone_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_ClientPhone_InsertUpdate ON dbo.ClientPhone AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientPhone', 'TRG_ClientPhone_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			/****************************************************************************************************************/
			--Set as Default Number if there is no Default Number
			UPDATE CP
			SET CP.DefaultNumber = 'True'
			FROM INSERTED I
			INNER JOIN dbo.ClientPhone CP ON CP.Id = I.Id
			WHERE ISNULL(I.DefaultNumber, 'False') = 'False'
			AND NOT EXISTS (SELECT * 
							FROM dbo.ClientPhone CP2
							WHERE CP2.ClientId = CP.ClientId
							AND CP2.DefaultNumber = 'True'
							AND CP2.Id != CP.Id)
			;
			
			--Set Default Number is False if NULL
			UPDATE CP
			SET CP.DateAdded = GETDATE()
			FROM INSERTED I
			INNER JOIN dbo.ClientPhone CP ON CP.ClientId = I.ClientId
			WHERE CP.DateAdded IS NULL
			;

			--Set Default Number is False if NULL
			UPDATE CP
			SET CP.DefaultNumber = 'False'
			FROM INSERTED I
			INNER JOIN dbo.ClientPhone CP ON CP.ClientId = I.ClientId
			WHERE CP.DefaultNumber IS NULL
			;

			/****************************************************************************************************************/

		END --END PROCESS
	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP034_07.01_CreateInsertAndUpdateTriggerOnClientPhone.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	