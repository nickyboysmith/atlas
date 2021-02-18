
		-- View Trainer Availability Session Summary
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainerAvailabilitySessionSummary', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerAvailabilitySessionSummary;
		END		
		GO

		/*
			Create vwTrainerAvailabilitySessionSummary
		*/
		CREATE VIEW vwTrainerAvailabilitySessionSummary
		AS
			SELECT ISNULL(TAD.TrainerId, -1)										AS TrainerId
					, TAD.[Date]													AS [Date]
					, COUNT(*)														AS TotalSessions
					, SUM(CASE WHEN TBD.TrainerId IS NOT NULL THEN 1 ELSE 0 END)	AS SessionsBooked
					, CAST((CASE WHEN COUNT(*) = SUM(CASE WHEN TBD.TrainerId IS NOT NULL THEN 1 ELSE 0 END)
							THEN 'True' ELSE 'False' END) AS BIT)					AS FullyBooked
					, CAST((CASE WHEN COUNT(*) > SUM(CASE WHEN TBD.TrainerId IS NOT NULL THEN 1 ELSE 0 END)
									AND SUM(CASE WHEN TBD.TrainerId IS NOT NULL THEN 1 ELSE 0 END) > 0
									THEN 'True' ELSE 'False' END) AS BIT)			AS PartiallyBooked
					, SUM(CASE WHEN TAD.SessionNumber = 1 THEN 1 ELSE 0 END)		AS Session1AvailableCount
					, SUM(CASE WHEN TAD.SessionNumber = 1 
							AND TBD.Session1Booked = 1
							THEN 1 ELSE 0 END)										AS Session1BookedCount
					, SUM(CASE WHEN TAD.SessionNumber = 2 THEN 1 ELSE 0 END)		AS Session2AvailableCount
					, SUM(CASE WHEN TAD.SessionNumber = 2 
							AND TBD.Session2Booked = 1
							THEN 1 ELSE 0 END)										AS Session2BookedCount
					, SUM(CASE WHEN TAD.SessionNumber = 3 THEN 1 ELSE 0 END)		AS Session3AvailableCount
					, SUM(CASE WHEN TAD.SessionNumber = 3 
							AND TBD.Session3Booked = 1
							THEN 1 ELSE 0 END)										AS Session3BookedCount
			FROM TrainerAvailabilityDate TAD
			LEFT JOIN vwTrainerBookedDate TBD	ON TBD.TrainerId = TAD.TrainerId
												AND TBD.CourseStartDate = TAD.[Date]
												AND (
													(TAD.SessionNumber = 1 AND TBD.Session1Booked = 1)
													OR (TAD.SessionNumber = 2 AND TBD.Session2Booked = 1)
													OR (TAD.SessionNumber = 3 AND TBD.Session3Booked = 1)
													)
			--LEFT JOIN CourseTrainer CT					ON CT.TrainerId = TAD.TrainerId
			--LEFT JOIN CourseDate CD					ON CD.CourseId = CT.CourseId
			--											AND CAST(CD.DateStart AS DATE) = CAST(TAD.[Date] AS DATE)
			--											AND (CD.AssociatedSessionNumber IS NULL OR CD.AssociatedSessionNumber = TAD.SessionNumber)
			GROUP BY TAD.TrainerId, TAD.[Date]
			
			;
			
		GO
		/*********************************************************************************************************************/
		