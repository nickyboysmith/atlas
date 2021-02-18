		/*
			Drop the View if it already exists
			
		*/
		IF OBJECT_ID('dbo.vwInterpreterAvailabilityByDateAndSession', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterAvailabilityByDateAndSession;
		END		
		GO
		
		/*** 
			Create [vwInterpreterAvailabilityByDateAndSession]

		 ***/

		 CREATE VIEW [dbo].[vwInterpreterAvailabilityByDateAndSession]
		 AS 
			SELECT ISNULL(IAD.InterpreterId,0)	AS InterpreterId
				, IAD.[Date]					AS [Date]
				, IAD.SessionNumber				AS SessionNumber
			FROM dbo.InterpreterAvailabilityDate IAD
			LEFT JOIN dbo.CourseInterpreter CI		ON CI.InterpreterId = IAD.InterpreterId
			LEFT JOIN dbo.CourseDate CD				ON CI.CourseId = CD.CourseId
														AND IAD.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
														AND CD.AssociatedSessionNumber = IAD.SessionNumber
			LEFT JOIN dbo.CourseDate CD2			ON CI.CourseId = CD2.CourseId
														AND IAD.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
														AND (CD2.AssociatedSessionNumber IS NULL) 
												
			WHERE CD.Id IS NULL OR CD2.Id IS NULL

		GO
		/*********************************************************************************************************************/