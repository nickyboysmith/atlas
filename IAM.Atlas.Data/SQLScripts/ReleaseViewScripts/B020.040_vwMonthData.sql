-- View Month Numbers
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwMonthData', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwMonthData;
		END		
		GO

		/*
			Create vwMonthData
		*/
		CREATE VIEW vwMonthData
		AS
			SELECT MonthNumber
			FROM (
				SELECT 01 MonthNumber
				UNION
				SELECT 02 MonthNumber
				UNION
				SELECT 03 MonthNumber
				UNION
				SELECT 04 MonthNumber
				UNION
				SELECT 05 MonthNumber
				UNION
				SELECT 06 MonthNumber
				UNION
				SELECT 07 MonthNumber
				UNION
				SELECT 08 MonthNumber
				UNION
				SELECT 09 MonthNumber
				UNION
				SELECT 10 MonthNumber
				UNION
				SELECT 11 MonthNumber
				UNION
				SELECT 12 MonthNumber
				) MTH
			;
			
		GO