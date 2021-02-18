
--Create Sub View vwCourseClientDORSAttendanceReadySummary
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseClientDORSAttendanceReadySummary', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseClientDORSAttendanceReadySummary;
END		
GO

/*
	Create vwCourseClientDORSAttendanceReadySummary
*/
CREATE VIEW vwCourseClientDORSAttendanceReadySummary
AS
	SELECT 
		OrganisationId
		, OrganisationName
		, CourseId
		, CourseReference
		, CourseStartDate
		, CourseEndDate
		, COUNT(CourseClientId)			AS NumberOfCourseClients
		, SUM(CASE 
				WHEN CourseClientAttenedAllCourseDates = 'True'
				THEN 1 ELSE 0 END)				AS NumberOfCourseClientAttendedAllCourseDates
	FROM vwCourseClientDORSAttendanceReadyForSending
	GROUP BY 
		OrganisationId
		, OrganisationName
		, CourseId
		, CourseReference
		, CourseStartDate
		, CourseEndDate
	;
GO

/*********************************************************************************************************************/
		