/*
	SCRIPT: Amend trigger TRG_TrainerToUpdateDistance_Update
	Author: Robert Newnham
	Created: 11/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_31.04_AmendUpdateTriggerOnTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend trigger TRG_TrainerToUpdateDistance_Update';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_TrainerToUpdateDistance_Update', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_TrainerToUpdateDistance_Update;
		END
GO
		CREATE TRIGGER TRG_TrainerToUpdateDistance_Update ON dbo.Trainer AFTER UPDATE
		AS
		BEGIN	
			DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
			DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
			IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
			BEGIN                 
				EXEC uspLogTriggerRunning 'Trainer', 'TRG_TrainerToUpdateDistance_Update', @insertedRows, @deletedRows;
				-------------------------------------------------------------------------------------------

				DECLARE @TrainerId INT;
				DECLARE @VenueId INT;
				DECLARE @TrainerVenueId INT = 0;
				DECLARE @CNT INT = 0;

				DECLARE cur_TrainerVenues CURSOR
				FOR 
				SELECT DISTINCT
					TV.VenueId 
					,TV.TrainerId
					, TV.Id AS TrainerVenueId
				FROM INSERTED I
				INNER JOIN dbo.TrainerVenue TV		ON TV.TrainerId = I.Id	-- Find All Trainer Venues Assigned to the Trainer
				INNER JOIN dbo.TrainerLocation TL	ON TL.TrainerId = TV.TrainerId
													AND TL.MainLocation = 'True'
				INNER JOIN [Location] L				ON L.Id = TL.LocationId
													AND LEN(L.PostCode) > 0 --Trainer Must Have a Valid Post Code
				INNER JOIN PostCodeInformation PCI	ON REPLACE(PCI.PostCode, ' ','') = REPLACE(L.PostCode, ' ','')  --Trainer Should Have a Valid Post Code
				INNER JOIN dbo.VenueAddress VA		ON VA.VenueId = TV.VenueId
				INNER JOIN [Location] L2			ON L2.Id = VA.LocationId
													AND LEN(L2.PostCode) > 0 --Venue Must Have a Valid Post Code
				INNER JOIN PostCodeInformation PCI2	ON REPLACE(PCI.PostCode, ' ','') = REPLACE(L2.PostCode, ' ','') --Venue Should Have a Valid Post Code
				WHERE (L.DateUpdated >= TV.DateUpdated
						OR ISNULL(TV.DistanceHomeToVenueInMiles,0) <= 0);
			
				OPEN cur_TrainerVenues   
				FETCH NEXT FROM cur_TrainerVenues INTO @VenueId, @TrainerId, @TrainerVenueId;

				WHILE @@FETCH_STATUS = 0   
				BEGIN IF (ISNULL(@VenueId,-1) > 0 AND ISNULL(@TrainerId,-1) > 0)
					BEGIN
						--SET @CNT = @CNT + 1;
						--PRINT 'CNT: ' +  CAST(@CNT AS VARCHAR) + 'T:' + CAST(@TrainerId AS VARCHAR) + ' - TV:' + CAST(@TrainerVenueId AS VARCHAR) + ' - V:' + CAST(@VenueId AS VARCHAR);
						EXEC uspUpdateTrainerVenueDistance @TrainerId, @VenueId; 
					END
					FETCH NEXT FROM cur_TrainerVenues INTO @VenueId, @TrainerId, @TrainerVenueId;
				END

				CLOSE cur_TrainerVenues;
				DEALLOCATE cur_TrainerVenues;
			END --END PROCESS

		END

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_31.04_AmendUpdateTriggerOnTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO