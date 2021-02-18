/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseListRecentAndFuture', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseListRecentAndFuture;
END		
GO

/*
	Create vwCourseListRecentAndFuture
*/
CREATE VIEW vwCourseListRecentAndFuture
AS
	SELECT
		CO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, CO.Id								AS CourseId
		, CO.Reference						AS CourseReference
		, CO.CourseTypeId					AS CourseTypeId
		, CT.Title							AS CourseType
		, CT.Code							AS CourseTypeCode
		, ISNULL(CO.Reference,'')
			+ (CASE WHEN LEN(CT.Code) > 0
				THEN ' (' + CT.Code + ')'
				ELSE '' END)
			+ ' - ' + CONVERT(VARCHAR(11), MIN(COD.DateStart), 106)
											AS CourseIdentity
		, MIN(COD.DateStart)				AS CourseStartDate
		, MAX(COD.DateEnd)					AS CourseEndDate
	FROM dbo.CourseDate COD
	INNER JOIN dbo.Course CO					ON CO.Id = COD.CourseId
	INNER JOIN dbo.OrganisationCourse OCO		ON OCO.CourseId = COD.CourseId
	INNER JOIN dbo.Organisation O				ON O.Id = OCO.OrganisationId
	INNER JOIN dbo.CourseType CT				ON CT.Id = CO.CourseTypeId
	WHERE COD.DateStart > DATEADD(DAY, 14, GETDATE())
	GROUP BY
		CO.OrganisationId
		, O.[Name]
		, CO.Id
		, CO.Reference
		, CO.CourseTypeId
		, CT.Title
		, CT.Code
	;
GO

/*********************************************************************************************************************/