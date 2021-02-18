

		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwInterpreterAvailabilitySessionSummary', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterAvailabilitySessionSummary;
		END		
		GO
		/*
			Create vwInterpreterAvailabilitySessionSummary
		*/
		CREATE VIEW dbo.vwInterpreterAvailabilitySessionSummary 
		AS
			SELECT ISNULL(IAD.InterpreterId, -1)										AS InterpreterId
					, IAD.[Date]														AS [Date]
					, COUNT(*)															AS TotalSessions
					, SUM(CASE WHEN IBD.InterpreterId IS NOT NULL THEN 1 ELSE 0 END)	AS SessionsBooked
					, CAST((CASE WHEN COUNT(*) = SUM(CASE WHEN IBD.InterpreterId IS NOT NULL THEN 1 ELSE 0 END)
							THEN 'True' ELSE 'False' END) AS BIT)						AS FullyBooked
					, CAST((CASE WHEN COUNT(*) > SUM(CASE WHEN IBD.InterpreterId IS NOT NULL THEN 1 ELSE 0 END)
									AND SUM(CASE WHEN IBD.InterpreterId IS NOT NULL THEN 1 ELSE 0 END) > 0
									THEN 'True' ELSE 'False' END) AS BIT)				AS PartiallyBooked
					, SUM(CASE WHEN IAD.SessionNumber = 1 THEN 1 ELSE 0 END)			AS Session1AvailableCount
					, SUM(CASE WHEN IAD.SessionNumber = 1 
							AND IBD.Session1Booked = 1
							THEN 1 ELSE 0 END)											AS Session1BookedCount
					, SUM(CASE WHEN IAD.SessionNumber = 2 THEN 1 ELSE 0 END)			AS Session2AvailableCount
					, SUM(CASE WHEN IAD.SessionNumber = 2 
							AND IBD.Session2Booked = 1
							THEN 1 ELSE 0 END)											AS Session2BookedCount
					, SUM(CASE WHEN IAD.SessionNumber = 3 THEN 1 ELSE 0 END)			AS Session3AvailableCount
					, SUM(CASE WHEN IAD.SessionNumber = 3 
							AND IBD.Session3Booked = 1
							THEN 1 ELSE 0 END)											AS Session3BookedCount
			FROM dbo.InterpreterAvailabilityDate IAD
			LEFT JOIN vwInterpreterBookedDate IBD	ON IBD.InterpreterId = IAD.InterpreterId
													AND IBD.CourseStartDate = IAD.[Date]
													AND (
														(IAD.SessionNumber = 1 AND IBD.Session1Booked = 1)
														OR (IAD.SessionNumber = 2 AND IBD.Session2Booked = 1)
														OR (IAD.SessionNumber = 3 AND IBD.Session3Booked = 1)
														)
			GROUP BY IAD.InterpreterId, IAD.[Date]
			
		;
			

GO