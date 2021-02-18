

		/*
			Drop the View if it already exists
			NB - Used in vwInterpreterAvailabilitySessionSummary
		*/
		IF OBJECT_ID('dbo.vwInterpreterAvailabilitySessionSummaryFlags', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterAvailabilitySessionSummaryFlags;
		END		
		GO
		/*
			Create vwInterpreterAvailabilitySessionSummaryFlags
		*/
		CREATE VIEW dbo.vwInterpreterAvailabilitySessionSummaryFlags
		AS
			SELECT ISNULL(IASS.InterpreterId, -1)			AS InterpreterId
				, IASS.[Date]								AS [Date]
				, IASS.TotalSessions						AS TotalSessions
				, IASS.SessionsBooked						AS SessionsBooked
				, IASS.FullyBooked							AS FullyBooked
				, IASS.PartiallyBooked						AS PartiallyBooked
				, IASS.Session1AvailableCount				AS Session1AvailableCount
				, IASS.Session1BookedCount					AS Session1BookedCount
				, IASS.Session2AvailableCount				AS Session2AvailableCount
				, IASS.Session2BookedCount					AS Session2BookedCount
				, IASS.Session3AvailableCount				AS Session3AvailableCount
				, IASS.Session3BookedCount					AS Session3BookedCount
				, CAST((CASE WHEN IASS.Session1AvailableCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession1
				, CAST((CASE WHEN IASS.Session1BookedCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession1Booked
				, CAST((CASE WHEN IASS.Session2AvailableCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession2
				, CAST((CASE WHEN IASS.Session2BookedCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession2Booked
				, CAST((CASE WHEN IASS.Session3AvailableCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession3
				, CAST((CASE WHEN IASS.Session3BookedCount > 0
						THEN 'True' ELSE 'False' END)
						AS BIT)									AS ShowSession3Booked
			FROM vwInterpreterAvailabilitySessionSummary IASS			
			;
			

GO