




/*Remove Duplicate CourseDate with duplicated Dates */
--DELETE CD2
--FROM (
--	SELECT CourseId, AssociatedSessionNumber, COUNT(*) CNT, Max(Id) MaxId
--	FROM CourseDate
--	GROUP BY CourseId, AssociatedSessionNumber
--	HAVING COUNT(*) > 1
--	) CD1
--INNER JOIN CourseDate CD2 ON CD2.CourseId = CD1.CourseId
--							AND CD2.AssociatedSessionNumber = CD1.AssociatedSessionNumber
--WHERE CD2.Id != CD1.MaxId


--/*Remove Duplicate CourseDate with duplicated Dates*/
--DELETE CD2
--FROM (
--	SELECT CourseId, DateStart, DateEnd, COUNT(*) CNT, MIN(Id) MinId
--	FROM CourseDate
--	GROUP BY CourseId, DateStart, DateEnd
--	HAVING COUNT(*) > 1
--	) CD1
--INNER JOIN CourseDate CD2 ON CD2.CourseId = CD1.CourseId
--							AND CD2.DateStart = CD1.DateStart
--							AND CD2.DateEnd = CD1.DateEnd
--WHERE CD2.Id != CD1.MinId

SELECT [StartTime]
		, CAST([StartTime] AS TIME)
      , [EndTime]
      ,  CAST([EndTime] AS TIME)
	  , Title
	  , Number
  FROM [dbo].[TrainingSession]

  
SELECT CD.[DateStart], CAST(CD.[DateStart] AS TIME)
	, CD.[DateEnd], CAST(CD.[DateEnd] AS TIME)
	, (CASE WHEN CAST(CD.[DateStart] AS TIME) >= (SELECT TOP 1 CAST([StartTime] AS TIME) FROM [dbo].[TrainingSession] WHERE [Number] = 3)
			THEN (SELECT TOP 1 TITLE FROM [dbo].[TrainingSession] WHERE [Number] = 3)
			WHEN CAST(CD.[DateStart] AS TIME) <= (SELECT TOP 1 CAST([EndTime] AS TIME) FROM [dbo].[TrainingSession] WHERE [Number] = 1)
			THEN (SELECT TOP 1 TITLE FROM [dbo].[TrainingSession] WHERE [Number] = 1)
			ELSE  (SELECT TOP 1 TITLE FROM [dbo].[TrainingSession] WHERE [Number] = 2)
			END)
	, (CASE WHEN CAST(CD.[DateStart] AS TIME) >= (SELECT TOP 1 CAST([StartTime] AS TIME) FROM [dbo].[TrainingSession] WHERE [Number] = 3)
			THEN 3
			WHEN CAST(CD.[DateStart] AS TIME) <= (SELECT TOP 1 CAST([EndTime] AS TIME) FROM [dbo].[TrainingSession] WHERE [Number] = 1)
			THEN 1
			ELSE 2
			END)
FROM CourseDate CD
WHERE CD.AssociatedSessionNumber IS NULL

UPDATE CourseDate
SET AssociatedSessionNumber =
	--(CASE WHEN CAST([DateStart] AS TIME) >= (SELECT TOP 1 CAST([StartTime] AS TIME) FROM [dbo].[TrainingSession] WHERE [Number] = 3)
	--		THEN 3
	--		WHEN CAST([DateStart] AS TIME) <= (SELECT TOP 1 CAST([EndTime] AS TIME) FROM [dbo].[TrainingSession] WHERE [Number] = 1)
	--		THEN 1
	--		ELSE 2
	--		END)
	(CASE WHEN CAST([DateStart] AS TIME) >= (SELECT TOP 1 CAST([StartTime] AS TIME) FROM [dbo].[TrainingSession] WHERE Title = 'EVE')
			THEN (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'EVE')
			WHEN CAST([DateStart] AS TIME) <= (SELECT TOP 1 CAST([EndTime] AS TIME) FROM [dbo].[TrainingSession] WHERE Title = 'AM')
			THEN (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'AM')
			ELSE (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'PM')
			END)
WHERE AssociatedSessionNumber IS NULL
