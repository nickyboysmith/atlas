
--vwTaskByOrganisationAndUser
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTaskByOrganisationAndUser', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTaskByOrganisationAndUser;
END		
GO
/*
	Create vwTaskByOrganisationAndUser
*/
CREATE VIEW vwTaskByOrganisationAndUser
AS
	SELECT
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, OSC.AllowTaskCreation			AS AllowTaskCreation
		, OU.UserId						AS UserId
		, U.[Name]						AS UserName
		, U.Email						AS UserEmailAddress
		, T.Id							AS TaskId
		, T.Title						AS TaskTitle
		, T.TaskCategoryId				AS TaskCategoryId
		, TC.Title						AS TaskCategory
		, T.PriorityNumber				AS TaskPriorityNumber
		, T.DateCreated					AS TaskDateCreated
		, T.CreatedByUserId				AS TaskCreatedByUserId
		, T_U.[Name]					AS TaskCreatedByUserName
		, T_U.Email						AS TaskCreatedByUserEmailAddress
		, T.DeadlineDate				AS TaskDeadlineDate
		, T.TaskClosed					AS TaskClosed
		, T.ClosedByUserId				AS TaskClosedByUserId
		, T_U2.[Name]					AS TaskClosedByUserName
		, T_U2.Email					AS TaskClosedByUserEmailAddress
		, T.DateClosed					AS TaskDateClosed
		, N.Note						AS TaskNote
		, TRT_CL.ClientId				AS TaskRelatedToClientId
		, TRT_CO.CourseId				AS TaskRelatedToCourseId
		, TRT_TR.TrainerId				AS TaskRelatedToTrainerId
		, (
			CASE WHEN TRT_CL.ClientId IS NOT NULL 
				THEN 'Client: ' + CLI.DisplayName
				WHEN TRT_CO.CourseId IS NOT NULL 
				THEN 'Course: ' + ISNULL(COU.Reference,'') 
								+ '; ' + ISNULL(COUT.Title,'') 
								+ (CASE WHEN COUD.StartDate IS NULL THEN ''
									ELSE '; ' + CAST(COUD.StartDate AS VARCHAR)
									END)
				 WHEN TRT_TR.TrainerId IS NOT NULL 
				THEN 'Trainer: ' + TRA.DisplayName
				ELSE '' END
			)							AS LinkedToDetails
		, CAST((CASE WHEN TCFU.Id IS NULL
				THEN 'False' ELSE 'True'
				END) AS BIT)			AS TaskCompletedByUser
	FROM dbo.Organisation O
	INNER JOIN dbo.OrganisationSystemConfiguration OSC				ON OSC.OrganisationId = O.Id
	INNER JOIN dbo.OrganisationUser OU								ON OU.OrganisationId = O.Id
	INNER JOIN dbo.[User] U											ON U.Id = OU.UserId
	INNER JOIN dbo.TaskForOrganisation TFO							ON TFO.OrganisationId = O.Id
	INNER JOIN dbo.Task T											ON T.Id = TFO.TaskId
																	AND T.TaskClosed = 'False'
	INNER JOIN dbo.TaskCategory TC									ON TC.Id = T.TaskCategoryId
	LEFT JOIN dbo.TaskRemovedFromOrganisation TRFO					ON TRFO.TaskId = TFO.TaskId
																	AND TRFO.OrganisationId = TFO.OrganisationId
	LEFT JOIN dbo.TaskRemovedFromUser TRFU							ON TRFU.TaskId = TFO.TaskId
																	AND TRFU.UserId = OU.UserId
	LEFT JOIN dbo.TaskCompletedForUser TCFU							ON TCFU.TaskId = TFO.TaskId
																	AND TCFU.UserId = OU.UserId
	LEFT JOIN dbo.[User] T_U										ON T_U.Id = T.CreatedByUserId
	LEFT JOIN dbo.[User] T_U2										ON T_U2.Id = T.ClosedByUserId
	LEFT JOIN dbo.TaskNote TN										ON TN.TaskId = T.Id
	LEFT JOIN dbo.Note N											ON N.Id = TN.NoteId
	LEFT JOIN dbo.TaskRelatedToClient TRT_CL						ON TRT_CL.TaskId = T.Id
	LEFT JOIN dbo.TaskRelatedToCourse TRT_CO						ON TRT_CO.TaskId = T.Id
	LEFT JOIN dbo.TaskRelatedToTrainer TRT_TR						ON TRT_TR.TaskId = T.Id
	LEFT JOIN dbo.Client CLI										ON CLI.Id = TRT_CL.ClientId
	LEFT JOIN dbo.Course COU										ON COU.Id = TRT_CO.CourseId
	LEFT JOIN dbo.CourseType COUT									ON COUT.Id = COU.CourseTypeId
	LEFT JOIN dbo.vwCourseDates_SubView COUD						ON COUD.CourseId = TRT_CO.CourseId
	LEFT JOIN dbo.Trainer TRA										ON TRA.Id = TRT_TR.TrainerId

	WHERE OSC.ShowTaskList = 'True'
	AND TRFO.Id IS NULL
	AND TRFU.Id IS NULL
	UNION 
	SELECT
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, OSC.AllowTaskCreation			AS AllowTaskCreation
		, OU.UserId						AS UserId
		, U.[Name]						AS UserName
		, U.Email						AS UserEmailAddress
		, T.Id							AS TaskId
		, T.Title						AS TaskTitle
		, T.TaskCategoryId				AS TaskCategoryId
		, TC.Title						AS TaskCategory
		, T.PriorityNumber				AS TaskPriorityNumber
		, T.DateCreated					AS TaskDateCreated
		, T.CreatedByUserId				AS TaskCreatedByUserId
		, T_U.[Name]					AS TaskCreatedByUserName
		, T_U.Email						AS TaskCreatedByUserEmailAddress
		, T.DeadlineDate				AS TaskDeadlineDate
		, T.TaskClosed					AS TaskClosed
		, T.ClosedByUserId				AS TaskClosedByUserId
		, T_U2.[Name]					AS TaskClosedByUserName
		, T_U2.Email					AS TaskClosedByUserEmailAddress
		, T.DateClosed					AS TaskDateClosed
		, N.Note						AS TaskNote
		, TRT_CL.ClientId				AS TaskRelatedToClientId
		, TRT_CO.CourseId				AS TaskRelatedToCourseId
		, TRT_TR.TrainerId				AS TaskRelatedToTrainerId
		, (
			CASE WHEN TRT_CL.ClientId IS NOT NULL 
				THEN 'Client: ' + CLI.DisplayName
				WHEN TRT_CO.CourseId IS NOT NULL 
				THEN 'Course: ' + ISNULL(COU.Reference,'') 
								+ '; ' + ISNULL(COUT.Title,'') 
								+ (CASE WHEN COUD.StartDate IS NULL THEN ''
									ELSE '; ' + CAST(COUD.StartDate AS VARCHAR)
									END)
				 WHEN TRT_TR.TrainerId IS NOT NULL 
				THEN 'Trainer: ' + TRA.DisplayName
				ELSE '' END
			)							AS LinkedToDetails
		, CAST((CASE WHEN TCFU.Id IS NULL
				THEN 'False' ELSE 'True'
				END) AS BIT)			AS TaskCompletedByUser
	FROM dbo.Organisation O
	INNER JOIN dbo.OrganisationSystemConfiguration OSC				ON OSC.OrganisationId = O.Id
	INNER JOIN dbo.OrganisationUser OU								ON OU.OrganisationId = O.Id
	INNER JOIN dbo.[User] U											ON U.Id = OU.UserId
	INNER JOIN dbo.TaskForUser TFU									ON TFU.UserId = OU.UserId
	INNER JOIN dbo.Task T											ON T.Id = TFU.TaskId
																	AND T.TaskClosed = 'False'
	INNER JOIN dbo.TaskCategory TC									ON TC.Id = T.TaskCategoryId
	LEFT JOIN dbo.TaskRemovedFromUser TRFU							ON TRFU.TaskId = TFU.TaskId
																	AND TRFU.UserId = OU.UserId
	LEFT JOIN dbo.TaskCompletedForUser TCFU							ON TCFU.TaskId = TFU.TaskId
																	AND TCFU.UserId = OU.UserId
	LEFT JOIN dbo.[User] T_U										ON T_U.Id = T.CreatedByUserId
	LEFT JOIN dbo.[User] T_U2										ON T_U2.Id = T.ClosedByUserId
	LEFT JOIN dbo.TaskNote TN										ON TN.TaskId = T.Id
	LEFT JOIN dbo.Note N											ON N.Id = TN.NoteId
	LEFT JOIN dbo.TaskRelatedToClient TRT_CL						ON TRT_CL.TaskId = T.Id
	LEFT JOIN dbo.TaskRelatedToCourse TRT_CO						ON TRT_CO.TaskId = T.Id
	LEFT JOIN dbo.TaskRelatedToTrainer TRT_TR						ON TRT_TR.TaskId = T.Id
	LEFT JOIN dbo.Client CLI										ON CLI.Id = TRT_CL.ClientId
	LEFT JOIN dbo.Course COU										ON COU.Id = TRT_CO.CourseId
	LEFT JOIN dbo.CourseType COUT									ON COUT.Id = COU.CourseTypeId
	LEFT JOIN dbo.vwCourseDates_SubView COUD						ON COUD.CourseId = TRT_CO.CourseId
	LEFT JOIN dbo.Trainer TRA										ON TRA.Id = TRT_TR.TrainerId

	WHERE OSC.ShowTaskList = 'True'
	AND TRFU.Id IS NULL

	;
	
GO


/*********************************************************************************************************************/
