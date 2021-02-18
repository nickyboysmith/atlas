
		-- Five Years of Dates, Current Year plus two either side
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwZData_FiveYearDate', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwZData_FiveYearDate;
		END		
		GO

		/*
			Create vwZData_FiveYearDate
		*/
		CREATE VIEW vwZData_FiveYearDate
		AS
			--Return Five Years of Valid Dates. Used to get Result Set of Dates for a particular Month.
			SELECT YearNumber, MonthNumber, DayNumber
				, CAST((CAST(YearNumber AS VARCHAR) + '-' + CAST(MonthNumber AS VARCHAR) + '-' + CAST(DayNumber AS VARCHAR)) AS DATE) AS TheDate
			FROM vwZData_DayNumber DN
			CROSS JOIN vwZData_MonthNumber MN
			CROSS JOIN (SELECT YEAR(GETDATE()) -2 AS YearNumber
						UNION SELECT YEAR(GETDATE()) -1 AS YearNumber
						UNION SELECT YEAR(GETDATE()) AS YearNumber
						UNION SELECT YEAR(GETDATE()) +1 AS YearNumber
						UNION SELECT YEAR(GETDATE()) +2 AS YearNumber
						) YN
			WHERE ISDATE(CAST(YearNumber AS VARCHAR) + '-' + CAST(MonthNumber AS VARCHAR) + '-' + CAST(DayNumber AS VARCHAR)) = 1
			;
			
		GO
		/*********************************************************************************************************************/
		