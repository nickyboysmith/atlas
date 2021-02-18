/*
	SCRIPT: Amend Trigger TRG_VenueAddressToUpdateTrainerVenueDistance_Update Tabel VenueAddress
	Author: Robert Newnham
	Created: 12/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_04.08_AmendUpdateTriggerOnVenueAddress.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Trigger TRG_TrainerLocationToUpdateDistance_Update Tabel VenueAddress';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_VenueAddressToUpdateTrainerVenueDistance_Update', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_VenueAddressToUpdateTrainerVenueDistance_Update;
	END
GO
	CREATE TRIGGER TRG_VenueAddressToUpdateTrainerVenueDistance_Update ON dbo.VenueAddress AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'VenueAddress', 'TRG_VenueAddressToUpdateTrainerVenueDistance_Update', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
				
			DECLARE @VenueId INT;

			DECLARE cur_TrainerVenues CURSOR
			FOR 
			SELECT DISTINCT I.VenueId
			FROM INSERTED I;
			
			OPEN cur_TrainerVenues   
			FETCH NEXT FROM cur_TrainerVenues INTO @VenueId;

			WHILE @@FETCH_STATUS = 0   
			BEGIN 
				IF (ISNULL(@VenueId,-1) > 0)
				BEGIN
					EXEC uspUpdateVenueTrainerDistancesForAttachedTrainers @VenueId
				END
				FETCH NEXT FROM cur_TrainerVenues INTO @VenueId;
			END

			CLOSE cur_TrainerVenues;
			DEALLOCATE cur_TrainerVenues;
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_04.08_AmendUpdateTriggerOnVenueAddress.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO