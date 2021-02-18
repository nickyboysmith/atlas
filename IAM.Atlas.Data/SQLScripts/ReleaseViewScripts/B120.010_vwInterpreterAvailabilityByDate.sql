		/*
			Drop the View if it already exists
			
		*/
		IF OBJECT_ID('dbo.vwInterpreterAvailabilityByDate', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterAvailabilityByDate;
		END		
		GO
		/*
			Create vwInterpreterAvailabilityByDate
		*/
		CREATE VIEW dbo.vwInterpreterAvailabilityByDate 
		AS
			SELECT DISTINCT ISNULL(IAD.InterpreterId,0)	AS InterpreterId
				, IAD.[Date]					AS [Date]
			FROM dbo.InterpreterAvailabilityDate IAD
			LEFT JOIN dbo.CourseInterpreter CI		ON CI.InterpreterId = IAD.InterpreterId
			LEFT JOIN dbo.CourseDate CD				ON CI.CourseId = CD.CourseId													
			WHERE CD.Id IS NULL
				AND NOT IAD.[Date] BETWEEN CAST(ISNULL(CD.DateStart, GETDATE()) AS DATE) AND CAST(ISNULL(CD.DateEnd, GETDATE()) AS DATE)
			;

		GO

		/*********************************************************************************************************************/