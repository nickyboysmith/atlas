/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwReportsCourseType', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportsCourseType;
END		
GO

/*
	Create vwReportsCourseType
*/
CREATE VIEW vwReportsCourseType
AS
	SELECT DISTINCT
		OCO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, CT.Id
		, CT.Title
			+ (CASE WHEN O.[Name] = CTO.[Name]
					THEN ''
					ELSE ' (' + CTO.[Name] + ')'
					END)					AS Title
		, CT.Code
		, CT.Description
		, ISNULL(CT.[Disabled],'False')		AS [Disabled]
		, ISNULL(CT.DORSOnly,'False')		AS DORSOnly
		, CT.MaxTheoryTrainers
		, CT.MaxPracticalTrainers
	FROM dbo.OrganisationCourse OCO
	INNER JOIN dbo.Organisation O			ON O.Id = OCO.OrganisationId
	INNER JOIN dbo.Course CO				ON CO.Id = OCO.CourseId
	INNER JOIN [dbo].[CourseType] CT		ON CT.Id = CO.CourseTypeId
	INNER JOIN dbo.Organisation CTO			ON CTO.Id = CT.OrganisationId
	;

GO

/*********************************************************************************************************************/
