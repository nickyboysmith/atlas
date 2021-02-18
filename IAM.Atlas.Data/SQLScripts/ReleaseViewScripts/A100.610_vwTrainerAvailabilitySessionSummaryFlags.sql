
		-- View Trainer Availability Session Summary Flags
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainerAvailabilitySessionSummaryFlags', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerAvailabilitySessionSummaryFlags;
		END		
		GO

		/*
			Create vwTrainerAvailabilitySessionSummaryFlags
		*/
		CREATE VIEW vwTrainerAvailabilitySessionSummaryFlags
		AS
			SELECT ISNULL(TASS.TrainerId, -1)					AS TrainerId
				, TASS.[Date]								AS [Date]
				, TASS.TotalSessions						AS TotalSessions
				, TASS.SessionsBooked						AS SessionsBooked
				, TASS.FullyBooked							AS FullyBooked
				, TASS.PartiallyBooked						AS PartiallyBooked
				, TASS.Session1AvailableCount				AS Session1AvailableCount
				, TASS.Session1BookedCount					AS Session1BookedCount
				, TASS.Session2AvailableCount				AS Session2AvailableCount
				, TASS.Session2BookedCount					AS Session2BookedCount
				, TASS.Session3AvailableCount				AS Session3AvailableCount
				, TASS.Session3BookedCount					AS Session3BookedCount
				, CAST((CASE WHEN TASS.Session1AvailableCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession1
				, CAST((CASE WHEN TASS.Session1BookedCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession1Booked
				, CAST((CASE WHEN TASS.Session2AvailableCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession2
				, CAST((CASE WHEN TASS.Session2BookedCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession2Booked
				, CAST((CASE WHEN TASS.Session3AvailableCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession3
				, CAST((CASE WHEN TASS.Session3BookedCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession3Booked
			FROM vwTrainerAvailabilitySessionSummary TASS			
			;
			
		GO
		/*********************************************************************************************************************/
		