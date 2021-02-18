
		
		-- Month Numbers
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwZData_MonthNumber', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwZData_MonthNumber;
		END		
		GO

		/*
			Create vwZData_MonthNumber
		*/
		CREATE VIEW vwZData_MonthNumber
		AS
			--Return The Month Numbers. This is used in other Queries
			--SELECT TOP (12) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id])) AS MonthNumber
			--FROM sys.all_objects AS s1 
			--CROSS JOIN sys.all_objects AS s2;
			SELECT 1 AS MonthNumber
			UNION SELECT 2 AS MonthNumber
			UNION SELECT 3 AS MonthNumber
			UNION SELECT 4 AS MonthNumber
			UNION SELECT 5 AS MonthNumber
			UNION SELECT 6 AS MonthNumber
			UNION SELECT 7 AS MonthNumber
			UNION SELECT 8 AS MonthNumber
			UNION SELECT 9 AS MonthNumber
			UNION SELECT 10 AS MonthNumber
			UNION SELECT 11 AS MonthNumber
			UNION SELECT 12 AS MonthNumber
			;
			
		GO
		/*********************************************************************************************************************/
		