



SELECT DISTINCT
	TRO.TrainerId													AS AtlasTrainerId
	, ISNULL(DTR.DORSTrainerIdentifier, '*UNKNOWN*')				AS DORSTrainerIdentifier
	, TR.FirstName													AS TrainerForename
	, TR.Surname													AS TrainerSurname
	, ISNULL(E.[Address], '*UNKNOWN*')								AS TrainerEmailAddress
FROM dbo.TrainerOrganisation TRO
INNER JOIN dbo.Trainer TR ON TR.Id = TRO.TrainerId
LEFT JOIN dbo.TrainerEmail TRE ON TRE.TrainerId = TRO.TrainerId
LEFT JOIN dbo.Email E ON E.Id = TRE.EmailId
LEFT JOIN dbo.DORSTrainer DTR ON DTR.TrainerId = TRO.TrainerId
WHERE TRO.OrganisationId = 318
AND TR.Id IN (SELECT DISTINCT TrainerId 
			FROM dbo.CourseTrainer CT
			INNER JOIN dbo.CourseDate CD ON CD.CourseId = CT.CourseId
			WHERE CD.DateStart > DATEADD(YEAR, -3.5, GETDATE()) )
ORDER BY TR.Surname, TR.FirstName

