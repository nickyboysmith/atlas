	/*
	SCRIPT: Create Delete Trigger On TrainerAvailabilityDate
	Author: Nick Smith
	Created: 01/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_04.01_CreateDeleteTriggerOnTrainerAvailabilityDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Delete Trigger on TrainerAvailabilityDate';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_TrainerAvailabilityDate_Delete', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_TrainerAvailabilityDate_Delete;
	END

	GO

	CREATE TRIGGER TRG_TrainerAvailabilityDate_Delete ON dbo.TrainerAvailabilityDate AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'TrainerAvailabilityDate', 'TRG_TrainerAvailabilityDate_Delete', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			/* Delete Cases 4 (AMPM), 5 (PMEVE) */
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
				   INNER JOIN Deleted d ON d.TrainerId = TAD.TrainerId
				   GROUP BY TAD.TrainerId, TAD.[Date]
			)

			DELETE TAD
			FROM TrainerAvailabilityDate TAD
			INNER JOIN TrainerAvailabilityCounts TAC ON TAC.TrainerId = TAD.TrainerId
														AND TAC.[Date] = TAD.[Date]
			WHERE TAD.SessionNumber = 
							CASE WHEN (TAC.AM = 0 AND TAC.PM > 0 AND TAC.AMPM > 0) 
								OR (TAC.AM > 0 AND TAC.PM = 0 AND TAC.AMPM > 0) THEN 4
									WHEN (TAC.PM = 0 AND TAC.EVE > 0 AND TAC.PMEVE > 0) 
										OR (TAC.PM > 0 AND TAC.EVE = 0 AND TAC.PMEVE > 0) THEN 5
										ELSE 0 END
			;

			/* Delete Case 6 (AMPMEVE) */
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
				   INNER JOIN Deleted d ON d.TrainerId = TAD.TrainerId
				   GROUP BY TAD.TrainerId, TAD.[Date]
			)

			DELETE TAD
			FROM TrainerAvailabilityDate TAD
			INNER JOIN TrainerAvailabilityCounts2 TAC ON TAC.TrainerId = TAD.TrainerId
														AND TAC.[Date] = TAD.[Date]
			WHERE TAD.SessionNumber = 
							CASE WHEN (TAC.AM = 0 AND TAC.PM > 0 AND TAC.EVE > 0 AND TAC.AMPMEVE > 0) 
											OR (TAC.AM > 0 AND TAC.PM = 0 AND TAC.EVE > 0 AND TAC.AMPMEVE > 0)
												OR (TAC.AM > 0 AND TAC.PM > 0 AND TAC.EVE = 0 AND TAC.AMPMEVE > 0) THEN 6
										ELSE 0 END
			;
			
		END
	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP043_04.01_CreateDeleteTriggerOnTrainerAvailabilityDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO