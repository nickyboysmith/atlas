



--Create Fake Trainer Emails

--SELECT T.Id AS TrainerId, -1 AS EmailId
--INTO #TempT
--FROM Trainer T
--LEFT JOIN TrainerEmail TE ON TE.TrainerId = T.Id
--WHERE TE.Id IS NULL

--INSERT INTO Email ([Address])
--SELECT 'fakeemail_xy_' + CAST(TrainerId AS VARCHAR) + '@notrealemail.com'
--FROM #TempT T

--INSERT INTO [dbo].[TrainerEmail] (TrainerId, EmailId, MainEmail)
--SELECT CAST(SUBSTRING([Address],14, (CHARINDEX('@notrealemail.com', [Address]) - 14)) AS INT) AS TrainerId
--	, Id AS EmailId
--	, 'True' AS MainEmail
--FROM Email
--WHERE [Address] LIKE 'fakeemail_xy_%@notrealemail.com'

select * from vwCourseAvailableTrainer where CourseId = 103807

SELECT CourseTypeId, count(*)
FROM dbo.DORSSchemeCourseType
GROUP BY CourseTypeId 
HAVING COUNT(*) > 1

SELECT CT.*
FROM DORSSchemeCourseType CT
INNER JOIN (
SELECT CourseTypeId, count(*) AS CNT
FROM dbo.DORSSchemeCourseType
GROUP BY CourseTypeId 
HAVING COUNT(*) > 1) T ON T.CourseTypeId = CT.CourseTypeId
WHERE CT.DateCreated = CAST('2016-12-23 00:00:00.000' AS DATETIME)
ORDER BY CT.CourseTypeId

DELETE CT
FROM DORSSchemeCourseType CT
INNER JOIN (
SELECT CourseTypeId, count(*) AS CNT
FROM dbo.DORSSchemeCourseType
GROUP BY CourseTypeId 
HAVING COUNT(*) > 1) T ON T.CourseTypeId = CT.CourseTypeId
WHERE CT.DateCreated = CAST('2016-12-23 00:00:00.000' AS DATETIME)
ORDER BY CT.CourseTypeId
