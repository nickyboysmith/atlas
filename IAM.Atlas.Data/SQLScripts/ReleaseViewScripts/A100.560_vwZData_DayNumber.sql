
		-- Day Numbers
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwZData_DayNumber', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwZData_DayNumber;
		END		
		GO

		/*
			Create vwZData_DayNumber
		*/
		CREATE VIEW vwZData_DayNumber
		AS
			--Return The Day Numbers. This is used in other Queries
			--SELECT TOP (31) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id])) AS DayNumber
			--FROM sys.all_objects AS s1 
			--CROSS JOIN sys.all_objects AS s2;
			SELECT 1 AS DayNumber
			UNION SELECT 2 AS DayNumber
			UNION SELECT 3 AS DayNumber
			UNION SELECT 4 AS DayNumber
			UNION SELECT 5 AS DayNumber
			UNION SELECT 6 AS DayNumber
			UNION SELECT 7 AS DayNumber
			UNION SELECT 8 AS DayNumber
			UNION SELECT 9 AS DayNumber
			UNION SELECT 10 AS DayNumber
			UNION SELECT 11 AS DayNumber
			UNION SELECT 12 AS DayNumber
			UNION SELECT 13 AS DayNumber
			UNION SELECT 14 AS DayNumber
			UNION SELECT 15 AS DayNumber
			UNION SELECT 16 AS DayNumber
			UNION SELECT 17 AS DayNumber
			UNION SELECT 18 AS DayNumber
			UNION SELECT 19 AS DayNumber
			UNION SELECT 20 AS DayNumber
			UNION SELECT 21 AS DayNumber
			UNION SELECT 22 AS DayNumber
			UNION SELECT 23 AS DayNumber
			UNION SELECT 24 AS DayNumber
			UNION SELECT 25 AS DayNumber
			UNION SELECT 26 AS DayNumber
			UNION SELECT 27 AS DayNumber
			UNION SELECT 28 AS DayNumber
			UNION SELECT 29 AS DayNumber
			UNION SELECT 30 AS DayNumber
			UNION SELECT 31 AS DayNumber
			;
			
		GO
		/*********************************************************************************************************************/
		