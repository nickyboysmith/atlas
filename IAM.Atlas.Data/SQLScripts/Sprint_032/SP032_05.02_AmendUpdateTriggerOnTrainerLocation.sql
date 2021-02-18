/*
	SCRIPT: Amend Trigger TRG_TrainerLocationToUpdateDistance_Update Tabel TraineLocation
	Author: Robert Newnham
	Created: 13/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_05.02_AmendUpdateTriggerOnTrainerLocation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Trigger TRG_TrainerLocationToUpdateDistance_Update Tabel TraineLocation';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_TrainerLocationToUpdateDistance_Update', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_TrainerLocationToUpdateDistance_Update;
	END
GO
	CREATE TRIGGER TRG_TrainerLocationToUpdateDistance_Update ON dbo.TrainerLocation AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'TrainerLocation', 'TRG_TrainerLocationToUpdateDistance_Update', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
				
			DECLARE @TrainerId INT;

			DECLARE cur_TrainerLocation1301 CURSOR
			FOR 
			SELECT DISTINCT Id
			FROM INSERTED I;
			
			OPEN cur_TrainerLocation1301   
			FETCH NEXT FROM cur_TrainerLocation1301 INTO @TrainerId;

			WHILE @@FETCH_STATUS = 0   
			BEGIN 
				IF (ISNULL(@TrainerId,-1) > 0)
				BEGIN
					EXEC uspUpdateTrainerDistancesForAttachedVenues @TrainerId
				END
				FETCH NEXT FROM cur_TrainerLocation1301 INTO @TrainerId;
			END

			CLOSE cur_TrainerLocation1301;
			DEALLOCATE cur_TrainerLocation1301;
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_05.02_AmendUpdateTriggerOnTrainerLocation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO