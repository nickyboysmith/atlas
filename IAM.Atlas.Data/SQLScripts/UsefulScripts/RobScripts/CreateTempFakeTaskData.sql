
IF OBJECT_ID('tempdb..#TempTask', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TempTask;
END

SELECT DISTINCT
	OrganisationId
	, TaskCategoryId
	, Title
	, PriorityNumber
	, DateCreated
	, CreatedByUserId
	, ClientId
	, CourseId
	, TrainerId
	, Note
INTO #TempTask
FROM (
	SELECT
		CL.OrganisationId											AS OrganisationId
		, TC.Id														AS TaskCategoryId
		, 'New Special Client: '
			+ CL.DisplayName
			+ ' (Id: ' + CAST(CL.Id AS VARCHAR) + ')'				AS Title
		, 2															AS PriorityNumber
		, DATEADD(DAY, -2, GETDATE())								AS DateCreated
		, dbo.udfGetSystemUserId()									AS CreatedByUserId
		--, DeadlineDate
		--, TaskClosed
		--, ClosedByUserId
		--, DateClosed
		, CL.Id														AS ClientId
		, NULL														AS CourseId
		, NULL														AS TrainerId
		, 'This Task Note is all about the Special Client: '
			+ CL.DisplayName
			+ ' (Id: ' + CAST(CL.Id AS VARCHAR) + ')'				AS Note
	FROM dbo.TaskCategory TC
	, (SELECT TOP 10 C.Id, C.DisplayName, CO.Id AS OrganisationId
		FROM dbo.Client C
		INNER JOIN dbo.ClientOrganisation CO ON CO.ClientId = C.Id
		WHERE C.UserId IS NOT NULL
		AND LEN(ISNULL(C.DisplayName,'')) > 0
		AND LEN(ISNULL(C.Surname,'')) > 0
		AND C.Surname LIKE '[A-F]%'
		ORDER BY Id DESC) CL
	WHERE TC.Title = 'Client Notification'
	UNION
	SELECT
		CL.OrganisationId											AS OrganisationId
		, TC.Id														AS TaskCategoryId
		, 'New Special Client: '
			+ CL.DisplayName
			+ ' (Id: ' + CAST(CL.Id AS VARCHAR) + ')'				AS Title
		, 3															AS PriorityNumber
		, DATEADD(DAY, -3, GETDATE())								AS DateCreated
		, dbo.udfGetSystemUserId()									AS CreatedByUserId
		--, DeadlineDate
		--, TaskClosed
		--, ClosedByUserId
		--, DateClosed
		, CL.Id														AS ClientId
		, NULL														AS CourseId
		, NULL														AS TrainerId
		, 'This Task Note is all about the Special Client: '
			+ CL.DisplayName
			+ ' (Id: ' + CAST(CL.Id AS VARCHAR) + ')'				AS Note
	FROM dbo.TaskCategory TC
	, (SELECT TOP 10 C.Id, C.DisplayName, CO.Id AS OrganisationId
		FROM dbo.Client C
		INNER JOIN dbo.ClientOrganisation CO ON CO.ClientId = C.Id
		WHERE C.UserId IS NOT NULL
		AND LEN(ISNULL(C.DisplayName,'')) > 0
		AND LEN(ISNULL(C.Surname,'')) > 0
		AND C.Surname LIKE '[G-N]%'
		ORDER BY Id DESC) CL
	WHERE TC.Title = 'Client Notification'
	UNION
	SELECT
		CL.OrganisationId											AS OrganisationId
		, TC.Id														AS TaskCategoryId
		, 'New Special Client: '
			+ CL.DisplayName
			+ ' (Id: ' + CAST(CL.Id AS VARCHAR) + ')'				AS Title
		, 4															AS PriorityNumber
		, DATEADD(DAY, -4, GETDATE())								AS DateCreated
		, dbo.udfGetSystemUserId()									AS CreatedByUserId
		--, DeadlineDate
		--, TaskClosed
		--, ClosedByUserId
		--, DateClosed
		, CL.Id														AS ClientId
		, NULL														AS CourseId
		, NULL														AS TrainerId
		, 'This Task Note is all about the Special Client: '
			+ CL.DisplayName
			+ ' (Id: ' + CAST(CL.Id AS VARCHAR) + ')'				AS Note
	FROM dbo.TaskCategory TC
	, (SELECT TOP 10 C.Id, C.DisplayName, CO.Id AS OrganisationId
		FROM dbo.Client C
		INNER JOIN dbo.ClientOrganisation CO ON CO.ClientId = C.Id
		WHERE C.UserId IS NOT NULL
		AND LEN(ISNULL(C.DisplayName,'')) > 0
		AND LEN(ISNULL(C.Surname,'')) > 0
		AND C.Surname LIKE '[O-Z]%'
		ORDER BY Id DESC) CL
	WHERE TC.Title = 'Client Notification'
	-----------------------------------------------------------
	UNION
	SELECT
		CO.OrganisationId											AS OrganisationId
		, TC.Id														AS TaskCategoryId
		, 'Course Warning, New Client: '
			+ CO.Reference
			+ '; ' + CO.CourseType
			+ ' (Id: ' + CAST(CO.Id AS VARCHAR) + ')'				AS Title
		, 2															AS PriorityNumber
		, DATEADD(DAY, -2, GETDATE())								AS DateCreated
		, dbo.udfGetSystemUserId()									AS CreatedByUserId
		--, DeadlineDate
		--, TaskClosed
		--, ClosedByUserId
		--, DateClosed
		, NULL														AS ClientId
		, CO.Id														AS CourseId
		, NULL														AS TrainerId
		, 'This Task Note is all about Not One Client On the Course: '
			+ CO.Reference
			+ '; ' + CO.CourseType
			+ ' (Id: ' + CAST(CO.Id AS VARCHAR) + ')'				AS Note
	FROM dbo.TaskCategory TC
	, (SELECT DISTINCT TOP 10 C.Id, C.Reference, C.OrganisationId, CT.Title AS CourseType
		FROM dbo.Course C
		INNER JOIN dbo.CourseType CT ON CT.Id = C.CourseTypeId
		WHERE C.OrganisationId IS NOT NULL
		AND LEN(ISNULL(C.Reference,'')) > 0
		AND C.Reference LIKE '[A-F]%'
		AND C.CreatedByUserId IS NOT NULL
		AND EXISTS (SELECT CC.Id, COUNT(*)
					FROM CourseClient CC
					--WHERE CC.CourseId = C.Id
					GROUP BY CC.Id
					HAVING COUNT(*) > 0)
		ORDER BY Id DESC) CO
	WHERE TC.Title = 'Course Notification'
	UNION
	SELECT
		CO.OrganisationId											AS OrganisationId
		, TC.Id														AS TaskCategoryId
		, 'Course Warning, New Client: '
			+ CO.Reference
			+ '; ' + CO.CourseType
			+ ' (Id: ' + CAST(CO.Id AS VARCHAR) + ')'				AS Title
		, 2															AS PriorityNumber
		, DATEADD(DAY, -2, GETDATE())								AS DateCreated
		, dbo.udfGetSystemUserId()									AS CreatedByUserId
		--, DeadlineDate
		--, TaskClosed
		--, ClosedByUserId
		--, DateClosed
		, NULL														AS ClientId
		, CO.Id														AS CourseId
		, NULL														AS TrainerId
		, 'This Task Note is all about Not One Client On the Course: '
			+ CO.Reference
			+ '; ' + CO.CourseType
			+ ' (Id: ' + CAST(CO.Id AS VARCHAR) + ')'				AS Note
	FROM dbo.TaskCategory TC
	, (SELECT DISTINCT TOP 10 C.Id, C.Reference, C.OrganisationId, CT.Title AS CourseType
		FROM dbo.Course C
		INNER JOIN dbo.CourseType CT ON CT.Id = C.CourseTypeId
		WHERE C.OrganisationId IS NOT NULL
		AND LEN(ISNULL(C.Reference,'')) > 0
		AND C.Reference LIKE '[G-N]%'
		AND C.CreatedByUserId IS NOT NULL
		AND EXISTS (SELECT CC.Id, COUNT(*)
					FROM CourseClient CC
					--WHERE CC.CourseId = C.Id
					GROUP BY CC.Id
					HAVING COUNT(*) > 0)
		ORDER BY Id DESC) CO
	WHERE TC.Title = 'Course Notification'
	UNION
	SELECT
		CO.OrganisationId											AS OrganisationId
		, TC.Id														AS TaskCategoryId
		, 'Course Warning, No Clients On Course: '
			+ CO.Reference
			+ '; ' + CO.CourseType
			+ ' (Id: ' + CAST(CO.Id AS VARCHAR) + ')'				AS Title
		, 3															AS PriorityNumber
		, DATEADD(DAY, -3, GETDATE())								AS DateCreated
		, dbo.udfGetSystemUserId()									AS CreatedByUserId
		--, DeadlineDate
		--, TaskClosed
		--, ClosedByUserId
		--, DateClosed
		, NULL														AS ClientId
		, CO.Id														AS CourseId
		, NULL														AS TrainerId
		, 'This Task Note is all about Not One Client On the Course: '
			+ CO.Reference
			+ '; ' + CO.CourseType
			+ ' (Id: ' + CAST(CO.Id AS VARCHAR) + ')'				AS Note
	FROM dbo.TaskCategory TC
	, (SELECT DISTINCT TOP 10 C.Id, C.Reference, C.OrganisationId, CT.Title AS CourseType
		FROM dbo.Course C
		INNER JOIN dbo.CourseType CT ON CT.Id = C.CourseTypeId
		WHERE C.OrganisationId IS NOT NULL
		AND LEN(ISNULL(C.Reference,'')) > 0
		AND C.Reference LIKE '[O-Z]%'
		AND C.CreatedByUserId IS NOT NULL
		AND NOT EXISTS (SELECT CC.Id, COUNT(*)
					FROM CourseClient CC
					--WHERE CC.CourseId = C.Id
					GROUP BY CC.Id
					HAVING COUNT(*) > 0)
		ORDER BY Id DESC) CO
	WHERE TC.Title = 'Course Notification'
	-----------------------------------------------------------------------
	UNION
	SELECT
		TR.OrganisationId											AS OrganisationId
		, TC.Id														AS TaskCategoryId
		, 'Trainer Is Naughty: '
			+ TR.DisplayName
			+ ' (Id: ' + CAST(TR.Id AS VARCHAR) + ')'				AS Title
		, 4															AS PriorityNumber
		, DATEADD(DAY, -4, GETDATE())								AS DateCreated
		, dbo.udfGetSystemUserId()									AS CreatedByUserId
		--, DeadlineDate
		--, TaskClosed
		--, ClosedByUserId
		--, DateClosed
		, NULL														AS ClientId
		, NULL														AS CourseId
		, TR.Id														AS TrainerId
		, 'This Task Note is all about a Naughty Trainer: '
								+ TR.DisplayName
								+ ' (Id: ' + CAST(TR.Id AS VARCHAR) + ')'					AS Note
	FROM dbo.TaskCategory TC
	, (SELECT TOP 40 T.Id, T.DisplayName, TRO.OrganisationId AS OrganisationId
		FROM dbo.Trainer T
		INNER JOIN dbo.TrainerOrganisation TRO ON TRO.TrainerId = T.Id
		WHERE LEN(ISNULL(T.DisplayName,'')) > 0
		AND LEN(ISNULL(T.Surname,'')) > 0
		--AND T.Surname LIKE '[O-Z]%'
		ORDER BY Id DESC) TR
	WHERE TC.Title = 'Trainer Notification'
	) UT

INSERT INTO dbo.Task (
	TaskCategoryId
	, Title
	, PriorityNumber
	, DateCreated
	, CreatedByUserId
	)
SELECT 
	TaskCategoryId
	, Title
	, PriorityNumber
	, DateCreated
	, CreatedByUserId
FROM #TempTask TT
WHERE NOT EXISTS (SELECT * FROM dbo.Task T2 WHERE T2.Title = TT.Title);

INSERT INTO dbo.TaskRelatedToClient (TaskId, ClientId)
SELECT DISTINCT T.Id AS TaskId, TT.ClientId
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
LEFT JOIN dbo.TaskRelatedToClient TTC ON TTC.TaskId = T.Id
									AND TTC.ClientId = TT.ClientId
WHERE TT.ClientId IS NOT NULL
AND TTC.Id IS NULL
;

INSERT INTO dbo.TaskRelatedToCourse (TaskId, CourseId)
SELECT DISTINCT T.Id AS TaskId, TT.CourseId
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
LEFT JOIN dbo.TaskRelatedToCourse TTC ON TTC.TaskId = T.Id
									AND TTC.CourseId = TT.CourseId
WHERE TT.CourseId IS NOT NULL
AND TTC.Id IS NULL
;

INSERT INTO dbo.TaskRelatedToTrainer (TaskId, TrainerId)
SELECT DISTINCT T.Id AS TaskId, TT.TrainerId
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
LEFT JOIN dbo.TaskRelatedToTrainer TTT ON TTT.TaskId = T.Id
									AND TTT.TrainerId = TT.TrainerId
WHERE TT.TrainerId IS NOT NULL
AND TTT.Id IS NULL
;

INSERT INTO dbo.Note (
	Note
	, DateCreated
	, CreatedByUserId
	, NoteTypeId
	)
SELECT DISTINCT
	TT.Note														AS Note
	, TT.DateCreated											AS DateCreated
	, TT.CreatedByUserId										AS CreatedByUserId
	, (SELECT Id FROM dbo.NoteType WHERE [Name] = 'General')	AS NoteTypeId
FROM #TempTask TT

INSERT INTO dbo.TaskNote (TaskId, NoteId)
SELECT DISTINCT T.Id AS TaskId, N.Id AS NoteId
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
INNER JOIN dbo.Note N ON N.Note = TT.Note
LEFT JOIN dbo.TaskNote TN ON TN.TaskId = T.Id
						AND TN.NoteId = N.Id
WHERE TN.Id IS NULL;

INSERT INTO dbo.TaskForOrganisation (OrganisationId, TaskId)
SELECT DISTINCT TT.OrganisationId, T.Id AS TaskId
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
INNER JOIN dbo.Organisation O ON O.Id = TT.OrganisationId
LEFT JOIN dbo.TaskForOrganisation TFO ON TFO.TaskId = T.Id
									AND TFO.OrganisationId = TT.OrganisationId
WHERE TFO.Id IS NULL;

IF OBJECT_ID('tempdb..#TempTask2', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TempTask2;
END

SELECT
	O.Id														AS OrganisationId
	, TC.Id														AS TaskCategoryId
	, 'Please put the Milk Out Tonight: ' + U.[Name]
		+ ' (' + CAST(U.Id AS VARCHAR) + ')'					AS Title
	, 1															AS PriorityNumber
	, GETDATE()													AS DateCreated
	, dbo.udfGetSystemUserId()									AS CreatedByUserId
	, DATEADD(DAY, 7, GETDATE())								AS DeadlineDate
	, OU.UserId													AS ForUser
INTO #TempTask2
FROM Organisation O
INNER JOIN OrganisationUser OU On OU.OrganisationId = O.Id
INNER JOIN dbo.[User] U ON U.Id = OU.UserId
, dbo.TaskCategory TC
WHERE TC.Title = 'General'
	
INSERT INTO dbo.Task (
	TaskCategoryId
	, Title
	, PriorityNumber
	, DateCreated
	, CreatedByUserId
	, DeadlineDate
	)
SELECT 
	TT2.TaskCategoryId
	, TT2.Title
	, TT2.PriorityNumber
	, TT2.DateCreated
	, TT2.CreatedByUserId
	, TT2.DeadlineDate 
FROM #TempTask2 TT2
LEFT JOIN dbo.Task T ON T.Title = TT2.Title
WHERE T.Id IS NULL;

INSERT INTO [dbo].[TaskForUser] (
	UserId
	, TaskId
	, DateAdded
	, AssignedByUserId
	)
SELECT DISTINCT
	TT2.ForUser				AS UserId
	, T.Id					AS TaskId
	, TT2.DateCreated		AS DateAdded
	, TT2.CreatedByUserId	AS AssignedByUserId
FROM #TempTask2 TT2
INNER JOIN dbo.Task T ON T.Title = TT2.Title
LEFT JOIN [dbo].[TaskForUser] TFU On TFU.UserId = TT2.ForUser
								AND TFU.TaskId = T.Id
WHERE TFU.Id IS NULL;

SELECT * FROM #TempTask2
/**
--UNDO ABOVE
DELETE TN
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
INNER JOIN dbo.Note N ON N.Note = TT.Note
INNER JOIN dbo.TaskNote TN ON TN.TaskId = T.Id
						AND TN.NoteId = N.Id

DELETE N
FROM #TempTask TT
INNER JOIN Note N ON N.Note = TT.Note

DELETE TTT
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
INNER JOIN dbo.TaskRelatedToTrainer TTT ON TTT.TaskId = T.Id
									AND TTT.TrainerId = TT.TrainerId
WHERE TT.TrainerId IS NOT NULL;

DELETE TTC
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
INNER JOIN dbo.TaskRelatedToCourse TTC ON TTC.TaskId = T.Id
									AND TTC.CourseId = TT.CourseId
WHERE TT.CourseId IS NOT NULL
;

DELETE TTC
FROM #TempTask TT
INNER JOIN dbo.Task T ON T.Title = TT.Title
INNER JOIN dbo.TaskRelatedToClient TTC ON TTC.TaskId = T.Id
									AND TTC.ClientId = TT.ClientId
WHERE TT.ClientId IS NOT NULL
;

DELETE T2
FROM #TempTask TT
INNER JOIN dbo.Task T2 ON T2.Title = TT.Title;

--*/