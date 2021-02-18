/*
	SCRIPT: Create Insert Trigger On TrainerAvailabilityDate
	Author: Nick Smith
	Created: 01/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_03.01_CreateInsertTriggerOnTrainerAvailabilityDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert Trigger on TrainerAvailabilityDate';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_TrainerAvailabilityDate_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_TrainerAvailabilityDate_Insert;
	END

	GO

	CREATE TRIGGER TRG_TrainerAvailabilityDate_Insert ON dbo.TrainerAvailabilityDate AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'TrainerAvailabilityDate', 'TRG_TrainerAvailabilityDate_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			/* Insert Cases 4 (AMPM), 5 (PMEVE) */
			WITH TrainerAvailabilityCounts (TrainerId, [Date], CNT, AM, PM, EVE, AMPM, PMEVE, AMPMEVE)
			AS
			(
			   SELECT TAD.TrainerId, TAD.[Date], COUNT(*) CNT
						  , SUM((CASE WHEN TAD.SessionNumber = 1 THEN 1 ELSE 0 END)) AM
						  , SUM((CASE WHEN TAD.SessionNumber = 2 THEN 1 ELSE 0 END)) PM
						  , SUM((CASE WHEN TAD.SessionNumber = 3 THEN 1 ELSE 0 END)) EVE
						  , SUM((CASE WHEN TAD.SessionNumber = 4 THEN 1 ELSE 0 END)) AMPM
						  , SUM((CASE WHEN TAD.SessionNumber = 5 THEN 1 ELSE 0 END)) PMEVE
						  , SUM((CASE WHEN TAD.SessionNumber = 6 THEN 1 ELSE 0 END)) AMPMEVE
				   FROM dbo.TrainerAvailabilityDate TAD
				   INNER JOIN Inserted i ON i.TrainerId = TAD.TrainerId
				   GROUP BY TAD.TrainerId, TAD.[Date]
			) 

			INSERT INTO dbo.TrainerAvailabilityDate (TrainerId, [Date], SessionNumber)
				SELECT TrainerId, [Date], CASE WHEN T.AM > 0 AND T.PM > 0 AND T.AMPM = 0 THEN 4
												WHEN T.PM > 0 AND T.EVE > 0 AND T.PMEVE = 0 THEN 5
												 ELSE 0 END
			FROM TrainerAvailabilityCounts T
			WHERE (T.AM > 0 AND T.PM > 0 AND T.AMPM = 0)
					OR (T.PM > 0 AND T.EVE > 0 AND T.PMEVE = 0)
			;

			/* Insert Case 6 (AMPMEVE) */
			WITH TrainerAvailabilityCounts2 (TrainerId, [Date], CNT, AM, PM, EVE, AMPM, PMEVE, AMPMEVE)
			AS
			(
			   SELECT TAD.TrainerId, TAD.[Date], COUNT(*) CNT
						  , SUM((CASE WHEN TAD.SessionNumber = 1 THEN 1 ELSE 0 END)) AM
						  , SUM((CASE WHEN TAD.SessionNumber = 2 THEN 1 ELSE 0 END)) PM
						  , SUM((CASE WHEN TAD.SessionNumber = 3 THEN 1 ELSE 0 END)) EVE
						  , SUM((CASE WHEN TAD.SessionNumber = 4 THEN 1 ELSE 0 END)) AMPM
						  , SUM((CASE WHEN TAD.SessionNumber = 5 THEN 1 ELSE 0 END)) PMEVE
						  , SUM((CASE WHEN TAD.SessionNumber = 6 THEN 1 ELSE 0 END)) AMPMEVE
				   FROM dbo.TrainerAvailabilityDate TAD
				   INNER JOIN Inserted i ON i.TrainerId = TAD.TrainerId
				   GROUP BY TAD.TrainerId, TAD.[Date]
			) 

			INSERT INTO dbo.TrainerAvailabilityDate (TrainerId, [Date], SessionNumber)
				SELECT TrainerId, [Date], CASE WHEN T.AM > 0 AND T.PM > 0 AND T.EVE > 0 AND T.AMPMEVE = 0 THEN 6
												 ELSE 0 END
			FROM TrainerAvailabilityCounts2 T
			WHERE (T.AM > 0 AND T.PM > 0 AND T.EVE > 0 AND T.AMPMEVE = 0)

			;
		END
	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP043_03.01_CreateInsertTriggerOnTrainerAvailabilityDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO