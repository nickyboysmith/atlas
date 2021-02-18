
--vwTaskSummaryByUser
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTaskSummaryByUser', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTaskSummaryByUser;
END		
GO
/*
	Create vwTaskSummaryByUser
*/
CREATE VIEW vwTaskSummaryByUser
AS
	SELECT 
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, OSC.ShowTaskList				AS ShowTaskList
		, OSC.AllowTaskCreation			AS AllowTaskCreation
		, OU.UserId						AS UserId
		, U.[Name]						AS UserName
		, U.Email						AS UserEmailAddress
		, TP.Number						AS TaskPriorityNumber
		, SUM(CASE WHEN TBOAU.TaskId IS NOT NULL
					AND TBOAU.TaskClosed = 'False'
					AND TBOAU.TaskCompletedByUser = 'False'
					THEN 1 ELSE 0 END)	AS TotalNumberOfOpenTasks
		, SUM(CASE WHEN TBOAU.TaskId IS NOT NULL
					AND TBOAU.TaskClosed = 'True'
					AND TBOAU.TaskCompletedByUser = 'True'
					THEN 1 ELSE 0 END)	AS TotalNumberOfClosedTasks
	FROM dbo.Organisation O
	INNER JOIN dbo.OrganisationSystemConfiguration OSC				ON OSC.OrganisationId = O.Id
	INNER JOIN dbo.OrganisationUser OU								ON OU.OrganisationId = O.Id
	INNER JOIN dbo.[User] U											ON U.Id = OU.UserId
	CROSS JOIN dbo.vwTaskPriority TP
	LEFT JOIN vwTaskByOrganisationAndUser TBOAU						ON TBOAU.OrganisationId = O.Id
																	AND TBOAU.UserId = OU.UserId
																	AND TBOAU.TaskPriorityNumber = TP.Number
	GROUP BY
		O.Id
		, O.[Name]
		, OSC.ShowTaskList
		, OSC.AllowTaskCreation
		, OU.UserId
		, U.[Name]
		, U.Email
		, TP.Number		
	;
	
GO


/*********************************************************************************************************************/
