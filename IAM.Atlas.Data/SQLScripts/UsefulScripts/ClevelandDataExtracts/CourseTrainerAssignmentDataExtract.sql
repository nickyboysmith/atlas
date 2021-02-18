



SELECT DISTINCT
	CO.Id															AS AtlasCourseId
	, CO.Reference													AS CourseReference
	, CD.StartDate													AS CourseStartDateAndTime
	, DCD.DORSCourseIdentifier										AS DORSCourseIdentifier
	, CT.TrainerId													AS AtlasTrainerId
	, ISNULL(DTR.DORSTrainerIdentifier, '*UNKNOWN*')				AS DORSTrainerIdentifier
	, TR.FirstName													AS TrainerForename
	, TR.Surname													AS TrainerSurname
	, (CASE WHEN CT.BookedForPractical = 'True' THEN 'Practical'
			WHEN CT.BookedForTheory = 'True' THEN 'Theory'
			ELSE '*UNKNOWN*' END)									AS TrainerRole
FROM dbo.Course CO
INNER JOIN dbo.vwCourseDates_SubView CD			ON CD.Courseid = CO.Id
INNER JOIN dbo.CourseTrainer CT					ON CT.CourseId = CO.Id
INNER JOIN dbo.Trainer TR						ON TR.Id = CT.TrainerId
LEFT JOIN dbo.DORSTrainer DTR					ON DTR.TrainerId = CT.TrainerId
LEFT JOIN dbo.DORSCourse DC						ON DC.CourseId = CO.Id
LEFT JOIN dbo.DORSCourseData DCD				ON DCD.DORSCourseIdentifier = DC.DORSCourseIdentifier
WHERE CO.OrganisationId = 318
AND CD.StartDate > DATEADD(YEAR, -3.5, GETDATE())
ORDER BY CD.StartDate DESC, TR.Surname, TR.FirstName

