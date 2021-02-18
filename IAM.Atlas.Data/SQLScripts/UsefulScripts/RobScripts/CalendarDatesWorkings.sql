

--DECLARE @Sunday INT = 1
--		, @Monday INT = 2
--		, @Tuesday INT = 3
--		, @Wednesday INT = 4
--		, @Thursday INT = 5
--		, @Friday INT = 6
--		, @Saturday INT = 7
--		;

--DECLARE @TheYear INT = 2016;
--DECLARE @TheMonth INT = 12;

--DECLARE @TheDate DATE;
--SELECT @TheDate = 
--		CAST(
--			CAST(@TheYear AS VARCHAR(4))
--			+ '-'
--			+ CAST(@TheMonth AS VARCHAR(2))
--			+ '-01'
--			AS DATE)

--SELECT 
--	'A' AS DateRowLetter
--	, 1 AS DateRowNumber
--	 , DATEADD(DAY, 2 - DATEPART(WEEKDAY, @TheDate), @TheDate) AS DateColumn1
--	 , DATEADD(DAY, 3 - DATEPART(WEEKDAY, @TheDate), @TheDate) AS DateColumn2
--	 , DATEADD(DAY, 4 - DATEPART(WEEKDAY, @TheDate), @TheDate) AS DateColumn3
--	 , DATEADD(DAY, 5 - DATEPART(WEEKDAY, @TheDate), @TheDate) AS DateColumn4
--	 , DATEADD(DAY, 6 - DATEPART(WEEKDAY, @TheDate), @TheDate) AS DateColumn5
--	 , DATEADD(DAY, 7 - DATEPART(WEEKDAY, @TheDate), @TheDate) AS DateColumn6
--	 , DATEADD(DAY, 8 - DATEPART(WEEKDAY, @TheDate), @TheDate) AS DateColumn7

SELECT 1 UNION SELECT 2

SELECT TOP (31) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id])) AS DayNumber
FROM sys.all_objects AS s1 
CROSS JOIN sys.all_objects AS s2;
SELECT TOP (12) CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id])) AS MonthNumber
FROM sys.all_objects AS s1 
CROSS JOIN sys.all_objects AS s2;


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
			, TheMonth
			, CAST(
					CAST(TheYear AS VARCHAR(4))
					+ '-' + CAST(TheMonth AS VARCHAR(2))
					+ '-01'
				AS DATE) AS TheDate
		FROM (
			 SELECT 1 AS TheMonth 
			 UNION SELECT 2 
			 UNION SELECT 3 
			 UNION SELECT 4 
			 UNION SELECT 5 
			 UNION SELECT 6 
			 UNION SELECT 7 
			 UNION SELECT 8 
			 UNION SELECT 9 
			 UNION SELECT 10 
			 UNION SELECT 11
			 UNION SELECT 12) MTHS
		, (SELECT YEAR(GETDATE()) AS TheYear 
			 UNION SELECT YEAR(GETDATE()) + 1
			 UNION SELECT YEAR(GETDATE()) - 1) YRS
		) TheDates
	) TDS
WHERE TDS.NumCalc <= 28
ORDER BY
	TheYear
	, TheMonth
	, DateRowLetter
	, DateRowNumber
