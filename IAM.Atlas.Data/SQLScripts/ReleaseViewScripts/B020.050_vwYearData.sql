-- View Ten Year Span
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwYearData', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwYearData;
		END		
		GO

		/*
			Create vwYearData
		*/
		CREATE VIEW vwYearData
		AS
			SELECT ISNULL([Year], 0) AS [Year]
			FROM (
					SELECT DATEPART(YEAR, DATEADD(YEAR, -5, GETDATE())) [Year]
					UNION
					SELECT DATEPART(YEAR, DATEADD(YEAR, -3, GETDATE())) [Year]
					UNION
					SELECT DATEPART(YEAR, DATEADD(YEAR, -2, GETDATE())) [Year]
					UNION
					SELECT DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE())) [Year]
					UNION
					SELECT DATEPART(YEAR, GETDATE()) [Year]
					UNION
					SELECT DATEPART(YEAR, DATEADD(YEAR, 1, GETDATE())) [Year]
					UNION
					SELECT DATEPART(YEAR, DATEADD(YEAR, 2, GETDATE())) [Year]
					UNION
					SELECT DATEPART(YEAR, DATEADD(YEAR, 3, GETDATE())) [Year]
					UNION
					SELECT DATEPART(YEAR, DATEADD(YEAR, 4, GETDATE())) [Year]
					UNION
					SELECT DATEPART(YEAR, DATEADD(YEAR, 5, GETDATE())) [Year]
					) YR
		GO