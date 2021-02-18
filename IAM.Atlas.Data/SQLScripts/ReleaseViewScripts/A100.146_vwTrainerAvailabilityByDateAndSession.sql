

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwTrainerAvailabilityByDateAndSession', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerAvailabilityByDateAndSession;
		END		
		GO
		
		/*** Create vwTrainerAvailabilityByDateAndSession

		   NB - This view is used in vwCourseAvailableTrainer 

		 ***/

		 CREATE VIEW dbo.vwTrainerAvailabilityByDateAndSession
		 AS 
								SELECT 
				ISNULL(TAD.TrainerId,0)	AS TrainerId
						, TAD.[Date]				AS [Date]
						, TAD.SessionNumber			AS SessionNumber
			FROM dbo.TrainerAvailabilityDate TAD
			LEFT JOIN 
			(
			SELECT ISNULL(TAD.TrainerId,0)	AS TrainerId
				, TAD.[Date]				AS [Date]
				, TAD.SessionNumber			AS SessionNumber
			FROM dbo.TrainerAvailabilityDate TAD
			INNER JOIN dbo.CourseTrainer CT			ON CT.TrainerId = TAD.TrainerId AND CT.BookedForSessionNumber = TAD.SessionNumber
			INNER JOIN dbo.CourseDate CD				ON CT.CourseId = CD.CourseId
													AND TAD.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
											
					) T ON T.TrainerId = TAD.TrainerId 
					AND T.SessionNumber = TAD.SessionNumber 
					AND T.Date = TAD.Date
			
			LEFT JOIN 
			(
			SELECT ISNULL(TAD.TrainerId,0)	AS TrainerId
				, TAD.[Date]				AS [Date]
				, TAD.SessionNumber			AS SessionNumber
			FROM dbo.TrainerAvailabilityDate TAD
			INNER JOIN dbo.CourseTrainer CT			ON CT.TrainerId = TAD.TrainerId AND CT.BookedForSessionNumber = TAD.SessionNumber
			INNER JOIN dbo.CourseDate CD				ON CT.CourseId = CD.CourseId
													AND TAD.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
											
					) T2 ON T2.TrainerId = TAD.TrainerId 
					AND T2.SessionNumber = CASE WHEN TAD.SessionNumber = 4 THEN 1
												WHEN TAD.SessionNumber = 5 THEN 2
												WHEN TAD.SessionNumber = 6 THEN 1
											ELSE TAD.SessionNumber END
					AND T2.Date = TAD.Date


			LEFT JOIN 
			(
			SELECT ISNULL(TAD.TrainerId,0)	AS TrainerId
				, TAD.[Date]				AS [Date]
				, TAD.SessionNumber			AS SessionNumber
			FROM dbo.TrainerAvailabilityDate TAD
			INNER JOIN dbo.CourseTrainer CT			ON CT.TrainerId = TAD.TrainerId AND CT.BookedForSessionNumber = TAD.SessionNumber
			INNER JOIN dbo.CourseDate CD				ON CT.CourseId = CD.CourseId
													AND TAD.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
											
					) T3 ON T3.TrainerId = TAD.TrainerId 
					AND T3.SessionNumber = CASE WHEN TAD.SessionNumber = 4 THEN 2
												WHEN TAD.SessionNumber = 5 THEN 3
												WHEN TAD.SessionNumber = 6 THEN 2
											ELSE TAD.SessionNumber END
					AND T3.Date = TAD.Date


			LEFT JOIN 
			(
			SELECT ISNULL(TAD.TrainerId,0)	AS TrainerId
				, TAD.[Date]				AS [Date]
				, TAD.SessionNumber			AS SessionNumber
			FROM dbo.TrainerAvailabilityDate TAD
			INNER JOIN dbo.CourseTrainer CT			ON CT.TrainerId = TAD.TrainerId AND CT.BookedForSessionNumber = TAD.SessionNumber
			INNER JOIN dbo.CourseDate CD				ON CT.CourseId = CD.CourseId
													AND TAD.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
											
					) T4 ON T4.TrainerId = TAD.TrainerId 
					AND T4.SessionNumber = CASE WHEN TAD.SessionNumber = 6 THEN 3
											ELSE TAD.SessionNumber END
					AND T4.Date = TAD.Date


			WHERE T.TrainerId IS NULL 
				AND T2.TrainerId IS NULL
				AND T3.TrainerId IS NULL
				AND T4.TrainerId IS NULL

		GO