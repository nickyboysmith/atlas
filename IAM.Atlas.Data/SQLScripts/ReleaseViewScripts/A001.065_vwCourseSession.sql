
--Create Sub View vwCourseSession
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseSession', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseSession;
END		
GO

/*
	Create vwCourseSession
	NB. This view is used within other views
*/
CREATE VIEW vwCourseSession
AS
	--/* This View will return the Correct Session for a Course even if the Course Has Multiple Dates on Different Sessions*/
SELECT 
		CD.CourseId							AS CourseId
		, CD.AssociatedSessionNumber		AS SessionNumber
		, TS.Title							AS SessionTitle
	FROM CourseDate CD
	INNER JOIN TrainingSession TS ON TS.Number = CD.AssociatedSessionNumber
	LEFT JOIN (SELECT CourseId, COUNT(*) CNT, MIN(Id) As MinId
				FROM CourseDate 
				GROUP BY CourseId
				HAVING COUNT(*) > 1) CD2	ON CD2.CourseId = CD.CourseId
	WHERE CD2.MinId IS NULL
	UNION
	SELECT 
		CD3.CourseId						AS CourseId
		, TS.Number							AS SessionNumber
		, TS.Title							AS SessionTitle
	FROM (
		SELECT 
			CD.CourseId							AS CourseId
			, COUNT(*)							AS CNT
		FROM CourseDate CD
		INNER JOIN TrainingSession TS ON TS.Number = CD.AssociatedSessionNumber
		LEFT JOIN (SELECT CourseId, COUNT(*) CNT, MIN(Id) As MinId
					FROM CourseDate 
					GROUP BY CourseId
					HAVING COUNT(*) > 1) CD2	ON CD2.CourseId = CD.CourseId
		WHERE CD2.MinId IS NOT NULL
		AND CD2.CNT < 3
		AND CD.AssociatedSessionNumber IN (1, 2) --AM AND PM
		GROUP BY CD.CourseId
		HAVING COUNT(*) > 1) CD3
	INNER JOIN TrainingSession TS ON TS.Title = 'AM & PM'
	UNION
	SELECT 
		CD3.CourseId						AS CourseId
		, TS.Number							AS SessionNumber
		, TS.Title							AS SessionTitle
	FROM (
		SELECT 
			CD.CourseId							AS CourseId
			, COUNT(*)							AS CNT
		FROM CourseDate CD
		INNER JOIN TrainingSession TS ON TS.Number = CD.AssociatedSessionNumber
		LEFT JOIN (SELECT CourseId, COUNT(*) CNT, MIN(Id) As MinId
					FROM CourseDate 
					GROUP BY CourseId
					HAVING COUNT(*) > 1) CD2	ON CD2.CourseId = CD.CourseId
		WHERE CD2.MinId IS NOT NULL 
		AND CD2.CNT < 3
		AND CD.AssociatedSessionNumber IN (2, 3) --PM AND EVE
		GROUP BY CD.CourseId
		HAVING COUNT(*) > 1) CD3
	INNER JOIN TrainingSession TS ON TS.Title = 'PM & EVE'
	UNION
	SELECT 
		CD3.CourseId						AS CourseId
		, TS.Number							AS SessionNumber
		, TS.Title							AS SessionTitle
	FROM (
		SELECT 
			CD.CourseId							AS CourseId
			, COUNT(*)							AS CNT
		FROM CourseDate CD
		INNER JOIN TrainingSession TS ON TS.Number = CD.AssociatedSessionNumber
		LEFT JOIN (SELECT CourseId, COUNT(*) CNT, MIN(Id) As MinId
					FROM CourseDate 
					GROUP BY CourseId
					HAVING COUNT(*) > 1) CD2	ON CD2.CourseId = CD.CourseId
		WHERE CD2.MinId IS NOT NULL 
		AND CD2.CNT = 3
		AND CD.AssociatedSessionNumber IN (2, 3) --PM AND EVE
		GROUP BY CD.CourseId
		HAVING COUNT(*) > 1) CD3
	INNER JOIN TrainingSession TS ON TS.Title = 'AM & PM & EVE'
	
GO

/*********************************************************************************************************************/
		
