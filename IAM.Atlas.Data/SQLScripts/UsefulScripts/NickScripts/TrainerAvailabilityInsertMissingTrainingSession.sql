	INSERT INTO dbo.TrainerAvailabilityDate (TrainerId, [Date], SessionNumber)
	SELECT TrainerId, [Date], 4 as SessionNumber
	FROM (
       SELECT TAD.TrainerId, TAD.[Date], COUNT(*) CNT
              , SUM((CASE WHEN TAD.SessionNumber = 1 THEN 1 ELSE 0 END)) AM
              , SUM((CASE WHEN TAD.SessionNumber = 2 THEN 1 ELSE 0 END)) PM
              , SUM((CASE WHEN TAD.SessionNumber = 3 THEN 1 ELSE 0 END)) EVE
              , SUM((CASE WHEN TAD.SessionNumber = 4 THEN 1 ELSE 0 END)) AMPM
              , SUM((CASE WHEN TAD.SessionNumber = 5 THEN 1 ELSE 0 END)) PMEVE
              , SUM((CASE WHEN TAD.SessionNumber = 6 THEN 1 ELSE 0 END)) AMPMEVE
       FROM dbo.TrainerAvailabilityDate TAD
       GROUP BY TAD.TrainerId, TAD.[Date]
       ) T
       WHERE T.AM > 0 AND T.PM > 0 AND T.AMPM = 0

	INSERT INTO dbo.TrainerAvailabilityDate (TrainerId, [Date], SessionNumber)
	SELECT TrainerId, [Date], 5 as SessionNumber
	FROM (
       SELECT TAD.TrainerId, TAD.[Date], COUNT(*) CNT
              , SUM((CASE WHEN TAD.SessionNumber = 1 THEN 1 ELSE 0 END)) AM
              , SUM((CASE WHEN TAD.SessionNumber = 2 THEN 1 ELSE 0 END)) PM
              , SUM((CASE WHEN TAD.SessionNumber = 3 THEN 1 ELSE 0 END)) EVE
              , SUM((CASE WHEN TAD.SessionNumber = 4 THEN 1 ELSE 0 END)) AMPM
              , SUM((CASE WHEN TAD.SessionNumber = 5 THEN 1 ELSE 0 END)) PMEVE
              , SUM((CASE WHEN TAD.SessionNumber = 6 THEN 1 ELSE 0 END)) AMPMEVE
       FROM dbo.TrainerAvailabilityDate TAD
       GROUP BY TAD.TrainerId, TAD.[Date]
       ) T
       WHERE T.PM > 0 AND T.EVE > 0 AND T.PMEVE = 0

	INSERT INTO dbo.TrainerAvailabilityDate (TrainerId, [Date], SessionNumber)
	SELECT TrainerId, [Date], 6 as SessionNumber
	FROM (
       SELECT TAD.TrainerId, TAD.[Date], COUNT(*) CNT
              , SUM((CASE WHEN TAD.SessionNumber = 1 THEN 1 ELSE 0 END)) AM
              , SUM((CASE WHEN TAD.SessionNumber = 2 THEN 1 ELSE 0 END)) PM
              , SUM((CASE WHEN TAD.SessionNumber = 3 THEN 1 ELSE 0 END)) EVE
              , SUM((CASE WHEN TAD.SessionNumber = 4 THEN 1 ELSE 0 END)) AMPM
              , SUM((CASE WHEN TAD.SessionNumber = 5 THEN 1 ELSE 0 END)) PMEVE
              , SUM((CASE WHEN TAD.SessionNumber = 6 THEN 1 ELSE 0 END)) AMPMEVE
       FROM dbo.TrainerAvailabilityDate TAD
       GROUP BY TAD.TrainerId, TAD.[Date]
       ) T
       WHERE T.AM > 0 AND T.PM > 0 AND T.EVE > 0 AND T.AMPMEVE = 0

