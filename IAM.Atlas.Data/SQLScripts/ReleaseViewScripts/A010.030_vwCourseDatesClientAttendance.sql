
--Create Sub View vwCourseDatesClientAttendance
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseDatesClientAttendance', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseDatesClientAttendance;
END		
GO

/*
	Create vwCourseDatesClientAttendance
*/
CREATE VIEW vwCourseDatesClientAttendance
AS
	SELECT 
		CD.CourseId				AS Courseid
		, CDCA.ClientId			AS ClientId
		, MIN(CD.[DateStart])	AS StartDate
		, MAX(CD.[DateEnd])		AS EndDate
		, COUNT(CDCA.Id)		AS NumberOfDatesAttenedByClient
	FROM [dbo].[CourseDate] CD
	LEFT JOIN [dbo].[CourseDateClientAttendance] CDCA ON CDCA.CourseDateId = CD.Id
														AND CDCA.CourseId = CD.CourseId
	GROUP BY CD.CourseId, CDCA.ClientId; 
GO

/*********************************************************************************************************************/
		