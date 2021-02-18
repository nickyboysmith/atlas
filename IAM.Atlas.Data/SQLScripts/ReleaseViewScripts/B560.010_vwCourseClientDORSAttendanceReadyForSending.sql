
--Create Sub View vwCourseClientDORSAttendanceReadyForSending
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseClientDORSAttendanceReadyForSending', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseClientDORSAttendanceReadyForSending;
END		
GO

/*
	Create vwCourseClientDORSAttendanceReadyForSending
*/
CREATE VIEW vwCourseClientDORSAttendanceReadyForSending
AS
	
	SELECT 
		C.OrganisationId						AS OrganisationId
		, O.[Name]								AS OrganisationName
		, C.Id									AS CourseId
		, C.Reference							AS CourseReference
		, CD.StartDate							AS CourseStartDate
		, CD.EndDate							AS CourseEndDate
		, CC.ClientId							AS CourseClientId
		, CD.NumberOfCourseDates				AS NumberOfCourseDates
		, CDCA.NumberOfDatesAttenedByClient		AS NumberOfDatesAttenedByClient
		, CAST(
			(CASE WHEN CD.NumberOfCourseDates = ISNULL(CDCA.NumberOfDatesAttenedByClient, -1)
				THEN 'True' ELSE 'False' END)
			AS BIT)								AS CourseClientAttenedAllCourseDates
		, CDC.DORSAttendanceStateIdentifier		AS CourseClientDORSAttendanceStateIdentifier
		, CDD.DORSAttendanceRef					AS DORSClientAttendanceIdentifier
		, CCA.Attended							AS Attended
		, CASE WHEN CCA.Attended = 'False' 
			THEN 
				(SELECT DORSAttendanceStateIdentifier 
				FROM DORSAttendanceState 
				WHERE [Name] = 'Did Not Attend') 
			ELSE 
				(SELECT DORSAttendanceStateIdentifier 
				FROM DORSAttendanceState 
				WHERE [Name] = 'Attended and Completed') 
											END AS NewDORSAttendanceStateIdentifier
			--TODO: The above needs to be refactored
	FROM [dbo].[Course] C
	INNER JOIN Organisation O							ON O.Id = C.OrganisationId
	INNER JOIN dbo.[vwCourseDates_SubView] CD			ON CD.Courseid = C.Id
	INNER JOIN dbo.[CourseClient] CC					ON CC.CourseId = C.Id
	INNER JOIN dbo.DORSSchemeCourseType DSCT			ON C.CourseTypeId = DSCT.CourseTypeId
	INNER JOIN dbo.[ClientDORSData] CDD					ON CC.ClientId = CDD.ClientId
															AND DSCT.DORSSchemeId = CDD.DORSSchemeId
	INNER JOIN dbo.vwCourseClientAttended CCA			ON CC.CourseId = CCA.CourseId
															AND CC.ClientId = CCA.ClientId
	LEFT JOIN dbo.[CourseClientRemoved] CCR				ON CCR.CourseId = CC.CourseId
														AND CCR.ClientId = CC.ClientId
														AND CCR.CourseClientId = CC.Id
	LEFT JOIN dbo.[CourseDORSClient] CDC				ON CDC.CourseId = C.Id
															AND CDC.ClientId = CC.ClientId
	LEFT JOIN dbo.[vwCourseDatesClientAttendance] CDCA	ON CDCA.CourseId = CC.CourseId
															AND CDCA.ClientId = CC.ClientId

	WHERE C.SendAttendanceDORS = 'True'
	AND C.AttendanceCheckVerified = 'True'
	AND C.AttendanceSentToDORS = 'False'
	AND CCR.Id IS NULL
	AND CDD.DORSAttendanceRef IS NOT NULL
	AND ISNULL(CDC.[IsMysteryShopper], 'False') = 'False'
	AND CD.StartDate > CAST('28-Jun-2017' AS DATE)
	;

GO

/*********************************************************************************************************************/
		