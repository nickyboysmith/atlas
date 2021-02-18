
		-- View Calendar Dates By Month
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCalendarDatesByMonth', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCalendarDatesByMonth;
		END		
		GO

		/*
			Create vwCalendarDatesByMonth
		*/
		CREATE VIEW vwCalendarDatesByMonth
		AS
			SELECT
				TheYear
				, TheMonth
				, DateRowLetter
				, DateRowNumber
				, DATEADD(DAY, 2 + NumCalc - DATEPART(WEEKDAY, TheDate), TheDate) AS DateColumn1
				, DATEADD(DAY, 3 + NumCalc - DATEPART(WEEKDAY, TheDate), TheDate) AS DateColumn2
				, DATEADD(DAY, 4 + NumCalc - DATEPART(WEEKDAY, TheDate), TheDate) AS DateColumn3
				, DATEADD(DAY, 5 + NumCalc - DATEPART(WEEKDAY, TheDate), TheDate) AS DateColumn4
				, DATEADD(DAY, 6 + NumCalc - DATEPART(WEEKDAY, TheDate), TheDate) AS DateColumn5
				, DATEADD(DAY, 7 + NumCalc - DATEPART(WEEKDAY, TheDate), TheDate) AS DateColumn6
				, DATEADD(DAY, 8 + NumCalc - DATEPART(WEEKDAY, TheDate), TheDate) AS DateColumn7
			FROM (
				SELECT
					TheDates.TheYear
					, TheDates.TheMonth
					, CHAR(64 + RowNumber) AS DateRowLetter
					, RowNumber AS DateRowNumber
					, TheDate
					, (CASE WHEN DATEPART(WEEKDAY, TheDate) = 1 --Is A Sunday
							THEN ((RowNumber - 2) * 7)
							ELSE ((RowNumber - 1) * 7)
							END) NumCalc
				FROM (
					SELECT 1 AS RowNumber 
					UNION SELECT 2 
					UNION SELECT 3 
					UNION SELECT 4 
					UNION SELECT 5 
					UNION SELECT 6) RN
				, (SELECT TheYear
						, MonthNumber AS TheMonth
						, CAST(
								CAST(TheYear AS VARCHAR(4))
								+ '-' + CAST(MonthNumber AS VARCHAR(2))
								+ '-01'
							AS DATE) AS TheDate
					FROM vwZData_MonthNumber MTHS
					, (SELECT YEAR(GETDATE()) AS TheYear 
						 UNION SELECT YEAR(GETDATE()) + 1
						 UNION SELECT YEAR(GETDATE()) - 1) YRS
					) TheDates
				) TDS
			WHERE TDS.NumCalc <= 28
			GROUP BY
				TheYear
				, TheMonth
				, DateRowLetter
				, DateRowNumber	
				, TheDate	
				, NumCalc	
			;
			
		GO
		/*********************************************************************************************************************/
		