

--SELECT CD.DateStart, CD.DateEnd, C.DefaultStartTime, C.DefaultEndTime, CD.AssociatedSessionNumber, TS.StartTime, TS.EndTime
--FROM (
--	SELECT TOP 1000 CD2.CourseId, COUNT(*) NoOfDates
--	FROM dbo.CourseDate CD2
--	GROUP BY CD2.CourseId
--	HAVING COUNT(*) = 1
--) T
--INNER JOIN dbo.CourseDate CD ON CD.CourseId = T.CourseId
--INNER JOIN dbo.Course C ON C.Id = T.CourseId
--INNER JOIN dbo.TrainingSession TS ON TS.Number = CD.AssociatedSessionNumber


--SELECT CD.DateStart
--	, CD.DateEnd
--	, C.DefaultStartTime
--	, C.DefaultEndTime
--	, CAST(CAST(CAST(CD.DateStart AS DATE) AS VARCHAR) + ' ' + C.DefaultStartTime AS DATETIME)
--	, CAST(CD.DateStart AS TIME)
--	, CASE WHEN CAST(CD.DateStart AS TIME) = CAST('00:00:00.0000000' AS TIME) THEN 'True' ELSE 'False' END
--	, CASE WHEN CAST(CD.DateEnd AS TIME) = CAST('00:00:00.0000000' AS TIME) THEN 'True' ELSE 'False' END
--FROM (
--	SELECT TOP 1000 CD2.CourseId, COUNT(*) NoOfDates
--	FROM dbo.CourseDate CD2
--	GROUP BY CD2.CourseId
--	HAVING COUNT(*) = 1
--) T
--INNER JOIN dbo.CourseDate CD ON CD.CourseId = T.CourseId
--INNER JOIN dbo.Course C ON C.Id = T.CourseId

--DISABLE TRIGGER dbo.TRG_CourseDate_InsertUpdateDelete ON CourseDate
--GO
--DISABLE TRIGGER dbo.TRG_CourseDate_InsertUpdate ON CourseDate
--GO

--SELECT *
--INTO dbo.RobTemp_CourseDate_BAK
--FROM dbo.CourseDate


--UPDATE CD
--SET CD.DateStart = (CASE WHEN CAST(CD.DateStart AS TIME) = CAST('00:00:00.0000000' AS TIME) 
--						THEN CAST(CAST(CAST(CD.DateStart AS DATE) AS VARCHAR) + ' ' + C.DefaultStartTime AS DATETIME)
--						ELSE CD.DateStart END)
--, CD.DateEnd = (CASE WHEN CAST(CD.DateEnd AS TIME) = CAST('00:00:00.0000000' AS TIME) 
--						THEN CAST(CAST(CAST(CD.DateEnd AS DATE) AS VARCHAR) + ' ' + C.DefaultEndTime AS DATETIME)
--						ELSE CD.DateEnd END)
--FROM (
--	SELECT CD2.CourseId, COUNT(*) NoOfDates
--	FROM dbo.CourseDate CD2
--	GROUP BY CD2.CourseId
--	HAVING COUNT(*) = 1
--) T
--INNER JOIN dbo.CourseDate CD ON CD.CourseId = T.CourseId
--INNER JOIN dbo.Course C ON C.Id = T.CourseId

--SELECT 
--	C.Id,
--	CD.Id
--	, CD.DateStart
--	, CD.DateEnd
--	, C.DefaultStartTime
--	, C.DefaultEndTime
--	, CAST(CAST(CAST(CD.DateStart AS DATE) AS VARCHAR) + ' ' + C.DefaultStartTime AS DATETIME)
--	, CAST(CD.DateStart AS TIME)
--	, CASE WHEN CAST(CD.DateStart AS TIME) = CAST('00:00:00.0000000' AS TIME) THEN 'True' ELSE 'False' END
--	, CASE WHEN CAST(CD.DateEnd AS TIME) = CAST('00:00:00.0000000' AS TIME) THEN 'True' ELSE 'False' END
--FROM (
--	SELECT CD2.CourseId, COUNT(*) NoOfDates
--	FROM dbo.CourseDate CD2
--	GROUP BY CD2.CourseId
--	HAVING COUNT(*) = 2
--) T
--INNER JOIN dbo.CourseDate CD ON CD.CourseId = T.CourseId
--INNER JOIN dbo.Course C ON C.Id = T.CourseId

--UPDATE CD
--SET CD.DateStart = (CASE WHEN CAST(CD.DateStart AS TIME) = CAST('00:00:00.0000000' AS TIME) 
--						THEN CAST(CAST(CAST(CD.DateStart AS DATE) AS VARCHAR) + ' ' + C.DefaultStartTime AS DATETIME)
--						ELSE CD.DateStart END)
--, CD.DateEnd = (CASE WHEN CAST(CD.DateEnd AS TIME) = CAST('00:00:00.0000000' AS TIME) 
--						THEN CAST(CAST(CAST(CD.DateEnd AS DATE) AS VARCHAR) + ' ' + C.DefaultEndTime AS DATETIME)
--						ELSE CD.DateEnd END)
--FROM (
--	SELECT CD2.CourseId, COUNT(*) NoOfDates
--	FROM dbo.CourseDate CD2
--	GROUP BY CD2.CourseId
--	HAVING COUNT(*) = 2
--) T
--INNER JOIN dbo.CourseDate CD ON CD.CourseId = T.CourseId
--INNER JOIN dbo.Course C ON C.Id = T.CourseId

--UPDATE CourseDate
--SET AssociatedSessionNumber =
--	(CASE WHEN CAST([DateStart] AS TIME) >= (SELECT TOP 1 CAST([StartTime] AS TIME) FROM [dbo].[TrainingSession] WHERE Title = 'EVE')
--			THEN (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'EVE')
--			WHEN CAST([DateStart] AS TIME) <= (SELECT TOP 1 CAST([EndTime] AS TIME) FROM [dbo].[TrainingSession] WHERE Title = 'AM')
--			THEN (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'AM')
--			ELSE (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'PM')
--			END)
--WHERE AssociatedSessionNumber <> (CASE WHEN CAST([DateStart] AS TIME) >= (SELECT TOP 1 CAST([StartTime] AS TIME) FROM [dbo].[TrainingSession] WHERE Title = 'EVE')
--			THEN (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'EVE')
--			WHEN CAST([DateStart] AS TIME) <= (SELECT TOP 1 CAST([EndTime] AS TIME) FROM [dbo].[TrainingSession] WHERE Title = 'AM')
--			THEN (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'AM')
--			ELSE (SELECT TOP 1 [Number] FROM [dbo].[TrainingSession] WHERE Title = 'PM')
--			END)


--GO

--ENABLE TRIGGER dbo.TRG_CourseDate_InsertUpdateDelete ON CourseDate
--GO
--ENABLE TRIGGER dbo.TRG_CourseDate_InsertUpdate ON CourseDate
--GO
