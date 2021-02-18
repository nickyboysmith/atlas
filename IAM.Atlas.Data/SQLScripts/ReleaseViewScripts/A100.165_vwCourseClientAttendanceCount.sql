
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseClientAttendanceCount', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseClientAttendanceCount;
END		
GO
/*
	Create vwCourseClientAttendanceCount
*/
CREATE VIEW vwCourseClientAttendanceCount 
AS
	SELECT 
		O.Id										AS OrganisationId
		, O.[Name]									AS OrganisationName
		, CO.Id										AS CourseId
		, CO.Reference								AS CourseReference
		, COC.ClientId								AS ClientId
		, SUM(CASE WHEN COTR.TrainerId IS NOT NULL
					AND CODCA.Id IS NULL
					THEN 1
				WHEN COTR.TrainerId IS NULL
					THEN 0
				ELSE 0 END)							AS NumberOfAbsentMarks
		, SUM(CASE WHEN COTR.TrainerId IS NOT NULL
					AND CODCA.Id IS NOT NULL
					THEN 1
				WHEN COTR.TrainerId IS NULL
					THEN 0
				ELSE 0 END)							AS NumberOfPresentMarks
	FROM dbo.Course CO
	INNER JOIN dbo.Organisation O					ON O.Id = CO.OrganisationId
	INNER JOIN dbo.CourseDate COD					ON COD.CourseId = CO.Id
	LEFT JOIN dbo.CourseTrainer COTR				ON COTR.CourseId = CO.Id
	LEFT JOIN dbo.CourseClient COC					ON COC.CourseId = CO.Id
	LEFT JOIN dbo.CourseClientRemoved COCR			ON COCR.CourseId = CO.Id
													AND COCR.ClientId = COC.ClientId
													AND COCR.CourseClientId = COC.Id
	LEFT JOIN dbo.CourseDateClientAttendance CODCA	ON CODCA.CourseDateId = COD.Id
													AND CODCA.CourseId = CO.Id
													AND CODCA.ClientId = COC.ClientId
													AND CODCA.TrainerId = COTR.TrainerId
	WHERE COCR.Id IS NULL
	GROUP BY 
			O.Id
			, O.[Name]
			, CO.Id
			, CO.Reference
			, COC.ClientId
	;
GO
/*********************************************************************************************************************/
		