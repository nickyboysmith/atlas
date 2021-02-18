		/*
			Drop the View if it already exists
			
		*/

		IF OBJECT_ID('dbo.vwInterpreterBookedDate', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterBookedDate;
		END		
		GO

		/*
			Create [vwInterpreterBookedDate]
		*/
		CREATE VIEW [dbo].[vwInterpreterBookedDate]
		AS
			SELECT CI.InterpreterId					AS InterpreterId
				, CI.CourseId						AS CourseId
				, MIN(CAST(CD.DateStart AS DATE))	AS CourseStartDate
				, MAX(CAST(CD.DateEnd AS DATE))		AS CourseEndDate
				, MAX(CASE WHEN CD.AssociatedSessionNumber IS NULL
							OR CD.AssociatedSessionNumber = 1 
							THEN 1 ELSE 0 END)		AS Session1Booked
				, MAX(CASE WHEN CD.AssociatedSessionNumber IS NULL
							OR CD.AssociatedSessionNumber = 2
							THEN 1 ELSE 0 END)		AS Session2Booked
				, MAX(CASE WHEN CD.AssociatedSessionNumber IS NULL
							OR CD.AssociatedSessionNumber = 3
							THEN 1 ELSE 0 END)		AS Session3Booked
					
			FROM dbo.CourseInterpreter CI
			LEFT JOIN dbo.CourseDate CD		ON CD.CourseId = CI.CourseId
			GROUP BY CI.InterpreterId, CI.CourseId
			;
			
		GO
		/*********************************************************************************************************************/

