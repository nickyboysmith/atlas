


INSERT INTO [dbo].[CourseNote] (CourseId, CourseNoteTypeId, Note, DateCreated, CreatedByUserId, Removed, OrganisationOnly)
SELECT DISTINCT
	C.Id AS CourseId
	, (SELECT TOP 1 Id FROM CourseNoteType WHERE [Title] = 'Instructor') AS CourseNoteTypeId
	, 'This is a Test Note From the Trainer (AKA Instructor)' AS Note
	, GETDATE() AS DateCreated
	, T.UserId AS CreatedByUserId
	, 'False' AS Removed
	, 'False' AS OrganisationOnly
FROM Course C
INNER JOIN CourseTrainer CT ON CT.CourseId = C.Id
INNER JOIN Trainer T ON T.Id = CT.TrainerId
LEFT JOIN [dbo].[CourseNote] CN ON CN.CourseId = C.Id AND CN.CreatedByUserId = T.UserId
WHERE CN.Id IS NULL
AND T.UserId IS NOT NULL

INSERT INTO [dbo].[CourseNote] (CourseId, CourseNoteTypeId, Note, DateCreated, CreatedByUserId, Removed, OrganisationOnly)
SELECT 
	C.Id AS CourseId
	, (SELECT TOP 1 Id FROM CourseNoteType WHERE [Title] = 'General') AS CourseNoteTypeId
	, 'Just a Generated Note from the Organisation' AS Note
	, GETDATE() AS DateCreated
	, T.UserId AS CreatedByUserId
	, 'False' AS Removed
	, 'True' AS OrganisationOnly
FROM (SELECT OU.OrganisationId, MAX(OU.UserId) AS UserId
			FROM OrganisationUser OU
			GROUP BY OU.OrganisationId) T
INNER JOIN Course C  ON T.OrganisationId = C.OrganisationId
LEFT JOIN [dbo].[CourseNote] CN ON CN.CourseId = C.Id AND CN.CreatedByUserId = T.UserId
WHERE CN.Id IS NULL
UNION
SELECT 
	C.Id AS CourseId
	, (SELECT TOP 1 Id FROM CourseNoteType WHERE [Title] = 'General') AS CourseNoteTypeId
	, 'Just a Another Test Generated Note from the Organisation' AS Note
	, GETDATE() AS DateCreated
	, T.UserId AS CreatedByUserId
	, 'False' AS Removed
	, 'False' AS OrganisationOnly
FROM (SELECT OU.OrganisationId, MIN(OU.UserId) AS UserId
			FROM OrganisationUser OU
			GROUP BY OU.OrganisationId) T
INNER JOIN Course C  ON T.OrganisationId = C.OrganisationId
LEFT JOIN [dbo].[CourseNote] CN ON CN.CourseId = C.Id AND CN.CreatedByUserId = T.UserId
WHERE CN.Id IS NULL

