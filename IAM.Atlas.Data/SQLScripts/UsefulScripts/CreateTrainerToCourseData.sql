


/* Add Trainers To Organisations */
INSERT INTO [dbo].[TrainerOrganisation] (TrainerId, OrganisationId)
SELECT DISTINCT	
	T.Id					AS TrainerId
	, O.Id					AS OrganisationId
FROM Organisation O
, Trainer T
WHERE NOT EXISTS (SELECT * 
					FROM [TrainerOrganisation] TORG
					WHERE TORG.TrainerId = T.Id
					AND TORG.OrganisationId = O.Id);

/* Make Course Type on Specific Courses Avaiable to All Trainers*/
INSERT INTO TrainerCourseType (TrainerId, CourseTypeId)
SELECT DISTINCT
	T.Id				AS TrainerId
	, C.CourseTypeId	AS CourseTypeId
FROM Course C
INNER JOIN CourseTrainer CT ON CT.CourseId = C.Id
INNER JOIN Trainer T ON T.Id != CT.TrainerId --Find Trainers Not on the Course Already
INNER JOIN TrainerOrganisation TORG ON TORG.TrainerId = T.Id
									AND TORG.OrganisationId = C.OrganisationId --Trainer Must be in the Same Organisation
LEFT JOIN TrainerCourseType TCT ON TCT.TrainerId = T.Id
								AND TCT.CourseTypeId = C.CourseTypeId
WHERE TCT.Id IS NULL
AND C.Id IN (264081, 264086, 264087, 264088, 264089) --Specific Courses

/* Make Course Type on Specific Courses Avaiable to All Trainers*/
INSERT INTO TrainerCourseTypeCategory (TrainerId, CourseTypeCategoryId, [Disabled])
SELECT DISTINCT
	T.Id						AS TrainerId
	, C.CourseTypeCategoryId	AS CourseTypeCategoryId
	, 'False'					AS [Disabled]
FROM Course C
INNER JOIN CourseTrainer CT ON CT.CourseId = C.Id
INNER JOIN Trainer T ON T.Id != CT.TrainerId
LEFT JOIN TrainerCourseTypeCategory TCTC ON TCTC.TrainerId = T.Id
										AND TCTC.CourseTypeCategoryId = C.CourseTypeCategoryId
WHERE TCTC.Id IS NULL
AND C.Id IN (264081, 264086, 264087, 264088, 264089) --Specific Courses
 

/* Add a Trainer to a Course */
INSERT INTO CourseTrainer (CourseId, TrainerId, DateCreated, CreatedByUserId, AttendanceCheckRequired)
SELECT DISTINCT
	C.Id						AS CourseId
	, MIN(T.[Id])				AS TrainerId --Use the First Trainer Id Found For the Course
	, GETDATE()					AS DateCreated
	, dbo.udfGetSystemUserId()	AS CreatedByUserId
	, 'True'					AS AttendanceCheckRequired
FROM  Course C
INNER JOIN CourseTrainer CT ON CT.CourseId = C.Id
INNER JOIN Trainer T ON T.Id != CT.TrainerId --Find Trainers Not on the Course Already
INNER JOIN TrainerOrganisation TORG ON TORG.TrainerId = T.Id
									AND TORG.OrganisationId = C.OrganisationId --Trainer Must be in the Same Organisation
LEFT JOIN CourseTrainer CT2 ON CT2.CourseId = C.Id
							AND CT2.TrainerId = T.Id
WHERE CT2.Id IS NULL
AND C.Id IN (264081, 264086, 264087, 264088, 264089) --Specific Courses
GROUP BY C.Id;


SELECT TOP (1000) 
		T.[Id] AS TrainerId
      ,T.[Title]
      ,T.[FirstName]
      ,T.[Surname]
      ,T.[OtherNames]
      ,T.[DisplayName]
	  , U.Id AS USerId
	  , U.LoginId
	  , U.Password
	  , U.Name
	  , U.Email
	  , CO.OrganisationId
	  , (CASE WHEN SAU.Id IS NULL THEN '' ELSE 'Is Admin' END)
  FROM [dbo].[Trainer] T
  INNER JOIN [User] U ON U.Id = T.UserId
  INNER JOIN TrainerOrganisation CO ON CO.TrainerId = T.Id
  LEFT JOIN SystemAdminUser SAU ON SAU.UserId = T.UserId
  order by U.DateUpdated desc