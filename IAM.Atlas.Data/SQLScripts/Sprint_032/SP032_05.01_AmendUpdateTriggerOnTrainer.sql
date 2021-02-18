/*
	SCRIPT: Amend trigger TRG_TrainerToUpdateDistance_Update
	Author: Robert Newnham
	Created: 12/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_05.01_AmendUpdateTriggerOnTrainer.sql';
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

				DECLARE cur_Trainers1301 CURSOR
				FOR 
				SELECT DISTINCT Id
				FROM INSERTED I;
			
				OPEN cur_Trainers1301   
				FETCH NEXT FROM cur_Trainers1301 INTO @TrainerId;

				WHILE @@FETCH_STATUS = 0   
				BEGIN 
					IF (ISNULL(@TrainerId,-1) > 0)
					BEGIN
						EXEC uspUpdateTrainerDistancesForAttachedVenues @TrainerId
					END
					FETCH NEXT FROM cur_Trainers1301 INTO @TrainerId;
				END

				CLOSE cur_Trainers1301;
				DEALLOCATE cur_Trainers1301;
			END --END PROCESS

		END

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_05.01_AmendUpdateTriggerOnTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO