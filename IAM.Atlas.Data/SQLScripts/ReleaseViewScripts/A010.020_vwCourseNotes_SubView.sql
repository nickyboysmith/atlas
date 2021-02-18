/*********************************************************************************************************************/

--Course Notes
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseNotes_SubView', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseNotes_SubView;
END		
GO
/*
	Create vwCourseNotes_SubView
*/
CREATE VIEW vwCourseNotes_SubView 
AS
	SELECT 
		O.Id			AS OrganisationId
		, O.[Name]		AS OrganisationName
		, C1.CourseId	AS CourseId
		, ISNULL(STUFF( 
					(SELECT ','
						+ 'NOTE ADDED: ' + CONVERT(NVARCHAR(MAX), CN.DateCreated, 0) 
						+ ' BY: ' + (CASE WHEN SAU.Id IS NOT NULL 
										THEN 'Atlas Systems Administration' 
										WHEN T.Id IS NOT NULL THEN T.DisplayName + ' (Trainer)'
										ELSE U.[Name] END)
						+ CHAR(13) + CHAR(10)
						+ CN.Note
						+ CHAR(13) + CHAR(10)
						+ '------------------------------------'
						+ CHAR(13) + CHAR(10)
					FROM [dbo].[CourseNote] CN
					INNER JOIN [dbo].[User] U ON U.Id = CN.CreatedByUserId
					LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = CN.CreatedByUserId
					LEFT JOIN [dbo].[Trainer] T ON T.UserId = CN.CreatedByUserId
					WHERE C1.CourseId = CN.CourseId
					AND CN.Removed = 'False'
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)')
				, 1, 1, ''), '') AS Notes
		, ISNULL(STUFF( 
					(SELECT ','
						+ 'NOTE ADDED: ' + CONVERT(NVARCHAR(MAX), CN.DateCreated, 0) 
						+ ' BY: ' + (CASE WHEN SAU.Id IS NOT NULL THEN 'Atlas Systems Administration'
										WHEN OU.Id IS NOT NULL THEN ISNULL(O.[Name], 'Organisation') + ' Administration' 
										WHEN T.Id IS NOT NULL THEN T.DisplayName + ' (Trainer)'
										ELSE U.[Name] END)
						+ CHAR(13) + CHAR(10)
						+ CN.Note
						+ CHAR(13) + CHAR(10)
						+ '------------------------------------'
						+ CHAR(13) + CHAR(10)
					FROM [dbo].[CourseNote] CN
					INNER JOIN [dbo].[User] U ON U.Id = CN.CreatedByUserId
					LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = CN.CreatedByUserId
					LEFT JOIN [dbo].[Trainer] T ON T.UserId = CN.CreatedByUserId
					LEFT JOIN [dbo].[OrganisationUser] OU ON OU.UserId = CN.CreatedByUserId
					LEFT JOIN [dbo].[Organisation] O ON O.Id = OU.OrganisationId
					WHERE C1.CourseId = CN.CourseId
					AND CN.OrganisationOnly = 'False'
					AND CN.Removed = 'False'
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)')
				, 1, 1, ''), '') AS TrainerNotes
	FROM dbo.Organisation O
	INNER JOIN dbo.Course C ON C.OrganisationId = O.Id
	INNER JOIN dbo.CourseNote C1 ON C1.CourseId = C.Id
	GROUP by O.Id, O.[Name], C1.CourseId
	;
GO